require "json"

abstract class TcpCommand
  property socket : Socket
  property client : Client
  property command : JSON::Any

  macro safe_delegate(method, target)
    def {{method}}(*args, **xargs)
      {{target}}.not_nil!.{{method}}(*args, **xargs) unless {{target}}.nil?
    end
  end

  safe_delegate error, Commands::Hub::INSTANCE.log
  safe_delegate warn, Commands::Hub::INSTANCE.log
  safe_delegate info, Commands::Hub::INSTANCE.log

  def app
    Commands::Hub::INSTANCE.app.not_nil!
  end

  def log
    Commands::Hub::INSTANCE.log
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
