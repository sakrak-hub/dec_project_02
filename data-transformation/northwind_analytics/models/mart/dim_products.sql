{{ config(
    materialized='table',
    schema='analytics'
) }}

SELECT
    {{ dbt_utils.generate_surrogate_key(['product_id']) }} AS product_key,
    p.product_id,
    p.product_name,
    p.supplier_id,
    p.category_id,
    p.quantity_per_unit,
    p.unit_price,
    p.units_in_stock,
    p.units_on_order,
    p.reorder_level,
    p.discontinued_status,

    c.category_name,
    c.description AS category_description,

    CASE 
        WHEN p.discontinued_status = 1 THEN 'Discontinued'
        WHEN p.units_in_stock = 0 THEN 'Out of Stock'
        WHEN p.units_in_stock < p.reorder_level THEN 'Low Stock'
        ELSE 'In Stock'
    END AS stock_status
FROM {{ ref('stg_products') }} p
LEFT JOIN {{ ref('stg_categories') }} c ON p.category_id = c.category_id