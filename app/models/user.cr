require "crypto/bcrypt/password"
# require "secure_random"

require "./base_model"
require "../mailers/user_mailer"

class User < Granite::ORM::Base
  include BaseModel
  adapter pg
  table_name users
  primary id : Int32
  field name : String
  field email : String
  field encrypted_password : String
  field log_requests : Bool
  field reset_password_token : String
  field last_login_at : Time
  timestamps

  getter clients = [] of Client

  has_many :auth_tokens
  has_many :sessions
  has_many :request_items

  @password : String | Nil

  def self.build(**args)
    build(args.to_h)
  end

  def self.build(args : Hash(Symbol | String, String | JSON::Type)) : User
    user = self.new(args)
    user.password = args[:password] || args["password"] || Random::Secure.base64
    user
  end

  def password=(pass : String | Nil) : String | Nil
    return if pass.nil?
    @password_hash = Crypto::Bcrypt::Password.create(pass.not_nil!)
    @encrypted_password = @password_hash.to_s
  end

  def password
    nil
  end

  def valid_password?(pass : String) : Bool
    return false if @encrypted_password.nil?
    @password_hash ||= Crypto::Bcrypt::Password.new(@encrypted_password.not_nil!)
    @password_hash == pass
  end

  def reset_password!
    @reset_password_token = Random::Secure.hex(16)
    UserMailer.new(self).restore_password_instructions! if save
  end
end
