require "../*"
require "../helpers/*"

abstract class ApplicationController
  protected getter context : HTTP::Server::Context
  include ApplicationHelper

  macro before_action(*methods, params = {} of String | Symbol => String | Symbol | Bool | Number)
    def run_before!
      {% for method in methods %}
        return unless self.try(&.{{method.id}})
      {% end %}
    end

    def initialize(@context)
      run_before!
    end
  end

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
      redirect_to "/login"
      return false
    end
    return true
  end
end
