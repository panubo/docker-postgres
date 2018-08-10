#!/usr/bin/env bash

# Configure repmgr.conf and postgres cli credentials to allow authenticated
# repmgr connections.

set -e

# Conf
REPMGR_CONF="/etc/repmgr.conf"

# Variable tests / defaults
[ "${REPMGR_ENABLED}" == "true" ] || { echo "Info: REPMGR_ENABLED false"; exit 0; }
[ -z "$REPMGR_NODE_ID" ] && { echo "Error: REPMGR_NODE_ID not set"; exit 128; }
[ -z "$REPMGR_CONNINFO" ] && { echo "Error: REPMGR_CONNINFO not set"; exit 128; }
: ${REPMGR_NODE_NAME:=$(hostname)}
: ${REPMGR_DATA_DIRECTORY:="${PGDATA}"}

# Change settings
sed -i -e "s@^#node_id=.*@node_id=${REPMGR_NODE_ID}@g" ${REPMGR_CONF}
sed -i -e "s@^#node_name=.*@node_name=\'${REPMGR_NODE_NAME}\'@g" ${REPMGR_CONF}
sed -i -e "s@^#conninfo=.*@conninfo=\'${REPMGR_CONNINFO}\'@g" ${REPMGR_CONF}
sed -i -e "s@^#data_directory=.*@data_directory=\'${REPMGR_DATA_DIRECTORY}\'@g" ${REPMGR_CONF}

# Create credentials for repmgr cli
# hostname:port:database:username:password
echo "*:5432:*:${REPMGR_USER}:${REPMGR_PASSWORD}" > ~postgres/.pgpass
chmod 600 ~postgres/.pgpass
chown postgres:postgres ~postgres/.pgpass
