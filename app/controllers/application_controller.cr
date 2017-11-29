require "../*"

abstract class ApplicationController
  protected getter context : HTTP::Server::Context

  protected def user_signed_in?
    context.request.session.try(&.user?)
  end

  def initialize(@context)
  end
end
