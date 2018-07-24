require "json"
require "db"
require "../../config/db"
# require "granite_orm"
require "granite/adapter/pg"

alias AnyKey = Symbol | String
alias AnyType = String | JSON::Any::Type | DB::Any
alias AnyValue = String | Symbol | Int32 | Int64 | Nil

module BaseModel
  def self.build(args : Hash(Symbol | String, String | JSON::Any::Type)) : User
    self.new(args)
  end
end
