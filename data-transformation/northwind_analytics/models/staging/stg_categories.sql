{{ config(materialized='view')}}

SELECT
category_id, 
category_name,
description, 
picture
FROM {{source('raw_northwind','categories')}}