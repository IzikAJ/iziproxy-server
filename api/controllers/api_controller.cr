require "../../app/controllers/application_controller"
require "../forms/api_form"

module Api
  abstract class ApiController < ApplicationController
    def initialize(@context)
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
