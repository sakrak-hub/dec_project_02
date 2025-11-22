{{ config(materialized='view')}}

SELECT
customer_id,
contact_name as customer_name,
contact_title,
company_name,
phone,
fax,
address,
city,
region, 
country,
postal_code
FROM {{source('raw_northwind', 'customers')}}






 
 
