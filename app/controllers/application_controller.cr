require "../*"
require "../helpers/*"

abstract class ApplicationController
  protected getter context : HTTP::Server::Context
  include ApplicationHelper

  def initialize(@context)
  end

  #
  protected def user_signed_in?
    context.request.session.try(&.user?)
  end

  protected def current_user
    context.request.session.try(&.user)
  end

  protected def status_code!(status_code : Int32 = 200)
    @context.response.status_code = status_code
  end

  protected def controller
    self.class
  end

  protected def redirect_to(path : String, status_code : Int32 = 302)
    @context.response.headers.add("Location", path)
    @context.response.status_code = status_code
    @context.response.close
  end

  protected def authorize_user! : Bool
    unless user_signed_in?
      redirect_to "/auth/session/new"
      return false
    end
    return true
  end

  protected def redirect_if_authorized!(path : String = "/")
    if user_signed_in?
      redirect_to path
      return
    end
  end
end
