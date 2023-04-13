# PostgreSQL Docker Images

## Supported tags

Images are available at `quay.io/panubo/postgres` or `public.ecr.aws/panubo/postgres`.

* `12-bullseye`, `12.14-bullseye`, `12.14-2.9.3-bullseye`, `12-2.9-bullseye`
* `9.6-to-12-upgrade`
* `9.6-dev`, `9.6-1.6-dev`

**All future images will use the OS name and version instead of codenames**

### Testing tags

These images are being tested.

* `14-debian11`, `14.7-debian11`, `14.7-2.5.2-debian11`, `14-2.5-debian11`

## Extensions

These Docker images for PostgreSQL include a few improvements to the official
images.

| Image       | PostgeSQL | TimescaleDB  | PostGIS | pglogical |
| ----------- | --------- | ------------ | ------- | --------- |
| 12-bullseye | 12        | 2.5.2, 2.9.3 | 2.5.5   | 2.4.1     |
| 14-debian11 | 14        | 2.5.2        | 3.1.8   | 2.4.2     |

REF:

[PostGIS Support Matrix](https://trac.osgeo.org/postgis/wiki/UsersWikiPostgreSQLPostGIS#PostGISSupportMatrix)

### Timescale versions

[Timescale Release Notes](https://docs.timescale.com/timescaledb/latest/overview/release-notes/)

| TS / PG  | PG 12 | PG 14 |
| -------- | ----- | ----- |
| 2.5.X    | ✓     | ✓     |
| 2.6.X    | ✓     | ✓     |
| 2.7.X    | ✓     | ✓     |
| 2.8.X    | ✓     | ✓     |
| 2.9.X    | ✓     | ✓     |
| 2.10.X   | ✓     | ✓     |

## Upgrade

```
docker run --rm -i -v $(DATA_DIR):/var/lib/postgresql -e POSTGRES_PASSWORD=password panubo/postgres:9.6-to-12-buster-upgrade -O "-c timescaledb.restoring='on'" --link
```

**Known Upgrade Issues**

* The VIEW created by prometheus-exporter can cause pg_upgrade to fail. If this occurs you should remove `postgres_exporter.pg_stat_activity` and re-install post upgrade with `/usr/local/bin/docker-initdb-run /docker-entrypoint-initdb.d/prometheus-exporter.sh`.
* Postgres images 9.6-dev and 12 have `POSTGRES_INITDB_ARGS="--data-checksum"` by default which will conflict if the source was not using data checksum. You can set `POSTGRES_INITDB_ARGS=""` to avoid the issue during upgrade.
* The `9.6-to-12-upgrade` image does NOT support timescaledb upgrade.
