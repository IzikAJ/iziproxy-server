# iziproxy

## Install dependencies
```
shards
```
## Usage (dev)
start proxy server
```
crystal app.cr
```
start client
```
crystal client.cr
```

## Development
start server (live reload by sentry)
```
crystal dev.cr
```
build client
```
crystal build client.cr
```
run client (port 3001, requested subdomain - sample)
```
./client -p 3001 -s sample
```

## License
MIT
