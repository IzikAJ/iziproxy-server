require "./application_form"

class LoginForm < ApplicationForm
  property email : String?
  property password : String?
  property user : User?

  accesible email, password

  def fetch_param(params : Kemal::ParamParser, key : String)
    params.body.fetch("user[#{key}]", nil)
  end

  def self.from_params(params : Kemal::ParamParser) : LoginForm
    form = self.new
    form.fetch_all(params)
    form.user = User.find_by(:email, form.email) unless form.email.nil?
    form
  end

  def correct_password?
    return false if @user.nil?
    user.not_nil!.valid_password?(password.not_nil!)
  end

  def valid?
    validate email, present, email
    validate password, present
    add_error(:email, "invalid") if @user.nil?
    add_error(:password, "invalid") unless correct_password?
    errors.empty?
  end
end
