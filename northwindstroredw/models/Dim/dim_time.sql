

with date_dim as (
    {{ dbt_date.get_date_dimension("1990-01-01", "2050-12-31") }}
)

select
    {{ dbt_utils.generate_surrogate_key(['date_day']) }} as date_sk,
    *
from date_dim