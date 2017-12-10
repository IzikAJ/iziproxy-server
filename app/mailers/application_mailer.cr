require "sendgrid"
require "dotenv"
Dotenv.load

abstract class ApplicationMailer
  property mail_from : String = ENV["MAILER_FROM"]
  property mail_subject : String?
  property mail_to : String?
  property mail_text : String?

  @client : Sendgrid::Client

  def initialize
    @client = Sendgrid::Client.new(
      ENV["SENDGRID_ENDPOINT"],
      ENV["SENDGRID_API_KEY"]
    )
  end

  def build_message
    message = Sendgrid::Message.new
    message.from = Sendgrid::Address.new(mail_from)
    message.to << Sendgrid::Address.new(mail_to.not_nil!)
    message.subject = mail_subject.not_nil!
    message.content = Sendgrid::Content.new(mail_text.not_nil!)
    message
  end

  def prod?
    ENV["ENV"] == "production"
  end

  def deliver!
    message = build_message
    if prod?
      @client.send message
    else
      puts "----------- SEND LETTER -----------"
      puts "FROM: #{message.from.inspect}"
      puts "TO: #{message.to.map(&.email)}"
      puts "SUBJECT: #{message.subject.inspect}"
      puts "CONTENT: #{message.content.inspect}"
      puts "----------- ----------- -----------"
    end
  end
end
