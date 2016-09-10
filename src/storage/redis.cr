class Storage::Redis
  getter keys

  def initialize(@redis : ::Redis::Client, @zset : String, @sampling : Int32, @keys : Array(String) = [] of String)
    @keys = load_keys if @keys.empty?
  end

  def load_keys
    zset = resolve_key(Time.now.epoch - 60)
    json = @redis.zrange(zset, -1, -1).first{ "" }.to_s.as(String)
    JSON.parse(json).as_h.keys.map(&.to_s).as(Array(String))
  rescue err
    puts "ERR: #{err} (#{self.class}#load_keys)".colorize.red
    %w( usr used writ free )
  end

  def search(epoch1, epoch2) : Array(String)
    keys  = [epoch1, epoch2].map{|e| resolve_key(e)}.uniq
    query = Query.new(keys, epoch1, epoch2, @sampling)

    lines = [] of String
    query.build.each do |plan|
      puts "-- Process  " + "-" * 50
      puts "ZRANGEBYSCORE #{plan.key} #{plan.epoch1} #{plan.epoch2}"
      result = @redis.zrangebyscore(plan.key, plan.epoch1, plan.epoch2)
      debug_cmd_result result
      result.each do |line|
        lines << line.to_s.as(String)
      end
    end

    return lines
  end
  
  private def resolve_key(epoch)
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
