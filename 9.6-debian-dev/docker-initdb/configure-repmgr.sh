#!/usr/bin/env bash

# Initialise database with repmgr extension

set -e

[ "${REPMGR_ENABLED}" == "true" ] || { echo "Info: REPMGR_ENABLED false"; exit 0; }
[ -z "$REPMGR_PASSWORD" ] && { echo "Error: REPMGR_PASSWORD not set"; exit 128; }
: ${REPMGR_USER:='repmgr'}
: ${REPMGR_DB:='repmgr'}


psql -v ON_ERROR_STOP=1 --username "${POSTGRES_USER}" --dbname "${POSTGRES_DB}" << EOF
  CREATE OR REPLACE FUNCTION __tmp_create_user() returns void as \$$
  BEGIN
    IF NOT EXISTS (
            SELECT                       -- SELECT list can stay empty for this
            FROM   pg_catalog.pg_user
            WHERE  usename = '${REPMGR_USER}') THEN
      CREATE USER ${REPMGR_USER};
    END IF;
  END;
  \$$ language plpgsql;

  SELECT __tmp_create_user();
  DROP FUNCTION __tmp_create_user();

  ALTER USER ${REPMGR_USER} WITH PASSWORD '${REPMGR_PASSWORD}';
EOF

echo "SELECT 'CREATE DATABASE ${REPMGR_DB} OWNER ${REPMGR_USER}' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '${REPMGR_DB}')\gexec" | psql -v ON_ERROR_STOP=1 --username "${POSTGRES_USER}" --dbname "${POSTGRES_DB}"
