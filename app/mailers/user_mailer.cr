require "./application_mailer"

class UserMailer < ApplicationMailer
  property user : User

  def initialize(@user)
    super()
    self.mail_to = user.email
  end

  def restore_password_instructions!
    self.mail_subject = "Restore password"
    self.mail_text = "
      Hello, your reset password link is:
      http://localhost:9000/auth/password/edit?token=#{user.reset_password_token}
    "
    deliver!
  end
end
