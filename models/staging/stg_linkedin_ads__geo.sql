{{ config(enabled=fivetran_utils.enabled_vars(['ad_reporting__linkedin_ads_enabled','linkedin_ads__using_geo'])) }}

with base as (

    select * 
    from {{ ref('stg_linkedin_ads__geo_tmp') }}
),

macro as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_linkedin_ads__geo_tmp')),
                staging_columns=get_geo_columns()
            )
        }}
    
        {{ fivetran_utils.apply_source_relation(package_name='linkedin_ads') }}

    from base
),

fields as (
    
    select 
        source_relation,
        id as geo_id,
        value
    from macro
)

select *
from fields