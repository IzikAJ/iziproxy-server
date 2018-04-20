# require "../*"
require "kemal"
require "json"
require "./queries/*"
require "./commands/redis_log/*"

module Sockets
  # commands
  JOIN_COMMAND  = "join"
  LEAVE_COMMAND = "leave"

  WELCOME_TYPE = "welcome"

  KIND_FIELD = "kind"
  TYPE_FIELD = "type"

  class Message
    getter kind : Int32 = 0
    getter target : String
    getter message : String

    def initialize(kind : Int32, target : String, message : String)
      @kind = kind
      @target = target
      @message = message
    end
  end

  class Server
    getter channel : Channel(Message)

    private def send_or_remove(keys : Array(String), token : String, message : String)
      if socket = @sockets[token]?
        socket.send message
      else
        keys.delete token
      end
    end

    def send_global(message : String)
      @global_pull.each do |key|
        send_or_remove @global_pull, key, message
      end
    end

    def send_user(message : String, target : Int64)
      if items = @user_pull[target]?
        items.each do |key|
          send_or_remove items, key, message
        end
      end
    end

    def send_session(message : String, target : Int64)
      if items = @session_pull[target]?
        items.each do |key|
          send_or_remove items, key, message
        end
      end
    end

    def send_client(message : String, target : String)
      if items = @client_pull[target]?
        items.each do |key|
          send_or_remove items, key, message
        end
      end
    end

    def self.send_global(message : String)
      instance.send_global(message)
    end

    def self.send_user(message : String, user : User)
      if user_id = user.id
        instance.send_user(message, user_id)
      end
    end

    def self.send_session(message : String, session : Session)
      instance.send_session(message, session.id)
    end

    def self.send_client(message : String, client : Client)
      if client_uuid = client.uuid
        instance.send_client(message, client_uuid)
      end
    end

    private def leave!(socket : String, message : JSON::Any, session : Session, user : User, redis : Redis)
      case message[KIND_FIELD]?
      when RedisLogService::GLOBAL
        puts "LEAVE: #{RedisLogService.name(RedisLogService::GLOBAL)}"
        redis.unsubscribe RedisLogService.name(RedisLogService::GLOBAL)
      when RedisLogService::USER
        if user_id = user.id
          puts "LEAVE: #{RedisLogService.name(RedisLogService::USER, user_id)}"
          redis.unsubscribe RedisLogService.name(RedisLogService::USER, user_id)
        end
      when RedisLogService::SESSION
        if session_id = session.id
          puts "LEAVE: #{RedisLogService.name(RedisLogService::SESSION, session_id)}"
          redis.unsubscribe RedisLogService.name(RedisLogService::SESSION, session_id)
        end
      when RedisLogService::CLIENT
        if uuid = message["uuid"]?.try(&.as_s)
          puts "LEAVE: #{RedisLogService.name(RedisLogService::CLIENT, uuid)}"
          redis.unsubscribe RedisLogService.name(RedisLogService::CLIENT, uuid)
        end
      else
        puts "LEAVE FAILED: unknown kind"
      end
    end

    private def join!(socket : String, message : JSON::Any, session : Session, user : User, redis : Redis)
      name : String?
      case message[KIND_FIELD]?
      when RedisLogService::GLOBAL
        name = RedisLogService.name(RedisLogService::GLOBAL)
      when RedisLogService::USER
        if user_id = user.id
          name = RedisLogService.name(RedisLogService::USER, user_id)
        end
      when RedisLogService::SESSION
        if session_id = session.id
          name = RedisLogService.name(RedisLogService::SESSION, session_id)
        end
      when RedisLogService::CLIENT
        if uuid = message["uuid"]?.try(&.as_s)
          name = RedisLogService.name(RedisLogService::CLIENT, uuid)
        end
      end
      if namespace = name
        # puts "LISTEN: #{name}"
        redis.subscribe name
      else
        # puts "LISTEN FAILED: unknown kind"
      end
    end

    def run
      messages = [] of String

      puts "INIT WEBSOCKET"

      ws "/socket/:token" do |socket, env|
        sub : Redis::Subscription? = nil
        redis = Redis.new

        if (token = env.params.url["token"]) &&
           (session = SessionQuery.new.find(token)) &&
           (user = session.user)
          @sockets[token] = socket

          spawn do
            redis.subscribe(RedisLogService.name(RedisLogService::SYSTEM)) do |on|
              on.message do |channel, message|
                socket.send(message)
              rescue
                if (token = env.params.url["token"])
                  redis.punsubscribe("*")
                  @sockets.delete(token)
                  puts "Closing Socket???: #{socket}"
                end
              end
            end
          end

          socket.send({
            type:    WELCOME_TYPE,
            time:    Time.now,
            message: "welcome #{user.name || user.email || "User"}",
          }.to_json)
        end

        # Handle incoming message and dispatch it to all connected clients
        socket.on_message do |message|
          if (token = env.params.url["token"]) &&
             (sess = SessionQuery.new.find(token)) &&
             (user = sess.user)
            if msg = JSON.parse(message)
              case msg[TYPE_FIELD]?
              when JOIN_COMMAND
                join! token, msg, sess, user, redis
              when LEAVE_COMMAND
                leave! token, msg, sess, user, redis
              end
            end
          end
        end

        # Handle disconnection and clean sockets
        socket.on_close do |_|
          if token = env.params.url["token"]
            @sockets.delete(token)
          end
          puts "Closing Socket: #{socket}"
        end
      end
    end

    def self.instance
      @@instance ||= new
    end

    def initialize
      @redis = Redis.new
      @sockets = {} of String => HTTP::WebSocket
      @channel = Channel(Sockets::Message).new
    end

    def self.run
      self.instance.run
    end
  end
end
