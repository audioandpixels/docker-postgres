# Postgres Dockerfile

Docker image for Postgres 9.3 + WAL-E

## Build the image
```
$ docker build -t audioandpixels/postgres github.com/audioandpixels/docker-postgres
```

## Basic usage

```
$ mkdir $HOME/postgresdata && chown root:root $HOME/postgresdata && chmod 0700 $HOME/postgresdata
```

Fill it with data...
```
$ su postgres --command "/usr/lib/postgresql/9.3/bin/initdb -D /var/lib/postgresql/9.3/main"
```
Start the container...

If you want to store the WAL-E backups in a directory matching the ip of the host substitute directory with:
```
$(/sbin/ifconfig | grep -A1 eth | grep "inet addr" | head -1 | sed "s/[^0-9]*\([0-9.]*\).*/\1/")
```
```
$ docker run -d -v "$HOME/postgresdata":"/var/lib/postgresql/9.3/main" -e AWS_SECRET_ACCESS_KEY=xxxxxxxx -e AWS_ACCESS_KEY_ID=xxxxxxxx -e WALE_S3_PREFIX=s3://some-bucket/directory -e PASSWORD=xxxx audioandpixels/postgres /sbin/my_init
```

## WAL-E

This image comes with [WAL-E][wal-e] for performing continuous archiving of PostgreSQL WAL files and base backups.  To use WAL-E, you need to do a few things:

Runing the container with `/sbin/my_init` instead of the default command starts cron, syslog, and Postgres.  In this mode, [runit][runit] manages the cron and Postgres processes and will restart them automatically if they crash.

## License

MIT license.

[wal-e]:  https://github.com/wal-e/wal-e
[runit]:  http://smarden.org/runit/
