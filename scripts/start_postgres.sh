#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
$DIR/ensure_ownership.sh
exec su postgres -c "/usr/lib/postgresql/9.3/bin/postgres -D /var/lib/postgresql/9.3/main -c config_file=/etc/postgresql/9.3/main/postgresql.conf"
exec su postgres -c " psql -h 0.0.0.0 -c "ALTER USER postgres WITH PASSWORD '$PASSWORD';""