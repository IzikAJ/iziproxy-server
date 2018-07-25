require "dotenv"
require "http/server"
require "./app/*"
require "./app/middleware/*"
require "crouter"

Dotenv.load

AppLogger.configure do |conf|
  conf.logger = Logger.new(STDOUT)
  conf.logger.level = Logger::INFO
end

server = HTTP::Server.new([
  # middlewares
  HTTP::LogHandler.new,
  Middleware::SessionHandler.new(ENV["SESSION_KEY"]),
  # handlers
  Api::Core.handler("/api"),
  Sockets::Server.handler("/socket"),
  # HttpServer::Router.new,
]) do |context|
  context.response.content_type = "text/plain"
  context.response.print "APP BACKEND IS UP"
end

puts "TRY BIND 1 START #{ENV["PORT"].to_i}"
server.bind_tcp "0.0.0.0", ENV["PORT"].to_i
puts "TRY BIND 1 OK"

Sockets::Server.run
# HttpServer.run

puts "READY BACKEND:#{ENV["PORT"]}"
server.listen
