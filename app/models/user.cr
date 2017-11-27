require "../config/db"
require "granite_orm/adapter/pg"
require "crypto/bcrypt/password"
require "secure_random"

module App
  module Models
    class User < Granite::ORM::Base
      adapter pg
      table_name "users"

      primary id : Int64 | Int32
      field name : String
      field email : String
      field encrypted_password : String
      timestamps

      has_many :auth_tokens

      property :password

      def self.build(**args)
        build(args.to_h)
      end

      def self.build(args : Hash(Symbol | String, String | JSON::Type)) : User
        user = self.new(args)
        user.password = args[:password] || args["password"] || SecureRandom.base64
        user
      end

      def password=(pass : String) : String
        @password_hash = Crypto::Bcrypt::Password.create(pass)
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
    end
  end
end
