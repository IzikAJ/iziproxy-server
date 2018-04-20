require "./api_controller"
require "../forms/login_form"

module Api
  class SessionController < ApiController
    def show
      if session = context.request.session
        SessionSerializer.new(session).to_json
      else
        SessionSerializer.blank.to_json
      end
    end

    def create
      form = Api::LoginForm.from_any(context)
      if form && form.valid? &&
         (session = context.request.session) &&
         (user = form.user)
        session.sign_in(user)
        SessionSerializer.new(session).to_json
      end

      form_error! form
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
