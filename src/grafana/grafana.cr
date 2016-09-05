module Grafana
  alias DataValue  = (Int64|Float64|Nil)
  alias Datapoints = Array(Tuple(DataValue, Int64))
end
