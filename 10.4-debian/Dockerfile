FROM docker.io/postgres:10.4

# Install rsync to backup script
RUN apt-get update && \
  apt-get -y install rsync && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

COPY locale.gen /etc/locale.gen
RUN locale-gen
ENV LANG en_AU.utf8
ENV POSTGRES_INITDB_ARGS "--locale=en_AU.utf8 --encoding=UTF8"

COPY dump.sh /dump.sh
COPY backup.sh /backup.sh
