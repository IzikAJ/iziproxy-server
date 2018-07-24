require "../../app/lib/utils/api_routes"
require "./controllers/api_controller"
require "crouter"

module Api
  class Core
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
