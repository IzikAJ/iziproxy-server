module App
  module Middleware
    class SubdomainMatcher
      include HTTP::Handler

      def initialize(@host : String, @rule : String, @handler : HTTP::Handler)
        make_regex!
      end

      def call(env : HTTP::Server::Context)
        host = env.request.host.to_s
        if @matcher =~ host
          subdomain = host.gsub(@tail.not_nil!, "")
          env.request.subdomain = subdomain
          @handler.call(env)
        else
          call_next(env)
        end
      end

      private def make_regex!
        @matcher = Regex.new "^#{normalize_rule(@rule)}$", Regex::Options::IGNORE_CASE
        @tail = Regex.new "\.#{@host.gsub(".", "\.")}$", Regex::Options::IGNORE_CASE
      end

      private def normalize_rule(rule : String) : String
        @rule.not_nil!.gsub(".", "\.").gsub("*", "[a-z0-9_-]+").gsub("@", @host)
      end
    end
  end
end
