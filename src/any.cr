require "http/server"
require "json"

class Server
  def initialize(@host : String = "127.0.0.1", @port : Int32 = 8080)
    @server = HTTP::Server.new(host, port) do |ctx|
      handle(ctx)
    end
  end
    
  def start
    puts "Listening on http://#{@host}:#{@port}"
    @server.listen
  end

  private def handle(ctx : HTTP::Server::Context)
    debug_req(ctx)
    case ctx.request.path
    when "/query"
      body = do_query(ctx)
    when "/search"
      body = do_search(ctx)
    else
      body = do_else(ctx)
    end
    debug_res(body)
    ctx.response.print body
  rescue err
    puts "!" * 50
    p [:err, err]
    ctx.response.status_code = 500
    ctx.response.print err.to_s
  end

  private def debug_req(ctx)
    req =  ctx.request
    puts "=" * 50
    p [req.method, req.path, req.query_params]
    puts req.body
  end

  private def debug_res(body)
    puts "-" * 50
    puts body
  end

  private def search(epoch1, epoch2, key)
    points = [] of Tuple(Int64, Int32)
    # DEBUG
    epoch2 = epoch1 + 10
    (epoch1..epoch2).each do |t|
      points << {rand(100).to_i64, t}
    end
    return points
  end

  private def query_hash(epoch1, epoch2, key)
    hash = {
      "target" => key,
      "datapoints" => search(epoch1, epoch2, key),
    }
  end    

  private def do_query(ctx)
    body = ctx.request.body.not_nil!
    json = JSON.parse(body)
    range = json["range"]
    from = Time.parse(range["from"].to_s, "%FT%T.%LZ").to_local.epoch.to_i32
    to   = Time.parse(range["to"].to_s, "%FT%T.%LZ").to_local.epoch.to_i32

    p [:from, from, Time.parse(range["from"].to_s, "%FT%T.%LZ").epoch.to_i32]
    p [:length, to - from]

    hash = query_hash(from, to, "cpu")
    return [hash].to_json
  end

  private def do_search(ctx)
    search
  end

  private def do_else(ctx)
    "hello"
  end

  private def query2
    <<-JSON
      [
        {
          "target":"cpu",
          "datapoints":[
            [622,1450754160000],
            [365,1450754220000]
          ]
        },
        {
          "target":"mem",
          "datapoints":[
            [861,1450754160000],
            [767,1450754220000]
          ]
        }
      ]
      JSON
  end

  private def query
    <<-JSON
      [
        {
          "target":"upper_75",
          "datapoints":[
            [622,1450754160000],
            [365,1450754220000]
          ]
        },
        {
          "target":"upper_90",
          "datapoints":[
            [861,1450754160000],
            [767,1450754220000]
          ]
        }
      ]
      JSON
  end

  private def search
    <<-JSON
      [
        "cpu",
        "mem"
      ]
      JSON
  end
end

s = Server.new(port: 3334)
s.start
