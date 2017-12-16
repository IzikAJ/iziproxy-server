# require "faraday"
require "dotenv"
require "./proxy_client/*"
require "optarg"

Dotenv.load

class ClientOptions < Optarg::Model
  string "-p", default: "3000"
  string "-s"
  string "-d", default: "localhost"

  VERSION = "1.0.0"

  on("-v") { version }
  on("--version") { version }
  on("-h") { help }
  on("--help") { help }

  property port : String = "3000"
  property domain : String = "localhost"
  property subdomain : String?

  def version
    puts "version: #{VERSION}"
    exit
  end

  def help
    puts "LocalProxy & ngrok alternative"
    puts
    puts "Available modifiers:"
    puts "  -s - request preferred subdomain (default: empty - random)"
    puts "  -p - set port for target local server (default: 3000)"
    puts "  -d - set domain for target local server (default: localhost)"
    puts
    puts "  -v (--version) - show program version"
    puts "  -h (--help)    - show this window"
    exit
  end

  def start!
    @port = self.p if self.p?
    @subdomain = self.s if self.s?
    @domain = self.d if self.d?

    ENV["LOCAL_HOST"] = @domain
    ENV["LOCAL_PORT"] = @port
    ENV["REQUEST_SUBDOMAIN"] = @subdomain

    ProxyClient::App.new
  end
end

# start app by recived args
ClientOptions.parse(ARGV).start!
