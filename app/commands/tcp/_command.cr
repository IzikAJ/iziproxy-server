require "json"
require "../../proxy_server"
require "../../app_logger"

abstract class TcpCommand
  property socket : Socket
  property client : Client
  property command : JSON::Any

  delegate error, warn, info, to: AppLogger

  def app
    ProxyServer.instance
  end

  def send_error!(code : Symbol | String, message : String)
    # socket.close_read if client.user.nil?
    resp = JSON.build do |json|
      json.object do
        json.field :error do
          json.object do
            json.field :code, code.to_s
            json.field :message, message
          end
        end
      end
    end
    socket.puts resp
  end

  def initialize(socket : Socket, client : Client, command : JSON::Any)
    # store instance variables
    @socket = socket
    @client = client
    @command = command
    # call logic
    call
  end

  abstract def call
end
