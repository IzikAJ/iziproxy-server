require "socket"
require "json"
require "./commands/hub"
#
require "./models/client"
require "./models/connection"
require "./proxy_server"
require "./app_logger"
require "./commands/redis_log/client"
require "./services/redis_log"

# client flow:
# 1 - connect
# failed - retry 1 && attempt++ if attempts < LIMIT
# failed - exit if attempts > LIMIT
# 2 - authorize
# failed - exit
# not passed in TIMEOUT - exit
# connection closed - go to step 1
# 3 - request namespace (subdomain)
# connection closed - go to step 1
# 4 - connection completed
# connection closed - go to step 1

class TcpServer
  getter app : ProxyServer = ProxyServer.instance
  getter server : TCPServer?

  def self.instance
    @@instance ||= new
  end

  def self.run
    self.instance.run
  end

  def initialize
    # remove all connections on boot
    Connection.clear
  end

  def save_response!(client : Client, resp : JSON::Any)
    if (req = resp["request"]?) &&
       (req_id = req["id"]?) &&
       (item = RequestItem.find_by(:uuid, req_id.as_s)) &&
       (data = resp["response"]?) &&
       (status = data["status"]?.try(&.as_i)) &&
       (headers = data["headers"]?)
      item.status_code = status
      item.response = headers.to_json
      item.save
      if conn = client.connection
        if (status >= 200 && status < 400)
          conn.packets_count = (conn.packets_count || 0) + 1
        else
          conn.errors_count = (conn.errors_count || 0) + 1
        end
        conn.save
      end

      RedisLog::ClientCommand.new(client).blob({
        at:            "recived",
        uuid:          item.uuid,
        connection_id: item.connection_id,
        status:        status,
        stored_id:     item.id,
      })
    end
  end

  def run
    AppLogger.info "BIND TO PORT: #{app.http_port}"
    # RedisLog::ClientCommand.new

    @server = TCPServer.new(app.tcp_port)

    spawn do
      if _server = server
        loop do
          if socket = _server.accept?
            AppLogger.info "Handle the client in a fiber"

            spawn do
              if _socket = socket
                # setup some socket configs
                _socket.keepalive = true
                _socket.reuse_address = true

                client = Client.new(_socket)

                @app.clients[client.uuid] = client
                client_log = RedisLog::ClientCommand.new(client)

                client_log.connected

                while line = _socket.gets
                  response_pack = JSON.parse line

                  break if client.expired?

                  if command = response_pack["command"]?
                    Commands::Hub.call(_socket, client, command)
                  elsif client.authorized? && response_pack["request"]?
                    @app.responses[response_pack["request"]["id"]] = response_pack
                    save_response!(client, response_pack) if client.log_requests?
                  end
                end

                AppLogger.info "CONNECTION: CLOSE #{client}"
                client_log.disconnected
                client.free_subdomain!(client.subdomain) if client.subdomain
                if conn = client.connection
                  # remove connection when it lost
                  conn.destroy
                end

                @app.clients.delete client.uuid
              end
            end
          else
            AppLogger.error "Another fiber closed the server"
            break
          end
        end
      end
    end
  end
end
