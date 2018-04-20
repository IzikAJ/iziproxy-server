require "../models/user"
require "../models/auth_token"

class ConnectionsQuery
  def initialize(@user : User)
  end

  def list(page : Int32 = 1, per : Int32 = 10)
    Connection.all(
      "WHERE user_id = ?",
      [@user.id]
    )
  end

  def find(connection_id : Int64)
    Connection.first(
      "WHERE user_id = ? AND id = ?",
      [@user.id, connection_id]
    )
  end
end
