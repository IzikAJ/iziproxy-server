require "./base_model"
require "secure_random"

class Session < Granite::ORM::Base
  include BaseModel

  adapter pg
  table_name sessions

  primary id : Int32 | Int64
  field user_id : Int32 | Int64 | Nil
  field token : String
  field expired : Bool
  timestamps

  belongs_to :user

  before_save :generate_token

  def user?
    !(user_id.nil? || User.find(user_id).nil?)
  end

  protected def generate_token
    @token ||= SecureRandom.hex(128)
  end
end
