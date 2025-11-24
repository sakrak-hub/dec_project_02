with raw_orderdetails as (


    Select * from {{source('westend_sales', 'order_details')}}

)

Select order_id, product_id, quantity, unit_price, discount from raw_orderdetails