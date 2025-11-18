#!/bin/bash
set -e

until pg_isready -U "$POSTGRES_USER"; do
  echo "Waiting for PostgreSQL..."
  sleep 2
done

psql --username "$POSTGRES_USER" <<-EOSQL
    CREATE DATABASE dvdrental;
    GRANT ALL PRIVILEGES ON DATABASE dvdrental TO $POSTGRES_USER;
EOSQL

pg_restore -U "$POSTGRES_USER" -d dvdrental /docker-entrypoint-initdb.d/dvdrental.tar

psql -U "$POSTGRES_USER" -d "dvdrental" <<-EOSQL
    ALTER USER $POSTGRES_USER REPLICATION;
EOSQL

psql -U "$POSTGRES_USER" -d "dvdrental" <<-EOSQL
    SELECT pg_create_logical_replication_slot('airbyte_slot_dvdrental', 'pgoutput');
EOSQL

psql -U "$POSTGRES_USER" -d "dvdrental" <<-EOSQL
    ALTER TABLE rental REPLICA IDENTITY DEFAULT;
    ALTER TABLE payment REPLICA IDENTITY DEFAULT;
    ALTER TABLE inventory REPLICA IDENTITY DEFAULT;
    ALTER TABLE customer REPLICA IDENTITY DEFAULT;
    ALTER TABLE film REPLICA IDENTITY DEFAULT;
    ALTER TABLE film_actor REPLICA IDENTITY DEFAULT;
    ALTER TABLE film_category REPLICA IDENTITY DEFAULT;
    ALTER TABLE actor REPLICA IDENTITY DEFAULT;
    ALTER TABLE category REPLICA IDENTITY DEFAULT;
    ALTER TABLE store REPLICA IDENTITY DEFAULT;
    ALTER TABLE staff REPLICA IDENTITY DEFAULT;
    ALTER TABLE address REPLICA IDENTITY DEFAULT;
    ALTER TABLE city REPLICA IDENTITY DEFAULT;
    ALTER TABLE country REPLICA IDENTITY DEFAULT;
    ALTER TABLE language REPLICA IDENTITY DEFAULT;
EOSQL

psql -U "$POSTGRES_USER" -d "dvdrental" <<-EOSQL
    CREATE PUBLICATION airbyte_publication_dvdrental  FOR TABLE 
        rental, payment, inventory, customer, film,
        film_actor, film_category, actor, category,
        store, staff, address, city, country, language;
EOSQL