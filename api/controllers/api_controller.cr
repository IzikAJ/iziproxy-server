require "../../app/helpers/*"
require "../forms/api_form"

module Api
  abstract class ApiController
    include ApplicationHelper

    protected getter context : HTTP::Server::Context
    protected getter params : HTTP::Params

    def respond(data)
      context.response.print data.to_json
    end

    def initialize(@context, @params)
      @context.response.content_type = "application/json"
    end

    def fail!(code = 422, message = "sorry")
      status_code! 422
      "sorry"
    end

    def form_error!(failed_form : ApiForm | Nil)
      status_code! 422
      if form = failed_form
        {
          errors: form.try(&.errors),
        }.to_json
      else
        {
          errors: {base: ["server error"]},
        }.to_json
      end
    end
  end
end

require "./session_controller"
require "./profile_controller"
require "./accounts/*"
