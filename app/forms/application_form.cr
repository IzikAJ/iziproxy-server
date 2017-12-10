require "kemal/param_parser"
require "../lib/active/*"
require "../lib/active/validators/*"

abstract class ApplicationForm
  # simple accesible attribures implementation
  include Active::AccessibleAttributes

  # simple validation engine
  include Active::Validation
  # required validators
  include Active::Validators::EmailValidator
  include Active::Validators::PresenceValidator
end
