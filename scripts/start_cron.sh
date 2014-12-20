#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
$DIR/ensure_ownership.sh

echo "$AWS_SECRET_ACCESS_KEY" > /etc/wal-e.d/env/AWS_SECRET_ACCESS_KEY
echo "$AWS_ACCESS_KEY_ID" > /etc/wal-e.d/env/AWS_ACCESS_KEY_ID
echo "$WALE_S3_PREFIX" > /etc/wal-e.d/env/WALE_S3_PREFIX

exec cron -f
