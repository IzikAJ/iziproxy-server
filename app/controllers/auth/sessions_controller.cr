require "../../forms/*"
require "../application_controller"

module Auth
  class SessionsController < ApplicationController
    property form : LoginForm = LoginForm.new

    def action_new
      redirect_if_authorized!
      redirect_to "/stats" if user_signed_in?
      render "app/views/auth/sessions/new.slim"
    end

    def action_create
      redirect_if_authorized!
      form = LoginForm.from_params(params)
      if form && form.valid? &&
         (session = context.request.session) &&
         (user = form.user)
        session.sign_in(user)
        redirect_to "/", 302
        return
      end
      status_code! 422
      render "app/views/auth/sessions/new.slim"
    end
  end
end
