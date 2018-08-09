FROM docker.io/postgres:10.4

ENV LANG en_AU.utf8
ENV POSTGRES_INITDB_ARGS "--locale=en_AU.utf8 --encoding=UTF8"
ENV TIMESCALEDB_VERSION=0.11.0 TIMESCALEDB_SHA1=0444c4c16ce7a1f7425f3c2046988916b9b9d784

# Build and install TimescaleDB extension
RUN apt-get update \
  && apt-get -y install curl cmake postgresql-server-dev-10 \
  && DIR=$(mktemp -d) && cd ${DIR} \
  && curl -s -L https://github.com/timescale/timescaledb/archive/${TIMESCALEDB_VERSION}.tar.gz -o timescaledb.tar.gz \
  && echo "${TIMESCALEDB_SHA1} timescaledb.tar.gz" | sha1sum -c - \
  && tar -xzf timescaledb.tar.gz --strip-components=1 \
  && ./bootstrap && cd build && make && make install \
  && apt-get -y remove curl cmake postgresql-server-dev-10 \
  && apt-get -y autoremove && apt-get clean \
  && rm -rf /var/lib/apt/lists/* ${DIR}

# Install Repmgr extension
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
  && apt-get update \
  && apt-get -y install postgresql-10-repmgr \
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

# Fix https://github.com/docker-library/postgres/issues/478
RUN usermod -d /var/lib/postgresql -s /bin/bash postgres
