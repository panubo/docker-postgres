FROM panubo/postgres:11-buster as pgold

FROM panubo/postgres:12

COPY --from=pgold /usr/lib/postgresql/11/bin /usr/lib/postgresql/11/bin
COPY --from=pgold /usr/lib/postgresql/11/lib /usr/lib/postgresql/11/lib
COPY --from=pgold /usr/share/postgresql/11 /usr/share/postgresql/11

ENV \
  PGBINOLD=/usr/lib/postgresql/11/bin \
  PGBINNEW=/usr/lib/postgresql/12/bin \
  PGDATAOLD=/var/lib/postgresql/11/data \
  PGDATANEW=/var/lib/postgresql/12/data

RUN set -e \
  && mkdir -p "$PGDATAOLD" "$PGDATANEW" \
  && chown -R postgres:postgres /var/lib/postgresql \
  ;

COPY docker-upgrade /usr/local/bin/

WORKDIR /var/lib/postgresql

ENTRYPOINT ["docker-upgrade"]
CMD ["pg_upgrade", "-O", "-c timescaledb.restoring='on'", "--link"]
