#!/bin/bash
set -e

until pg_isready -U "$POSTGRES_USER"; do
  echo "Waiting for PostgreSQL..."
  sleep 2
done

psql --username "$POSTGRES_USER" <<-EOSQL
    CREATE DATABASE northwind;
    GRANT ALL PRIVILEGES ON DATABASE northwind TO $POSTGRES_USER;
EOSQL

psql -U "$POSTGRES_USER" -d northwind -f /docker-entrypoint-initdb.d/northwind.sql

psql -U "$POSTGRES_USER" -d "northwind" <<-EOSQL
    ALTER USER $POSTGRES_USER REPLICATION;
EOSQL

psql -U "$POSTGRES_USER" -d "northwind" <<-EOSQL
    SELECT pg_create_logical_replication_slot('airbyte_slot_northwind', 'pgoutput');
EOSQL

psql -U "$POSTGRES_USER" -d "northwind" <<-EOSQL
    ALTER TABLE categories REPLICA IDENTITY DEFAULT;
    ALTER TABLE customers REPLICA IDENTITY DEFAULT;
    ALTER TABLE customer_customer_demo REPLICA IDENTITY DEFAULT;
    ALTER TABLE customer_demographics REPLICA IDENTITY DEFAULT;
    ALTER TABLE employees REPLICA IDENTITY DEFAULT;
    ALTER TABLE employee_territories REPLICA IDENTITY DEFAULT;
    ALTER TABLE orders REPLICA IDENTITY DEFAULT;
    ALTER TABLE order_details REPLICA IDENTITY DEFAULT;
    ALTER TABLE products REPLICA IDENTITY DEFAULT;
    ALTER TABLE region REPLICA IDENTITY DEFAULT;
    ALTER TABLE shippers REPLICA IDENTITY DEFAULT;
    ALTER TABLE suppliers REPLICA IDENTITY DEFAULT;
    ALTER TABLE territories REPLICA IDENTITY DEFAULT;
    ALTER TABLE us_states REPLICA IDENTITY DEFAULT;
EOSQL

psql -U "$POSTGRES_USER" -d "northwind" <<-EOSQL
    CREATE PUBLICATION airbyte_publication_northwind FOR TABLE 
        categories, customers, customer_customer_demo,
        customer_demographics, employees, employee_territories,
        orders, order_details, products, region, shippers,
        suppliers, territories, us_states;
EOSQL