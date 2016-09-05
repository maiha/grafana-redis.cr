require "../spec_helper"

private def plan(key, epoch1, epoch2)
  Storage::Query::Plan.new(key, epoch1, epoch2)
end

describe Storage::Query do
  describe "#build" do
    it "(when multiple keys exist with small entries)" do
      query = Storage::Query.new(["a", "b"], 1, 100, 3600)
      query.build.should eq([plan("a",1,100), plan("b",1,100)])
    end

    it "(when multiple keys exist with large entries)" do
      query = Storage::Query.new(["a", "b"], 1, 10000, 3600)
      query.build.should eq([plan("a",1,1800), plan("b",8201,10000)])
    end

    it "(when all data are stored in one key with small entries)" do
      query = Storage::Query.new(["a"], 1, 100, 3600)
      query.build.should eq([plan("a",1,100)])
    end

    it "(when all data are stored in one key with large entries)" do
      query = Storage::Query.new(["a"], 1, 10000, 3600)
      query.build.should eq([plan("a",1,1800), plan("a",8201,10000)])
    end
  end
end
