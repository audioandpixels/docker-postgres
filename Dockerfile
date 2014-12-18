FROM       phusion/baseimage:0.9.15
MAINTAINER Jason Cox <jason@audioandpixels.com>

ENV USERNAME postgres
ENV VERSION  9.3

# Disable SSH and existing cron jobs
RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh /etc/cron.daily/dpkg /etc/cron.daily/apt \
           /etc/cron.daily/passwd /etc/cron.daily/logrotate /etc/cron.daily/upstart /etc/cron.weekly/fstrim

# Ensure UTF-8 locale
COPY locale /etc/default/locale
RUN  DEBIAN_FRONTEND=noninteractive locale-gen en_US.UTF-8
RUN  DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales

# Update APT
RUN DEBIAN_FRONTEND=noninteractive apt-get update

# Install Postgres
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y postgresql-$VERSION postgresql-contrib-$VERSION postgresql-server-dev-$VERSION

# Install WAL-E dependencies
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y libxml2-dev libxslt1-dev python-dev daemontools libevent-dev lzop pv git

# Install WAL-E
RUN curl https://bootstrap.pypa.io/get-pip.py | python
RUN pip install git+https://github.com/audioandpixels/wal-e@v0.7.3-fixed

# Create directory for storing secret WAL-E environment variables
RUN umask u=rwx,g=rx,o= && mkdir -p /etc/wal-e.d/env && chown -R root:postgres /etc/wal-e.d

# Clean up APT and temporary files
RUN DEBIAN_FRONTEND=noninteractive apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy Postgres configs
COPY ./pg_hba.conf     /etc/postgresql/$VERSION/main/
COPY ./postgresql.conf /etc/postgresql/$VERSION/main/

# Copy wal-e cron
COPY ./wal-e /etc/cron.d/

# COPY sets ownership on this directory to root
RUN chown -R postgres:postgres /etc/postgresql/$VERSION/main

# Use wrapper scripts to start cron and Postgres
COPY scripts /data/scripts
RUN  chmod -R 755 /data/scripts

# Copy runit configs
RUN  mkdir -m 755 -p /etc/service/postgres
COPY runit/cron     /etc/service/cron/run
COPY runit/postgres /etc/service/postgres/run
RUN  chmod 755 /etc/service/cron/run /etc/service/postgres/run

# Start with cron + WAL-E
CMD ["/sbin/my_init"]

# Keep Postgres log, config and storage outside of union filesystem
VOLUME ["/var/log/postgresql", "/var/log/supervisor", "/etc/postgresql/$VERSION/main", "/var/lib/postgresql/$VERSION/main"]

EXPOSE 5432