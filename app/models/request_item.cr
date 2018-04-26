require "./base_model"

class RequestItem < Granite::ORM::Base
  include BaseModel
  adapter pg
  table_name request_items
  primary id : Int64
  #
  field uuid : String
  field connection_id : Int64
  field client_uuid : String
  field remote_ip : String

  field method : String
  field path : String
  field query : String
  field status_code : Int32
  #
  timestamps

  belongs_to :connection
end
