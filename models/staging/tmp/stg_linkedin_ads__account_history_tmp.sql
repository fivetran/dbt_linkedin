{{ config(enabled=var('ad_reporting__linkedin_ads_enabled', True)) }}

{% if var('linkedin_union_schemas', []) | length > 0 or var('linkedin_union_databases', []) | length > 0 %}

{{
    fivetran_utils.union_data(
        table_identifier='account_history', 
        database_variable='linkedin_database', 
        schema_variable='linkedin_schema', 
        default_database=target.database,
        default_schema='linkedin',
        default_variable='account_history',
        union_schema_variable='linkedin_union_schemas',
        union_database_variable='linkedin_union_databases'
    )
}}

{% else %}

{{
    fivetran_utils.union_connections(
        connection_dictionary='linkedin_sources',
        single_source_name='linkedin',
        single_table_name='account_history'
    )
}}

{% endif %}