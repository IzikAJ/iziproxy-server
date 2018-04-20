require "json"
require "../../models/auth_token"

class AuthCommand < TcpCommand
  property auth : AuthToken?

  def call
    token = command["token"].as_s

    auth = AuthToken.first(
      "WHERE token = ? AND expired_at > ?",
      [token, Time.now]
    )

    if auth.nil?
      send_error!(:invalid, "Auth token invalid")
      socket.close_read if client.user.nil?
      return
    end

    client.user = auth.not_nil!.user
    if user = client.user
      user.clients << client

      if conn = client.connection
        conn.user_id = user.id
        conn.save
      end

      RedisLog::ClientCommand.new(client).authorized
    end

    respond!
  end

  def result?
    JSON.build do |json|
      json.object do
        json.field :command do
          json.object do
            json.field :kind, command["kind"]?.to_s
            json.field :auth, client.user ? "authorized" : "failed"
          end
        end
      end
    end
  end

  def respond!
    socket.puts result?
  end
end

Commands::Hub.register("auth", AuthCommand)
