{{ config(
    materialized='view',
    schema='analytics'
    )}}

SELECT
    {{ dbt_utils.generate_surrogate_key(['customer_id']) }} AS customer_key,
    customer_id,
    customer_name,
    contact_title,
    company_name,
    address,
    city,
    region,
    postal_code,
    country,
    phone,
    fax,

    CASE 
        WHEN country IN ('USA', 'Canada', 'Mexico') THEN 'North America'
        WHEN country IN ('UK', 'France', 'Germany', 'Spain', 'Italy', 'Belgium', 'Switzerland', 'Austria', 'Sweden', 'Finland', 'Norway', 'Denmark', 'Poland', 'Ireland') THEN 'Europe'
        WHEN country IN ('Brazil', 'Argentina', 'Venezuela') THEN 'South America'
        ELSE 'Other'
    END AS region_group
FROM {{ ref('stg_customers') }}