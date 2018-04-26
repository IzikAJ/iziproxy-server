# require "json"
require "./ws/base"

module WS
  alias CommandsHash = Hash(String, BaseCommand.class)

  KIND_FIELD = "kind"
  TYPE_FIELD = "type"

  ARRAY_TYPE = "array"

  class Hub
    INSTANCE = self.new
    getter commands : CommandsHash = CommandsHash.new

    def register(cmd : String, command : BaseCommand.class)
      commands[cmd] = command
    end

    def self.register(cmd : String, command : BaseCommand.class)
      INSTANCE.register(cmd, command)
    end

    def call(message : JSON::Any, socket : HTTP::WebSocket, session : Session, user : User, redis : Redis)
      if (kind = message[TYPE_FIELD].as_s) &&
         (commands.has_key?(kind))
        commands[kind].call(message, socket, session, user, redis)
      end
    end

    def self.call(message : JSON::Any, socket : HTTP::WebSocket, session : Session, user : User, redis : Redis)
      INSTANCE.call(message, socket, session, user, redis)
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

# load ws commands to hub
require "./ws/*"

puts "TOTAL WS COMMANDS: #{WS::Hub.commands.keys.inspect}"
