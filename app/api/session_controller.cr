require "./api_controller"

module Api
  class SessionController < ApiController
    def show
      {
        session: "nil",
      }
    end

    def ping
      "pong"
    end
  end
end
