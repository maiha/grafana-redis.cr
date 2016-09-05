class Storage::Redis
  getter keys

  def initialize(@redis : Redis::Client, @zset : String, @keys : Array(String) = [] of String)
    @keys = load_keys if @keys.empty?
  end

  def load_keys
    sample = Time.now.epoch - 60
    zset = zrange_key_for(sample)
    json = @redis.zrange(zset, -1, -1).first{ "" }.to_s.as(String)
    JSON.parse(json).as_h.keys.map(&.to_s).as(Array(String))
  rescue err
    puts "ERR: #{err} (#{self.class}#load_keys)".colorize.red
    %w( usr used writ free )
  end

  def search(epoch1, epoch2, key, size) : Array(Tuple(Int64, Int64))
    results = [] of ::Redis::RedisValue
    zsets = [epoch1, epoch2].map{|e| zrange_key_for(e)}.sort.uniq
    zsets.each do |zset|
      puts "-- Process  " + "-" * 50
      puts "ZRANGEBYSCORE #{zset} #{epoch1} #{epoch2}"
      result = @redis.zrangebyscore(zset, epoch1, epoch2)
      debug_cmd_result result
      results += result
    end

    # squeeze lines to size
    degree = [results.size / size, 1].max
    lines = [] of String
    results.each_with_index do |line, i|
      if i % degree == 0
        lines << line.to_s.as(String)
      end
    end

    points = [] of Tuple(Int64, Int64)
    path = ".#{key}"
    lines.each do |json|
      jq = Jq.new(json)
      e  = jq[".epoch"].as_i64
      v  = jq[path].as_i64
      points << {v, e*1000}
    end
    return points
  end

  private def zrange_key_for(epoch)
    Time.epoch(epoch).to_local.to_s(@zset)
  end

  private def debug_cmd_result(lines)
    if lines.size > 0
      puts "  -> #{lines.size} items".colorize.green
    else
      puts "  -> #{lines.size} items".colorize.yellow
    end
  end
end
