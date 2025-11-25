{{ config(materialized='view')}}

SELECT
employee_id,
first_name,
last_name,
first_name || ' ' || last_name as full_name,
photo, 
photo_path,
title,
title_of_courtesy,
reports_to,
extension,  
hire_date,
birth_date,
address, 
home_phone, 
city,
region,
country, 
postal_code, 
notes
FROM {{ source('raw_northwind','employees')}}