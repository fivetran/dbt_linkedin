{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false)
) }}

with creative_report as (

    select 
        sum(conversion_value_in_local_currency) as total_value
    from {{ ref('linkedin_ads__creative_report') }}
),

account_report as (

    select 
        sum(conversion_value_in_local_currency) as total_value
    from {{ ref('linkedin_ads__account_report') }}
),

campaign_group_report as (

    select 
        sum(conversion_value_in_local_currency) as total_value
    from {{ ref('linkedin_ads__campaign_group_report') }}
),

campaign_report as (

    select 
        sum(conversion_value_in_local_currency) as total_value
    from {{ ref('linkedin_ads__campaign_report') }}
),

url_report as (

    select 
        sum(conversion_value_in_local_currency) as total_value
    from {{ ref('linkedin_ads__url_report') }}
),

creative_w_url_report as (

    select 
        sum(creatives.conversion_value_in_local_currency) as total_value
    from {{ ref('linkedin_ads__creative_report') }} creatives 
    join {{ ref('linkedin_ads__url_report') }} urls 
        on creatives.creative_id = urls.creative_id
        and creatives.date_day = urls.date_day
)

select 
    'creative vs account' as comparison
from creative_report
join account_report on true
where creative_report.total_value != account_report.total_value

union all 

select 
    'creative vs campaign group' as comparison
from creative_report
join campaign_group_report on true
where creative_report.total_value != campaign_group_report.total_value

union all 

select 
    'creative vs campaign' as comparison
from creative_report
join campaign_report on true
where creative_report.total_value != campaign_report.total_value

union all 

select 
    'creative vs url' as comparison
from creative_report
join creative_w_url_report on true
where creative_report.total_value != creative_w_url_report.total_value
