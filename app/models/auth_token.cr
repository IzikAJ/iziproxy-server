require "./base_model"

class AuthToken < Granite::ORM::Base
  include BaseModel
  adapter pg
  table_name auth_tokens
  primary id : Int32
  field user_id : Int32 | Int64
  field token : String
  field expired_at : Time
  timestamps

  belongs_to :user
  before_save :fill_defaults!

  protected def fill_defaults!
    @token ||= Random::Secure.hex(50)
    @expired_at ||= Time.now + 1.week
  end
end
