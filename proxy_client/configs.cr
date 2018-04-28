require "yaml"

module ProxyClient
  class Configs
    LOCAL_HOST        = "LOCAL_HOST"
    LOCAL_PORT        = "LOCAL_PORT"
    REQUEST_SUBDOMAIN = "REQUEST_SUBDOMAIN"
    PROXY_ENDPOINT    = "PROXY_ENDPOINT"
    PROXY_PORT        = "PROXY_PORT"
    AUTH_TOKEN        = "AUTH_TOKEN"

    class DEFAULT
      LOCAL_HOST        = "localhost"
      LOCAL_PORT        = 3000
      REQUEST_SUBDOMAIN = ""

      PROXY_ENDPOINT = "connection.lvh.me"
      PROXY_PORT     = 9090
    end

    CONFIG_PATHS = %w(
      client_config.yml
      client_config.yaml
      #{ENV["HOME"]}/.izi_proxy/client_config.yml
      #{ENV["HOME"]}/.izi_proxy/client_config.yaml
    )

    getter config_path : String
    getter configs = {} of String => String | Int32 | Int64 | YAML::Type

    def config_path?
      CONFIG_PATHS.each do |name|
        return name if File.exists? name
      end
    end

    def load!
      data = YAML.parse(File.read(@config_path))
      data.each do |k, v|
        if key = k.to_s
          value = v.to_s
          ENV[key] = value

          case key
          when /_port$/i
            value = value.to_i64
          else
          end
          @configs[key] = value
        end
      end
    end

    def save!
      @configs.each do |k, v|
        ENV[k.to_s] = v.to_s
      end
      File.write(@config_path, @configs.to_yaml)
      puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
      puts "CONFIG SAVED:  #{@configs.inspect}"
      puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    end

    def update(key : String, value : String | Int32 | Int64)
      @configs[key] = value
      save!
    end

    def update(&block)
      yield @configs
      save!
    end

    def make_default!
      update do |conf|
        conf[LOCAL_HOST] = DEFAULT::LOCAL_HOST
        conf[LOCAL_PORT] = DEFAULT::LOCAL_PORT
        conf[REQUEST_SUBDOMAIN] = DEFAULT::REQUEST_SUBDOMAIN

        conf[PROXY_ENDPOINT] = DEFAULT::PROXY_ENDPOINT
        conf[PROXY_PORT] = DEFAULT::PROXY_PORT
      end
    end

    def initialize
      if path = config_path?
        # config file found
        @config_path = path
        load!
      else
        # no config file, create default one
        @config_path = CONFIG_PATHS[0]
        make_default!
      end
    end

    def self.load!
      instance
    end

    def self.instance
      @@INSTANCE ||= Configs.new
    end

    def self.update(key : String, value : String | Int32 | Int64)
      instance.update(key, value)
    end

    def self.update(&block)
      instance.update do |conf|
        yield conf
      end
    end
  end
end
