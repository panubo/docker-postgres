# PostgreSQL Docker Images

## Supported tags

* `12-buster`, `12.8-buster`, `12.8-2.5.1-buster`, `12-2.5-buster`
* `12`, `12.8`, `12.8-1.7.4`, `12-1.7`
* `11-to-12-upgrade`
* `9.6-to-12-upgrade`
* `11-buster`, `11.13-buster`, `11.13-1.7.4-buster`, `11-1.7-buster`
* `11`, `11.13`, `11.13-1.7.4`, `11-1.7`
* `9.6-dev`, `9.6.22-dev`, `9.6.22-1.6.1-dev`, `9.6-1.6-dev`
* `9.6`, `9.6.22`, `9.6.22-1.6.1`, `9.6-1.6`

## Extensions

These Docker images for PostgreSQL include a few improvements to the official
images.

| Image     | PostgeSQL | TimescaleDB | PostGIS | pglogical | Repmgr |
| --------- | --------- | ----------- | ------- | --------- | ------ |
| 12-buster | 12        | 2.5.1       | 2.5     | 2.3.3     | x      |
| 12-debian | 12        | 1.7.4       | 2.5     | 2.3.3     | x      |
| 11-buster | 11        | 1.7.4       | 2.5     | x         | _latest_ |
| 11-debian | 11        | 1.7.4       | 2.5     | x         | _latest_ |

REF:

[PostGIS Support Matrix](https://trac.osgeo.org/postgis/wiki/UsersWikiPostgreSQLPostGIS#PostGISSupportMatrix)

## Timescale versions

[Timescale Release Notes](https://docs.timescale.com/timescaledb/latest/overview/release-notes/)

| TS / PG | PG 11 | PG 12 | PG 13 | PG 14 |
| ------- | ----- | ----- | ----- | ----- |
| 1.6.x   | ✓     | x     | x     | x     |
| 1.7.x   | ✓     | ✓     | x     | x     |
| 2.0.x   | ✓     | ✓     | x     | x     |
| 2.1.x   | ✓     | ✓     | ✓     | x     |
| 2.2.x   | ✓     | ✓     | ✓     | x     |
| 2.3.X   | ✓     | ✓     | ✓     | x     |
| 2.4.X   | x     | ✓     | ✓     | x     |
| 2.5.X   | x     | ✓     | ✓     | ✓     |

## Upgrade

```
docker run --rm -i -v $(DATA_DIR):/var/lib/postgresql -e POSTGRES_PASSWORD=password panubo/postgres:11-to-12-buster-upgrade -O "-c timescaledb.restoring='on'" --link
```

**Known Upgrade Issues**

* The VIEW created by prometheus-exporter can cause pg_upgrade to fail. If this occurs you should remove `postgres_exporter.pg_stat_activity` and re-install post upgrade with `/usr/local/bin/docker-initdb-run /docker-entrypoint-initdb.d/prometheus-exporter.sh`.
* Postgres images 9.6-dev and 12 have `POSTGRES_INITDB_ARGS="--data-checksum"` by default which will conflict if the source was not using data checksum. You can set `POSTGRES_INITDB_ARGS=""` to avoid the issue during upgrade.
* The `9.6-to-12-upgrade` image does NOT support timescaledb upgrade.

## Known issues:

* E: Package 'postgresql-11-postgis-2.4-scripts' has no installation candidate
