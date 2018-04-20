class RedisLogService
  SYSTEM  = 0
  GLOBAL  = 1
  USER    = 2
  SESSION = 3
  CLIENT  = 4

  # cache ttl - 5 min
  LOG_CACHE_TTL = 5 * 60

  getter redis

  def log(message : String, kind = GLOBAL, target : Int32 | Int64 | String | Nil = nil)
    name = channel_name(kind, target)
    # publish message
    @redis.publish(name, message)
    # # store it in cache for some time
    # ext_name = "#{name}@#{Random.rand}"
    # @redis.set(ext_name, message)
    # @redis.expire(ext_name, LOG_CACHE_TTL)
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
    @redis = Redis.new
  end
end
