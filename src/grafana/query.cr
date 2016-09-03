module Grafana::Query
  class Request
    Jq.mapping({
      from_s:  {String, ".range.from"},
      to_s:    {String, ".range.to"},
      from:    {Time, ".range.from", "%FT%T.%LZ"},
      to:      {Time, ".range.to", "%FT%T.%LZ"},
      targets: {Array(String), ".targets[].target"},
      format:  String,
      max:     {Int64, ".maxDataPoints"},
    })
  end
end
