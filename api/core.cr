require "../../app/lib/utils/api_routes"
require "./controllers/api_controller"

module Api
  class Core
    include ApiRoutes

    def self.draw_routes!
      get "session", "session#show"
      post "session", "session#create"
      delete "session", "session#destroy"

      get "profile", "profile#show"
      post "profile", "profile#update"

      get "accounts/tokens", "accounts/tokens#index"
      post "accounts/tokens", "accounts/tokens#create"
      delete "accounts/tokens/:token_id/x", "accounts/tokens#destroy"

      get "accounts/connections", "accounts/connections#index"
    end
  end
end
