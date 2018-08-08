#!/usr/bin/env bash

set -e

echo "Enabling TimescaleDB extension"
sed -i -e "s@^#shared_preload_libraries.*@shared_preload_libraries = 'timescaledb'@g" /var/lib/postgresql/data/postgresql.conf
