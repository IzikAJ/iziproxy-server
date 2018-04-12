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

    def get_resp(method, path, headers, body, deep = 0)
      return connection.exec(method, path, headers, body)
    rescue e
      if deep > 5
        puts "!!!!!!!!!!!!!!!!!!!!!"
        puts "!!!     WTF???    !!!"
        puts "!!!!!!!!!!!!!!!!!!!!!"
        puts e.inspect
        return HTTP::Client::Response.new(500, "SORRY")
      else
        @connection = HTTP::Client.new(host, port)
        return get_resp(method, path, headers, body, deep + 1)
      end
    end

    def process(socket : TCPSocket, line : String)
      puts "____ before parse"
      request = JSON.parse line.chomp
      puts "____ after parse"

      method = request["method"].as_s.upcase
      path = request["path"].as_s
      headers = ::App::Utils::Headers.parse_json(request["headers"])
      body = Base64.decode(request["body"].as_s) if request["body"]?

      started_at = Time.now

      puts "____ before exec"
      response = get_resp(method, path, headers, body)
      puts "____ after exec"

      print "[#{started_at.to_s}] "
      print "(#{response.status_code}) "
      print "#{method} #{path} "
      print "-> in #{(Time.now - started_at).total_milliseconds}ms "
      puts ""

      puts "____ before send"
      send_results socket, request, response
      puts "____ after send"
    rescue e
      log.error "PIPE ERROR #{e.message}"
    end
  end
end
