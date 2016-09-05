record Storage::Query,
  zsets    : Array(String),
  epoch1   : Int32,
  epoch2   : Int32,
  sampling : Int32 do

  record Plan, key : String, epoch1 : Int32, epoch2 : Int32

  def build
    plans = Array(Plan).new
    small = (epoch2 - epoch1) <= sampling
    width = (sampling.to_f/2).ceil.to_i - 1

    if zsets.size > 1
      if small
        # when multiple keys exist with small entries
        plans << Plan.new(zsets[0], epoch1, epoch2)
        plans << Plan.new(zsets[1], epoch1, epoch2)
      else
        # when multiple keys exist with large entries
        plans << Plan.new(zsets[0], epoch1, epoch1 + width)
        plans << Plan.new(zsets[1], epoch2 - width, epoch2)
      end
    else
      if small
        # when all data are stored in one key with small entries
        plans << Plan.new(zsets[0], epoch1, epoch2)
      else
        # when all data are stored in one key with large entries
        plans << Plan.new(zsets[0], epoch1, epoch1 + width)
        plans << Plan.new(zsets[0], epoch2 - width, epoch2)
      end
    end
    return plans
  end
end
