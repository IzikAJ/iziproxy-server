require "../config/db"
require "pg"
require "micrate"

puts Micrate::Cli.run_dbversion
puts Micrate::Cli.run_up
puts Micrate::Cli.run_status
puts Micrate::Cli.run_dbversion
