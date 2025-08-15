# Getting timescaledb-tune and other tools from the official timescaledb images
# The timescaledb version doesn't need to mactch the postgres version here
FROM timescale/timescaledb:latest-pg14 AS tools

# FROM quay.io/panubo/postgres:14-debian13 AS oldversions

FROM docker.io/postgres:14-trixie

ENV POSTGIS_VERSION=3.1.8 POSTGIS_SHA256=54254fb57070ce44d1da9434f472e0a82df0ef24321c2b9a22c449f756e278e7
ENV TIMESCALEDB_VERSION=2.5.2 TIMESCALEDB_SHA256=b1a20832189c22ce378f009f9a24ef1db61d7131f7f79bde74fdcde87bcf2d7c
ENV WALG_VERSION=2.0.1 WALG_SHA256=2640cb9110e802bf971efdc9b7a35515af7757e06693bf5c81bd4915d8d42b9c
ENV POSTGRES_INITDB_ARGS="--data-checksums"

# Install some system utils
RUN set -x \
  && apt-get update \
  && apt-get -y install procps lsb-release curl apt-transport-https \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  ;

# Install PostGIS extension
RUN set -x \
  && apt-get update \
  && apt-get -y install build-essential libsfcgal-dev libxml2-dev libgdal-dev libproj-dev libjson-c-dev libprotobuf-c-dev libgeos-dev libsfcgal2 libgdal36 libjson-c5 libproj25 libgeos-c1v5 libprotobuf-c1 protobuf-c-compiler xsltproc docbook-xsl docbook-mathml postgresql-server-dev-${PG_MAJOR} \
  && DIR=$(mktemp -d) && cd ${DIR} \
  && curl -s -L https://download.osgeo.org/postgis/source/postgis-${POSTGIS_VERSION}.tar.gz -o postgis.tar.gz \
  && sha256sum postgis.tar.gz \
  && echo "${POSTGIS_SHA256} postgis.tar.gz" | sha256sum -c - \
  && tar -xzf postgis.tar.gz --strip-components=1 \
  && ./configure --with-sfcgal && make -j 4 && make install \
  && apt-get -y remove build-essential libsfcgal-dev libxml2-dev libgdal-dev libproj-dev libjson-c-dev libprotobuf-c-dev libgeos-dev xsltproc docbook-xsl docbook-mathml postgresql-server-dev-${PG_MAJOR} \
  && apt-get -y autoremove && apt-get clean \
  && rm -rf /var/lib/apt/lists/* ${DIR} \
  && sed -r -i "s/[#]*\s*(shared_preload_libraries)\s*=\s*'(.*)'/\1 = 'postgis-3,\2'/;s/,'/'/" /usr/share/postgresql/postgresql.conf.sample \
  ;

# Build and install TimescaleDB extension
RUN set -x \
  && apt-get update \
  && apt-get -y install libssl3 \
  && apt-get -y install cmake clang-format libkrb5-dev libssl-dev postgresql-server-dev-${PG_MAJOR} \
  # && ln -s /usr/bin/clang-format-7 /usr/bin/clang-format \
  && DIR=$(mktemp -d) && cd ${DIR} \
  && curl -s -L https://github.com/timescale/timescaledb/archive/${TIMESCALEDB_VERSION}.tar.gz -o timescaledb.tar.gz \
  && ( echo "${TIMESCALEDB_SHA256} timescaledb.tar.gz" | sha256sum -c - || ( echo "Expected $(sha256sum timescaledb.tar.gz)"; exit 1; )) \
  && tar -xzf timescaledb.tar.gz --strip-components=1 \
  && ./bootstrap -DREGRESS_CHECKS=OFF && cd build && make && make install \
  && apt-get -y remove cmake clang-format libkrb5-dev libssl-dev postgresql-server-dev-${PG_MAJOR} \
  && apt-get -y autoremove && apt-get clean \
  && rm -rf /var/lib/apt/lists/* ${DIR} \
  && sed -r -i "s/[#]*\s*(shared_preload_libraries)\s*=\s*'(.*)'/\1 = 'timescaledb,\2'/;s/,'/'/" /usr/share/postgresql/postgresql.conf.sample \
  ;

# Install WAL-G
RUN set -x \
  && DIR=$(mktemp -d) && cd ${DIR} \
  && curl -sSf -L https://github.com/wal-g/wal-g/releases/download/v${WALG_VERSION}/wal-g-pg-ubuntu-20.04-amd64.tar.gz -o wal-g-pg-ubuntu-20.04-amd64.tar.gz \
  && echo "${WALG_SHA256}  wal-g-pg-ubuntu-20.04-amd64.tar.gz" | sha256sum -c - \
  && tar -xzf wal-g-pg-ubuntu-20.04-amd64.tar.gz \
  && cp wal-g-pg-ubuntu-20.04-amd64 /usr/local/bin/wal-g \
  && rm -rf ${DIR} \
  ;

# Install pglogical
RUN set -x \
  && apt-get update \
  && apt-get install -y postgresql-${PG_MAJOR}-pglogical \
  && apt-get -y autoremove \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf ${DIR} \
  ;

# Install pg_cron
RUN set -x \
  && apt-get update \
  && apt-get install -y postgresql-${PG_MAJOR}-cron \
  && apt-get -y autoremove \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf ${DIR} \
  && sed -r -i "s/[#]*\s*(shared_preload_libraries)\s*=\s*'(.*)'/\1 = 'pg_cron,\2'/;s/,'/'/" /usr/share/postgresql/postgresql.conf.sample \
  ;

COPY etc/* /etc/
RUN locale-gen

COPY bin/* /usr/local/bin/
COPY docker-entrypoint-initdb.d/* /docker-entrypoint-initdb.d/
COPY entry-init.d/* /entry-init.d/

ENTRYPOINT ["entry.sh"]
CMD ["postgres"]

COPY --from=tools /usr/local/bin/timescaledb-tune /usr/local/bin/timescaledb-parallel-copy /usr/local/bin/

# COPY --from=oldversions /usr/lib/postgresql/14/lib/timescaledb-*.so /usr/lib/postgresql/14/lib/
# COPY --from=oldversions /usr/share/postgresql/14/extension/timescaledb--*.sql /usr/share/postgresql/14/extension/

# COPY --from=oldversions /usr/lib/postgresql/14/lib/postgis-*.so /usr/lib/postgresql/14/lib/
# COPY --from=oldversions /usr/lib/postgresql/14/lib/postgis_topology-*.so /usr/lib/postgresql/14/lib/
# COPY --from=oldversions /usr/share/postgresql/14/extension/postgis--*.sql /usr/share/postgresql/14/extension/
# COPY --from=oldversions /usr/share/postgresql/14/extension/postgis_sfcgal--*.sql /usr/share/postgresql/14/extension/
# COPY --from=oldversions /usr/share/postgresql/14/extension/postgis_tiger_geocoder--*.sql /usr/share/postgresql/14/extension/
# COPY --from=oldversions /usr/share/postgresql/14/extension/postgis_topology--*.sql /usr/share/postgresql/14/extension/
