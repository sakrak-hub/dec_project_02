{% snapshot snapshot_category %}
    {{config(target_schema = 'DEV',
            unique_key = 'category_id',
            strategy = 'check',
            check_cols = ['description', 'category_name'] )}}
    SELECT * FROM {{ ref('source_category') }}
{% endsnapshot %}
