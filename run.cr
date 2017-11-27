require "kemal"
require "./app/*"

class HTTP::Request
  property subdomain
  setter subdomain
  getter subdomain : String | Nil
end

host = "lvh.me"

log = Logger.new(STDOUT)
server = App::Server.new(log)
# filters must be inserted
# from most common
# to specific one
Kemal.config.add_filter_handler(
  App::SubdomainMatcher.new(host, "*.@", App::ProxySubdomainHandler.new(server))
)

get "/" do
  "Hello world \n #{server.subdomains.inspect}"
end

server.start
Kemal.run
