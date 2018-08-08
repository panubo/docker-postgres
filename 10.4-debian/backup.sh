#!/usr/bin/env bash

# Rsync file level backup of Postgres data directory (excluding WAL)

set -e

# dirs
BACKUP_PATH="/srv/pg_backup/data"

# checks
[ ! -d "${BACKUP_PATH}" ] && { echo "Error: ${BACKUP_PATH} does not exist"; exit 128; }

psql -U postgres -c "SELECT pg_start_backup('backup', true);"
rsync -av --inplace --delete --no-whole-file --exclude pg_wal/* /var/lib/postgresql/data/ ${BACKUP_PATH}
psql -U postgres -c "SELECT pg_stop_backup();"
