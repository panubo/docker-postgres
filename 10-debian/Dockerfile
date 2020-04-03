FROM docker.io/postgres:10

ENV POSTGIS_MAJOR=2.4
ENV TIMESCALEDB_VERSION=1.1.1 TIMESCALEDB_SHA256=c2f0f745f9ab52bf7fedd24e129efde5f39a0f27a8f41e1568aab98cd21d5a68

# Install lsb-release
RUN apt-get update \
  && apt-get -y install --no-install-recommends lsb-release \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Install PostGIS extension
RUN apt-get update \
  && apt-get -y install --no-install-recommends postgresql-${PG_MAJOR}-postgis-${POSTGIS_MAJOR} postgresql-${PG_MAJOR}-postgis-${POSTGIS_MAJOR}-scripts postgis \
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
  && rm -rf /var/lib/apt/lists/* ${DIR}

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
