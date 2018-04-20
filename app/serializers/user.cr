require "./base"
require "../models/user"

class UserSerializer < BaseSerializer
  def initialize(@src : User)
  end

  def as_json
    {
      id:           @src.id,
      name:         @src.name,
      email:        @src.email,
      log_requests: @src.log_requests,
      created_at:   @src.created_at,
    }
  end
end
