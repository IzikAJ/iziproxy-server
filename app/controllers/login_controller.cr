require "../*"
require "./application_controller"

class LoginController < ApplicationController
  def create
    # context.params.body.fetch("email", nil)
    # context.params.body.fetch("password", nil)
    mail = context.params.body.fetch("email", nil)
    password = context.params.body.fetch("password", nil)
    tmp_user = App::Models::User.first("email = ?", mail)
    if (user = tmp_user) && (session = context.request.session)
      if user.valid_password?(password.not_nil!)
        session.user_id = user.id.as(Int64)
        session.save
      end
    end
    render "app/views/welcome/show.slim"
  end
end
