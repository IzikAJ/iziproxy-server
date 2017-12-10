require "../../forms/*"
require "../application_controller"

module Auth
  class PasswordsController < ApplicationController
    property form : ApplicationForm = NewPasswordForm.new

    def new
      render "app/views/auth/passwords/new.slim"
    end

    def create
      form = NewPasswordForm.from_params(context.params)
      if form && form.valid? && (user = form.user)
        user.reset_password!
        return render "app/views/auth/passwords/sent.slim"
      end
      status_code! 422
      render "app/views/auth/passwords/new.slim"
    end

    def edit
      form = UpdatePasswordForm.from_params(context.params)
      render "app/views/auth/passwords/edit.slim"
    end

    def update
      form = UpdatePasswordForm.from_params(context.params)
      if form && form.valid? &&
         (session = context.request.session) &&
         (user = form.user)
        user.password = form.password
        user.save
        session.user_id = user.id.not_nil!.to_i64
        session.save
        redirect_to "/", 302
        return
      end
      status_code! 422
      render "app/views/auth/passwords/edit.slim"
    end
  end
end
