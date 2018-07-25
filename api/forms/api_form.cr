require "../../app/lib/active/*"
require "../../app/lib/active/validators/*"

require "json"

abstract class ApiForm
  # simple accesible attribures implementation
  include Active::AccessibleAttributes

  # simple validation engine
  include Active::Validation
  # required validators
  include Active::Validators::EmailValidator
  include Active::Validators::PresenceValidator

  def self.from_body(context : HTTP::Server::Context) : ApiForm?
    if body = context.request.body
      puts "LOAD FROM BODY"
      form = self.from_json(body.gets_to_end)
      puts "LOADED: #{form.inspect}"
      return form
    end
  end

  def self.from_any(context : HTTP::Server::Context) : ApiForm?
    self.from_body(context)
  end
end
