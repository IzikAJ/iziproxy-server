require "./base_model"

class Subdomain
  getter :namespace, :client_id

  def initialize(uuid : String, namespace : String)
    @client_id = uuid
    @namespace = namespace
  end
end
