
with o_d as (
    Select * from {{ref('source_orderdetails')}}
),
o as (
    Select * from {{ref('source_orders')}}
),
prod_dim as (
    Select * from {{ref('dim_product')}}
),
time_dim as (
    Select * from {{ref('dim_time')}}
)


Select prod_dim.dim_product_key, time_dim.date_sk, order_details.quantity, order_details.unit_price from
(Select  o_d.quantity, o_d.unit_price, o_d.product_id ,o.order_date from o_d 
left join
o  on o_d.order_id = o.order_id) as order_details
left join
prod_dim on prod_dim.product_id = order_details.product_id and order_details.order_date 
between prod_dim.valid_from and coalesce(prod_dim.valid_to, '9999-01-01')
left join
time_dim on time_dim.date_day = order_details.order_date