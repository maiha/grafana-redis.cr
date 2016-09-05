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

  def search(epoch1, epoch2, keys : Array(String), size) : Hash(String, Grafana::Datapoints)
    values = [] of ::Redis::RedisValue
    zsets = [epoch1, epoch2].map{|e| zrange_key_for(e)}.sort.uniq
    zsets.each do |zset|
      puts "-- Process  " + "-" * 50
      puts "ZRANGEBYSCORE #{zset} #{epoch1} #{epoch2}"
      result = @redis.zrangebyscore(zset, epoch1, epoch2)
      debug_cmd_result result
      values += result
    end
    
    # squeeze massive values into size-ed lines
    degree = [values.size / size, 1].max
    lines = [] of String
    values.each_with_index do |line, i|
      if i % degree == 0
        lines << line.to_s.as(String)
      end
    end

    results = Hash(String, Grafana::Datapoints).new
    keys.each do |key|
      points = Grafana::Datapoints.new
      path = ".#{key}"
      lines.each do |json|
        jq = Jq.new(json)
        e  = jq[".epoch"].as_i64
        v  = as_value(jq[path]?)
        points << {v, e*1000}
      end
      results[key] = points
    end
    return results
  end

  private def zrange_key_for(epoch)
    Time.epoch(epoch).to_local.to_s(@zset)
  end

  private def as_value(v : Jq?) : Grafana::DataValue
    case v.try(&.raw).to_s
    when /\A\d+\Z/
      v.not_nil!.as_i64
    when /\./
      v.not_nil!.as_f
    else
      nil
    end
  end

  private def debug_cmd_result(lines)
    if lines.size > 0
      puts "  -> #{lines.size} items".colorize.green
    else
      puts "  -> #{lines.size} items".colorize.yellow
    end
  end
end
