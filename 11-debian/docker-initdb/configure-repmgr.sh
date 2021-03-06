#!/usr/bin/env bash

# Initialise database with repmgr extension and configure pg_hba.conf
# to allow authenticated connection from repmgr

set -e

[ "${REPMGR_ENABLED}" == "true" ] || { echo "Info: REPMGR_ENABLED false"; exit 0; }
[ -z "$REPMGR_PASSWORD" ] && { echo "Error: REPMGR_PASSWORD not set"; exit 128; }
: ${REPMGR_USER:='repmgr'}
: ${REPMGR_DB:='repmgr'}

createuser -s ${REPMGR_USER}
createdb ${REPMGR_DB} -O ${REPMGR_USER}

psql -c "ALTER user ${REPMGR_USER} WITH PASSWORD '${REPMGR_PASSWORD}'"

echo -e "host\treplication\t${REPMGR_USER}\tall\t\t\tmd5" >> "${PGDATA}/pg_hba.conf"
echo -e "host\t${REPMGR_DB}\t${REPMGR_USER}\tall\t\t\tmd5" >> "${PGDATA}/pg_hba.conf"
