require "./base_model"

# id SERIAL PRIMARY KEY,
# user_id SERIAL,
# token VARCHAR(256) NOT NULL,
# remote_ip INET,
# expired_at TIMESTAMP,
# created_at TIMESTAMP,
# updated_at TIMESTAMP

class Session < Granite::ORM::Base
  include BaseModel

  EXPIRE_TIMEOUT = 7.days
  SOON_EXPIRE_IN = 1.day

  adapter pg
  table_name sessions

  primary id : Int64
  field user_id : Int64 | Nil
  field token : String
  field expired_at : Time
  timestamps

  belongs_to :user
  before_save :generate_token

  def user?
    !(user_id.nil? || User.find(user_id).nil?)
  end

  def sign_in(user : User)
    @user_id = user.id.not_nil!.to_i64
    @expired_at = EXPIRE_TIMEOUT.from_now
    save
    user.last_login_at = Time.now
    user.save
  end

  def expire!
    @expired_at = 1.second.ago
    save
  end

  def expires_soon?
    if expired = @expired_at
      puts "EXPIRE TIME: #{expired}"
      expired < SOON_EXPIRE_IN.from_now
    end
  end

  def update_expiration_time!
    @expired_at = EXPIRE_TIMEOUT.from_now
    save
  end

  protected def generate_token
    @user_id ||= -1.to_i64
    @token ||= Random::Secure.hex(128)
  end
end
