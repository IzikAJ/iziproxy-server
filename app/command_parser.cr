require "json"
require "logger"
#
require "./models/client"
require "./commands/*"

module App
  class CommandParser
    property :app, :log

    def initialize(@app : App::Server, @log : Logger)
    end

    def parse(client : Models::Client, command : JSON::Any)
      @log.info "COMMAND: #{command.inspect}"
      new_subdomain = command["subdomain"].as_s
      if @app.subdomains[new_subdomain]?
        @log.error "SUBDOMAIN \"#{new_subdomain}\" NOT AVAILABLE"
      else
        client.register_subdomain Models::Subdomain.new(client.uuid, new_subdomain)
      end

      resp = JSON.build do |json|
        json.object do
          json.field :command do
            json.object do
              json.field :subdomain, client.subdomain.try(&.namespace)
            end
          end
        end
      end
      @log.error "SUBDOMAIN ANS #{client.subdomain.try(&.namespace)}"

      resp
    end
  end
end
