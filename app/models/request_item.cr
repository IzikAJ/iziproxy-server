require "./base_model"

# id SERIAL PRIMARY KEY,
# connection_id SERIAL NOT NULL,
# remote_ip INET,
# request TEXT,
# status_code INTEGER,
# response TEXT,
# created_at TIMESTAMP,
# updated_at TIMESTAMP

class RequestItem < Granite::ORM::Base
  include BaseModel
  adapter pg
  table_name request_items
  primary id : Int64
  #
  field connection_id : Int64
  field request : String
  field response : String
  field status_code : Int32
  field remote_ip : String
  #
  timestamps

  belongs_to :connection
end
