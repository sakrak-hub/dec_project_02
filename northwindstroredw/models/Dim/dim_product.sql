with product_hist as (
    select
        product_id,
        product_name,
        category_id,
        dbt_valid_from,
        coalesce(dbt_valid_to, '9999-12-31') as valid_to
    from {{ ref('snapshot_products') }}
),

category_hist as (
    select
        category_id,
        category_name,
        description,
        dbt_valid_from,
        coalesce(dbt_valid_to, '9999-12-31') as valid_to
    from {{ ref('snapshot_category') }}
),

-- TEMPORAL ALIGNMENT JOIN
aligned as (
    select
        p.product_id,
        p.product_name,
        c.category_name,
        c.description,

        greatest(p.dbt_valid_from, c.dbt_valid_from) as valid_from,
        least(p.valid_to,       c.valid_to)         as valid_to
    from product_hist p
    join category_hist c
      on p.category_id = c.category_id
     and p.dbt_valid_from <= c.valid_to
     and c.dbt_valid_from <= p.valid_to
),

-- CLEAN INVALID RANGES
filtered as (
    select *
    from aligned
    where valid_from < valid_to
)

select
    {{ dbt_utils.generate_surrogate_key([
        'product_id',
        'product_name',
        'category_name',
        'description',
        'valid_from'
    ]) }} as dim_product_key,

    product_id,
    product_name,
    category_name,
    description,
    valid_from,
    nullif(valid_to, '9999-12-31') as valid_to,
    case when valid_to = '9999-12-31' then 1 else 0 end as is_current

from filtered
order by product_id, valid_from
