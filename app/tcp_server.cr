require "socket"
require "json"
require "logger"
#
require "./command_parser"
require "./models/client"

class TcpServer
  getter :app, :log, :server, :port
  property :commander

  def initialize(@app : Server, @log : Logger)
    @commander = CommandParser.new(@app, @log)
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
                @log.info "CONNECTION: ESTABLISH #{client.inspect}"
                @log.warn "CLIENT ID: #{client.uuid}"

                while line = _socket.gets
                  response_pack = JSON.parse line

                  if command = response_pack["command"]?
                    _socket.puts @commander.not_nil!.parse(client, command)
                  elsif response_pack["request"]?
                    @app.responses[response_pack["request"]["id"]] = response_pack
                  end
                end

                @log.info "CONNECTION: CLOSE #{client.inspect}"
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
