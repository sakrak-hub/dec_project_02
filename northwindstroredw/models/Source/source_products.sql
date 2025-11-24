with raw_product as (

    Select * from {{source('westend_sales', 'products')}}
)

Select product_id, product_name, category_id from raw_product
