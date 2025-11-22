{{ config(
    materialized='view',
    schema='analytics'
)}}

SELECT
    {{ dbt_utils.generate_surrogate_key(['shipper_id']) }} AS shipper_key,
    shipper_id,
    phone, 
    company_name
    FROM {{ ref('stg_shippers')}}