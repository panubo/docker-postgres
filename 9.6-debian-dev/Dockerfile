# Getting timescaledb-tune and other tools from the official timescaledb images
# The timescaledb version doesn't need to mactch the postgres version here
FROM timescale/timescaledb:latest-pg12 as tools

FROM panubo/postgres:9.6-debian as oldversions

FROM docker.io/postgres:9.6

ENV POSTGIS_MAJOR=2.5
ENV TIMESCALEDB_VERSION=1.6.1 TIMESCALEDB_SHA256=da0f9a6f36195392bbff7346c89a28c42a90762f4f5603443975887f781ecef6
ENV WALG_VERSION=0.2.19 WALG_SHA256=1dc4c6cd65010d855bb5d6d27b1d9ee9b306615900a24977806b37cacdd18563

# Install some system utils
RUN apt-get update \
  && apt-get -y install procps rsync lsb-release curl \
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
  && rm -rf /var/lib/apt/lists/*

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

# Install Repmgr extension
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
  && apt-get update \
  && apt-get -y install postgresql-${PG_MAJOR}-repmgr \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN set -x \
  && DIR=$(mktemp -d) && cd ${DIR} \
  && curl -sSf -L https://github.com/wal-g/wal-g/releases/download/v${WALG_VERSION}/wal-g.linux-amd64.tar.gz -o wal-g.linux-amd64.tar.gz \
  && echo "${WALG_SHA256}  wal-g.linux-amd64.tar.gz" | sha256sum -c - \
  && tar -xzf wal-g.linux-amd64.tar.gz \
  && cp wal-g /usr/local/bin/wal-g \
  && rm -rf ${DIR} \
  ;

COPY etc/* /etc/
RUN locale-gen

# DEPRECATING scripts from / will be removed in a later version
COPY bin/* /
COPY bin/* /usr/local/bin/
COPY docker-initdb/* /docker-entrypoint-initdb.d/
COPY entry-init/* /entry-init.d/

ENTRYPOINT ["entry.sh"]
CMD ["postgres"]

COPY --from=tools /usr/local/bin/timescaledb-tune /usr/local/bin/timescaledb-parallel-copy /usr/local/bin/

COPY --from=oldversions /usr/lib/postgresql/9.6/lib/timescaledb-*.so /usr/lib/postgresql/9.6/lib/
COPY --from=oldversions /usr/share/postgresql/9.6/extension/timescaledb--*.sql /usr/share/postgresql/9.6/extension/

ENV POSTGRES_INITDB_ARGS="--data-checksum"

# COPY --from=oldversions /usr/lib/postgresql/9.6/lib/postgis-*.so /usr/lib/postgresql/9.6/lib/
# COPY --from=oldversions /usr/lib/postgresql/9.6/lib/postgis_topology-*.so /usr/lib/postgresql/9.6/lib/
# COPY --from=oldversions /usr/share/postgresql/9.6/extension/postgis--*.sql /usr/share/postgresql/9.6/extension/
# COPY --from=oldversions /usr/share/postgresql/9.6/extension/postgis_sfcgal--*.sql /usr/share/postgresql/9.6/extension/
# COPY --from=oldversions /usr/share/postgresql/9.6/extension/postgis_tiger_geocoder--*.sql /usr/share/postgresql/9.6/extension/
# COPY --from=oldversions /usr/share/postgresql/9.6/extension/postgis_topology--*.sql /usr/share/postgresql/9.6/extension/
