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

      get "accounts/tokens", "accounts/tokens#index"
      post "accounts/token", "accounts/tokens#create"
      delete "accounts/token/:token_id", "accounts/tokens#destroy"
    end
  end
end
