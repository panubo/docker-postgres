# Getting timescaledb-tune and other tools from the official timescaledb images
# The timescaledb version doesn't need to mactch the postgres version here
FROM timescale/timescaledb:latest-pg14 AS tools

FROM quay.io/panubo/postgres:14-debian13 AS oldversions

FROM docker.io/postgres:14-trixie

ENV TIMESCALEDB_VERSION=2.17.2 TIMESCALEDB_SHA256=b2fcc29e9975b88c5323aefb062346326694c391d52af46186f5a5ad09136d47
ENV WALG_VERSION=3.0.7 WALG_AMD64_SHA256=76d51ed915165d45314bc947300b9d1776adb2d875d857f580a730fd6f66900e WALG_AARCH64_SHA256=fcf25aac732f66e77e121e9d287a08d8bf867c604b81cb6fcfff2d6c692d38c9
ENV POSTGRES_INITDB_ARGS="--data-checksums"

# Install some system utils
RUN set -x \
  && apt-get update \
  && apt-get -y install procps lsb-release curl apt-transport-https \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
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
  && if [ "$(uname -m)" = "x86_64" ] ; then \
  WALG_SHA256="${WALG_AMD64_SHA256}"; \
  WALG_ARCH="amd64"; \
  elif [ "$(uname -m)" = "aarch64" ]; then \
  WALG_SHA256="${WALG_AARCH64_SHA256}"; \
  WALG_ARCH="aarch64"; \
  fi \
  && curl -sSf -L https://github.com/wal-g/wal-g/releases/download/v${WALG_VERSION}/wal-g-pg-ubuntu-22.04-${WALG_ARCH}.tar.gz -o wal-g-pg-ubuntu-22.04-${WALG_ARCH}.tar.gz \
  && ( echo "${WALG_SHA256} wal-g-pg-ubuntu-22.04-${WALG_ARCH}.tar.gz" | sha256sum -c - || ( echo "Expected $(sha256sum wal-g-pg-ubuntu-22.04-${WALG_ARCH}.tar.gz)"; exit 1; )) \
  && tar -xzf wal-g-pg-ubuntu-22.04-${WALG_ARCH}.tar.gz \
  && cp wal-g-pg-ubuntu-22.04-${WALG_ARCH} /usr/local/bin/wal-g \
  && rm -rf ${DIR} \
  ;

# Install postgis
RUN set -x \
  && apt-get update \
  && apt-get install -y postgresql-${PG_MAJOR}-postgis \
  && apt-get -y autoremove \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
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

COPY --from=oldversions /usr/lib/postgresql/14/lib/timescaledb-*.so /usr/lib/postgresql/14/lib/
COPY --from=oldversions /usr/share/postgresql/14/extension/timescaledb--*.sql /usr/share/postgresql/14/extension/

# COPY --from=oldversions /usr/lib/postgresql/14/lib/postgis-*.so /usr/lib/postgresql/14/lib/
# COPY --from=oldversions /usr/lib/postgresql/14/lib/postgis_topology-*.so /usr/lib/postgresql/14/lib/
# COPY --from=oldversions /usr/share/postgresql/14/extension/postgis--*.sql /usr/share/postgresql/14/extension/
# COPY --from=oldversions /usr/share/postgresql/14/extension/postgis_sfcgal--*.sql /usr/share/postgresql/14/extension/
# COPY --from=oldversions /usr/share/postgresql/14/extension/postgis_tiger_geocoder--*.sql /usr/share/postgresql/14/extension/
# COPY --from=oldversions /usr/share/postgresql/14/extension/postgis_topology--*.sql /usr/share/postgresql/14/extension/
