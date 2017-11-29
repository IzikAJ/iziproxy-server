require "kemal"
require "dotenv"
require "./app/patches/engine"
require "./app/*"
require "./app/middleware/*"

Dotenv.load

log = Logger.new(STDOUT)
log.level = Logger::INFO

host = "lvh.me"

log = Logger.new(STDOUT)
server = App::Server.new(log)
# filters must be inserted from most common to specific one
Kemal.config.add_filter_handler(App::Middleware::SessionHandler.new(ENV["SESSION_KEY"]))
Kemal.config.add_filter_handler(App::Middleware::SubdomainMatcher.new(
  host, "*.@", App::ProxySubdomainHandler.new(server)
))

http_server = App::HttpServer.new(server)

server.start
Kemal.run
