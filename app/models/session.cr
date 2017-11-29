require "../config/db"
require "granite_orm/adapter/pg"
require "secure_random"

module App
  module Models
    class Session < Granite::ORM::Base
      adapter pg
      table_name "sessions"

      primary id : Int64 | Int32
      field user_id : Int64 | Int32 | Nil
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
  end
end
