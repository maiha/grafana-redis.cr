require "../all"

class Servers::Redis
  def initialize(@host : String, @port : Int32, @storage : Storage::Redis)
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
    puts "ERR: #{err.message}".colorize.red
    ctx.response.status_code = 500
    ctx.response.print({"error" => err.to_s}.to_json)
  end

  private def debug_req(ctx)
    req =  ctx.request
    puts "== Request  " + "=" * 50
    p [req.method, req.path, req.query_params]
    puts req.body
  end

  private def debug_res(body)
    puts "-- Response " + "-" * 50
    puts "(%d bytes) %s" % [body.size, body[0..100]]
  end

  private def query_hash(epoch1, epoch2, key, size)
    hash = {
      "target" => key,
      "datapoints" => @storage.search(epoch1, epoch2, key, size),
    }
  end    

  private def do_query(ctx)
    body = ctx.request.body.not_nil!
    req  = Grafana::Query::Request.from_json(body)
    from = req.from.to_local.epoch.to_i32
    to   = req.to.to_local.epoch.to_i32

    array = req.targets.map{|key| query_hash(from, to, key, req.max) }
    return array.to_json
  rescue err : Jq::ParseError
    puts "ERR: #{err.message}".colorize.red
    return "{}"
  end

  private def do_search(ctx)
    @storage.keys.to_json
  end

  private def do_else(ctx)
    "OK"
  end
end
