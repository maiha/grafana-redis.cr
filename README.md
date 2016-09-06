# grafana-redis.cr

Grefana Datasource for Redis storage

- created by crystal-0.18.7
- binary download: https://github.com/maiha/grafana-redis.cr/releases

## Features

- Grafana Datasource protocol: `SimpleJson`
- Redis Storage Format: `ZADD KEY epoch DSTAT_JSON`

## Usage

#### config.toml

```toml
## Setting for Redis Storage where stats are stored
[redis]
host = "127.0.0.1"
port = 6379
# pass = "secret"
zset = "dstat"  # specify your ZADD key
sampling = 3600      # max number of data to retrieve from redis

[engine]
limit = 100  # max number of datapoints to send to grafana server

## Backend Simple JSON Server that listens for Grafana
[httpd]
host = "127.0.0.1"
port = 3334
```

#### run backend server

```shell
grafana-redis config.toml
```

#### Grafana (Add data source)

- Type: `SimpleJson`
- Url: `http://127.0.0.1:3334`

## Redis Stats

#### Importing

- use `ZADD` with epoched SCORE

```shell
% redis-cli ZADD dstat CH 1472914799 '{"usr":1,"sys":1,...}'
```

- `dstat-redis` with following `cmds` suit best to this use.
- https://github.com/maiha/dstat-redis.cr

```toml
cmds = [
  "ZADD   dstat CH __epoch__ __json__",
]
```

#### Fetching

Expected stats are stored in `ZSET` as JSON String where

- 1. The JSON must contain `epoch` field.

```shell
% redis-cli --raw ZRANGE "dstat" -1 -1
{"usr":1,"sys":1,"idl":99,"wai":0,"hiq":0,"siq":0,"1m":0.02,"5m":0.03,"15m":0.05,"used":351000000,"buff":329000000,"cach":323000000,"free":997000000,"read":0,"writ":16000,"recv":1646,"send":860,"int":287,"csw":365,"lis":16,"act":15,"syn":1,"tim":0,"clo":0,"epoch":1472914799}
```

- 2. The entry has `epoch` value as SCORE.

```shell
% redis-cli --raw ZRANGEBYSCORE "dstat" 1472914796 1472914797
{"usr":1,"sys":1,"idl":98,"wai":0,"hiq":0,"siq":0,"1m":0.02,"5m":0.03,"15m":0.05,"used":351000000,"buff":329000000,"cach":323000000,"free":998000000,"read":0,"writ":16000,"recv":1808,"send":664,"int":347,"csw":422,"lis":16,"act":15,"syn":0,"tim":0,"clo":0,"epoch":1472914796}
{"usr":2,"sys":0,"idl":98,"wai":0,"hiq":0,"siq":0,"1m":0.02,"5m":0.03,"15m":0.05,"used":351000000,"buff":329000000,"cach":323000000,"free":997000000,"read":0,"writ":16000,"recv":2276,"send":1498,"int":354,"csw":467,"lis":16,"act":15,"syn":0,"tim":0,"clo":0,"epoch":1472914797}
```

## Development

```shell
crystal src/bin/main.cr -- config.toml
```

## Restrictions

- Works only for Int values. It maybe fail with selecting `1m` etc.

## Contributing

1. Fork it ( https://github.com/maiha/grafana-redis.cr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [maiha](https://github.com/maiha) maiha - creator, maintainer
