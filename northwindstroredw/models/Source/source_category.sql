with category as (

    Select * from {{source('westend_sales','categories')}}
)

Select category_id, description, category_name from category

