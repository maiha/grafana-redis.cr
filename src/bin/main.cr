require "../grafana-redis"

class Main
  include Opts

  VERSION = Shard.version
  PROGRAM = Shard.program
  ARGS    = "config.toml"

  option version : Bool, "--version", "Print the version and exit", false
  option help    : Bool, "--help"   , "Output this help and exit" , false

  @config : TOML::Config?
  getter! config
  delegate str, str?, strs, i32, bool, to: config
  
  def run
    @config = TOML::Config.parse_file(args.shift { die "config not found!" })

    host = str("httpd/host")
    port = i32("httpd/port")

    httpd = Servers::Redis.new(host: host, port: port, storage: storage, limit: i32("engine/limit"))
    httpd.start
  end

  private def redis
    Redis::Client.new(str("redis/host"), i32("redis/port"), password: str?("redis/pass"))
  end

  private def storage
    zset = str("redis/zset").gsub(/__host__/, System.hostname)
    Storage::Redis.new(redis, zset, i32("redis/sampling"))
  end
end

Main.run
