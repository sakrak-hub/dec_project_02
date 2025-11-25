{{ config(materialized='view')}}

SELECT
order_id,
product_id,
quantity,
unit_price,
discount as discount_rate,
(unit_price * (1 - discount)) as discounted_price,
quantity*(unit_price * (1 - discount)) as total_price
FROM {{source('raw_northwind','order_details')}}