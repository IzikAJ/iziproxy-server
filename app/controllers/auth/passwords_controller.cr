require "../../forms/*"
require "../application_controller"

module Auth
  class PasswordsController < ApplicationController
    property form : ApplicationForm = NewPasswordForm.new

    def action_new
      redirect_if_authorized!
      render "app/views/auth/passwords/new.slim"
    end

    def action_create
      redirect_if_authorized!
      form = NewPasswordForm.from_params(context.params)
      if form && form.valid? && (user = form.user)
        user.reset_password!
        return render "app/views/auth/passwords/sent.slim"
      end
      status_code! 422
      render "app/views/auth/passwords/new.slim"
    end

    def action_edit
      redirect_if_authorized!
      form = UpdatePasswordForm.from_params(context.params)
      render "app/views/auth/passwords/edit.slim"
    end

    def action_update
      redirect_if_authorized!
      form = UpdatePasswordForm.from_params(context.params)
      if form && form.valid? &&
         (session = context.request.session) &&
         (user = form.user)
        user.password = form.password
        user.save
        session.sign_in(user)
        redirect_to "/", 302
        return
      end
      status_code! 422
      render "app/views/auth/passwords/edit.slim"
    end
  end
end
