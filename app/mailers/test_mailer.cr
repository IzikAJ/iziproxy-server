require "./application_mailer"

class TestMailer < ApplicationMailer
  def initialize
    super
    self.mail_to = "izik@mailinator.com"
    self.mail_subject = "Test"
    self.mail_text = "Test mail. Just for fun."
    deliver!
  end
end
