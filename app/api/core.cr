require "../lib/utils/api_routes"

require "./api_controller"
require "./session_controller"

module Api
  class Core
    include ApiRoutes

    def self.draw_routes!
      get "session", "session#show"

      get "ping", "session#ping"
    end
  end
end
