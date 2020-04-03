FROM panubo/postgres:10-debian as oldversions

FROM docker.io/postgres:10

ENV POSTGIS_MAJOR=2.5
ENV TIMESCALEDB_VERSION=1.6.1 TIMESCALEDB_SHA256=da0f9a6f36195392bbff7346c89a28c42a90762f4f5603443975887f781ecef6

# Install lsb-release
RUN apt-get update \
  && apt-get -y install --no-install-recommends lsb-release \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Install PostGIS extension
RUN apt-get update \
  && apt-get -y install --no-install-recommends postgresql-${PG_MAJOR}-postgis-${POSTGIS_MAJOR} postgresql-${PG_MAJOR}-postgis-${POSTGIS_MAJOR}-scripts \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Build and install TimescaleDB extension
RUN apt-get update \
  && apt-get -y install libssl1.1 \
  && apt-get -y install curl cmake clang-format-7 libssl-dev postgresql-server-dev-${PG_MAJOR} \
  && ln -s /usr/bin/clang-format-7 /usr/bin/clang-format \
  && DIR=$(mktemp -d) && cd ${DIR} \
  && curl -s -L https://github.com/timescale/timescaledb/archive/${TIMESCALEDB_VERSION}.tar.gz -o timescaledb.tar.gz \
  && sha256sum timescaledb.tar.gz \
  && echo "${TIMESCALEDB_SHA256} timescaledb.tar.gz" | sha256sum -c - \
  && tar -xzf timescaledb.tar.gz --strip-components=1 \
  && ./bootstrap -DREGRESS_CHECKS=OFF && cd build && make && make install \
  && apt-get -y remove curl cmake clang-format-7 libssl-dev postgresql-server-dev-${PG_MAJOR} \
  && apt-get -y autoremove && apt-get clean \
  && rm -rf /var/lib/apt/lists/* ${DIR} \
  && sed -r -i "s/[#]*\s*(shared_preload_libraries)\s*=\s*'(.*)'/\1 = 'timescaledb,\2'/;s/,'/'/" /usr/share/postgresql/postgresql.conf.sample \
  ;

# Install Repmgr extension
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
  && apt-get update \
  && apt-get -y install postgresql-${PG_MAJOR}-repmgr \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Install rsync for backup.sh
RUN apt-get update \
  && apt-get -y install rsync \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY etc/* /etc/
RUN locale-gen

COPY bin/* /
COPY docker-initdb/* /docker-entrypoint-initdb.d/
COPY entry-init/* /entry-init.d/

ENTRYPOINT ["/entry.sh", "docker-entrypoint.sh"]
CMD ["postgres"]

COPY --from=oldversions /usr/lib/postgresql/10/lib/timescaledb-*.so /usr/lib/postgresql/10/lib/
COPY --from=oldversions /usr/share/postgresql/10/extension/timescaledb--*.sql /usr/share/postgresql/10/extension/

COPY --from=oldversions /usr/lib/postgresql/10/lib/postgis-*.so /usr/lib/postgresql/10/lib/
COPY --from=oldversions /usr/lib/postgresql/10/lib/postgis_topology-*.so /usr/lib/postgresql/10/lib/
COPY --from=oldversions /usr/share/postgresql/10/extension/postgis--*.sql /usr/share/postgresql/10/extension/
COPY --from=oldversions /usr/share/postgresql/10/extension/postgis_sfcgal--*.sql /usr/share/postgresql/10/extension/
COPY --from=oldversions /usr/share/postgresql/10/extension/postgis_tiger_geocoder--*.sql /usr/share/postgresql/10/extension/
COPY --from=oldversions /usr/share/postgresql/10/extension/postgis_topology--*.sql /usr/share/postgresql/10/extension/
