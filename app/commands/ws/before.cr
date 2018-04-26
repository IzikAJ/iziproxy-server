require "./base"

module WS
  class BeforeCommand < BaseCommand
    def self.call(message : JSON::Any, socket : HTTP::WebSocket, session : Session, user : User, redis : Redis)
      puts "////////////// BEFORE CALL"
      puts "////////////// BEFORE name #{namespace(message, session, user)}"
      puts "////////////// BEFORE raw #{message["before"]?}"
      if (name = namespace(message, session, user)) &&
         (before_raw = message["before"]?) &&
         (before = before_raw.as_s)
        case message[KIND_FIELD]?
        when RedisLogService::GLOBAL
          puts "////////////// BEFORE GLOBAL"
        when RedisLogService::USER
          puts "////////////// BEFORE USER"
        when RedisLogService::SESSION
          puts "////////////// BEFORE SESSION"
        when RedisLogService::CLIENT
          if uuid = message["uuid"]?.try(&.as_s)
            puts "////////////// BEFORE CLIENT"
            send_previous_logs!(uuid, before, socket)
          end
        end
      else
        # puts "LISTEN FAILED: unknown kind"
      end
    end

    private def self.send_previous_logs!(uuid : String, before : Time | String | Nil, socket : HTTP::WebSocket)
      query = RequestsQuery.new(uuid)
      items_count = query.total_count
      if items_count > 0
        log_items = query.last(before).map do |item|
          RequestItemSerializer.new(item).as_json
        end
        if log_items.size > 0
          socket.send({
            type:   "before",
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

WS::Hub.register("before", WS::BeforeCommand)
