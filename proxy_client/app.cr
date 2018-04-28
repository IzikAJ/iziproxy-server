# require "faraday"
require "http/client"
require "socket"
require "json"
require "base64"
require "logger"

module ProxyClient
  VERSION = "1.0.0"

  class App
    LIMIT_ATTEMPTS = 2

    property host : String = "localhost"
    property subdomain : String?
    property? authorized = false

    getter log = Logger.new(STDOUT)
    getter reciver
    getter sender
    getter client

    property attempts = 0

    def initialize
      @log.level = Logger::ERROR
      # @log.level = Logger::WARN
      # @log.level = Logger::INFO

      @reciver = Reciver.new @log
      @sender = Sender.new @log

      @client = Pipe.new @log do |conf|
        conf.host = ENV["LOCAL_HOST"]
        conf.port = ENV["LOCAL_PORT"].to_i
      end

      @host = ENV["PROXY_ENDPOINT"] if ENV["PROXY_ENDPOINT"]

      unless (token = ENV["AUTH_TOKEN"]?) &&
             !token.blank?
        auth_token_error!
      end

      connect!
    end

    def auth_token_error!
      puts "!!! AUTH TOKEN NOT VALID !!!"
      puts "Please visit your IziProxy account, and get new one"
      exit
    end

    def authorize!(socket : TCPSocket)
      return if authorized?
      begin
        sender.send socket, :auth do |json|
          json.field :token, ENV["AUTH_TOKEN"]?.to_s
        end

        reciver.recive socket, :auth do |resp, error|
          if !error.nil?
            auth_token_error! if error["code"]? == "invalid"
            puts "AUTH ERROR: #{error["message"]? || error}" unless error.nil?
          elsif !resp.nil?
            @authorized = true
          end
        end
      rescue e
        log.error "AUTHORIZE ERROR #{e.message}"
      end
    end

    def request_namespace!(socket : TCPSocket, namespace : String?)
      # return if !subdomain.nil? && subdomain == namespace
      begin
        sender.send socket, :subdomain do |json|
          json.field :subdomain, namespace.to_s
        end

        reciver.recive socket, :subdomain do |resp, error|
          if error.nil? && resp
            @subdomain = resp["subdomain"]?.to_s
          else
            #
          end
        end
      rescue e
        log.error "NAMESPACE ERROR #{e.message}"
      end

      log.warn "SUBDOMAIN REGISTERED: #{subdomain.inspect}"
    end

    def request_namespace!(socket : TCPSocket)
      request_namespace!(socket, nil)
    end

    def connect!
      loop do
        break if @attempts >= LIMIT_ATTEMPTS
        @attempts += 1
        begin
          socket = TCPSocket.new(host, ENV["PROXY_PORT"]? || 9777)
          log.info "CONNECTION SUCCESS"

          # auth request
          authorize! socket
          next unless authorized?

          request_namespace! socket, subdomain || ENV["REQUEST_SUBDOMAIN"]?
          next if subdomain.nil?

          log.info "MAIN LOOP READY"

          # reset attempts on success connection
          @attempts = 0

          while line = socket.gets
            client.process socket, line
          end

          socket.close
          @authorized = false

          log.warn "SOCKET CLOSED"
        rescue e
          log.error "CONNECTION ERROR #{e.message}"
          sleep 1.second
        end
      end
    end
  end
end
