#!/usr/bin/env bash

# Perform Postgres Dump of all databases

set -e

# dirs
BACKUP_PATH=/srv/pg_dump
BACKUP_DIR="${BACKUP_PATH}/$(date +%Y%m%d%H%M%S)"

# checks
[ ! -d "${BACKUP_PATH}" ] && { echo "Error: ${BACKUP_PATH} does not exist"; exit 128; }

# configs
PG_BIN=/usr/lib/postgresql/${PG_MAJOR}/bin
DBS=$(su -l postgres -c "${PG_BIN}/psql -At -c \"SELECT datname FROM pg_database WHERE NOT datistemplate\"")
mkdir -p "${BACKUP_DIR}" ${BACKUP_PATH}/latest

# globals
su -l postgres -c "${PG_BIN}/pg_dumpall --globals-only" | gzip > "${BACKUP_DIR}/globals.sql.gz";
ln -f "${BACKUP_DIR}/globals.sql.gz" ${BACKUP_PATH}/latest/globals.sql.gz;

# DB's
for DB in $DBS; do
    # echo "Dumping ${DB}";
    su -l postgres -c "${PG_BIN}/pg_dump -Fp ${DB}" | gzip > "${BACKUP_DIR}/${DB}.sql.gz";
    ln -f "${BACKUP_DIR}/${DB}.sql.gz" "${BACKUP_PATH}/latest/${DB}.sql.gz";
done
