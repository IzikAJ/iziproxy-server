class RedisLogService
  SYSTEM  = 0
  GLOBAL  = 1
  USER    = 2
  SESSION = 3
  CLIENT  = 4

  getter redis

  def log(message : String, kind = GLOBAL, target : Int32 | Int64 | String | Nil = nil)
    name = channel_name(kind, target)
    # publish message
    @redis.publish(name, message)
  end

  def channel_name(kind = GLOBAL, target : Int32 | Int64 | String | Nil = nil)
    return "kind_#{kind}_target__#{target}" if target && kind != GLOBAL
    "kind_#{kind}__no_target"
  end

  def self.log(message : String, kind = GLOBAL, target : Int32 | Int64 | String | Nil = nil)
    instance.log(message, kind, target)
  end

  def self.name(kind = GLOBAL, target : Int32 | Int64 | String | Nil = nil)
    instance.channel_name(kind, target)
  end

  def self.instance
    @@instance ||= new
  end

  def initialize
    @redis = Redis.new("127.0.0.1", 6379, nil, nil, 0, ENV["REDIS_URL"]?)
  end
end
