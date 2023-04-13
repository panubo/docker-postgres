# Getting timescaledb-tune and other tools from the official timescaledb images
# The timescaledb version doesn't need to mactch the postgres version here
FROM timescale/timescaledb:latest-pg12 as tools

FROM quay.io/panubo/postgres:12-bullseye as oldversions

FROM docker.io/postgres:12-bullseye

ENV POSTGIS_VERSION=3.1.8 POSTGIS_SHA256=54254fb57070ce44d1da9434f472e0a82df0ef24321c2b9a22c449f756e278e7
ENV TIMESCALEDB_VERSION=2.9.3 TIMESCALEDB_SHA256=ff0820891646a772aceab19ee0f7da0a5343dc53b9a72c965ab70f723d231d5c
ENV WALG_VERSION=1.1 WALG_SHA256=c922c46c770fa5edd38bd60bfacdb92d813272d5d6bd2fc83ef57084b9c6c68c
ENV PGLOGICAL_VERSION=2.4.2-1.bullseye+1
ENV POSTGRES_INITDB_ARGS="--data-checksum"

# Install some system utils
RUN apt-get update \
  && apt-get -y install procps rsync lsb-release curl apt-transport-https \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  ;

# Install go-crond
RUN set -x \
  && GOCROND_VERSION=21.5.0 \
  && GOCROND_CHECKSUM=9a412a3354da6d885ac2156e6d8dda5fdff7a7368134a02e05783ae745c8c88b \
  && DIR=$(mktemp -d) && cd ${DIR} \
  && curl -sSf -L https://github.com/webdevops/go-crond/releases/download/${GOCROND_VERSION}/go-crond-64-linux -o go-crond-64-linux \
  && echo "${GOCROND_CHECKSUM}  go-crond-64-linux" | sha256sum -c - \
  && mv go-crond-64-linux /usr/local/bin/go-crond \
  && chmod +x /usr/local/bin/go-crond \
  && rm -rf ${DIR} \
  ;

# Install PostGIS extension
RUN apt-get update \
  && apt-get -y install build-essential libsfcgal-dev libxml2-dev libgdal-dev libproj-dev libjson-c-dev libprotobuf-c-dev libgeos-dev libsfcgal1 libgdal28 libjson-c5 libproj19 libgeos-c1v5 libprotobuf-c1 protobuf-c-compiler xsltproc docbook-xsl docbook-mathml postgresql-server-dev-${PG_MAJOR} \
  && DIR=$(mktemp -d) && cd ${DIR} \
  && curl -s -L https://download.osgeo.org/postgis/source/postgis-${POSTGIS_VERSION}.tar.gz -o postgis.tar.gz \
  && sha256sum postgis.tar.gz \
  && echo "${POSTGIS_SHA256} postgis.tar.gz" | sha256sum -c - \
  && tar -xzf postgis.tar.gz --strip-components=1 \
  && ./configure --with-sfcgal && make -j 4 && make install \
  && apt-get -y remove build-essential libsfcgal-dev libxml2-dev libgdal-dev libproj-dev libjson-c-dev libprotobuf-c-dev libgeos-dev xsltproc docbook-xsl docbook-mathml postgresql-server-dev-${PG_MAJOR} \
  && apt-get -y autoremove && apt-get clean \
  && rm -rf /var/lib/apt/lists/* ${DIR} \
  && sed -r -i "s/[#]*\s*(shared_preload_libraries)\s*=\s*'(.*)'/\1 = 'postgis,\2'/;s/,'/'/" /usr/share/postgresql/postgresql.conf.sample \
  ;

# Build and install TimescaleDB extension
RUN apt-get update \
  && apt-get -y install libssl1.1 \
  && apt-get -y install cmake clang-format-11 libkrb5-dev libssl-dev postgresql-server-dev-${PG_MAJOR} \
  && ln -s /usr/bin/clang-format-7 /usr/bin/clang-format \
  && DIR=$(mktemp -d) && cd ${DIR} \
  && curl -s -L https://github.com/timescale/timescaledb/archive/${TIMESCALEDB_VERSION}.tar.gz -o timescaledb.tar.gz \
  && sha256sum timescaledb.tar.gz \
  && echo "${TIMESCALEDB_SHA256} timescaledb.tar.gz" | sha256sum -c - \
  && tar -xzf timescaledb.tar.gz --strip-components=1 \
  && ./bootstrap -DREGRESS_CHECKS=OFF && cd build && make && make install \
  && apt-get -y remove cmake clang-format-11 libkrb5-dev libssl-dev postgresql-server-dev-${PG_MAJOR} \
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
  && DIR=$(mktemp -d) && cd ${DIR} \
  && curl -sSf -L https://dl.2ndquadrant.com/default/release/browse/apt/pool/main/2/2ndquadrant-repository-keys/2ndquadrant-repository-keys_2023.1-1.bullseye+1_all.deb -o 2ndquadrant-repository-keys_2023.1-1.bullseye+1_all.deb \
  && dpkg -i 2ndquadrant-repository-keys_2023.1-1.bullseye+1_all.deb \
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

COPY --from=oldversions /usr/lib/postgresql/12/lib/timescaledb-*.so /usr/lib/postgresql/12/lib/
COPY --from=oldversions /usr/share/postgresql/12/extension/timescaledb--*.sql /usr/share/postgresql/12/extension/

COPY --from=oldversions /usr/lib/postgresql/12/lib/postgis-*.so /usr/lib/postgresql/12/lib/
COPY --from=oldversions /usr/lib/postgresql/12/lib/postgis_topology-*.so /usr/lib/postgresql/12/lib/
COPY --from=oldversions /usr/share/postgresql/12/extension/postgis--*.sql /usr/share/postgresql/12/extension/
COPY --from=oldversions /usr/share/postgresql/12/extension/postgis_sfcgal--*.sql /usr/share/postgresql/12/extension/
COPY --from=oldversions /usr/share/postgresql/12/extension/postgis_tiger_geocoder--*.sql /usr/share/postgresql/12/extension/
COPY --from=oldversions /usr/share/postgresql/12/extension/postgis_topology--*.sql /usr/share/postgresql/12/extension/
