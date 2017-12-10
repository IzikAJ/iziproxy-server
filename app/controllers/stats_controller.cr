require "../*"
require "./application_controller"

class StatsController < ApplicationController
  def show
    authorize_user!
    render "app/views/stats/show.slim"
  end
end
