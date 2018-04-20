require "http/server"
require "json"
# require "secure_random"
require "base64"
require "uuid"
#
require "./lib/engine"
require "./models/request_item"
require "./app_logger"
require "./commands/redis_log/client"

class SubdomainHandler
  include HTTP::Handler

  getter app : ProxyServer = ProxyServer.instance

  def call(env : HTTP::Server::Context)
    subdomain = env.request.try &.subdomain

    return call_next(env) if subdomain.nil?

    if !app.subdomains[subdomain]?
      AppLogger.error "Subdomain \"#{subdomain}\" not available #{app.subdomains.keys.inspect}"
      return call_next(env)
    end

    client_id = app.subdomains[subdomain].client_id
    if app.clients[client_id]?.nil?
      AppLogger.error "Client not available"
      return call_next(env)
    end

    AppLogger.info "Client: #{client_id}(#{!app.clients[client_id].nil?})"

    id = UUID.random.to_s

    fullpath = [env.request.path, env.request.query].reject(&.nil?).join("?")
    req = JSON.build do |json|
      json.object do
        json.field :id, id
        json.field :method, env.request.method
        json.field :path, fullpath
        json.field :headers do
          App::Utils::Headers.build_json(json, env.request.headers)
        end
        if body = env.request.body
          json.field :body, Base64.encode(body.gets_to_end)
        end
      end
    end

    if (client = app.clients[client_id]) &&
       (user = client.user) &&
       user.log_requests &&
       (conn = client.connection)
      req_item = RequestItem.new(
        uuid: id,
        connection_id: conn.id,
        request: req.to_s,
        remote_ip: env.remote_ip
      )
      req_item.save

      RedisLog::ClientCommand.new(client).blob({
        at:            "sent",
        uuid:          id,
        connection_id: conn.id,
        method:        env.request.method,
        path:          env.request.path,
        query:         env.request.query,
        remote_ip:     env.remote_ip,
        stored_id:     req_item.id,
      })
    end

    app.clients[client_id].socket.puts req

    timeout = 2.minutes.from_now
    if (hdr = env.request.headers["Content-Type"]?) &&
       (hdr =~ /^multipart\/form-data/)
      timeout = 20.minutes.from_now
    end

    while !app.responses.has_key?(id)
      begin
        sleep 0.05
        if Time.now > timeout
          env.response.status_code = 408
          env.response.print "Timeout"
        end
      rescue
        puts "ERROR: raised error on responce wait"
        env.response.status_code = 408
        env.response.print "Timeout"
      end
    end

    response = app.responses[id]["response"]

    env.response.status_code = response["status"].as_i
    env.response.headers.merge! App::Utils::Headers.parse_json(response["headers"])
    env.response.print Base64.decode_string(response["body"].as_s)

    env
  end
end
