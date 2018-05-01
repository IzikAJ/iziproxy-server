require "http/server"
require "dotenv"
require "sidekiq"
require "./app/lib/engine"
require "./app/middleware/*"
require "./app/queries/*"
require "./app/*"

Dotenv.load
Sidekiq::Client.default_context = Sidekiq::Client::Context.new

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
server = HTTP::Server.new(
  "0.0.0.0",
  9111,
  [
    HTTP::LogHandler.new,
    Middleware::SubdomainMatcher.new(
      ENV["HOST"], "*.@", SubdomainHandler.new
    ),
    Middleware::SessionHandler.new(ENV["SESSION_KEY"]),
  ]
) do |context|
  puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  context.response.content_type = "text/plain"
  context.response.print "Hello world!"
end
TcpServer.run
server.listen
