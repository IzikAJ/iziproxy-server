require "socket"
require "json"
require "logger"
require "./commands/hub"
#
require "./models/client"

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
  getter :app, :log, :server, :port
  property :commander

  def initialize(@app : Server, @log : Logger)
    Commands::Hub.configure! do |hub|
      hub.app = @app
      hub.log = @log
    end
  end

  def port=(port : Int32)
    @port = port
  end

  def start
    @log.warn "BIND TO PORT: #{@port}"
    @server = TCPServer.new(@port.as(Int))
    spawn do
      if server = @server
        loop do
          if socket = server.accept?
            @log.warn "handle the client in a fiber"
            spawn do
              if _socket = socket
                client = Client.new(@app, _socket)

                @app.clients[client.uuid] = client
                @log.info "CONNECTION: ESTABLISH #{client}"
                @log.warn "CLIENT ID: #{client.uuid}"

                while line = _socket.gets
                  response_pack = JSON.parse line

                  break if client.expired?

                  if command = response_pack["command"]?
                    Commands::Hub.call(_socket, client, command)
                  elsif client.authorized? && response_pack["request"]?
                    @app.responses[response_pack["request"]["id"]] = response_pack
                  end
                end

                @log.info "CONNECTION: CLOSE #{client}"
                @app.subdomains.delete client.subdomain.try(&.namespace) if client.subdomain
                @app.clients.delete client.uuid
              end
            end
          else
            @log.warn "another fiber closed the server"
            break
          end
        end
      end
    end
  end
end
