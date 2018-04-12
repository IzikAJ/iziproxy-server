require "../config/db"
require "pg"
require "micrate"

Micrate::Cli.run_dbversion
Micrate::Cli.run_up
Micrate::Cli.run_status
Micrate::Cli.run_dbversion
