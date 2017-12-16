require "socket"
require "json"
require "logger"

module ProxyClient
  class Reciver
    ANSWER_TIMEOUT = 5.seconds

    getter log

    def initialize(@log : Logger)
    end

    def recive(socket : TCPSocket, kind : String | Symbol)
      dealine = ANSWER_TIMEOUT.from_now
      recived = false

      spawn do
        while dealine > Time.now
          sleep ANSWER_TIMEOUT / 10
        end
        next if recived

        socket.close_read
        log.error("CLOSE BY TIMEOUT")
      end

      while line = socket.gets
        ans = JSON.parse line.chomp

        log.warn("RECIVE RESPONCE: #{ans.inspect}")

        if ans["error"]?
          yield ans["command"]?, ans["error"]
          recived = true
          break
        elsif ans["command"]? && ans["command"]["kind"]? == kind.to_s
          yield ans["command"], nil
          recived = true
          break
        end
      end
    end
  end
end
