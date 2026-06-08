{{ config(enabled=fivetran_utils.enabled_vars(['ad_reporting__linkedin_ads_enabled','linkedin_ads__using_monthly_ad_analytics_by_member_country'])) }}

{% if var('linkedin_union_schemas', []) | length > 0 or var('linkedin_union_databases', []) | length > 0 %}

{{
    fivetran_utils.union_data(
        table_identifier='monthly_ad_analytics_by_member_country', 
        database_variable='linkedin_database', 
        schema_variable='linkedin_schema', 
        default_database=target.database,
        default_schema='linkedin',
        default_variable='monthly_ad_analytics_by_member_country',
        union_schema_variable='linkedin_union_schemas',
        union_database_variable='linkedin_union_databases'
    )
}}

{% else %}

{{
    fivetran_utils.union_connections(
        connection_dictionary='linkedin_sources',
        single_source_name='linkedin',
        single_table_name='monthly_ad_analytics_by_member_country'
    )
}}

{% endif %}