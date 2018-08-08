FROM docker.io/postgres:10.4

ENV LANG en_AU.utf8
ENV POSTGRES_INITDB_ARGS "--locale=en_AU.utf8 --encoding=UTF8"
ENV TIMESCALEDB_VERSION=0.10.1

# Build and install TimescaleDB extension
RUN apt-get update \
  && apt-get -y install git cmake postgresql-server-dev-10 \
  && cd /tmp && git clone https://github.com/timescale/timescaledb.git && cd timescaledb \
  && git checkout ${TIMESCALEDB_VERSION} \
  && ./bootstrap && cd build && make && make install \
  && apt-get -y remove git cmake postgresql-server-dev-10 \
  && apt-get -y autoremove && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/timescaledb

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

COPY locale.gen /etc/locale.gen
RUN locale-gen

COPY dump.sh /dump.sh
COPY backup.sh /backup.sh
COPY configure-extensions.sh /docker-entrypoint-initdb.d/
