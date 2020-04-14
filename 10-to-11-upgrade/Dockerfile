FROM panubo/postgres:10-debian-1.6.1 as pgold

FROM panubo/postgres:11-debian

COPY --from=pgold /usr/lib/postgresql/10/bin /usr/lib/postgresql/10/bin
COPY --from=pgold /usr/lib/postgresql/10/lib /usr/lib/postgresql/10/lib
COPY --from=pgold /usr/share/postgresql/10 /usr/share/postgresql/10

ENV \
  PGBINOLD=/usr/lib/postgresql/10/bin \
  PGBINNEW=/usr/lib/postgresql/11/bin \
  PGDATAOLD=/var/lib/postgresql/10/data \
  PGDATANEW=/var/lib/postgresql/11/data

RUN set -e \
  && mkdir -p "$PGDATAOLD" "$PGDATANEW" \
  && chown -R postgres:postgres /var/lib/postgresql \
  ;

COPY docker-upgrade /usr/local/bin/

WORKDIR /var/lib/postgresql

ENTRYPOINT ["docker-upgrade"]
CMD ["pg_upgrade", "-O", "-c timescaledb.restoring='on'", "--link"]
