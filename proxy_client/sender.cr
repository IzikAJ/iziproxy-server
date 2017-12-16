require "socket"
require "json"
require "logger"

module ProxyClient
  class Sender
    getter log

    def initialize(@log : Logger)
    end

    def send(socket : TCPSocket, kind : String | Symbol)
      req = JSON.build do |json|
        json.object do
          json.field :command do
            json.object do
              json.field :kind, kind.to_s
              yield json
            end
          end
        end
      end

      log.warn("SEND COMMAND: #{req}")

      socket.puts req
    end
  end
end
