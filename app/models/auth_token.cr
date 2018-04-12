require "./base_model"

# id SERIAL PRIMARY KEY,
# user_id SERIAL NOT NULL,
# token VARCHAR(100) NOT NULL,
# remote_ip INET,
# expired_at TIMESTAMP,
# created_at TIMESTAMP,
# updated_at TIMESTAMP

class AuthToken < Granite::ORM::Base
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
