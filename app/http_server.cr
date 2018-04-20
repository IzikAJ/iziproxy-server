require "kemal"

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
    self.instance.draw_routes!

    Api::Core.draw_routes!
  end

  def draw_routes!
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
