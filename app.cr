require "kemal"
require "dotenv"
require "./app/lib/engine"
require "./app/middleware/*"
require "./app/queries/*"
require "./app/*"

Dotenv.load

AppLogger.configure do |conf|
  conf.logger = Logger.new(STDOUT)
  conf.logger.level = Logger::INFO
end

ProxyServer.configure do |conf|
  conf.http_port = ENV["HTTP_PORT"].to_i
  conf.tcp_port = ENV["TCP_PORT"].to_i
  conf.host = ENV["HOST"]
end

# filters must be inserted from most common to specific one
Kemal.config.add_filter_handler Middleware::SessionHandler.new(ENV["SESSION_KEY"])
Kemal.config.add_filter_handler Middleware::SubdomainMatcher.new(
  ENV["HOST"], "*.@", SubdomainHandler.new
)

HttpServer.run
SocketServer.run
TcpServer.run
Kemal.run
