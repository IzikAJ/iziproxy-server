require "./application_form"

class NewPasswordForm < ApplicationForm
  property email : String?
  property user : User?

  accesible email

  def fetch_param(params : Kemal::ParamParser, key : String)
    params.body.fetch("user[#{key}]", nil)
  end

  def self.from_params(params : Kemal::ParamParser) : NewPasswordForm
    form = self.new
    form.fetch_all(params)
    form.user = User.find_by(email: form.email) unless form.email.nil?
    form
  end

  def valid?
    validate email, present, email
    add_error(:email, "invalid") if @user.nil?
    errors.empty?
  end
end
