require "dotenv"
require "pg"
require "crecto"

Dotenv.load
# database connection path
DB_URL = "postgresql://#{ENV["DB_USER"]}:#{ENV["DB_PASS"]}@#{ENV["DB_HOST"]}:#{ENV["DB_PORT"]}/#{ENV["DB_NAME"]}"

# save this path to environment
ENV["DB_URL"] = DB_URL
ENV["DATABASE_URL"] = DB_URL

module Repo
  extend Crecto::Repo

  config do |conf|
    conf.adapter = Crecto::Adapters::Postgres
    conf.database = ENV["DB_NAME"]
    conf.hostname = ENV["DB_HOST"]
    conf.username = ENV["DB_USER"]
    conf.password = ENV["DB_PASS"]
    conf.port = ENV["DB_PORT"].to_i
    # you can also set initial_pool_size, max_pool_size, max_idle_pool_size,
    #  checkout_timeout, retry_attempts, and retry_delay
  end
end

# shortcut variables, optional
Crecto::Repo::Query
Crecto::Multi
