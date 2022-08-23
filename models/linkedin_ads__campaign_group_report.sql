{{ config(enabled=var('ad_reporting__linkedin_ads_enabled', True)) }}

with campaign_group as (

    select *
    from {{ var('campaign_group_history') }}
    where is_latest_version
),

campaign as (

    select *
    from {{ var('campaign_history') }}
    where is_latest_version
),

account as (

    select *
    from {{ var('account_history') }}
    where is_latest_version
),

report as (

    select *
    from {{ var('ad_analytics_by_campaign') }}
),

final as (

    select 
        report.date_day,
        campaign_group.campaign_group_id,
        campaign_group.campaign_group_name,
        account.account_id,
        account.account_name,
        campaign_group.status,
        account.currency,
        campaign_group.is_backfilled,
        campaign_group.run_schedule_start_at,
        campaign_group.run_schedule_end_at,
        campaign_group.last_modified_at,
        campaign_group.created_at,
        sum(report.clicks) as clicks,
        sum(report.impressions) as impressions,
        sum(report.cost) as cost

        {{ fivetran_utils.persist_pass_through_columns('linkedin_ads__campaign_passthrough_metrics', transform='sum') }}
    
    from report 
    left join campaign 
        on report.campaign_id = campaign.campaign_id
    left join campaign_group
        on campaign.campaign_group_id = campaign_group.campaign_group_id
    left join account 
        on campaign.account_id = account.account_id

    {{ dbt_utils.group_by(n=12) }}

)

select *
from final