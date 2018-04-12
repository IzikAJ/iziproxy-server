require "./application_controller"

class StatsController < ApplicationController
  def action_show
    authorize_user!
    render "app/views/stats/show.slim"
  end
end
