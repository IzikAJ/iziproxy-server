require "./base_model"

class Connection < Granite::ORM::Base
  include BaseModel
  adapter pg
  table_name connections
  primary id : Int64
  #
  field user_id : Int64
  field client_uuid : String
  field subdomain : String
  field remote_ip : String
  #
  field packets_count : Int32 = 0
  field errors_count : Int32 = 0
  #
  timestamps

  belongs_to :user
  has_many :connection_logs
  has_many :request_items
end
