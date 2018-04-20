require "../../services/redis_log"

module RedisLog
  class SystemCommand
    def initialize
    end

    def disconnected
      RedisLogService.log(
        {
          kind:    "system",
          message: "client disconnected",
        }.to_json,
        RedisLogService::SYSTEM
      )
      RedisLogService.log(
        {
          kind:    "global",
          message: "connection closed",
        }.to_json,
        RedisLogService::GLOBAL
      )
    end
  end
end
