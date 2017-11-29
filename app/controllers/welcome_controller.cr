require "../*"
require "./application_controller"

class WelcomeController < ApplicationController
  def show
    render "app/views/welcome/show.slim"
  end
end
