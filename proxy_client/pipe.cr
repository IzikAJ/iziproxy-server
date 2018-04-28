require "socket"
require "json"
require "base64"
require "uri"
require "logger"
require "../app/lib/utils/headers"

module ProxyClient
  class Pipe
    getter log
    getter connection : HTTP::Client = HTTP::Client.allocate
    property host : String = "localhost"
    property port : Int32 = 3000
    property tls = false

    def initialize(@log : Logger)
      # setup host & port in block
      yield self
      @connection = HTTP::Client.new(host, port, tls)
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
              json.field :status, (response.status_code == 301) ? 302 : response.status_code
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
        @connection = HTTP::Client.new(host, port, tls)
        return get_resp(method, path, headers, body, deep + 1)
      end
    end

    private def force_headers!(headers)
      # force host header for security reason

      if (hhost = headers["Host"]?) &&
         !(/#{host}/i =~ hhost)
        headers["Host"] = "#{host.gsub(/http(s)?:\/\//, "")}#{(port && port != 80) ? ":#{port}" : ""}"
      end

      if (loc = headers["Location"]?) &&
         (/((http(s)?:)?\/\/(www.)?)#{host}/ =~ loc)
        puts "REDIRECT ON SAME SITE"

        if (loc = headers["Location"]?) &&
           (new_uri = URI.parse(loc))
          puts "?!?!? #{new_uri.inspect}"
          @tls = new_uri.scheme === "https"
          @host = new_uri.host || "/"
          @port = new_uri.port || 80
          @connection = HTTP::Client.new(new_uri)

          headers.merge!({
            "Location" => loc.gsub(/(((http(s)?:)?\/\/?)#{host})/, ""),
          })
        end

        puts "!!!!1 #{host}"
        puts "!!!!2 #{port}"
        puts "!!!!2 #{tls}"
      end

      headers
    end

    def process(socket : TCPSocket, line : String)
      request = JSON.parse line.chomp

      method = request["method"].as_s.upcase
      path = request["path"].as_s
      headers = ::App::Utils::Headers.parse_json(request["headers"])

      force_headers! headers

      puts "--------------------------"
      puts ">>> HEADERS: #{headers.inspect}"
      puts "--------------------------"
      body = Base64.decode(request["body"].as_s) if request["body"]?

      started_at = Time.now

      response = get_resp(method, path, headers, body)

      print "[#{started_at.to_s}] "
      print "(#{response.status_code}) "
      print "#{method} #{path} "
      print "-> in #{(Time.now - started_at).total_milliseconds}ms "
      puts ""
      puts "--------------------------"
      puts "<<< RAW: #{response.headers.inspect}"
      puts "--------------------------"

      force_headers! response.headers

      puts "--------------------------"
      puts "<<< HEADERS: #{response.headers.inspect}"
      puts "--------------------------"

      send_results socket, request, response
    rescue e
      log.error "PIPE ERROR #{e.message}"
    end
  end
end
