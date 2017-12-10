require "./base_model"
require "./subdomain"

class Client
  getter :uuid, :socket, :subdomain

  SUBDOMAIN_SIZE = 10

  def initialize(@server : Server, socket : TCPSocket)
    @uuid = SecureRandom.uuid
    @socket = socket

    register_subdomain(Subdomain.new(@uuid, random_subdomain))
  end

  def register_subdomain(subdomain : Subdomain)
    if server = @server
      if curr_subdomain = @subdomain
        server.subdomains.delete curr_subdomain.namespace
      end
      server.subdomains[subdomain.namespace] = subdomain
      @subdomain = subdomain
    end
  end

  def random_subdomain
    SecureRandom.urlsafe_base64.downcase[0..SUBDOMAIN_SIZE]
  end
end
