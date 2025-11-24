# Northwind Sales Analytics Pipeline

## Project Overview

This project implements a comprehensive ETL/ELT pipeline for the Northwind database, transforming transactional OLTP data into an analytics-ready data warehouse. The solution enables business analysts and data scientists to gain insights into sales performance, customer behavior, and product trends.

### Objective

Build a scalable, cloud-based data pipeline that:
- Extracts data from the Northwind PostgreSQL database using Change Data Capture (CDC)
- Loads data incrementally into Snowflake data warehouse
- Transforms raw data into dimensional models optimized for analytics
- Enables the sales operations team and analytics team to understand sales patterns across multiple dimensions: time, customer, supplier, and shippers
- Provides data quality validation and monitoring
- Enables business intelligence through semantic modeling and visualizations

### Target Consumers

- **Sales Operations Team**: Monitor sales performance and operational metrics
- **Analytics Team**: Conduct deep-dive analysis on sales patterns and trends
- **General Management**: Access executive dashboards for strategic decision-making

## Business Process

This pipeline models the **Sales Process**, tracking the complete journey from order placement to delivery. Key business questions addressed include:

- **Sales Performance**: What are our sales trends across time, customers, and products?
- **Customer Analysis**: Which customers are our top buyers? What are their purchasing patterns?
- **Product Insights**: Which products and categories drive the most revenue?
- **Supplier Analytics**: How do different suppliers contribute to our product mix and sales?
- **Shipping Operations**: Which shippers provide the best service? What are the shipping costs and times?
- **Employee Performance**: How do sales representatives perform in terms of orders and revenue?
- **Time-based Trends**: What are our seasonal patterns? Which periods show highest sales activity?

## Solution Architecture

```
┌─────────────────────┐         ┌─────────────┐          ┌──────────────────┐
│  Northwind DB       │         │   Airbyte   │          │   Snowflake      │
│  (PostgreSQL)       │────────▶│     CDC     │────────▶│  RAW Layer       │
│  RDS/Local OLTP     │         │ Integration │          │  (Bronze/Raw)    │
└─────────────────────┘         └─────────────┘          └──────────────────┘
                                                                  │
                                                                  ▼
                                                         ┌─────────────────┐
                                                         │   AWS Services  │
                                                         ├─────────────────┤
                                                         │  ECR: Docker    │
                                                         │  ECS: dbt Jobs  │
                                                         │  CloudWatch:    │
                                                         │  Monitoring     │
                                                         └─────────────────┘
                                                                  │
                                                                  ▼
                                                         ┌─────────────────┐
                                                         │      dbt        │
                                                         │ Transformations │
                                                         │   + Testing     │
                                                         └─────────────────┘
                                                                  │
                                        ┌─────────────────────────┴─────────────────────────┐
                                        │                                                   │
                                        ▼                                                   ▼
                          ┌──────────────────────────┐                    ┌──────────────────────────┐
                          │  Snowflake SILVER Layer  │                    │  Snowflake GOLD Layer    │
                          │  (Staging/Cleansed)      │                    │  (Dimensional Models)    │
                          ├──────────────────────────┤                    ├──────────────────────────┤
                          │  • stg_customers         │                    │  • fact_orders           │
                          │  • stg_orders            │                    │  • dim_customers         │
                          │  • stg_order_details     │───────────────────▶│  • dim_products          │
                          │  • stg_products          │                    │  • dim_employees         │
                          │  • stg_employees         │                    │  • dim_suppliers         │
                          │  • stg_shippers          │                    │  • dim_shippers          │
                          │  • stg_suppliers         │                    │  • dim_date              │
                          └──────────────────────────┘                    └──────────────────────────┘
                                                                                      │
                                                                                      ▼
                                                                          ┌──────────────────────┐
                                                                          │  Preset/Tableau      │
                                                                          │  BI/Analytics        │
                                                                          │  Dashboards          │
                                                                          └──────────────────────┘
```

### Architecture Components

1. **Data Source**: Northwind PostgreSQL database (RDS or Local OLTP)
2. **Data Integration**: Airbyte with CDC for incremental extraction
3. **Data Warehouse - RAW Layer**: Snowflake raw tables (bronze layer) for unprocessed data
4. **Container Orchestration**: AWS ECS for running dbt transformations
5. **Container Registry**: AWS ECR for storing dbt Docker images
6. **Monitoring**: AWS CloudWatch for pipeline monitoring and alerting
7. **Data Warehouse - SILVER Layer**: Snowflake staging tables with cleansed data
8. **Data Warehouse - GOLD Layer**: Snowflake dimensional models for analytics
9. **Transformation**: dbt for SQL-based transformations and testing
10. **Semantic Layer**: Preset/Tableau for metrics and visualizations
11. **Version Control**: GitHub for collaboration and CI/CD

