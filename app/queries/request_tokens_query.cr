require "../models/user"
require "../models/auth_token"

class RequestTokensQuery
  def initialize(@user : User)
  end

  def list(page : Int32 = 1, per : Int32 = 10)
    AuthToken.all(
      "WHERE user_id = ?",
      [@user.id]
    )
  end

  def find(token_id : Int64)
    AuthToken.first(
      "WHERE user_id = ? AND id = ?",
      [@user.id, token_id]
    )
  end
end
