# PostgreSQL 10 w/ TimescaleDB and Repmgr

This builds upon the offical PostgreSQL 10 image and adds TimescaleDB and
Repmgr extensions.

## Extension Configuration

- `TIMESCALEDB_ENABLED` - enable TimescaleDB extension
- `REPMGR_ENABLED` - enable Repmgr extension, also enables setting repmgr configuration.

### Repmgr Configuration

- `REPMGR_NODE_ID` (Required)
- `REPMGR_CONNINFO` (Required)
- `REPMGR_NODE_NAME` (Defaults to hostname)
- `REPMGR_DATA_DIRECTORY` (Default to $PGDATA)

See https://repmgr.org/docs/4.0/configuration-file-settings.html
