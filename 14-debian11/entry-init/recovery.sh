#!/usr/bin/env bash
# This entrypoint script performs a recovery instead of initializing a fresh database.
# The process is intended to be idempotent so does not require the removal of RESTORE_ environment variables after the recovery is complete.
# Currently only supports S3 Wal-g recovery

set -euo pipefail
IFS=$'\n\t'

if [[ -n "${RECOVERY_WALG_S3_PREFIX:-}" ]]; then

  # In PG 12+ this file is created by our recovery_end_command not the postgres recovery mode
  if [[ -e "${PGDATA}/recovery.signal.done" ]]; then
    echo "INFO: recovery.signal.done file found skipping recovery"
    return 0
  fi

  # Although technically not an issue performing a recovery and continuing to write to the same destination can lead to issues
  # Using a new location makes recovery cleaner and leaves the original backups intact in case there are recovery issues
  if [[ "${RECOVERY_WALG_S3_PREFIX}" == "${WALG_S3_PREFIX}" ]]; then
    echo "ERROR: RECOVERY_WALG_S3_PREFIX and WALG_S3_PREFIX must not be the same"
    exit 1
  fi

  # create recovery-wal-g.json
  echo "{\"WALG_S3_PREFIX\": \"${RECOVERY_WALG_S3_PREFIX}\"}" > "/run/postgresql/recovery-wal-g.json"

  cat /run/postgresql/recovery-wal-g.json

  # TODO: this should be able to be skipped if the base backup has already been restored
  if [[ -e "${PGDATA}/PG_VERSION" ]] && [[ "${RECOVERY_CONTINUE_ON_EXISTING:-}" != "true" ]]; then
    echo "ERROR: the database already appears to be initialized, skipping recovery or set RECOVERY_CONTINUE_ON_EXISTING=true"
    exit 1
  elif [[ ! -e "${PGDATA}/PG_VERSION" ]]; then
    # Since there is no database present assume one needs to be restored with backup-fetch
    # Run in a sub shell so we can adjust the environment
    (
      # export WALG_LOG_LEVEL=DEVEL
      unset WALG_S3_PREFIX
      # TODO: make LATEST configurable
      wal-g --config=/run/postgresql/recovery-wal-g.json backup-fetch "${PGDATA}" LATEST

      ls -l "${PGDATA}"
    )
  else
    echo "INFO: performing restore on existing database"
  fi

  # Create recovery signal file
  echo "" > "${PGDATA:-/var/lib/postgres/data}/recovery.signal"

  echo "Recovery setup script done. Wait for postgres recovery."

fi 
