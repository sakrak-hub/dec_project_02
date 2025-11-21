FROM postgres:15-alpine

COPY ./init-scripts/ /docker-entrypoint-initdb.d/

RUN chmod +x /docker-entrypoint-initdb.d/*.sh

ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=password
ENV POSTGRES_DB=northwind

RUN { \
    echo ''; \
    echo '# CDC Configuration'; \
    echo 'wal_level = logical'; \
    echo 'max_wal_senders = 10'; \
    echo 'max_replication_slots = 10'; \
    echo 'wal_keep_size = 512'; \
    echo 'max_slot_wal_keep_size = 1024'; \
    } >> /usr/local/share/postgresql/postgresql.conf.sample

EXPOSE 5432