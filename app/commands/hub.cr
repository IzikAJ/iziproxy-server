require "json"

module Commands
  alias CommandsHash = Hash(String, TcpCommand.class)

  class Hub
    INSTANCE = self.new
    getter commands : CommandsHash = CommandsHash.new

    getter app : ProxyServer = ProxyServer.instance

    def register(cmd : String, command : TcpCommand.class)
      commands[cmd] = command
    end

    def call(socket : Socket, client : Client, command : JSON::Any)
      kind = command["kind"]
      return unless commands.has_key?(kind.as_s)
      commands[kind.as_s].new(socket, client, command)
    end

    def self.register(cmd : String, command : TcpCommand.class)
      INSTANCE.register(cmd, command)
    end

    def self.call(socket : Socket, client : Client, command : JSON::Any)
      INSTANCE.call(socket, client, command)
    end

    def self.commands
      INSTANCE.commands
    end

    def self.configure
      yield INSTANCE
    end

    def instance
      INSTANCE
    end
  end
end

# load tcp commands to hub
require "./tcp/_command"
require "./tcp/*"

puts "TOTAL COMMANDS: #{Commands::Hub.commands.keys.inspect}"
