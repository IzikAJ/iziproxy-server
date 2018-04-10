require "../../app/controllers/application_controller"

module Api
  abstract class ApiController < ApplicationController
    def initialize(@context)
      @context.response.content_type = "application/json"
    end
  end
end

require "./session_controller"
require "./profile_controller"
require "./servers_controller"
