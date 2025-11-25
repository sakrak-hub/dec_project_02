# Postgres to Snowflake CDC Pipeline Setup

A complete guide for setting up a Change Data Capture (CDC) pipeline that replicates data from PostgreSQL (Northwind database) to Snowflake using Airbyte.

## Prerequisites

Before you begin, ensure you have the following installed:

- **Docker Desktop** - For running PostgreSQL in containers
- **Airbyte** - For data replication ([Installation Guide](https://docs.airbyte.com/deploying-airbyte/local-deployment))
- **Snowflake Account** - With appropriate permissions to create databases, warehouses, and users
- **pgAdmin** (Optional) - Included in docker-compose for database management

## Project Structure

```
.
├── airbyte-config
│   └── airbyte_snowflake_setup.sql
├── docker-compose.yml
└── source-db
    ├── Dockerfile
    └── init-scripts
        ├── 01-init-northwind.sh
        └── northwind.sql
```

## Architecture Overview

This pipeline implements CDC using PostgreSQL's logical replication:

- **Source**: PostgreSQL 15 with Northwind database
- **Replication Method**: PostgreSQL logical replication with `pgoutput` plugin
- **Replication Slot**: `airbyte_slot_northwind`
- **Publication**: `airbyte_publication_northwind` (covers all 14 tables)
- **Destination**: Snowflake (`NORTHWIND` database, `RAW` schema)

## Step-by-Step Setup Guide

### Step 1: Start PostgreSQL Source Database

Build and start the PostgreSQL container with the Northwind database:

```bash
docker-compose up --build -d
```

This command will:
- Build the PostgreSQL container with CDC configurations
- Load the Northwind database schema and data
- Create a logical replication slot (`airbyte_slot_northwind`)
- Set up a publication for all tables
- Configure replica identity for CDC

**Verify the setup:**

```bash
# Check if container is running
docker ps

# Check PostgreSQL logs
docker logs postgres-sources
```

**Database Connection Details:**
- Host: `localhost`
- Port: `5433`
- Database: `northwind`
- Username: `postgres`
- Password: `password`

### Step 2: Access pgAdmin (Optional)

If you want to explore the database using pgAdmin:

1. Open your browser and navigate to: `http://localhost:8080`
2. Login with:
   - Email: `admin@example.com`
   - Password: `adminpassword`
3. Add a new server connection:
   - **General > Name**: Northwind DB
   - **Connection > Host**: `postgres-sources`
   - **Connection > Port**: `5432`
   - **Connection > Database**: `northwind`
   - **Connection > Username**: `postgres`
   - **Connection > Password**: `password`

### Step 3: Configure Airbyte Source (PostgreSQL)

1. Open Airbyte UI (typically `http://localhost:8000`)
2. Navigate to **Sources** and click **+ New source**
3. Select **Postgres** as the source type
4. Configure with the following settings:

**Basic Configuration:**
- **Source name**: `Northwind PostgreSQL` (or your preferred name)
- **Host**: `host.docker.internal` (if Airbyte is in Docker) or `localhost`
- **Port**: `5433`
- **Database**: `northwind`
- **Username**: `postgres`
- **Password**: `password`

**Replication Settings:**
- **Replication Method**: Select **Logical Replication (CDC)**
- **Replication Slot**: `airbyte_slot_northwind`
- **Publication**: `airbyte_publication_northwind`

**Advanced Settings (Optional):**
- **SSL Mode**: `prefer` or `disable` (for local development)
- **Schemas**: Leave empty to replicate all schemas, or specify `public`

5. Click **Set up source** and wait for the connection test to complete

### Step 4: Configure Snowflake Destination

First, set up the Snowflake environment by running the provided SQL script.

**In Snowflake:**

1. Open a Snowflake worksheet
2. Open the `airbyte_snowflake_setup.sql` file
3. **IMPORTANT**: Update the `airbyte_password` variable with a secure password:
   ```sql
   SET airbyte_password = 'your_secure_password_here';
   ```
4. Run the entire script

This script will create:
- **Role**: `AIRBYTE_ROLE`
- **User**: `AIRBYTE_USER` (with the password you specified)
- **Warehouse**: `AIRBYTE_WAREHOUSE` (X-Small, auto-suspend in 60s)
- **Database**: `NORTHWIND`
- **Schema**: `RAW` (created automatically by Airbyte)

**In Airbyte:**

1. Navigate to **Destinations** and click **+ New destination**
2. Select **Snowflake** as the destination type
3. Configure with the following settings:

**Basic Configuration:**
- **Destination name**: `Snowflake - Northwind` (or your preferred name)
- **Account**: Your Snowflake account identifier (e.g., `xy12345.us-east-1`)
- **Database**: `NORTHWIND`
- **Default Schema**: `RAW`
- **Username**: `AIRBYTE_USER`
- **Password**: The password you set in the SQL script
- **Warehouse**: `AIRBYTE_WAREHOUSE`
- **Role**: `AIRBYTE_ROLE`

**Loading Method:**
- Select your preferred loading method (typically **Internal Staging** for simplicity)

4. Click **Set up destination** and wait for the connection test to complete

### Step 5: Create Connection

1. Navigate to **Connections** and click **+ New connection**
2. Select your source: **Northwind PostgreSQL**
3. Select your destination: **Snowflake - Northwind**
4. Configure the connection:

**Transfer Settings:**
- **Replication frequency**: Choose your preferred schedule (e.g., Every 24 hours, Every hour, Manual)
- **Destination Namespace**: `<destination default>` (will use `RAW` schema)

**Streams:**
- Select the tables you want to replicate (all 14 Northwind tables should be available)
- For each table, set **Sync mode** to **Incremental | Append + Deduped**

**Normalization & Transformation (Optional):**
- Enable **Normalized tabular data** if you want Airbyte to create normalized views
- Add dbt transformations if needed

5. Click **Set up connection**

### Step 6: Start Data Sync

1. Once the connection is created, click **Sync now** to start the initial data transfer
2. Monitor the sync progress in the connection's **Job History**
3. Wait for the sync to complete successfully

### Step 7: Verify Data in Snowflake

After the sync completes, verify the data in Snowflake:

```sql
-- Switch to appropriate role and warehouse
USE ROLE AIRBYTE_ROLE;
USE WAREHOUSE AIRBYTE_WAREHOUSE;
USE DATABASE NORTHWIND;
USE SCHEMA RAW;

-- List all tables
SHOW TABLES;

-- Check record counts
SELECT 'categories' AS table_name, COUNT(*) AS record_count FROM categories
UNION ALL
SELECT 'customers', COUNT(*) FROM customers
UNION ALL
SELECT 'employees', COUNT(*) FROM employees
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_details', COUNT(*) FROM order_details
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'suppliers', COUNT(*) FROM suppliers
UNION ALL
SELECT 'shippers', COUNT(*) FROM shippers
UNION ALL
SELECT 'territories', COUNT(*) FROM territories
UNION ALL
SELECT 'region', COUNT(*) FROM region
UNION ALL
SELECT 'employee_territories', COUNT(*) FROM employee_territories
UNION ALL
SELECT 'customer_demographics', COUNT(*) FROM customer_demographics
UNION ALL
SELECT 'customer_customer_demo', COUNT(*) FROM customer_customer_demo
UNION ALL
SELECT 'us_states', COUNT(*) FROM us_states;

-- Sample data from a table
SELECT * FROM orders LIMIT 10;
```

## 🎉 Congratulations!

You have successfully set up a CDC pipeline from PostgreSQL to Snowflake using Airbyte. Your data will now sync automatically based on the replication frequency you configured.

## Testing CDC Functionality

To verify that CDC is working properly, make changes in PostgreSQL and observe them in Snowflake:

```sql
-- In PostgreSQL (via pgAdmin or psql)
INSERT INTO categories (category_name, description) 
VALUES ('Test Category', 'Testing CDC functionality');

-- Wait for the next sync cycle, then check in Snowflake
SELECT * FROM categories WHERE category_name = 'Test Category';
```

## Troubleshooting

### PostgreSQL Connection Issues

**Problem**: Airbyte cannot connect to PostgreSQL

**Solutions**:
- Verify the container is running: `docker ps`
- Check port mapping: Ensure port `5433` is not in use
- Use `host.docker.internal` instead of `localhost` if Airbyte runs in Docker
- Check firewall settings

### Replication Slot Issues

**Problem**: Replication slot already exists or is active

**Solution**:
```sql
-- Connect to PostgreSQL
psql -U postgres -d northwind -p 5433

-- Check existing slots
SELECT * FROM pg_replication_slots;

-- Drop and recreate if necessary (only if not in use)
SELECT pg_drop_replication_slot('airbyte_slot_northwind');
SELECT pg_create_logical_replication_slot('airbyte_slot_northwind', 'pgoutput');
```

### Snowflake Permission Issues

**Problem**: Insufficient privileges errors

**Solution**:
- Verify the SQL setup script ran completely
- Ensure the password was set correctly
- Check role assignments: `SHOW GRANTS TO ROLE AIRBYTE_ROLE;`
- Verify warehouse is running: `SHOW WAREHOUSES;`

### Sync Failures

**Problem**: Airbyte sync fails repeatedly

**Solutions**:
- Check the job logs in Airbyte UI for specific error messages
- Verify network connectivity between Airbyte and both databases
- Check disk space and memory on Docker host
- Review Airbyte logs: `docker logs airbyte-server`

## Tables Included

The Northwind database includes the following tables:

1. **categories** - Product categories
2. **customers** - Customer information
3. **customer_customer_demo** - Customer demographics mapping
4. **customer_demographics** - Demographic information
5. **employees** - Employee records
6. **employee_territories** - Employee territory assignments
7. **orders** - Order headers
8. **order_details** - Order line items
9. **products** - Product catalog
10. **region** - Region definitions
11. **shippers** - Shipping companies
12. **suppliers** - Supplier information
13. **territories** - Sales territories
14. **us_states** - US state information


## Additional Resources

- [Airbyte Documentation](https://docs.airbyte.com)
- [PostgreSQL Logical Replication](https://www.postgresql.org/docs/current/logical-replication.html)
- [Snowflake Documentation](https://docs.snowflake.com)
- [Northwind Database Guide](https://github.com/pthom/northwind_psql)

## License

This setup guide is provided as-is for educational and development purposes.

---

**Questions or Issues?** Feel free to reach out or open an issue in your project repository.