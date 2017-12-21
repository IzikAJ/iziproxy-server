require "http/server"
require "json"
require "secure_random"
require "base64"
#
require "./lib/engine"
require "./models/request_item"
require "./app_logger"

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

    id = SecureRandom.uuid

    req = JSON.build do |json|
      json.object do
        json.field :id, id
        json.field :method, env.request.method
        json.field :path, env.request.path
        json.field :headers do
          App::Utils::Headers.build_json(json, env.request.headers)
        end
        json.field :body, Base64.encode(env.request.body.to_s)
      end
    end

    if (user = app.clients[client_id].user) && !user.id.nil? && user.log_requests
      req_item = RequestItem.new(
        uuid: id,
        client_uuid: client_id,
        request: req.to_s,
        user_id: user.id.not_nil!.to_i64
      )
      req_item.save
    end

    app.clients[client_id].socket.puts req

    i = 0
    while !app.responses.has_key?(id)
      sleep 0.05
      i += 1
      if i > 2000
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
