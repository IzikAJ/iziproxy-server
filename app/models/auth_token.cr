require "../config/db"
require "granite_orm/adapter/pg"
require "secure_random"

module App
  module Models
    class AuthToken < Granite::ORM::Base
      adapter pg
      table_name "auth_tokens"

      primary id : Int64 | Int32
      field user_id : Int64 | Int32
      field token : String
      field expired : Bool
      timestamps

      belongs_to :user

      before_save :generate_token

      protected def generate_token
        @token ||= SecureRandom.hex(50)
      end
    end
  end
end
