require "crouter"

require "./proxy_server"
require "./serializers/*"
require "../api/core"

class HttpServer
  property :commander

  def self.instance
    @@instance ||= new
  end

  def self.run
    self.instance

    # Api::Core.draw_routes!
  end
end
