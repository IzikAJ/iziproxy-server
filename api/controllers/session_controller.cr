require "./api_controller"
require "../forms/login_form"

module Api
  class SessionController < ApiController
    def show
      if session = context.request.session
        user_params = nil
        if user = session.user
          user_params = {
            id:            user.id,
            name:          user.name,
            email:         user.email,
            log_requests:  user.log_requests,
            last_login_at: user.last_login_at,
            created_at:    user.created_at,
          }
        end
        {
          token:      session.token,
          user:       user_params,
          expired_at: session.expired_at,
        }.to_json
      else
        {
          session: "",
        }.to_json
      end
    end

    def create
      form = Api::LoginForm.from_any(context)
      if form && form.valid? &&
         (session = context.request.session) &&
         (user = form.user)
        session.sign_in(user)

        return {
          token: session.token,
        }.to_json
      end

      status_code! 422
      {
        errors: form.try(&.errors),
      }.to_json
    end

    def destroy
      if session = context.request.session
        if user = session.user
          session.expire!
          "ok"
        else
          status_code! 401
          "unauthorized"
        end
      end
    end
  end
end
