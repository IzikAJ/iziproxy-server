require "./base"
require "./user"
require "../models/session"

class SessionSerializer < BaseSerializer
  def initialize(@src : Session)
  end

  def self.blank
    {
      session: nil,
    }
  end

  def as_json
    {
      token:      @src.token,
      expired_at: @src.expired_at,
      user:       (user = @src.user) ? UserSerializer.new(user).as_json : nil,
    }
  end
end
