require "logger"

class AppLogger
  property logger : Logger

  def initialize
    @logger = Logger.new(STDOUT)
  end

  def self.instance
    @@instance ||= new
  end

  macro delegate_any(*methods)
    {% for method, index in methods %}
      def self.{{method}}(*args)
        self.instance.logger.{{method}}(*args)
      end
    {% end %}
  end

  delegate_any debug, info, warn, error, fatal

  def self.configure
    yield instance
  end

  def configure
    yield self
  end
end
