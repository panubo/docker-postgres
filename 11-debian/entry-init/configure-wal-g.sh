#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

if [[ "${WALG_ENABLED:-}" != "true" ]]; then
  echo "Info: WALG_ENABLED false"
  return 0
fi

if [[ -n "${AWS_ENDPOINT}" ]] && [[ "${AWS_S3_FORCE_PATH_STYLE:-}" != "true" ]]; then
  echo "WARNING: looks like you are using a custom AWS_ENDPOINT by AWS_S3_FORCE_PATH_STYLE is not true, this may cause wal-g to fail to connect."
fi

if [[ -e "${PGDATA:-/var/lib/postgres/data}/PG_VERSION" ]]; then
  conf_file="${PGDATA:-/var/lib/postgres/data}/postgresql.conf"
else
  conf_file="/usr/share/postgresql/postgresql.conf.sample"
fi

ls "${conf_file}"

sed -i -e "s@^#archive_mode.*@archive_mode = on@g" "${conf_file}"
sed -i -e "s@^#archive_command.*@archive_command = '/usr/bin/timeout 600 /usr/local/bin/wal-g wal-push %p'@g" "${conf_file}"
sed -i -e "s@^#archive_timeout.*@archive_timeout = 600@g" "${conf_file}"