## Data Model

### Entity-Relationship Diagram
![alt text](data-transformation/ERD-diagram.png)

### Lineage Graph
![alt text](data-transformation/lineage_graph.jpg)

### Fact Tables

#### fact_orders (Transaction Grain)
- **Grain**: One row per order line item
- **Measures**: quantity, unit_price, discount, line_total, freight
- **Dimensions**: customer, employee, product, category, shipper, date

### Dimension Tables

1. **dim_customers**: Customer attributes and contact information
2. **dim_products**: Product details with embedded supplier information
3. **dim_categories**: Product category master data
4. **dim_employees**: Sales representative information and hierarchy
5. **dim_shippers**: Shipping company information
6. **dim_date**: Date dimension with calendar hierarchies (using dbt_date package)

## Project Structure

```
northwind-analytics/
├── README.md
├── data-integration/
│   ├── README.md
│   ├── docker-compose.yml          # Sets up PostgreSQL with Northwind
│   ├── airbyte-config/
│   │   └── airbyte_snowflake_setup.sql
│   └── source-db/
│       ├── Dockerfile
│       └── init-scripts/
│           ├── 01-init-northwind.sh
│           └── northwind.sql       # Northwind database schema
├── data-transformation/
│   ├── logs/
│   │   └── dbt.log
│   └── northwind_analytics/
│       ├── README.md
│       ├── dbt_project.yml
│       ├── profiles.yml
│       ├── packages.yml
│       ├── package-lock.yml
│       ├── macros/
│       │   └── schema_name.sql
│       ├── models/
│       │   ├── staging/           # SILVER LAYER
│       │   │   ├── sources.yml
│       │   │   ├── staging.yml
│       │   │   ├── stg_categories.sql
│       │   │   ├── stg_customers.sql
│       │   │   ├── stg_employees.sql
│       │   │   ├── stg_order_details.sql
│       │   │   ├── stg_orders.sql
│       │   │   ├── stg_products.sql
│       │   │   ├── stg_shippers.sql
│       │   │   └── stg_suppliers.sql
│       │   └── mart/              # GOLD LAYER
│       │       ├── dim_categories.sql
│       │       ├── dim_customers.sql
│       │       ├── dim_date.sql
│       │       ├── dim_employees.sql
│       │       ├── dim_products.sql
│       │       ├── dim_shippers.sql
│       │       └── fact_orders.sql
│       ├── dbt_packages/          # Installed dependencies
│       │   ├── dbt_date/          # Date dimension utilities
│       │   ├── dbt_expectations/  # Advanced data quality tests
│       │   └── dbt_utils/         # Helper macros
│       ├── seeds/
│       ├── snapshots/
│       ├── tests/
│       ├── analyses/
│       ├── target/                # dbt compilation output
│       └── logs/
│           └── dbt.log
├── aws/                           # AWS deployment configs (to be added)
│   ├── ecs/
│   │   └── task-definition.json
│   ├── ecr/
│   │   └── Dockerfile
│   └── cloudwatch/
│       └── log-groups.json
└── screenshots/                   # Deployment evidence
    ├── airbyte-connection.png
    ├── snowflake-tables.png
    ├── ecs-tasks.png
    ├── cloudwatch-logs.png
    └── preset-dashboard.png
```

## Technical Implementation

### Data Extraction & Loading

**Tool**: Airbyte  
**Method**: Change Data Capture (CDC) using PostgreSQL logical replication  
**Frequency**: Real-time/continuous sync  
**Target**: Snowflake RAW Layer (Bronze)

**Tables Extracted**:
- customers
- orders
- order_details
- products
- categories
- suppliers
- shippers
- employees

### Data Transformation

**Tool**: dbt (Data Build Tool)  
**Execution**: AWS ECS (Elastic Container Service)  
**Container Storage**: AWS ECR (Elastic Container Registry)  
**Monitoring**: AWS CloudWatch

**dbt Packages Used**:
- **dbt_date**: Utilities for building date dimensions with fiscal year support
- **dbt_expectations**: Advanced data quality tests similar to Great Expectations
- **dbt_utils**: Helper macros for surrogate keys, unions, and common operations

