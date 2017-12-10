require "kemal"
require "dotenv"
require "./app/lib/engine"
require "./app/middleware/*"
require "./app/*"

Dotenv.load

log = Logger.new(STDOUT)
log.level = Logger::INFO

host = "lvh.me"

log = Logger.new(STDOUT)
server = Server.new(log)
# filters must be inserted from most common to specific one
Kemal.config.add_filter_handler(Middleware::SessionHandler.new(ENV["SESSION_KEY"]))
Kemal.config.add_filter_handler(Middleware::SubdomainMatcher.new(
  host, "*.@", ProxySubdomainHandler.new(server)
))

http_server = HttpServer.new(server)

server.start
Kemal.run
