{{ config(materialized='view')}}

SELECT
PHONE, 
SHIPPER_ID,
COMPANY_NAME
FROM {{ source('raw_northwind','shippers')}}