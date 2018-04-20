require "../../services/redis_log"
require "../../serializers/*"
require "json"

module RedisLog
  class ClientCommand
    KIND_CLIENT = "client"
    KIND_USER   = "user"
    KIND_GLOBAL = "global"

    TYPE_CONNECTED    = "connected"
    TYPE_AUTHORIZED   = "authorized"
    TYPE_UPDATED      = "updated"
    TYPE_BLOB         = "blob"
    TYPE_DISCONNECTED = "disconnected"

    def initialize(@client : Client)
    end

    def connected
      RedisLogService.log({
        kind: KIND_GLOBAL,
        type: TYPE_CONNECTED,
      }.to_json, RedisLogService::GLOBAL)
    end

    def authorized
      if (user = @client.user) &&
         (conn = @client.connection)
        RedisLogService.log(
          ConnectionSerializer.new(conn).merge({
            kind: KIND_USER,
            type: TYPE_AUTHORIZED,
          }).to_json,
          RedisLogService::USER,
          user.id
        )
      end
    end

    def updated
      if (user = @client.user) &&
         (conn = @client.connection)
        RedisLogService.log(
          ConnectionSerializer.new(conn).merge({
            kind: KIND_USER,
            type: TYPE_UPDATED,
          }).to_json,
          RedisLogService::USER,
          user.id
        )
        RedisLogService.log(
          ConnectionSerializer.new(conn).merge({
            kind: KIND_CLIENT,
            type: TYPE_UPDATED,
          }).to_json,
          RedisLogService::CLIENT,
          @client.uuid
        )
      end
    end

    def blob(data = {} of String => JSON::Any)
      RedisLogService.log(
        data.merge({
          kind:   KIND_CLIENT,
          target: @client.uuid,
          type:   TYPE_BLOB,
        }).to_json,
        RedisLogService::CLIENT,
        @client.uuid
      )
    end

    def disconnected
      RedisLogService.log(
        {
          kind: KIND_CLIENT,
          type: TYPE_DISCONNECTED,
        }.to_json,
        RedisLogService::CLIENT,
        @client.uuid
      )
      if (user = @client.user) &&
         (conn = @client.connection)
        RedisLogService.log(
          ConnectionSerializer.new(conn).merge({
            kind: KIND_USER,
            type: TYPE_DISCONNECTED,
          }).to_json,
          RedisLogService::USER,
          user.id
        )
      end
    end
  end
end
