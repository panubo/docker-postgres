#!/usr/bin/env bash

psql -U postgres -c "SELECT pg_start_backup('backup', true);"
rsync -av --inplace --no-whole-file --exclude pg_xlog/* /var/lib/postgresql/data/ /srv/pg_backup/data/
psql -U postgres -c "SELECT pg_stop_backup();"

