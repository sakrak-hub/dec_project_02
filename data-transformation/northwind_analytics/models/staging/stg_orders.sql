{{ config(materialized='view')}}

SELECT
order_id,
customer_id,
employee_id,
order_date,
required_date,
shipped_date,
ship_via as shipper_id,
freight,
ship_name,
ship_address,
ship_city,
ship_region,
ship_country
FROM {{ source('raw_northwind','orders')}}