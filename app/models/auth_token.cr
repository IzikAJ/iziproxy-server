require "./base_model"

class AuthToken < Granite::Base
  include BaseModel
  adapter pg
  table_name auth_tokens
  primary id : Int64
  field user_id : Int64
  field token : String
  field expired_at : Time
  timestamps

  belongs_to :user
  before_save :fill_defaults!

  def refresh_deadline!(timeout = 1.week)
    @expired_at ||= Time.now + timeout
    save
  end

  protected def fill_defaults!
    @token ||= Random::Secure.hex(50)
    @expired_at ||= Time.now + 1.week
  end
end
