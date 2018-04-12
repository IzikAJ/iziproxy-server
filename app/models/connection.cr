require "./base_model"

# id SERIAL PRIMARY KEY,
# client_uuid UUID NOT NULL,
# user_id SERIAL NOT NULL,
# remote_ip INET,
# packets_count INTEGER DEFAULT 0,
# errors_count INTEGER DEFAULT 0,
# created_at TIMESTAMP,
# updated_at TIMESTAMP

class ClientConnection < Granite::ORM::Base
  include BaseModel
  adapter pg
  table_name connections
  primary id : Int64
  #
  field user_id : Int64
  field client_uuid : String
  field remote_ip : String
  field status_code : Int32
  field request : String
  field response : String
  #
  field packets_count : Int32
  field errors_count : Int32
  #
  timestamps

  has_many :connection_logs
  has_many :request_items
end
