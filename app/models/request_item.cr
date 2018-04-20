require "./base_model"

class RequestItem < Granite::ORM::Base
  include BaseModel
  adapter pg
  table_name request_items
  primary id : Int64
  #
  field connection_id : Int64
  field uuid : String
  field request : String
  field response : String
  field status_code : Int32
  field remote_ip : String
  #
  timestamps

  belongs_to :connection
end
