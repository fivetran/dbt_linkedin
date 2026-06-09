{{ config(enabled=var('ad_reporting__linkedin_ads_enabled', True)) }}

{% if var('linkedin_ads_union_schemas', []) | length > 0 or var('linkedin_ads_union_databases', []) | length > 0 %}

{{
    fivetran_utils.union_data(
        table_identifier='account_history', 
        database_variable='linkedin_ads_database', 
        schema_variable='linkedin_ads_schema', 
        default_database=target.database,
        default_schema='linkedin_ads',
        default_variable='account_history',
        union_schema_variable='linkedin_ads_union_schemas',
        union_database_variable='linkedin_ads_union_databases'
    )
}}

{% else %}

{{
    fivetran_utils.union_connections(
        connection_dictionary='linkedin_ads_sources',
        single_source_name='linkedin_ads',
        single_table_name='account_history'
    )
}}

{% endif %}