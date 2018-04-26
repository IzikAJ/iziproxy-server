require "sidekiq"
require "../models/connection"
require "../models/request_item"

class ClientCleanerWorker
  include Sidekiq::Worker

  def perform(client_uuid : String)
    puts "ClientCleaner - ACTION PERFORMED", Time.now
    Connection.all(
      "WHERE client_uuid = ?",
      [client_uuid]
    ).clear
    RequestItem.all(
      "WHERE client_uuid = ?",
      [client_uuid]
    ).clear
  end
end
