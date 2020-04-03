#!/usr/bin/env bash

# Enable postgres extensions as required.

set -e

# comma separated list of extensions to load
[ "${TIMESCALEDB_ENABLED}" == "true" ] && TIMESCALEDB="timescaledb"
[ "${REPMGR_ENABLED}" == "true" ] && REPMGR="repmgr"
EXTENSIONS=(${TIMESCALEDB} ${REPMGR})
EXTENSIONS=$(echo ${EXTENSIONS[*]} | sed -e 's@ @,@g')

if [ "${EXTENSIONS}" == "" ]; then
  echo "Info: No extensions to configure" && exit 0
else
  echo "Configuring extensions... ${EXTENSIONS}"
  sed -i -e "s@^#shared_preload_libraries.*@shared_preload_libraries = '${EXTENSIONS}'@g" "${PGDATA:-/var/lib/postgresql/data}/postgresql.conf"
fi
