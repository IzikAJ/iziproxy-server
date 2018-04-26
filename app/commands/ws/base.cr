require "json"

module WS
  abstract class BaseCommand
    def self.call(message : JSON::Any, socket : HTTP::WebSocket, session : Session, user : User, redis : Redis)
    end

    protected def self.namespace(message : JSON::Any, session : Session, user : User)
      case message[KIND_FIELD]?
      when RedisLogService::GLOBAL
        RedisLogService.name(RedisLogService::GLOBAL)
      when RedisLogService::USER
        if user_id = user.id
          RedisLogService.name(RedisLogService::USER, user_id)
        end
      when RedisLogService::SESSION
        if session_id = session.id
          RedisLogService.name(RedisLogService::SESSION, session_id)
        end
      when RedisLogService::CLIENT
        if uuid = message["uuid"]?.try(&.as_s)
          RedisLogService.name(RedisLogService::CLIENT, uuid)
        end
      end
    end
  end
end
