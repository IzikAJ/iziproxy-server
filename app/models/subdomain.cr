require "./base_model"

class Subdomain
  getter namespace : String, client_id : String

  def initialize(uuid : String, namespace : String)
    @client_id = uuid
    @namespace = namespace
  end
end
