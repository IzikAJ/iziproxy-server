require "./base"

module WS
  class LeaveCommand < BaseCommand
    def self.call(message : JSON::Any, socket : HTTP::WebSocket, session : Session, user : User, redis : Redis)
      if name = namespace(message, session, user)
        puts "LEAVE: #{name}"
        redis.unsubscribe name
      else
        puts "LEAVE FAILED: unknown kind"
      end
    end
  end
end

WS::Hub.register("leave", WS::LeaveCommand)
