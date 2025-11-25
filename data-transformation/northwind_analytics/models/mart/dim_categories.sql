{{ config(
    materialized='view',
    schema='analytics'
)}}

SELECT
    {{ dbt_utils.generate_surrogate_key(['category_id']) }} AS category_key,
    category_id,
    category_name,
    description,
    picture
FROM {{ ref('stg_categories')}}