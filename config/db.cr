require "dotenv"

Dotenv.load
# database connection path
DB_URL = "postgresql://#{ENV["DB_USER"]}:#{ENV["DB_PASS"]}@#{ENV["DB_HOST"]}:#{ENV["DB_PORT"]}/#{ENV["DB_NAME"]}"

# save this path to environment
ENV["DB_URL"] = DB_URL
ENV["DATABASE_URL"] = DB_URL
