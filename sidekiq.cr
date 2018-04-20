require "sidekiq/cli"

require "./app/workers/*"

cli = Sidekiq::CLI.new

server = cli.configure do |config|
  # middleware would be added here
end

channel = Channel(String).new

cli.run(server)
