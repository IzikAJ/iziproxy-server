# require "sinatra"
# require "sinatra/multi_route"
require "./app/server"
# require "byebug"

log = Logger.new(STDOUT)
# log.level = Logger::WARN
# log.level = Logger::ERROR
log.level = Logger::INFO

server = App::Server.new(log)

server.start
