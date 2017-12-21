require "../models/user"
require "../models/request_item"

class RequestsQuery
  def initialize(@user : User)
  end

  def list(page : Int32 = 1, per : Int32 = 2)
  end
end
