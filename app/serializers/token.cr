require "./base"
require "./user"
require "../models/auth_token"

class TokenSerializer < BaseSerializer
  def initialize(@src : AuthToken)
  end

  def as_json
    {
      id:         @src.id,
      token:      @src.token,
      expired_at: @src.expired_at,
    }
  end
end
