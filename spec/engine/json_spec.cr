require "../spec_helper"

private def process(keys, lines, limit)
  Engine::Json.new.process(keys, lines, limit)
end

describe Engine::Json do
  jsons = <<-EOF
    {"usr":1,"1m":1.04,"epoch":11}
    {"usr":2,"1m":1.19,"epoch":12}
    {"usr":3,"1m":1.25,"epoch":13}
    EOF
  lines = jsons.strip.split(/\s+/m)

  describe "#process" do
    it "(when lines < limit)" do
      process(["usr", "1m"], lines, 10).should eq({
        "usr" => [{1, 11000}, {2, 12000}, {3, 13000}],
        "1m"  => [{1.04, 11000}, {1.19, 12000}, {1.25, 13000}],
      })      
    end

    it "(when lines > limit)" do
      process(["usr", "1m"], lines, 2).should eq({
        "usr" => [{2, 11000}, {3, 13000}],
        "1m"  => [{1.19, 11000}, {1.25, 13000}],
      })      
    end

    it "(when all into 1)" do
      process(["usr", "1m"], lines, 1).should eq({
        "usr" => [{3, 11000}],
        "1m"  => [{1.25, 11000}],
      })      
    end
  end
end
