#!/usr/bin/env bash
# This entrypoint script performs a standby instead of initializing a fresh database.
# The script creates a standby.signal.done file which prevents this from running
# again which may result in a promoted database going back into stanby mode.
# Currently only supports S3 Wal-g recovery.

set -euo pipefail
IFS=$'\n\t'

# TODO change this and entry.sh so only STANDBY_WALG_S3_PREFIX needs to be set and RECOVERY_WALG_S3_PREFIX should be unset.
if [[ -n "${STANDBY_WALG_S3_PREFIX:-}" && -n "${RECOVERY_WALG_S3_PREFIX:-}" ]]; then

  # The standby.signal.done is created at the same time as standby.signal to
  # prevent a promoted standby from going back into standby mode (function
  # of this script not native postgresql)
  if [[ -e "${PGDATA}/standby.signal.done" ]]; then
    echo "INFO: standby.signal.done file found skipping creation of another standby.signal"
    return 0
  fi

  # create recovery-wal-g.json, TODO change this to standby-wal-g.json
  echo "{\"WALG_S3_PREFIX\": \"${RECOVERY_WALG_S3_PREFIX}\"}" > "/run/postgresql/recovery-wal-g.json"

  cat /run/postgresql/recovery-wal-g.json

  # Create standby signal file
  echo "" > "${PGDATA:-/var/lib/postgres/data}/standby.signal"
  echo "" > "${PGDATA:-/var/lib/postgres/data}/standby.signal.done"

  echo "Standby setup script done. Wait for postgres."

fi
