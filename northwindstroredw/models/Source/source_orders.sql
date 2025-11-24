with raw_order as 
(

    Select * from {{source('westend_sales', 'orders')}}
)

Select order_id, order_date from raw_order