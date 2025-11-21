{{ config(materialized='view')}}

SELECT
CATEGORY_ID, 
CATEGORY_NAME,
DESCRIPTION, 
PICTURE
FROM {{source('raw_northwind','categories')}}