require "../../forms/*"
require "../application_controller"

module Auth
  class SessionsController < ApplicationController
    property form : LoginForm = LoginForm.new

    def new
      redirect_to "/stats" if user_signed_in?
      render "app/views/auth/sessions/new.slim"
    end

    def create
      form = LoginForm.from_params(context.params)
      if form && form.valid? &&
         (session = context.request.session) &&
         (user = form.user)
        session.user_id = user.id.not_nil!.to_i64
        session.save
        redirect_to "/", 302
        return
      end
      status_code! 422
      render "app/views/auth/sessions/new.slim"
    end
  end
end
