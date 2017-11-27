require "../models/*"

module App
  module Middleware
    class SessionHandler
      include HTTP::Handler

      property session_key
      getter session_key : String

      def initialize(@session_key : String)
      end

      def call(env : HTTP::Server::Context)
        # env.request.session = nil
        user_session!(env)

        puts "!!!!! SESSION: #{env.request.session.inspect} !!!!!"
        call_next(env)
      end

      protected def user_session!(env : HTTP::Server::Context)
        session_token = nil
        session = nil
        cookies = HTTP::Cookies.from_headers(env.request.headers)
        if cookies && (cookie = cookies[@session_key]?)
          session_token = cookie.value
        end

        if session_token.nil?
          write_session_cookies(env)
        else
          session = App::Models::Session.first(
            "WHERE token = ? AND (expired = ? OR expired = ?)",
            [session_token, false, nil]
          )
          if session.nil?
            write_session_cookies(env)
          else
            env.request.session = session
          end
        end
      end

      protected def write_session_cookies(env : HTTP::Server::Context)
        cookies = HTTP::Cookies.new
        session = App::Models::Session.new(user_id: nil, expired: false)
        if session
          session.save
          cookies << HTTP::Cookie.new(
            @session_key,
            session.token.not_nil!,
            http_only: true
          )
          env.request.session = session
        end
        cookies.add_response_headers(env.response.headers)
      end
    end
  end
end
