require "./api_form"

module Api
  class LoginForm < ApiForm
    property email : String?
    property password : String?
    property user : User?

    accesible email, password

    JSON.mapping({
      email:    String?,
      password: String?,
    })

    def self.from_any(context : HTTP::Server::Context) : LoginForm?
      if form = self.from_body(context)
        form.user = User.find_by(email: form.email) unless form.email.nil?
        return form
      end
    end

    def correct_password?
      return false if @user.nil?
      user.not_nil!.valid_password?(password.not_nil!)
    end

    def valid?
      validate email, present, email
      validate password, present
      add_error(:email, "invalid") if user.nil?
      add_error(:password, "invalid") unless correct_password?
      errors.empty?
    end
  end
end
