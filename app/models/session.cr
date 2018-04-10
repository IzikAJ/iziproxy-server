require "./base_model"
# require "secure_random"

class Session < Granite::ORM::Base
  include BaseModel
  EXPIRE_TIMEOUT = 1.day

  adapter pg
  table_name sessions

  primary id : Int32
  field user_id : Int32 | Nil
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

  def update_expiration_time!
    @expired_at = EXPIRE_TIMEOUT.from_now
    save
  end

  protected def generate_token
    @token ||= Random::Secure.hex(128)
  end
end
