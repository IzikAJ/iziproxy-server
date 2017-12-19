require "socket"
require "json"
require "./commands/hub"
#
require "./models/client"
require "./proxy_server"
require "./app_logger"

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
  end

  def save_response!(resp : JSON::Any)
    if item = RequestItem.find_by(:uuid, resp["request"]["id"].as_s)
      item.status_code = resp["response"]["status"].as_i
      item.response = resp["response"]["headers"].as_s
      item.save
    end
  end

  def run
    AppLogger.warn "BIND TO PORT: #{app.http_port}"
    @server = TCPServer.new(app.tcp_port)

    spawn do
      if _server = server
        loop do
          if socket = _server.accept?
            AppLogger.warn "handle the client in a fiber"
            spawn do
              if _socket = socket
                client = Client.new(_socket)

                @app.clients[client.uuid] = client
                AppLogger.info "CONNECTION: ESTABLISH #{client}"
                AppLogger.warn "CLIENT ID: #{client.uuid}"

                while line = _socket.gets
                  response_pack = JSON.parse line

                  break if client.expired?

                  if command = response_pack["command"]?
                    Commands::Hub.call(_socket, client, command)
                  elsif client.authorized? && response_pack["request"]?
                    @app.responses[response_pack["request"]["id"]] = response_pack
                    save_response! response_pack
                  end
                end

                AppLogger.info "CONNECTION: CLOSE #{client}"
                @app.subdomains.delete client.subdomain.try(&.namespace) if client.subdomain
                @app.clients.delete client.uuid
              end
            end
          else
            AppLogger.warn "another fiber closed the server"
            break
          end
        end
      end
    end
  end
end
