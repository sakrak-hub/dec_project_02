{{ config(
    materialized='view',
    schema='analytics'
)}}

WITH date_spine AS (
    SELECT 
        DATEADD(day, SEQ4(), '1996-01-01'::DATE) AS date_day
    FROM TABLE(GENERATOR(ROWCOUNT => 1461))
)

SELECT 
    CAST(TO_CHAR(date_day, 'YYYYMMDD') AS INTEGER) AS date_key,
    date_day,
    DAYNAME(date_day) AS day_name,
    DAYOFWEEK(date_day) AS day_of_week,
    DAYOFWEEKISO(date_day) AS day_of_week_iso,
    DAY(date_day) AS day_of_month,
    DAYOFYEAR(date_day) AS day_of_year,
    WEEKOFYEAR(date_day) AS week_of_year,
    MONTH(date_day) AS month_number,
    MONTHNAME(date_day) AS month_name,
    QUARTER(date_day) AS quarter,
    YEAR(date_day) AS year,

    CASE
        WHEN MONTH(date_day) IN (1, 2, 3) THEN 'Q1'
        WHEN MONTH(date_day) IN (4, 5, 6) THEN 'Q2'
        WHEN MONTH(date_day) IN (7, 8, 9) THEN 'Q3'
        ELSE 'Q4'
    END AS quarter_name,

    YEAR(date_day) || '-Q' || QUARTER(date_day) AS year_quarter

FROM date_spine
WHERE date_day <= '2000-12-31'