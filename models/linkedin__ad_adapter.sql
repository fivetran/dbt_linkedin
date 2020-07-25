with metrics as (

    select *
    from {{ ref('stg_linkedin__ad_analytics_by_creative') }}

), creatives as (

    select *
    from {{ ref('stg_linkedin__creative_history') }}

), campaigns as (
    
    select *
    from {{ ref('stg_linkedin__campaign_history') }}

), campaign_groups as (
    
    select *
    from {{ ref('stg_linkedin__campaign_group_history') }}

), accounts as (
    
    select *
    from {{ ref('stg_linkedin__account_history') }}

), joined as (

    select
        metrics.creative_id,
        metrics.date_day,
        metrics.clicks,
        metrics.impressions,
        metrics.cost,
        metrics.daily_creative_id,
        creatives.base_url,
        creatives.url_host,
        creatives.url_path,
        creatives.utm_source,
        creatives.utm_medium,
        creatives.utm_campaign,
        creatives.utm_content,
        creatives.utm_term,
        campaigns.campaign_name,
        campaigns.campaign_id,
        campaign_groups.campaign_group_name,
        campaign_groups.campaign_group_id,
        accounts.account_name,
        accounts.account_id
    from metrics
    left join creatives
        on metrics.creative_id = creatives.creative_id
        and timestamp_add(metrics.date_day, INTERVAL 1 DAY) >= creatives.valid_from
        and timestamp_add(metrics.date_day, INTERVAL 1 DAY) <= coalesce(creatives.valid_to, timestamp_add(current_timestamp, INTERVAL 1 DAY))
    left join campaigns
        on creatives.campaign_id = campaigns.campaign_id
        and timestamp_add(metrics.date_day, INTERVAL 1 DAY) >= campaigns.valid_from
        and timestamp_add(metrics.date_day, INTERVAL 1 DAY) <= coalesce(campaigns.valid_to, timestamp_add(current_timestamp, INTERVAL 1 DAY))
    left join campaign_groups
        on campaigns.campaign_group_id = campaign_groups.campaign_group_id
        and timestamp_add(metrics.date_day, INTERVAL 1 DAY) >= campaign_groups.valid_from
        and timestamp_add(metrics.date_day, INTERVAL 1 DAY) <= coalesce(campaign_groups.valid_to, timestamp_add(current_timestamp, INTERVAL 1 DAY))
    left join accounts
        on campaign_groups.account_id = accounts.account_id
        and timestamp_add(metrics.date_day, INTERVAL 1 DAY) >= accounts.valid_from
        and timestamp_add(metrics.date_day, INTERVAL 1 DAY) <= coalesce(accounts.valid_to, timestamp_add(current_timestamp, INTERVAL 1 DAY))

)

select *
from joined