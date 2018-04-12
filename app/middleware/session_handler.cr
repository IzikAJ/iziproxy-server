require "../queries/session_query"
require "../models/*"

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
        session = SessionQuery.new.find(session_token)
        if session.nil?
          write_session_cookies(env)
        else
          session.update_expiration_time! if session.expires_soon?
          env.request.session = session
        end
      end
    end

    protected def write_session_cookies(env : HTTP::Server::Context)
      cookies = HTTP::Cookies.new
      session = Session.new(user_id: nil, expired_at: Session::EXPIRE_TIMEOUT.from_now)
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
