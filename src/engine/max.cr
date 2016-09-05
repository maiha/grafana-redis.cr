module Engine::Max
  def self.max(key, jqs) : Grafana::DataValue
    vals = extract(key, jqs).map{|v| as_value(v)}.compact.uniq
    if vals.empty?
      return nil
    else
      return vals.max
    end
  end

  private def self.extract(key, jqs)
    path = ".#{key}"
    jqs.map(&.[path]?).compact
  end

  private def self.as_value(v : Jq?) : Grafana::DataValue
    case v.try(&.raw).to_s
    when /\A\d+\Z/
      v.not_nil!.as_i64
    when /\./
      v.not_nil!.as_f
    else
      nil
    end
  end
end
