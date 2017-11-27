require "crinja"
require "dotenv"
require "../helpers/*"
require "../models/*"

Dotenv.load

module App
  module Views
    class Base
      @env = Crinja::Environment.new
      @params = {} of String => String | Array(String)
      @session_token : String | Nil
      @session : App::Models::Session | Nil

      def initialize(@app : App::Server, @context : HTTP::Server::Context)
        @session_token = nil
        user_session!
      end

      def user_signed_in?
        return true
        return false if @session.nil?
        @app.log.warn "user_signed_in? #{@session.inspect} #{!@session.not_nil!.user_id.nil?}"
        return !@session.not_nil!.user_id.nil?
      end

      protected def user_session!
        @cookies = HTTP::Cookies.from_headers(@context.request.headers)
        if (cookies = @cookies) && (cookie = cookies[ENV["SESSION_KEY"]?]?)
          @session_token = cookie.value
        end
        if @session_token.nil?
          write_session_cookies if @session_token.nil? || @session.nil?
        else
          @session = App::Models::Session.first(
            "WHERE token = ? AND (expired = ? OR expired = ?)",
            [@session_token, false, nil]
          )
          write_session_cookies if @session.nil?
        end
      end

      protected def write_session_cookies
        cookies = HTTP::Cookies.new
        @session = App::Models::Session.new(user_id: nil, expired: false)
        if session = @session
          session.save
          cookies << HTTP::Cookie.new(
            ENV["SESSION_KEY"],
            session.token.not_nil!,
            http_only: true
          )
        end
        cookies.add_response_headers(@context.response.headers)
      end

      protected def render(filename : String, status : Int32 = 200)
        # @@env ||= Crinja::Environment.new
        # @@params ||= {} of String => String | Array(String)
        template = "N/A"
        if env = @env
          env.loader = Crinja::Loader::FileSystemLoader.new("app/views/")
          template = env.get_template(filename)

          @context.response.status_code = status || 200
          @context.response.content_type = "text/html"

          @context.response.print template.render(@params)
        end
      end
    end
  end
end

require "./welcome/controller"