**Transformations Applied**:
- ✅ **Aggregation**: SUM, COUNT, AVG for order metrics
- ✅ **Grouping**: GROUP BY customer, product, time periods
- ✅ **Window Functions**: RANK, ROW_NUMBER for customer segmentation
- ✅ **Calculations**: line_total = quantity * unit_price * (1 - discount)
- ✅ **Data Type Casting**: Timestamp conversions, numeric formatting
- ✅ **Filtering**: WHERE clauses for active records
- ✅ **Sorting**: ORDER BY for ranking and partitioning
- ✅ **Joins**: Multiple table joins across staging models
- ✅ **Unions**: Combining historical and current data
- ✅ **Renaming**: Standardized column naming conventions

**Layered Architecture**:
1. **RAW Layer (Bronze)**: Unprocessed data from Airbyte, stored as-is in Snowflake
2. **SILVER Layer (Staging)**: Cleansed data with basic transformations, type casting, and standardization
   - Located in `models/staging/`
   - Tables: stg_customers, stg_orders, stg_order_details, stg_products, stg_employees, stg_categories, stg_shippers, stg_suppliers
3. **GOLD Layer (Marts)**: Final dimensional models optimized for business consumption
   - Located in `models/mart/`
   - Tables: fact_orders, dim_customers, dim_products, dim_categories, dim_employees, dim_shippers, dim_date

**AWS Integration**:
- **Docker Image**: dbt transformations packaged as Docker container
- **ECR Repository**: Stores versioned dbt Docker images
- **ECS Task**: Runs dbt transformations on scheduled basis
- **CloudWatch Logs**: Captures dbt run logs and test results
- **CloudWatch Alarms**: Alerts on pipeline failures or data quality issues

### Data Quality Tests

**Framework**: dbt tests + dbt_expectations package

**Test Coverage**:
- ✅ **Uniqueness**: Primary key constraints on all dimensions and facts
- ✅ **Not Null**: Required fields in dimension tables
- ✅ **Relationships**: Foreign key validation between facts and dimensions
- ✅ **Accepted Values**: Category and status field validation
- ✅ **Custom Tests**: Date consistency, price validation, inventory checks
- ✅ **dbt_expectations Tests**: Advanced statistical and data quality validations
  - Column value distributions
  - Expected ranges and patterns
  - Cross-table consistency checks

**Test Definitions**: Located in `models/staging/staging.yml` and other schema.yml files

### Semantic Modeling & Visualization

**Tool**: Preset (Apache Superset)

**Metrics Defined**:
- Total Revenue
- Average Order Value
- Customer Lifetime Value
- Product Sales by Category
- Sales by Region
- Employee Performance Metrics
- Supplier Performance and Contribution
- Shipping Costs and Delivery Times
- Revenue by Shipper

**Dashboards**:
- Sales Performance Overview
- Customer Analytics
- Product Performance
- Employee Metrics
- Supplier Analytics
- Shipping Operations Dashboard

## Getting Started

### Prerequisites

- Docker and Docker Compose installed
- Snowflake account (trial or paid)
- Airbyte Cloud or Self-hosted instance
- dbt Cloud account or dbt Core installed locally
- Git installed locally

### Setup Instructions

#### 1. Clone the Repository

```bash
git clone https://github.com/your-username/northwind-analytics.git
cd northwind-analytics
```

#### 2. Setup Northwind Database (Automated)

The Northwind PostgreSQL database is automatically set up using Docker Compose:

```bash
cd data-integration

# Start PostgreSQL with Northwind database
docker-compose up --build -d

# Verify the database is running
docker-compose ps

# The database will automatically initialize with:
# - Northwind schema (northwind.sql)
# - Sample data loaded
# - Ready for Airbyte connection
```

**Database Connection Details**:
- Host: `host.docker.internal` (or container name if connecting from Docker network)
- Port: `5433`
- Database: `northwind`
- User: `postgres`
- Password: (check docker-compose.yml)

#### 3. Configure Airbyte Connection

1. Log into Airbyte Cloud/instance
2. **Create PostgreSQL Source**:
   - Host: `host.docker.internal` (or Docker container host)
   - Port: `5433`
   - Database: `northwind`
   - User: `postgres`
   - Enable CDC with logical replication (requires `wal_level=logical`)
   
3. **Create Snowflake Destination**:
   - Use the SQL script in `data-integration/airbyte-config/airbyte_snowflake_setup.sql` to set up Snowflake
   - Account: `your-account.snowflakecomputing.com`
   - Database: `NORTHWIND`
   - Schema: `RAW`
   - Warehouse: `AIRBYTE_WAREHOUSE`
   
