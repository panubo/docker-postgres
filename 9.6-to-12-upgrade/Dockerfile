FROM panubo/postgres:9.6-debian-dev as pgold

FROM panubo/postgres:12-debian

COPY --from=pgold /usr/lib/postgresql/9.6/bin /usr/lib/postgresql/9.6/bin
COPY --from=pgold /usr/lib/postgresql/9.6/lib /usr/lib/postgresql/9.6/lib
COPY --from=pgold /usr/share/postgresql/9.6 /usr/share/postgresql/9.6

ENV \
  PGBINOLD=/usr/lib/postgresql/9.6/bin \
  PGBINNEW=/usr/lib/postgresql/12/bin \
  PGDATAOLD=/var/lib/postgresql/9.6/data \
  PGDATANEW=/var/lib/postgresql/12/data

RUN set -e \
  && mkdir -p "$PGDATAOLD" "$PGDATANEW" \
  && chown -R postgres:postgres /var/lib/postgresql \
  ;

COPY docker-upgrade /usr/local/bin/

WORKDIR /var/lib/postgresql

ENTRYPOINT ["docker-upgrade"]
CMD ["pg_upgrade", "-O", "-c timescaledb.restoring='on'", "--link"]
