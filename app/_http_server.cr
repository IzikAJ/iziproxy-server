require "http/server"
require "json"
require "logger"
require "secure_random"
require "base64"
#
require "./headers"

require "./views/base"

#

# module App
#   class HttpServer
#     getter :app, :log, :server, :port, :host

#     def initialize(@app : Server, @log : Logger)
#     end

#     def port=(port : Int32)
#       @port = port
#     end

#     def host=(host : String)
#       @host = host
#     end

#     def make_server
#       @server = HTTP::Server.new(@port.as(Int)) do |context|
#         host = context.request.host.to_s
#         subdomain = ""
#         if host_root = @host
#           if host.starts_with?(host_root)
#             #
#             App::Views::Welcome.new(@app, context).show
#             next
#           else
#             subdomain = host.gsub(".#{host_root}", "")
#           end
#         else
#           subdomain = host.gsub(/\..+\..+$/, "")
#         end

#         if !@app.subdomains[subdomain]?
#           @log.error "Subdomain \"#{subdomain}\" not available #{@app.subdomains.keys.inspect}"
#           next
#         end

#         client_id = @app.subdomains[subdomain].client_id
#         if @app.clients[client_id]?.nil?
#           @log.error "Client not available"
#           next
#         end

#         @log.info "Client: #{client_id}(#{!@app.clients[client_id].nil?})"

#         # @log.warn "HEADERS: #{context.request.headers.to_json}"
#         # @log.error context.request.inspect

#         id = SecureRandom.uuid

#         req = JSON.build do |json|
#           json.object do
#             json.field :id, id
#             json.field :method, context.request.method
#             json.field :path, context.request.path
#             json.field :headers do
#               App::Headers.build_json(json, context.request.headers)
#             end
#             json.field :body, Base64.encode(context.request.body.to_s)
#           end
#         end

#         # @log.info "#{id} #{req.inspect}"
#         @log.info "#{id} #{subdomain}"

#         @app.clients[client_id].socket.puts req

#         i = 0
#         while !@app.responses.has_key?(id)
#           sleep 0.05
#           i += 1
#           if i > 2000
#             context.response.status_code = 408
#             context.response.print "Timeout"
#           end
#         end

#         response = @app.responses[id]["response"]

#         context.response.status_code = response["status"].as_i
#         context.response.headers.merge! App::Headers.parse_json(response["headers"])
#         context.response.print Base64.decode_string(response["body"].as_s)
#       end
#     end

#     def start
#       make_server

#       @log.warn "Listening on http://0.0.0.0:#{@port}"
#       @server.as(HTTP::Server).listen
#     end
#   end
# end
