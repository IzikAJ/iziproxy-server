require "./application_form"

class UpdatePasswordForm < ApplicationForm
  property password : String?
  property password_confirmation : String?
  property token : String?
  property user : User?

  accesible token, password, password_confirmation

  def fetch_param(params : Kemal::ParamParser, key : String)
    params.body.fetch("user[#{key}]", params.query.fetch(key, nil))
  end

  def self.from_params(params : Kemal::ParamParser) : UpdatePasswordForm
    form = self.new
    form.fetch_all(params)
    form.user = User.find_by(:reset_password_token, form.token) if form.token
    form
  end

  def valid_confirmation?
    password == password_confirmation
  end

  def valid?
    validate password, present
    validate password_confirmation, present
    add_error(:password_confirmation, "invalid") unless valid_confirmation?
    errors.empty?
  end
end