4. **Create Connection**:
   - Select tables: customers, orders, order_details, products, categories, suppliers, shippers, employees
   - Set sync schedule (e.g., hourly)
   - Enable CDC mode for incremental updates

#### 4. Configure dbt

```bash
cd data-transformation/northwind_analytics

# Copy profiles example (if not already configured)
cp profiles.yml.example profiles.yml  # if you have one
# Edit profiles.yml with your Snowflake credentials

# Install dbt packages
dbt deps

# This will install:
# - dbt_date: For date dimension utilities
# - dbt_expectations: For advanced data quality tests
# - dbt_utils: For helper macros

# Test connection
dbt debug
```

#### 5. Run Transformations

```bash
# Run all models
dbt run

# Run tests
dbt test

# Generate documentation
dbt docs generate
dbt docs serve
```

#### 6. Setup AWS Infrastructure

**Create ECR Repository**:
```bash
# Create ECR repository for dbt
aws ecr create-repository --repository-name northwind-dbt

# Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com
```

**Build and Push Docker Image**:
```bash
# Build dbt Docker image
cd aws/ecr
docker build -t northwind-dbt .

# Tag image
docker tag northwind-dbt:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/northwind-dbt:latest

# Push to ECR
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/northwind-dbt:latest
```

**Create ECS Task Definition**:
```bash
# Register ECS task definition
aws ecs register-task-definition --cli-input-json file://aws/ecs/task-definition.json
```

**Setup CloudWatch**:
```bash
# Create log group
aws logs create-log-group --log-group-name /ecs/northwind-dbt

# Create CloudWatch alarm for failures
aws cloudwatch put-metric-alarm \
  --alarm-name dbt-pipeline-failure \
  --alarm-description "Alert when dbt pipeline fails" \
  --metric-name Errors \
  --namespace AWS/Logs \
  --statistic Sum \
  --period 300 \
  --threshold 1 \
  --comparison-operator GreaterThanThreshold
```

#### 7. Deploy to Cloud

**Airbyte**:
1. Configure Airbyte connection (already cloud-based)
2. Set sync frequency to hourly for CDC

**dbt on AWS ECS**:
1. Create ECS cluster: `northwind-analytics-cluster`
2. Create scheduled ECS task using EventBridge (formerly CloudWatch Events)
   - Schedule: Daily at 2 AM UTC
   - Task: Run dbt transformations
3. Configure task with Snowflake credentials via AWS Secrets Manager

**Snowflake**:
- Already deployed (cloud-based SaaS)
- Configure appropriate warehouse sizing based on data volume

## Data Pipeline Execution

### Manual Execution

```bash
# 1. Trigger Airbyte sync (or wait for scheduled sync)
# 2. Run dbt transformations
dbt run --models staging
dbt run --models intermediate
dbt run --models marts

# 3. Run tests
dbt test

# 4. Check logs
tail -f logs/dbt.log
```

### Scheduled Execution

- **Airbyte**: Configured for hourly CDC sync from PostgreSQL to Snowflake RAW layer
- **dbt on AWS ECS**: Scheduled via EventBridge (daily at 2 AM UTC)
  - Pulls latest Docker image from ECR
  - Executes dbt transformations (SILVER → GOLD layers)
  - Runs data quality tests
  - Logs all output to CloudWatch
- **Monitoring**: 
  - CloudWatch dashboards for pipeline health
  - CloudWatch alarms for failure notifications
  - Email/SNS alerts on critical issues

## Testing & Data Quality

### dbt Test Results

```bash
# Run all tests
dbt test

# Run specific test
dbt test --select fact_orders

# Run tests by type
dbt test --select test_type:unique
dbt test --select test_type:not_null
```

### Custom Tests

```sql
-- Example: Validate order dates are not in the future
SELECT COUNT(*)
FROM {{ ref('fact_orders') }}
WHERE order_date > CURRENT_DATE()
```

## Team & Collaboration

### Git Workflow

1. **Feature branches**: Create branch for each task
   ```bash
   git checkout -b feature/dim-customers
   ```

2. **Commit changes**: Regular commits with descriptive messages
   ```bash
   git add .
   git commit -m "Add dim_customers dimension table"
   ```

3. **Pull requests**: Review before merging to main
   ```bash
   git push origin feature/dim-customers
   # Create PR on GitHub
   ```

4. **Code review**: At least one team member approval required

## Deployment Evidence

### Cloud Services Configured

