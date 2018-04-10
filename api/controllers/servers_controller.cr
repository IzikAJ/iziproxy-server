require "./api_controller"

module Api
  class ServersController < ApiController
    def index
      if (session = context.request.session) &&
         (user = session.user)
        profile_json user
      else
        status_code! 422
        "sorry"
      end
    end

    private def profile_json(user : User)
      puts "~~~ #{user.clients.inspect}"
      {
        id:           user.id,
        name:         user.name,
        email:        user.email,
        log_requests: user.log_requests,
        created_at:   user.created_at,
      }.to_json
    end
  end
end
