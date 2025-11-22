{{ config(materialized='view')}}

SELECT
employee_id,
first_name,
last_name,
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