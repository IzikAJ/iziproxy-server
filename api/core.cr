require "../../app/lib/utils/api_routes"
require "./controllers/api_controller"

module Api
  class Core
    include ApiRoutes

    def self.draw_routes!
      get "session", "session#show"
      post "session", "session#create"
      delete "session", "session#destroy"

      get "servers", "servers#index"

      get "profile", "profile#show"
      post "profile", "profile#update"

      post "accounts/token", "accounts/tokens#create"
    end
  end
end
