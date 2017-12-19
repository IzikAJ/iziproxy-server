require "./base_model"
require "./subdomain"
require "../proxy_server"

class Client
  SUBDOMAIN_SIZE = 10
  AUTH_TIMEOUT   = 1.minute

  getter server : ProxyServer = ProxyServer.instance
  getter uuid, socket, subdomain
  property user : User?
  property created_at : Time

  def expired?
    @user.nil? && @created_at < AUTH_TIMEOUT.ago
  end

  def authorized?
    !@user.nil?
  end

  def initialize(socket : TCPSocket)
    @uuid = SecureRandom.uuid
    @socket = socket
    @created_at = Time.now

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
