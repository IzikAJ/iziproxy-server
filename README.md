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

other commands:

```
micrate create ... - create new migration
db/drop.sh - drop DB
db/create.sh - create DB
db/migrate.sh - run all migrations
db/seed.sh - fill DB by initial data
db/reset.sh - reset database & fill it
```

## TODO
### server improvements
 - log requests in db (for current session)
 - add 'replay request' function (available on log)
 - add detailed request preview (log)
 - add task to clear expired sessions
 - omniauth ?
 - add some css

### client improvements
 - remove .env file requirement
 - add commands to configure auth key
 - add commands to configure server address

## License
MIT
