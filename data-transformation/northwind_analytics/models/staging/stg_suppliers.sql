{{ config(materialized='view')}}

SELECT
SUPPLIER_ID,
COMPANY_NAME, 
CONTACT_NAME, 
CONTACT_TITLE,
PHONE,
FAX,
ADDRESS, 
CITY, 
REGION,  
COUNTRY, 
POSTAL_CODE,
HOMEPAGE
FROM {{ source('raw_northwind','suppliers')}}