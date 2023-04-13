FROM quay.io/panubo/postgres:12-bullseye as pgold

FROM quay.io/panubo/postgres:14-bullseye

COPY --from=pgold /usr/lib/postgresql/12/bin /usr/lib/postgresql/12/bin
COPY --from=pgold /usr/lib/postgresql/12/lib /usr/lib/postgresql/12/lib
COPY --from=pgold /usr/share/postgresql/12 /usr/share/postgresql/12

ENV \
  PGBINOLD=/usr/lib/postgresql/12/bin \
  PGBINNEW=/usr/lib/postgresql/14/bin \
  PGDATAOLD=/var/lib/postgresql/12/data \
  PGDATANEW=/var/lib/postgresql/14/data

RUN set -e \
  && mkdir -p "$PGDATAOLD" "$PGDATANEW" \
  && chown -R postgres:postgres /var/lib/postgresql \
  ;

COPY docker-upgrade /usr/local/bin/

WORKDIR /var/lib/postgresql

ENTRYPOINT ["docker-upgrade"]
CMD ["pg_upgrade", "-O", "-c timescaledb.restoring='on'", "--link"]
