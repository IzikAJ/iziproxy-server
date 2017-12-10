require "kemal"
require "./server"
require "./controllers/*"
require "./controllers/auth/*"
require "./lib/utils/pretty_routes"

class HttpServer
  include PrettyRoutes

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

    # root page
    get "/", "welcome#show"

    # new session
    get "/auth/session/new", "auth/sessions#new"
    post "/auth/session", "auth/sessions#create"
    # restore password
    get "/auth/password/new", "auth/passwords#new"
    post "/auth/password/create", "auth/passwords#create"
    # change password
    get "/auth/password/edit", "auth/passwords#edit"
    post "/auth/password/update", "auth/passwords#update"

    get "/stats", "stats#show"
  end
end
