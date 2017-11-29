require "kemal"
require "./server"
require "./controllers/*"

module App
  class HttpServer
    getter app : Server
    getter log : Logger

    property :commander

    def initialize(@app : Server)
      @log = @app.not_nil!.log
      # @commander = CommandParser.new(@app, @log)
      draw_routes!
    end

    private def draw_routes!
      # Kemal::RouteHandler.INSTANCE

      # get "/", WelcomeController.new().show
      get "/" do |env|
        WelcomeController.new(env).show
      end

      post "/login" do |env|
        LoginController.new(env).create
      end
    end
  end
end
