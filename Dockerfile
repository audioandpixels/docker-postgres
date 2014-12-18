FROM       phusion/baseimage:0.9.15
MAINTAINER Jason Cox <jason@audioandpixels.com>

ENV USERNAME postgres
ENV PASSWORD password
ENV VERSION  9.3

# Disable SSH and existing cron jobs
RUN rm -rf /etc/service/sshd \
  /etc/my_init.d/00_regen_ssh_host_keys.sh \
  /etc/cron.daily/dpkg \
  /etc/cron.daily/apt \
  /etc/cron.daily/passwd \
  /etc/cron.daily/logrotate \
  /etc/cron.daily/upstart \
  /etc/cron.weekly/fstrim

# Ensure UTF-8 locale
COPY locale /etc/default/locale
RUN locale-gen en_US.UTF-8 && dpkg-reconfigure locales

# Update APT
RUN apt-get update

# Install build dependencies
RUN apt-get install -y wget

# Install Postgres
RUN apt-get install -y postgresql-$VERSION postgresql-contrib-$VERSION postgresql-server-dev-$VERSION

# Install WAL-E dependencies
RUN apt-get install -y libxml2-dev libxslt1-dev python-dev daemontools libevent-dev lzop pv

# Install WAL-E
RUN curl https://bootstrap.pypa.io/get-pip.py | python
RUN pip install git+https://github.com/audioandpixels/wal-e@v0.7.3-fixed && ln -s /var/lib/postgresql/wal-e/bin/wal-e /usr/local/bin/wal-e

# Create directory for storing secret WAL-E environment variables
RUN umask u=rwx,g=rx,o= && mkdir -p /etc/wal-e.d/env && chown -R root:postgres /etc/wal-e.d

# Remove build dependencies and clean up APT and temporary files
RUN apt-get remove --purge -y wget && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy basic Postgres configs with values suitable for development
# (note: these should be overridden in production!)
COPY ./pg_hba.conf     /etc/postgresql/$VERSION/main/
COPY ./postgresql.conf /etc/postgresql/$VERSION/main/

# Copy wal-e cron
COPY ./wal-e /etc/cron.d/

# Copy ENV
#COPY ./AWS_ACCESS_KEY_ID      /etc/wal-e.d/env/
#COPY ./AWS_SECRET_ACCESS_KEY  /etc/wal-e.d/env/
#COPY ./WALE_S3_PREFIX         /etc/wal-e.d/env/

# COPY sets ownership on this directory to root
RUN chown -R postgres:postgres /etc/postgresql/$VERSION/main

# Use wrapper scripts to start cron and Postgres
COPY scripts /data/scripts
RUN chmod -R 755 /data/scripts

# Copy runit configs
RUN mkdir -m 755 -p /etc/service/postgres
COPY runit/cron     /etc/service/cron/run
COPY runit/postgres /etc/service/postgres/run
RUN chmod 755 /etc/service/cron/run /etc/service/postgres/run

USER postgres

RUN /etc/init.d/postgresql start &&\
  psql --command "ALTER USER postgres WITH PASSWORD '$PASSWORD';" && /etc/init.d/postgresql stop

USER root

# The image only runs Postgres by default. If you want to run periodic full
# backups with cron + WAL-E you should start supervisord instead (see README)
CMD ["/data/scripts/start_postgres.sh"]

# Keep Postgres log, config and storage outside of union filesystem
VOLUME ["/var/log/postgresql", "/var/log/supervisor", "/etc/postgresql/9.3/main", "/var/lib/postgresql/9.3/main"]

EXPOSE 5432