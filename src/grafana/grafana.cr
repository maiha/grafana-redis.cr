module Grafana
  alias DataValue  = (Int64|Float64|Nil)
  alias Datapoint  = Tuple(DataValue, Int64)
  alias Datapoints = Array(Datapoint)
end
