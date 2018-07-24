# require "kemal"
require "crouter"

require "./proxy_server"
require "./lib/utils/pretty_routes"
require "./serializers/*"
require "../api/core"

require "./controllers/*"
require "./controllers/auth/*"

class HttpServer
  include PrettyRoutes

  property :commander

  def self.instance
    @@instance ||= new
  end

  def self.run
    self.instance

    # Api::Core.draw_routes!
  end

  class Router < Crouter::Router
    # root page
    get "/", "WelcomeController#show"

    # new session
    get "/auth/session/new", "Auth::SessionsController#action_new"
    post "/auth/session", "Auth::SessionsController#action_create"
    # restore password
    get "/auth/password/new", "Auth::PasswordsController#action_new"
    post "/auth/password/create", "Auth::PasswordsController#action_create"
    # change password
    get "/auth/password/edit", "Auth::PasswordsController#action_edit"
    post "/auth/password/update", "Auth::PasswordsController#action_update"

    get "/stats", "StatsController#action_show"
  end
end
