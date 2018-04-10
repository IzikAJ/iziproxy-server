require "./base_model"
require "./subdomain"
require "../proxy_server"
require "uuid"

class Client
  SUBDOMAIN_SIZE = 10
  AUTH_TIMEOUT   = 1.minute

  getter server : ProxyServer = ProxyServer.instance
  getter uuid : String
  getter socket
  getter subdomain : Subdomain
  property user : User?
  property created_at : Time

  def expired?
    @user.nil? && @created_at < AUTH_TIMEOUT.ago
  end

  def authorized?
    !@user.nil?
  end

  def log_requests?
    user && user.not_nil!.log_requests
  end

  def initialize(socket : TCPSocket)
    @uuid = UUID.random.to_s
    @subdomain = Subdomain.new(@uuid, random_subdomain)
    @socket = socket
    @created_at = Time.now

    register_subdomain(@subdomain)
  end

  def free_subdomain!(subdomain : Subdomain)
    server.subdomains.delete subdomain.namespace
  end

  def register_subdomain(subdomain : Subdomain)
    if server = @server
      if curr_subdomain = @subdomain
        free_subdomain! curr_subdomain
      end
      server.subdomains[subdomain.namespace] = subdomain
      @subdomain = subdomain
    end
  end

  def random_subdomain
    Random::Secure.urlsafe_base64.downcase[0..SUBDOMAIN_SIZE]
  end
end
