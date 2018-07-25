require "./controllers/api_controller"
require "crouter"

module Api
  class Core
    def self.handler(mount_point = "/api")
      Api::Router.new(mount_point)
    end
  end

  class Router < Crouter::Router
    get "/session.json", "Api::SessionController#show"
    post "/session.json", "Api::SessionController#create"
    delete "/session.json", "Api::SessionController#destroy"

    get "/profile.json", "Api::ProfileController#show"
    post "/profile.json", "Api::ProfileController#update"

    get "/accounts/tokens.json", "Api::Accounts::TokensController#index"
    post "/accounts/tokens.json", "Api::Accounts::TokensController#create"
    delete "/accounts/tokens/:token_id/x.json", "Api::Accounts::TokensController#destroy"

    get "/accounts/connections.json", "Api::Accounts::ConnectionsController#index"
  end
end
