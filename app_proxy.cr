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

server = HTTP::Server.new([
  HTTP::LogHandler.new,
  Middleware::SubdomainMatcher.new(
    ENV["HOST"], "*.@", SubdomainHandler.new
  ),
]) do |context|
  context.response.content_type = "text/plain"
  context.response.print "PROXY SERVER IS UP"
end

puts "TRY BIND 2 START #{ENV["PROXY_PORT"].to_i}"
server.bind_tcp "0.0.0.0", ENV["PROXY_PORT"].to_i
puts "TRY BIND 2 OK"

TcpConnServer.run(ENV["TCP_PORT"].to_i)
puts "READY PROXY:#{ENV["PROXY_PORT"].to_i}"
server.listen
