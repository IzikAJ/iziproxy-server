require "socket"
require "json"
require "base64"
require "uri"
require "logger"
require "../app/lib/utils/headers"

module ProxyClient
  class Pipe
    getter log
    getter connection : HTTP::Client?
    property host : String = "localhost"
    property port : Int32? = 3000
    property uri : URI?

    def initialize(@log : Logger)
      # setup host & port in block
      yield self
      initial_uri = URI.parse("http://#{host}:#{port || 80}")
      @uri = initial_uri
      @connection = HTTP::Client.new(initial_uri)
    end

    def send_results(socket : TCPSocket, request : JSON::Any, response : HTTP::Client::Response)
      status_code = response.status_code

      if status_code == 301 || status_code == 308
        # force responce status code to NOT permanent
        status_code = 302
      end
      resp = JSON.build do |json|
        json.object do
          json.field :request do
            json.object do
              json.field :id, request["id"].as_s
            end
          end
          json.field :response do
            json.object do
              json.field :status, status_code
              json.field :headers do
                ::App::Utils::Headers.build_json(json, response.headers)
              end
              json.field :body, Base64.strict_encode(response.body)
            end
          end
        end
      end
      socket.puts resp
    end

    def get_resp(method, path, headers, body, deep = 0)
      if conn = connection
        return conn.exec(method, path, headers, body)
      end
    rescue e
      if deep > 5
        puts "!!!!!!!!!!!!!!!!!!!!!"
        puts "!!!     WTF???    !!!"
        puts "!!!!!!!!!!!!!!!!!!!!!"
        puts e.inspect
        return HTTP::Client::Response.new(500, "SORRY")
      else
        if uri = @uri
          @connection = HTTP::Client.new(uri)
        end
        return get_resp(method, path, headers, body, deep + 1)
      end
    end

    private def similar_host?(new_host : String)
      (
        host.split(".") && new_host.split(".")
      ).reject { |p| p == "www" || p == "m" }.size > 1
    end

    private def force_headers!(headers)
      # force host header for security reason

      if (hhost = headers["Host"]?) &&
         !(/#{host}/i =~ hhost)
        headers["Host"] = host
      end

      # headers.delete("Strict-Transport-Security")
      # headers.delete("Public-Key-Pins")
      # headers.delete("X-XSS-Protection")

      if (loc = headers["Location"]?) &&
         (new_uri = URI.parse(loc)) &&
         (new_host = new_uri.host) &&
         (host.gsub(/^www.|\/^/, "") == new_host.gsub(/^www.|\/^/, "")) &&
         similar_host?(new_host)
        @host = new_host
        @port = new_uri.port
        forced_path = new_uri.full_path
        new_uri.query = nil
        new_uri.path = "/"
        @uri = new_uri
        @connection = HTTP::Client.new(new_uri)

        headers.merge!({
          "Location" => forced_path,
        })
      end

      if (ctype = headers["Content-Type"]?) &&
         ctype =~ /charset/
        # force response charset header to utf-8
        # due to body auto-encoded to utf-8
        headers["Content-Type"] = ctype.gsub(/charset=[a-zA-Z0-9_-]+/, "charset=utf-8")
      end

      headers
    end

    def process(socket : TCPSocket, line : String)
      request = JSON.parse line.chomp

      method = request["method"].as_s.upcase
      path = request["path"].as_s
      headers = ::App::Utils::Headers.parse_json(request["headers"])

      if (enc = headers["Accept-Encoding"]?) && enc =~ /gzip/
        # replace gzip via some else
        headers["Accept-Encoding"] = "compress, br, deflate"
      end

      force_headers! headers

      body = Base64.decode(request["body"].as_s) if request["body"]?
      # puts "--------------------------"
      # puts ">>> #{method}: #{path}"
      # puts ">>> HEADERS: #{headers.inspect}"
      # puts ">>> BODY: #{body.inspect[0..500]}" unless body.nil?
      # puts "--------------------------"

      started_at = Time.now

      if response = get_resp(method, path, headers, body)
        # if response.headers["Content-Encoding"]? == "gzip"
        #   response.headers["Content-Encoding"] = "deflate"
        # end

        print "[#{started_at.to_s}] "
        print "(#{response.status_code}) "
        print "#{method} #{path} "
        print "-> in #{(Time.now - started_at).total_milliseconds}ms "
        puts ""

        force_headers! response.headers
        send_results socket, request, response
      end
    rescue e
      log.error "PIPE ERROR #{e.message}"
    end
  end
end
