require "socket"
require "http/server"
require "json"
require "secure_random"
require "base64"
#
require "./models/client"
require "./models/subdomain"
#
alias SubdomainsHash = Hash(String, Subdomain)
alias ClientsHash = Hash(String, Client)
alias ResponsesHash = Hash(String | JSON::Any, JSON::Any)

class ProxyServer
  getter subdomains : SubdomainsHash = SubdomainsHash.new
  getter clients : ClientsHash = ClientsHash.new
  getter responses : ResponsesHash = ResponsesHash.new

  property http_port : Int32 = 9000
  property tcp_port : Int32 = 9777
  property host : String = "lvh.me"

  def self.instance
    @@instance ||= new
  end

  def self.configure
    yield self.instance
  end

  def self.start
    self.instance.start
  end

  def configure
    yield self
  end
end
