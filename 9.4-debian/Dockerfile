FROM docker.io/postgres:9.4

# Install rsync to backup script
RUN apt-get update && \
  apt-get -y install rsync && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

COPY locale.gen /etc/locale.gen
RUN locale-gen
ENV PSQLRC=/etc/psqlrc

COPY psqlrc /etc/psqlrc
COPY dump.sh /dump.sh
COPY backup.sh /backup.sh
