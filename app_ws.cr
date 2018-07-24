require "dotenv"
require "http/server"
# require "kemal"
require "./app/*"
require "./app/middleware/*"
require "crouter"

Dotenv.load

AppLogger.configure do |conf|
  conf.logger = Logger.new(STDOUT)
  conf.logger.level = Logger::INFO
end

# ProxyServer.configure do |conf|
#   conf.http_port = ENV["HTTP_PORT"].to_i
#   conf.tcp_port = ENV["TCP_PORT"].to_i
#   conf.host = ENV["HOST"]
# end

class MyController
  private getter context : HTTP::Server::Context
  private getter params : HTTP::Params

  def initialize(@context, @params)
  end

  def my_action
    # do something
    context.response << "hi there"
  end
end

class WSH < HTTP::WebSocketHandler
  getter proc

  def initialize(&@proc : HTTP::WebSocket, HTTP::Server::Context -> Void)
  end

  def call(context : HTTP::Server::Context)
    super
  end
end

class MyRouter < Crouter::Router
  get "/" do
    context.response << "hello world"
  end
  get "/:token" do
    puts "?????? #{Time.now}"
    ws = WSH.new do |sock|
      puts "$!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
      puts "$!!!!!!!!!!!!! WS !!!!!!!!!!!!!!!"
      puts "$!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    end
    ws.call context
    context.response << "hello world #{params.inspect}"
  end

  get "/ctrl", "MyController#my_action"
end

# Kemal.config.add_filter_handler Middleware::SessionHandler.new(ENV["SESSION_KEY"])
server = HTTP::Server.new([
  HTTP::LogHandler.new,
  Middleware::SessionHandler.new(ENV["SESSION_KEY"]),
  Api::Router.new("/api"),
  Sockets::Server.instance.handler,
  HttpServer::Router.new,
  # MyRouter.new("/socket"),
]) do |context|
  puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  puts "!!!!!!!!!!!!! WS !!!!!!!!!!!!!!!"
  puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  context.response.content_type = "text/plain"
  context.response.print "WS is UP"
end
server.bind_tcp "0.0.0.0", 9112

Sockets::Server.run
HttpServer.run
# Kemal.run

puts "READY WS:9112"
server.listen
