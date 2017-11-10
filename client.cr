# require "faraday"
require "http/client"
require "socket"
require "json"
require "base64"
require "logger"
require "./app/headers"
# require "byebug"

log = Logger.new(STDOUT)
# log.level = Logger::WARN
log.level = Logger::INFO

# conn = HTTP::Client.new "google.com"
conn = HTTP::Client.new "localhost", 3001

# host = "198.199.84.217"
host = "localhost"
subdomain = nil

loop do
  begin
    socket = TCPSocket.new(host, 9777)
    log.info "Connection successful"

    while subdomain.nil?
      begin
        req_namespace = JSON.build do |json|
          json.object do
            json.field :command do
              json.object do
                json.field :subdomain, "joy"
              end
            end
          end
        end

        socket.puts req_namespace
        log.info "REQUEST SUBDOMAIN: #{req_namespace.inspect}"

        while line = socket.gets
          ans = JSON.parse line.chomp
          log.info "...: #{ans.inspect}"
          subdomain = ans["command"]["subdomain"]?
          break unless subdomain.nil?
        end
      rescue e
        log.error e.message
      end

      log.info "SUB: #{subdomain.inspect}"
    end

    log.info "MAIN LOOP READY #{subdomain}"
    while line = socket.gets
      begin
        request = JSON.parse line.chomp

        method = request["method"].as_s.upcase
        path = request["path"].as_s
        headers = App::Headers.parse_json(request["headers"])
        body = Base64.decode(request["body"].as_s)

        log.info "REQ: #{method} #{path}"
        log.info "HEADERS: #{headers.inspect}"
        log.info "BODY: #{body}"

        response = conn.exec(method, path, headers, body)
        log.info "RESP (#{response.status_code})"
        # log.info "RESP HEADERS (#{response.headers})"

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
                  App::Headers.build_json(json, response.headers)
                end
                json.field :body, Base64.encode(response.body)
              end
            end
          end
        end

        # log.info "RESP JSON: #{resp.inspect}"

        socket.puts resp
      rescue e
        log.error e.message
      end
    end
    socket.close
    subdomain = nil
    log.info "socket closed"
  rescue e
    log.error e.message
    sleep 0.1
  end
end
