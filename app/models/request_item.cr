require "./base_model"

class RequestItem < Granite::ORM::Base
  include BaseModel
  adapter pg
  table_name request_items
  primary id : Int32

  field user_id : Int32
  field uuid : String
  field client_uuid : String
  field request : String
  field status_code : Int32
  field response : String
  timestamps

  belongs_to :user
end
