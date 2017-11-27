require "../base"
require "../../server"

module App
  module Views
    class Welcome < App::Views::Base
      @namespace = "welcome"

      def initialize(@app : App::Server, @context : HTTP::Server::Context)
        # @app.log.warn "!!!!!! #{@context.request.headers.inspect}"
        super @app, @context
      end

      def show
        if user_signed_in?
          @params["subdomains"] = @app.subdomains.keys
          @params["clients"] = @app.clients.keys
          render "#{@namespace}/show.html.j2"
        else
          render "#{@namespace}/denied.html.j2"
        end
      end
    end
  end
end
