require "kemal"

require "json"

get "/" do |env|
  env.response.content_type = "application/json"
  {name: "Serdar", age: 27}.to_json
end

Kemal.run
