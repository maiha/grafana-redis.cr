require "../spec_helper"

private def max(key, jqs)
  Engine::Max.max(key, jqs)
end

describe Engine::Max do
  describe "#max" do
    jsons = <<-EOF
      {"epoch":100,"usr":1,"1m":1.04,"odd":1,"even":null}
      {"epoch":101,"usr":2,"1m":1.25,"odd":null,"even":2}
      {"epoch":102,"usr":3,"1m":1.19,"odd":5}
      EOF
    jqs = jsons.strip.split(/\n/).map{|j| Jq.new(j)}

    it "(int)" do
      max("usr", jqs).should be_a(Int64)
      max("usr", jqs).should eq(3)
    end

    it "(float)" do
      max("1m", jqs).should be_a(Float64)
      max("1m", jqs).should eq(1.25)
    end

    it "(nil field)" do
      max("xxx", jqs).should eq(nil)
    end

    it "(ignore nil value)" do
      max("odd", jqs).should eq(5)
    end

    it "(ignore nil entry)" do
      max("even", jqs).should eq(2)
    end
  end

  describe "case of inconsistent types" do
    jsons = <<-EOF
      {"epoch":100,"foo":1.0,"bar":3}
      {"epoch":101,"foo":2,"bar":4.0}
      EOF
    jqs = jsons.strip.split(/\s+/m).map{|j| Jq.new(j)}

    it "find max value" do
      max("foo", jqs).should be_a(Int64)
      max("foo", jqs).should eq(2)

      max("bar", jqs).should be_a(Float64)
      max("bar", jqs).should eq(4.0)
    end
  end
end