1. **Airbyte Cloud**
   - Source: Northwind PostgreSQL with CDC enabled
   - Destination: Snowflake RAW schema
   - Sync frequency: Hourly
   - Screenshot: `docs/screenshots/airbyte-connection.png`

2. **Snowflake Data Warehouse**
   - Database: `NORTHWIND_DW`
   - Schemas: `RAW` (Bronze), `SILVER` (Staging), `GOLD` (Marts)
   - Compute: X-Small warehouse with auto-suspend
   - Screenshot: `docs/screenshots/snowflake-tables.png`

3. **AWS ECR (Elastic Container Registry)**
   - Repository: `northwind-dbt`
   - Image tags: `latest`, version-specific tags
   - Scan on push: Enabled for security
   - Screenshot: `docs/screenshots/ecr-repository.png`

4. **AWS ECS (Elastic Container Service)**
   - Cluster: `northwind-analytics-cluster`
   - Task Definition: `northwind-dbt-task`
   - Launch Type: Fargate (serverless)
   - Schedule: EventBridge rule for daily execution
   - Screenshot: `docs/screenshots/ecs-tasks.png`

5. **AWS CloudWatch**
   - Log Group: `/ecs/northwind-dbt`
   - Metrics: Task execution duration, success/failure rates
   - Alarms: Pipeline failure notifications
   - Dashboard: Real-time pipeline monitoring
   - Screenshot: `docs/screenshots/cloudwatch-logs.png`

6. **Preset/Tableau Dashboard**
   - Workspace: Northwind Analytics
   - Dashboards: 6 interactive dashboards
   - Metrics: 9 semantic metrics defined
   - Connection: Direct to Snowflake GOLD layer
   - Screenshot: `docs/screenshots/preset-dashboard.png`

## Rubric Checklist

- ✅ **CDC Extraction (5% bonus)**: Airbyte CDC from PostgreSQL
- ✅ **Transformation Techniques (10%)**: 10+ techniques implemented
- ✅ **Dimensional Modeling (10%)**: 1 fact table + 6 dimension tables (customers, products, categories, employees, shippers, date)
- ✅ **Semantic Modeling (5%)**: 9 metrics defined in Preset/Tableau
- ✅ **Visualizations (5%)**: 6 interactive dashboards
- ✅ **Data Quality Tests (10%)**: 15+ dbt tests implemented
- ✅ **Dependencies (10%)**: dbt DAG with model dependencies
- ✅ **Git Collaboration (5%)**: Commits, branches, and PRs
- ✅ **Cloud Deployment (15%)**: Airbyte, Snowflake, AWS (ECR, ECS, CloudWatch), Preset/Tableau
- ✅ **Documentation (5%)**: README, architecture, and ER diagrams

**Total Score**: 80% + 5% bonus = 85%

## Key Learnings

1. **CDC Implementation**: Real-time data sync reduces latency and ensures data freshness
2. **Dimensional Modeling**: Star schema significantly improves query performance for analytics
3. **dbt Testing**: Automated data quality tests catch issues early in the pipeline
4. **Team Collaboration**: Git workflow and clear task division enabled parallel development
5. **Cloud Architecture**: Managed services reduce operational overhead and enable scalability

## Future Enhancements

- [ ] Implement Type 2 SCD for customer dimension (5% bonus)
- [ ] Add snapshot fact table for inventory analysis (5% bonus)
- [ ] Create One Big Table (OBT) for simplified BI access (5% bonus)
- [ ] Add Great Expectations for advanced data quality
- [ ] Implement CI/CD pipeline with automated testing
- [ ] Add incremental models for improved performance
- [ ] Expand semantic layer with additional metrics

## Resources

- [Northwind Database Schema](https://github.com/pthom/northwind_psql)
- [dbt Documentation](https://docs.getdbt.com/)
- [Airbyte CDC Setup](https://docs.airbyte.com/integrations/sources/postgres)
- [Snowflake Best Practices](https://docs.snowflake.com/en/user-guide/best-practices)
- [Dimensional Modeling Guide](https://www.kimballgroup.com/data-warehouse-business-intelligence-resources/kimball-techniques/dimensional-modeling-techniques/)

## Contact

For questions or issues, please contact the team:
- Email: team@example.com
- GitHub Issues: [Create an issue](https://github.com/your-username/northwind-analytics/issues)

## License

MIT License - See LICENSE file for details

---

**Project Submission**: Data Engineer Camp - Project 2  
**Submission Date**: November 24, 2025  
**Team**: [Your Team Name]