class Engine::Json
  def process(keys : Array(String), lines : Array(String), limit : Int32) : Hash(String, Grafana::Datapoints)
    results = Hash(String, Grafana::Datapoints).new

    # squeeze massive values into size-ed lines
    size = [(lines.size.to_f / limit).ceil.to_i, 1].max

    lines.in_groups_of(size) do |chunk|
      aggregate(keys, chunk) do |key, point|
        results[key] ||= Grafana::Datapoints.new
        results[key] << point
      end
    end

    return results
  end

  private def aggregate(keys, jsons)
    jqs = jsons.compact.map{|s| Jq.new(s)}
    return if jqs.empty?

    # ignore if epoch is missing
    epoch = jqs.map(&.[".epoch"]?.try(&.as_i64)).compact.first { return }
    
    keys.each do |key|
      max = Max.max(key, jqs)
      yield(key, Grafana::Datapoint.new(max, epoch*1000))
    end
  end
end
