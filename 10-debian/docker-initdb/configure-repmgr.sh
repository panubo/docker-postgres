#!/usr/bin/env bash

set -e

: ${REPMGR_USER:='repmgr'}
[ -z "$REPMGR_PASSWORD" ] && { echo "Error: REPMGR_PASSWORD not set"; exit 128; }
: ${REPMGR_DB:='repmgr'}

createuser -s ${REPMGR_USER}
createdb ${REPMGR_DB} -O ${REPMGR_USER}

psql -c "ALTER user ${REPMGR_USER} WITH PASSWORD '${REPMGR_PASSWORD}'"

echo -e "host\treplication\t${REPMGR_USER}\tall\t\t\tmd5" >> "${PGDATA}/pg_hba.conf"
echo -e "host\t${REPMGR_DB}\t${REPMGR_USER}\tall\t\t\tmd5" >> "${PGDATA}/pg_hba.conf"
