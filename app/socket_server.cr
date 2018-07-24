# require "../*"
# require "kemal"
require "json"
require "crouter"
require "./queries/*"
require "./commands/redis_log/*"
require "./commands/ws_hub"

module Sockets
  # commands
  JOIN_COMMAND  = "join"
  LEAVE_COMMAND = "leave"

  WELCOME_TYPE = "welcome"
  ARRAY_TYPE   = "array"

  KIND_FIELD = "kind"
  TYPE_FIELD = "type"

  class Router < Crouter::Router
    private getter server

    def initialize(path : String, @server : Server)
      initialize(path)
    end

    get "/" do
      context.response << "WS IS UP"
    end

    get "/:token" do
      puts "?????? #{Time.now}"
      ws = HTTP::WebSocketHandler.new do |sock, env|
        puts "$!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        puts "$!!!!!!!!!!!! WS !!!!!!!!!!!!!!!!"
        puts "$!!!!!!!!!!!! #{Sockets::Server.instance.inspect[0..100]} ?"
        puts "$!!!!!!!!!!!! #{sock.inspect[0..100]} ???"
        puts "$!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        Sockets::Server.instance.sock! sock, env, params
      end
      ws.call context
    end
  end

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

    private def join!(token : String, message : JSON::Any, session : Session, user : User, redis : Redis)
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
        redis.subscribe namespace

        if socket = @sockets[token]
          case message[KIND_FIELD]?
          when RedisLogService::GLOBAL
          when RedisLogService::USER
            if user_id = user.id
            end
          when RedisLogService::SESSION
            if session_id = session.id
            end
          when RedisLogService::CLIENT
            if uuid = message["uuid"]?.try(&.as_s)
              query = RequestsQuery.new(uuid)
              items_count = query.total_count
              if items_count > 0
                log_items = query.list.map do |item|
                  RequestItemSerializer.new(item).as_json
                end
                if log_items.size > 0
                  socket.send({
                    type:   ARRAY_TYPE,
                    kind:   "client",
                    target: uuid,
                    count:  items_count,
                    items:  log_items,
                  }.to_json)
                end
              end
            end
          end
        end
      else
        # puts "LISTEN FAILED: unknown kind"
      end
    end

    def sock!(socket, env, params)
      sub : Redis::Subscription? = nil
      redis = Redis.new
      puts ">>>>>> sock! ?? #{params.inspect}"

      if (token = params["token"]?) &&
         (session = SessionQuery.new.find(token.not_nil!)) &&
         (user = session.user)
        @sockets[token] = socket

        spawn do
          redis.subscribe(RedisLogService.name(RedisLogService::SYSTEM)) do |on|
            on.message do |channel, message|
              socket.send(message)
            rescue
              if (token = params["token"]?)
                redis.punsubscribe("*")
                @sockets.delete(token)
                redis.close rescue nil
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

        spawn do
          loop do
            sleep 30
            break if !socket || socket.closed?
            socket.ping
          end
        end
      end

      # Handle incoming message and dispatch it to all connected clients
      socket.on_message do |message|
        if (token = params["token"]?) &&
           (sess = SessionQuery.new.find(token.not_nil!)) &&
           (user = sess.user)
          if (msg = JSON.parse(message)) &&
             (sock = @sockets[token])
            puts "+++++++++++++++++++++++++"
            puts ">>> #{message}"

            WS::Hub.call(msg, sock, sess, user, redis)
            puts "+++++++++++++++++++++++++"
          end
        end
      end

      # Handle disconnection and clean sockets
      socket.on_close do |_|
        if token = params["token"]?
          @sockets.delete(token)
        end
        redis.close rescue nil
        puts "Closing Socket: #{socket}"
      end
    end

    def handler
      Router.new("/socket", self)
    end

    def run
      puts "INIT WEBSOCKET"
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
