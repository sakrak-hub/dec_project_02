{{ config(materialized='view')}}

SELECT
CUSTOMER_ID,
CONTACT_NAME AS CUSTOMER_NAME,
CONTACT_TITLE,
COMPANY_NAME,
PHONE,
FAX,
ADDRESS,
CITY,
REGION, 
COUNTRY,
POSTAL_CODE
FROM {{source('raw_northwind', 'customers')}}






 
 
