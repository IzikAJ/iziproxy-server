require "../controllers/application_controller"

module Api
  abstract class ApiController < ApplicationController
  end
end

require "./session_controller"
