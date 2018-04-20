require "dotenv"
require "kemal"
require "./app/*"
require "./app/middleware/*"

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

Kemal.config.add_filter_handler Middleware::SessionHandler.new(ENV["SESSION_KEY"])

Sockets::Server.run
HttpServer.run
Kemal.run
