#!/usr/bin/env bash

# Rsync file level backup of Postgres data directory (excluding WAL)

set -euo pipefail
IFS=$'\n\t'

# dirs
BACKUP_PATH="/srv/pg_backup"

# checks
[ ! -d "${BACKUP_PATH}" ] && { echo "Error: ${BACKUP_PATH} does not exist"; exit 128; }

psql -U postgres -c "SELECT pg_start_backup('backup', true);"

# Always stop the backup even on failure
# Trap is later in the script as it is only required if the backup is started successfully
finish() {
  psql -U postgres -c "SELECT pg_stop_backup();"
}
trap finish EXIT

rsync -av --inplace --delete --no-whole-file --exclude pg_wal/* --exclude pg_xlog/* /var/lib/postgresql/data/ ${BACKUP_PATH}/data/
