require "socket"
require "http/server"
require "json"
require "secure_random"
require "base64"
require "logger"
#
require "./headers"
require "./command_parser"

require "./models/client"
require "./models/subdomain"
#
require "./headers"
require "./tcp_server"

# require "./http_server"

module App
  class Server
    getter :log, :subdomains, :clients, :responses,
      :tcp_server, :http_server,
      :http_port, :tcp_port, :host

    property :tcp_server

    def initialize(@log : Logger)
      @clients = {} of String => Models::Client
      @subdomains = {} of String => Models::Subdomain
      @responses = {} of (String | JSON::Any) => JSON::Any

      @http_port = 8080
      @tcp_port = 9777
      @host = "lvh.me"

      if server = @tcp_server = TcpServer.new(self, @log)
        server.port = @tcp_port
      end
    end

    def start
      @tcp_server.not_nil!.start
    end
  end
end
