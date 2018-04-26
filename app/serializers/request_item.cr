require "./base"
require "../models/request_item"

class RequestItemSerializer < BaseSerializer
  def initialize(@src : RequestItem)
  end

  def as_json
    {
      id:            @src.id,
      uuid:          @src.uuid,
      connection_id: @src.connection_id,
      client_uuid:   @src.client_uuid,
      remote_ip:     @src.remote_ip,

      method:      @src.method,
      path:        @src.path,
      query:       @src.query,
      status_code: @src.status_code,

      created_at: @src.created_at,
      updated_at: @src.updated_at,
    }
  end
end
