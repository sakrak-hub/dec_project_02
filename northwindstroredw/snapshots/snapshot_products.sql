{% snapshot snapshot_products %}

    {{config(target_schema = 'DEV',
                unique_key = 'product_id',
                strategy = 'check',
                check_cols = ['product_name'])}} 
    Select * from {{ref('source_products')}}
{% endsnapshot %}