require "option_parser"
require "optarg"

module ProxyClient
  class Options < Optarg::Model
    class COMMAND
      START  = "start"
      RUN    = "run"
      CONFIG = "config"
      RESET  = "reset"
      AUTH   = "auth"
    end

    string %w(-s --subdomain)
    string %w(-p --port)
    string %w(-d --domain)
    bool %w(--non-default-subdomain), default: true, not: "-S"
    bool %w(--non-default-port), default: true, not: "-P"
    bool %w(--non-default-domain), default: true, not: "-D"

    arg %w(command)
    arg %w(token)

    on("-v") { version }
    on("--version") { version }
    on("-h") { help }
    on("--help") { help }

    def version
      puts default_header
      puts "  Client Version: #{ProxyClient::VERSION}"
      exit
    end

    def help
      puts default_header
      puts [
        "  Usage: client [COMMAND] [PARAMS]",
        "",
        "    commands:",
        "      start, run [PARAMS]    run client (empty command also works same)",
        "      auth [TOKEN]           authorize client or remove saved token",
        "      config [PARAMS]        configure client prefences without running",
        "      reset                  reset client options to default",
        "",
        "    run params:",
        "      -s NAME (--subdomain=NAME)    preffered subdomain  (-S to reset)",
        "      -p PORT (--port=PORT)         local server port    (-P to reset)",
        "      -d DOMAIN (--domain=DOMAIN)   local server domain  (-D to reset)",
      ].join("\n")
      exit
    end

    def default_header
      [
        "IziProxy, the most izi proxy ever",
        "(LocalProxy & ngrok alternative)",
      ].join("\n")
    end

    def usage_header
      [
        default_header,
        "  Usage: client [arguments]",
      ].join("\n")
    end

    def param(name, value)
      #
      puts "PARAM [#{name}]: #{value}"
    end

    def process_params!
      Configs.update do |conf|
        if subdomain = self.subdomain?
          conf[Configs::REQUEST_SUBDOMAIN] = subdomain
        elsif !self.non_default_subdomain?
          conf[Configs::REQUEST_SUBDOMAIN] = Configs::DEFAULT::REQUEST_SUBDOMAIN
        end
        if port = self.port?
          conf[Configs::LOCAL_PORT] = port
        elsif !self.non_default_port?
          conf[Configs::LOCAL_PORT] = Configs::DEFAULT::LOCAL_PORT
        end
        if domain = self.domain?
          conf[Configs::LOCAL_HOST] = domain
        elsif !self.non_default_domain?
          conf[Configs::LOCAL_HOST] = Configs::DEFAULT::LOCAL_HOST
        end
      end
    end

    def run_client!
      process_params!
      puts "Running client..."
      App.new
    end

    def process_commands!
      if cmd = self.command?
        case cmd
        when COMMAND::CONFIG
          puts "Update configuration..."
          process_params!
        when COMMAND::RESET
          puts "Reset configuration to default params"
          Configs.instance.make_default!
        when COMMAND::AUTH
          if token = self.token?
            puts "Update auth token"
            Configs.update(Configs::AUTH_TOKEN, token)
          else
            Configs.update(Configs::AUTH_TOKEN, "")
            puts "No token recived, clear it"
          end
        when COMMAND::START, COMMAND::RUN
          return run_client!
        end
      else
        return run_client!
      end
      exit
    end

    def self.load!
      instance.process_commands!
    end

    def self.instance
      @@instance ||= Options.parse(ARGV).as(Options)
    rescue ex
      puts "ERROR: #{ex}"
      @@instance ||= Options.parse(%w()).as(Options)
    end
  end
end
