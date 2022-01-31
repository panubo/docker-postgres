# PostgreSQL 12 w/ TimescaleDB

This builds upon the offical PostgreSQL 12 image and adds TimescaleDB extensions.

## Environment variables

### Included from upstream

- `POSTGRES_PASSWORD`
- `POSTGRES_USER`
- `POSTGRES_DB`
- `POSTGRES_INITDB_ARGS` - Specify any initdb arguments such as "--data-checksum", "--locale=en_AU.UTF-8". Default "--data-checksum" (this image turns on data checksum by default).
- `POSTGRES_INITDB_WALDIR`
- `POSTGRES_HOST_AUTH_METHOD` - **DISABLED** this env is used in the postgres upstream image but disabled in this image
- `PGDATA`

### Postgres config

- `POSTGRES_MAX_CONNECTIONS` - max connections, default "100"
- `POSTGRES_INCLUDE_IF_EXISTS` - comma separated list of additional config files to include with `include_if_exists`, default "".
- `POSTGRES_SSL_SELF_SIGNED` - creates a self signed certificate and sets POSTGRES_SSL_CERT_FILE and POSTGRES_SSL_KEY_FILE to the new certificate.
- `POSTGRES_SSL_CERT_FILE` - ssl_cert_file, default "".
- `POSTGRES_SSL_KEY_FILE` - ssl_key_file, default "".
- `POSTGRES_ENFORCE_SSL` - enforces SSL on connections, this is independent of whether ssl is on or not as an additional protection against misconfiguration.

### Extension Configuration

- `TIMESCALEDB_ENABLED` - enable TimescaleDB extension in the `POSTGRES_DB` database.

### Postgres exporter

[postgres_exporter](https://github.com/wrouesnel/postgres_exporter)

- `POSTGRES_EXPORTER_ENABLED` - when enabled a `postgres_exporter` user is created with appropriate access for the exporter. The user is only created on db init. Run `. /docker-entrypoint-initdb.d/prometheus-exporter.sh` in the container to enable later.
- `POSTGRES_EXPORTER_PASSWORD` - user password for postgres_exporter, default "password".

**Security:** if an exporter password is NOT set (including the default) remote connection as the postgres_export role will be rejected, only local socket connections will be possible.

### Wal-g

[wal-g](https://github.com/wal-g/wal-g)

- `WALG_ENABLED` - enabled wal-g
- `WALG_S3_PREFIX` - see wal-g docs for value.

If using wal-g with minio the following env vars should be set.

- `AWS_ENDPOINT`
- `AWS_S3_FORCE_PATH_STYLE`

### Wal-g Recovery

- `RECOVERY_WALG_S3_PREFIX` - Recovery target, same as `WALG_S3_PREFIX` but the values must NOT match.
- `RECOVERY_CONTINUE_ON_EXISTING` - Allows recovery even if a cluster has already been initialised, use if you are restoring from a disk snapshot instead of `wal-g backup-fetch ...`

### pglogical

pglogical is also installed and loaded. Docs are at https://www.2ndquadrant.com/en/resources/pglogical/pglogical-docs/

## Scripts

This image ships with some helper scripts

### docker-initdb-run

This scripts helps re-run scripts and sql files in /docker-entrypoint-initdb.d/. You MUST ensure any scripts you intedend to re-run are idempotent otherwise you may damage your system.

Example:

```
docker-initdb-run /docker-entrypoint-initdb.d/prometheus-exporter.sh
```

### backup-wal-g

Runs `wal-g backup-push`.

## Testing

```
docker run --rm -it --name postgres96 -v $(pwd)/data:/var/lib/postgresql/data panubo/postgres:9.6-debian
```
