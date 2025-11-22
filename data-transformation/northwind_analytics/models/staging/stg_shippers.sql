{{ config(materialized='view')}}

SELECT
shipper_id,
phone, 
company_name
FROM {{ source('raw_northwind','shippers')}}