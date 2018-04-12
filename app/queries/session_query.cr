require "../models/session"

class SessionQuery
  def find(token : String) : Session?
    Session.first(
      "WHERE token = ? AND expired_at > ?",
      [token, Time.now]
    )
  end

  def find_any(token : String) : Session?
    Session.first(
      "WHERE token = ?",
      [token]
    )
  end
end
