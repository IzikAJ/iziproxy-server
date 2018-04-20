require "./base"
require "../models/connection"

class ConnectionSerializer < BaseSerializer
  def initialize(@src : Connection)
  end

  def as_json
    {
      id:            @src.id,
      user_id:       @src.user_id,
      client_uuid:   @src.client_uuid,
      subdomain:     @src.subdomain,
      remote_ip:     @src.remote_ip,
      packets_count: @src.packets_count,
      errors_count:  @src.errors_count,
      created_at:    @src.created_at,
      updated_at:    @src.updated_at,
    }
  end
end
