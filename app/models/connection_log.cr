require "./base_model"

class ConnectionLog < Granite::ORM::Base
  include BaseModel
  adapter pg
  table_name client_logs
  primary id : Int64
  #
  field connection_id : Int64
  field message : String
  field level : Int32
  #
  timestamps

  belongs_to :connection
end
