# Docker Postgres

Docker image for Postgres 9.3 + WAL-E

## Build the image
```shell
$ docker build -t audioandpixels/postgres github.com/audioandpixels/docker-postgres
```

## Container requirements

#### Environment Variables
```
AWS_SECRET_ACCESS_KEY=xxxxxxxx
AWS_ACCESS_KEY_ID=xxxxxxxx
WALE_S3_PREFIX=s3://some-bucket/directory
PG_PASSWORD=xxxx
```

####External volumes
```
$HOME/postgres/data
$HOME/postgres/log
```

## Basic usage

####Initialize postgres data if you have none
```shell
$ docker run -v "$HOME/postgres/data":"/var/lib/postgresql/9.3/main" audioandpixels/postgres su postgres --command "/usr/lib/postgresql/9.3/bin/initdb -D /var/lib/postgresql/9.3/main"
```

####Start the container...

If you want WAL-E backups in a directory named ip of host, substitute directory with:
```shell
$(/sbin/ifconfig | grep -A1 eth | grep "inet addr" | head -1 | sed "s/[^0-9]*\([0-9.]*\).*/\1/")
```

```shell
$ docker run -d -p 5432:5432 -v "$HOME/postgres/data":"/var/lib/postgresql/9.3/main" -v "$HOME/postgres/log":"/var/log" -e AWS_SECRET_ACCESS_KEY=xxxxxxxx -e AWS_ACCESS_KEY_ID=xxxxxxxx -e WALE_S3_PREFIX=s3://some-bucket/directory -e PG_PASSWORD=xxxx audioandpixels/postgres
```

## WAL-E

This image includes [WAL-E][wal-e] for performing continuous archiving of PostgreSQL WAL files and base backups.

The image starts cron, syslog, and Postgres. [runit][runit] manages the cron and Postgres processes and will restart them automatically if they crash.

## License

MIT license.

[wal-e]:  https://github.com/wal-e/wal-e
[runit]:  http://smarden.org/runit/
