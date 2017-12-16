require "socket"
require "json"
require "base64"
require "logger"
require "../app/lib/utils/headers"

module ProxyClient
  class Pipe
    getter log
    getter connection : HTTP::Client = HTTP::Client.allocate
    property host : String = "localhost"
    property port : Int32 = 3000

    def initialize(@log : Logger)
      # setup host & port in block
      yield self
      @connection = HTTP::Client.new(host, port)
    end

    def send_results(socket : TCPSocket, request : JSON::Any, response : HTTP::Client::Response)
      resp = JSON.build do |json|
        json.object do
          json.field :request do
            json.object do
              json.field :id, request["id"].as_s
            end
          end
          json.field :response do
            json.object do
              json.field :status, response.status_code
              json.field :headers do
                ::App::Utils::Headers.build_json(json, response.headers)
              end
              json.field :body, Base64.encode(response.body)
            end
          end
        end
      end
      socket.puts resp
    end

    def process(socket : TCPSocket, line : String)
      begin
        request = JSON.parse line.chomp

        method = request["method"].as_s.upcase
        path = request["path"].as_s
        headers = ::App::Utils::Headers.parse_json(request["headers"])
        body = Base64.decode(request["body"].as_s)

        started_at = Time.now

        response = connection.exec(method, path, headers, body)

        print "[#{started_at.to_s}] "
        print "(#{response.status_code}) "
        print "#{method} #{path} "
        print "-> in #{(Time.now - started_at).total_milliseconds}ms "
        puts ""

        send_results socket, request, response
      rescue e
        log.error e.message
      end
    end
  end
end
