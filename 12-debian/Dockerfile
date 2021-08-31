# Getting timescaledb-tune and other tools from the official timescaledb images
# The timescaledb version doesn't need to mactch the postgres version here
FROM timescale/timescaledb:latest-pg12 as tools

# FROM panubo/postgres:12 as oldversions

FROM docker.io/postgres:12

ENV POSTGIS_MAJOR=2.5
ENV TIMESCALEDB_VERSION=1.7.4 TIMESCALEDB_SHA256=d0b7a153ff3e02ecf033a869ecdf4286f8610ea76140baa84928fc3a80223e99
ENV WALG_VERSION=1.1 WALG_SHA256=78b815bad560ee2866c91a9dfc1a1810556358e089efffe057872a4ffa5cf3bc
ENV PGLOGICAL_VERSION=2.3.3-1.buster+1
ENV POSTGRES_INITDB_ARGS="--data-checksum"

# Install some system utils
RUN apt-get update \
  && apt-get -y install procps rsync lsb-release curl apt-transport-https \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  ;

# Install go-crond
RUN set -x \
  && GOCROND_VERSION=20.7.0 \
  && GOCROND_CHECKSUM=b3ec9055648f89dae1a7b0578862311ff9dec8320adb2450f3d5ade44ff31ab5 \
  && DIR=$(mktemp -d) && cd ${DIR} \
  && curl -sSf -L https://github.com/webdevops/go-crond/releases/download/${GOCROND_VERSION}/go-crond-64-linux -o go-crond-64-linux \
  && echo "${GOCROND_CHECKSUM}  go-crond-64-linux" | sha256sum -c - \
  && mv go-crond-64-linux /usr/local/bin/go-crond \
  && chmod +x /usr/local/bin/go-crond \
  && rm -rf ${DIR} \
  ;

# Install PostGIS extension
RUN apt-get update \
  && apt-get -y install --no-install-recommends postgresql-${PG_MAJOR}-postgis-${POSTGIS_MAJOR} postgresql-${PG_MAJOR}-postgis-${POSTGIS_MAJOR}-scripts postgis \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  ;

# Build and install TimescaleDB extension
RUN apt-get update \
  && apt-get -y install libssl1.1 \
  && apt-get -y install cmake clang-format-7 libssl-dev postgresql-server-dev-${PG_MAJOR} \
  && ln -s /usr/bin/clang-format-7 /usr/bin/clang-format \
  && DIR=$(mktemp -d) && cd ${DIR} \
  && curl -s -L https://github.com/timescale/timescaledb/archive/${TIMESCALEDB_VERSION}.tar.gz -o timescaledb.tar.gz \
  && sha256sum timescaledb.tar.gz \
  && echo "${TIMESCALEDB_SHA256} timescaledb.tar.gz" | sha256sum -c - \
  && tar -xzf timescaledb.tar.gz --strip-components=1 \
  && ./bootstrap -DREGRESS_CHECKS=OFF && cd build && make && make install \
  && apt-get -y remove cmake clang-format-7 libssl-dev postgresql-server-dev-${PG_MAJOR} \
  && apt-get -y autoremove && apt-get clean \
  && rm -rf /var/lib/apt/lists/* ${DIR} \
  && sed -r -i "s/[#]*\s*(shared_preload_libraries)\s*=\s*'(.*)'/\1 = 'timescaledb,\2'/;s/,'/'/" /usr/share/postgresql/postgresql.conf.sample \
  ;

# Install WAL-G
RUN set -x \
  && DIR=$(mktemp -d) && cd ${DIR} \
  && curl -sSf -L https://github.com/wal-g/wal-g/releases/download/v${WALG_VERSION}/wal-g-pg-ubuntu-18.04-amd64.tar.gz -o wal-g-pg-ubuntu-18.04-amd64.tar.gz \
  && echo "${WALG_SHA256}  wal-g-pg-ubuntu-18.04-amd64.tar.gz" | sha256sum -c - \
  && tar -xzf wal-g-pg-ubuntu-18.04-amd64.tar.gz \
  && cp wal-g-pg-ubuntu-18.04-amd64 /usr/local/bin/wal-g \
  && rm -rf ${DIR} \
  ;

# Install pglogical
RUN set -x \
  && DIR=$(mktemp -d) && cd ${DIR} \
  && curl -sSf -L https://dl.2ndquadrant.com/default/release/browse/apt/pool/main/2/2ndquadrant-repository-keys/2ndquadrant-repository-keys_2020.1-3.buster+1_all.deb -o 2ndquadrant-repository-keys_2020.1-3.buster+1_all.deb \
  && dpkg -i 2ndquadrant-repository-keys_2020.1-3.buster+1_all.deb \
  && apt-key add /usr/share/2ndquadrant-repository-keys/*.asc \
  && source_list_file="/etc/apt/sources.list.d/2ndquadrant-dl-default-release.list" \
  && echo "deb [arch=$(dpkg --print-architecture)] https://dl.2ndquadrant.com/default/release/apt $(lsb_release -cs)-2ndquadrant main" > "${source_list_file}" \
  && apt-get update \
  && apt-cache madison postgresql-${PG_MAJOR}-pglogical \
  && apt-get install -y postgresql-${PG_MAJOR}-pglogical=${PGLOGICAL_VERSION} \
  && apt-get -y autoremove && apt-get clean \
  && rm -rf /var/lib/apt/lists/* ${DIR} \
  && rm -rf ${DIR} \
  ;

COPY etc/* /etc/
RUN locale-gen

COPY bin/* /usr/local/bin/
COPY docker-initdb/* /docker-entrypoint-initdb.d/
COPY entry-init/* /entry-init.d/

ENTRYPOINT ["entry.sh"]
CMD ["postgres"]

COPY --from=tools /usr/local/bin/timescaledb-tune /usr/local/bin/timescaledb-parallel-copy /usr/local/bin/

# COPY --from=oldversions /usr/lib/postgresql/12/lib/timescaledb-*.so /usr/lib/postgresql/12/lib/
# COPY --from=oldversions /usr/share/postgresql/12/extension/timescaledb--*.sql /usr/share/postgresql/12/extension/

# COPY --from=oldversions /usr/lib/postgresql/12/lib/postgis-*.so /usr/lib/postgresql/12/lib/
# COPY --from=oldversions /usr/lib/postgresql/12/lib/postgis_topology-*.so /usr/lib/postgresql/12/lib/
# COPY --from=oldversions /usr/share/postgresql/12/extension/postgis--*.sql /usr/share/postgresql/12/extension/
# COPY --from=oldversions /usr/share/postgresql/12/extension/postgis_sfcgal--*.sql /usr/share/postgresql/12/extension/
# COPY --from=oldversions /usr/share/postgresql/12/extension/postgis_tiger_geocoder--*.sql /usr/share/postgresql/12/extension/
# COPY --from=oldversions /usr/share/postgresql/12/extension/postgis_topology--*.sql /usr/share/postgresql/12/extension/
