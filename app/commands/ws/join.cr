require "../../serializers/*"
require "./base"

module WS
  class JoinCommand < BaseCommand
    def self.call(message : JSON::Any, socket : HTTP::WebSocket, session : Session, user : User, redis : Redis)
      if name = namespace(message, session, user)
        redis.subscribe name

        case message[KIND_FIELD]?
        when RedisLogService::GLOBAL
          puts "////////////// JOIN GLOBAL"
        when RedisLogService::USER
          puts "////////////// JOIN USER"
        when RedisLogService::SESSION
          puts "////////////// JOIN SESSION"
        when RedisLogService::CLIENT
          if uuid = message["uuid"]?.try(&.as_s)
            puts "////////////// JOIN CLIENT"
            send_previous_logs!(uuid, socket)
          end
        end
      else
        # puts "LISTEN FAILED: unknown kind"
      end
    end

    private def self.send_previous_logs!(uuid : String, socket : HTTP::WebSocket)
      query = RequestsQuery.new(uuid)
      items_count = query.total_count
      if items_count > 0
        log_items = query.last.map do |item|
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

WS::Hub.register("join", WS::JoinCommand)
