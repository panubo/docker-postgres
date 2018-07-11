FROM tianon/postgres-upgrade:9.2-to-9.6

COPY locale.gen /etc/locale.gen
RUN locale-gen
#ENV LANG en_AU.utf8
#ENV POSTGRES_INITDB_ARGS "--locale=en_AU.utf8 --encoding=UTF8"
