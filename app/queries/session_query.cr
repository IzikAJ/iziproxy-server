require "../models/session"

class SessionQuery
  def find(token : String) : Session?
    Session.first(
      "WHERE token = ? AND expired_at > ?",
      [token, Time.now]
    )
  end

  def by_user(user_id : Int64) : Array(Session)
    Session.all(
      "WHERE user_id = ? AND expired_at > ?",
      [user_id, Time.now]
    )
  end
end
