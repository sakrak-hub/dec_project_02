{{ config(
    materialized='table',
    schema='analytics'
) }}

WITH orders AS (
    SELECT * FROM {{ ref('stg_orders') }}
),

order_details AS (
    SELECT * FROM {{ ref('stg_order_details') }}
),

customers AS (
    SELECT 
        customer_key,
        customer_id
    FROM {{ ref('dim_customers') }}
),

products AS (
    SELECT 
        product_key,
        product_id
    FROM {{ ref('dim_products') }}
),

employees AS (
    SELECT 
        employee_key,
        employee_id
    FROM {{ ref('dim_employees') }}
),

shippers AS (
    SELECT 
        shipper_key,
        shipper_id
    FROM {{ ref('dim_shippers') }}
),

date_dim AS (
    SELECT 
        date_key,
        date_day
    FROM {{ ref('dim_date') }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['od.order_id', 'od.product_id']) }} AS order_detail_key,
    
    o.order_id,
    od.product_id,
    
    c.customer_key,
    p.product_key,
    e.employee_key,
    s.shipper_key,
    
    d_order.date_key AS order_date_key,
    d_required.date_key AS required_date_key,
    d_shipped.date_key AS shipped_date_key,
    
    o.order_date,
    o.required_date,
    o.shipped_date,
    
    o.ship_name,
    o.ship_address,
    o.ship_city,
    o.ship_region,
    o.ship_country,
    
    od.quantity,
    od.unit_price,
    od.discount_rate,
    od.discounted_price,
    od.total_price AS line_total,
    o.freight,
    
    od.unit_price * od.quantity AS extended_price,
    (od.unit_price * od.quantity) - od.total_price AS discount_amount,
    
    CASE 
        WHEN o.shipped_date IS NOT NULL AND o.required_date IS NOT NULL
        THEN DATEDIFF(day, o.required_date, o.shipped_date)
        ELSE NULL
    END AS days_late_or_early,
    
    CASE 
        WHEN o.shipped_date IS NULL THEN 'Not Shipped'
        WHEN o.shipped_date <= o.required_date THEN 'On Time'
        ELSE 'Late'
    END AS delivery_status,
    
    CASE 
        WHEN o.shipped_date IS NOT NULL 
        THEN DATEDIFF(day, o.order_date, o.shipped_date)
        ELSE NULL
    END AS days_to_ship

FROM order_details od
INNER JOIN orders o ON od.order_id = o.order_id
LEFT JOIN customers c ON o.customer_id = c.customer_id
LEFT JOIN products p ON od.product_id = p.product_id
LEFT JOIN employees e ON o.employee_id = e.employee_id
LEFT JOIN shippers s ON o.shipper_id = s.shipper_id
LEFT JOIN date_dim d_order ON o.order_date = d_order.date_day
LEFT JOIN date_dim d_required ON o.required_date = d_required.date_day
LEFT JOIN date_dim d_shipped ON o.shipped_date = d_shipped.date_day