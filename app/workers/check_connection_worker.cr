require "sidekiq"
require "../models/connection"

class CheckConnectionWorker
  include Sidekiq::Worker

  def perform(conn_id : Int64)
    puts "ACTION PERFORMED", Time.now
    Connection.all(
      "WHERE id = ? AND user_id = ?",
      [conn_id, nil]
    ).clear
  end
end
