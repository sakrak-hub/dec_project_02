{{ config(materialized='view')}}

SELECT
product_id, 
unit_price,
category_id, 
supplier_id, 
discontinued as discontinued_status, 
product_name, 
reorder_level, 
units_in_stock, 
units_on_order, 
quantity_per_unit
FROM {{ source('raw_northwind','products')}}