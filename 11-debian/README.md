# PostgreSQL 11 w/ TimescaleDB, PostGIS and Repmgr

This builds upon the offical PostgreSQL 11 image and adds TimescaleDB (v1.6.0), PostGIS (v3.0.0)
and Repmgr (v5.0.0) extensions as well as Wal-G.

## Extension Configuration

- `TIMESCALEDB_ENABLED` - enable TimescaleDB extension
- `REPMGR_ENABLED` - enable Repmgr extension, also enables setting Repmgr configuration.

### Repmgr Configuration

- `REPMGR_NODE_ID` (Required)
- `REPMGR_CONNINFO` (Required)
- `REPMGR_NODE_NAME` (Defaults to hostname)
- `REPMGR_DATA_DIRECTORY` (Default to $PGDATA)

See https://repmgr.org/docs/5.0/configuration-file-settings.html

## Wal-G Configuration

The most common required configs for S3 archiving with Postgres:

- `WALG_S3_PREFIX` eg "s3://acme-postgres-wal/< hostname>"
- `WALG_COMPRESSION_METHOD` "lz4"
- `WALG_ENABLED` "true" 

and to recover:

- `RECOVERY_WALG_S3_PREFIX` same as `WALG_S3_PREFIX`
- `RECOVERY_CONTINUE_ON_EXISTING` "true"

See https://github.com/wal-g/wal-g/blob/master/README.md#configuration
