require "../../app/models/session"

class HTTP::Request
  # add subdomain to request
  property subdomain
  setter subdomain
  getter subdomain : String | Nil

  # add session to request
  property session
  setter session
  getter session : Session | Nil
end
