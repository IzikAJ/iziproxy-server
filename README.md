# iziproxy

## Install dependencies
```
shards
```

## Usage

> TODO

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
### or simple (```gem install foreman``` first)
```
foreman start
```

### dev nginx

#### install

```
brew tap denji/nginx
brew unlink nginx
brew install nginx-full --with-stream
```

#### usage

start
```
nginx -c ~/www/sparse/iziproxy/nginx.conf
```
reload
```
nginx -s reload -c ~/www/sparse/iziproxy/nginx.conf
```
quit
```
nginx -s quit -c ~/www/sparse/iziproxy/nginx.conf
```

### other commands:

```
micrate create ... - create new migration
db/drop.sh - drop DB
db/create.sh - create DB
db/migrate.sh - run all migrations
db/seed.sh - fill DB by initial data
db/reset.sh - reset database & fill it
```

## DONE
### server features
 - authorization
 - active connections list
 - profile show/edit
 - manage autorization tokens

### client features
 - connect to proxy-server
 - authorize by token fron .env
 - reconnect on fail

## TODO
### server improvements
 - add task to clear expired sessions
 -- crontab or redis?
 - add some css
 -- login
 -- profile
 -- connections list

### client improvements
 - log requests in db (for current session)
 - add 'replay request' function (available on log?)
 - add detailed request preview (log?)
 - remove .env file requirement
 - add commands to configure auth key
 - add commands to configure server address

### Server structure mapping
```
connection.lvh.me
- TCP connection with client
- port: [TCP_PORT]:9777
- host: [TCP_HOST]
*.lvh.me
- delegated subdomain
- port: [PROXY_PORT]:80
lvl.me:
- server web interface
- port: [PORT]:80
- host: [HOST]
  …/ws
    - WebSocket connection scope
  …/api
    - API scope
  …/
    - React scope
```

## License
MIT
