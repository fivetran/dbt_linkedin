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
        and {{ timestamp_add('day', 1, 'metrics.date_day') }} >= creatives.valid_from
        and {{ timestamp_add('day', 1, 'metrics.date_day') }} <= coalesce(creatives.valid_to, {{ timestamp_add('day', 1, dbt_utils.current_timestamp()) }})
    left join campaigns
        on creatives.campaign_id = campaigns.campaign_id
        and {{ timestamp_add('day', 1, 'metrics.date_day') }} >= campaigns.valid_from
        and {{ timestamp_add('day', 1, 'metrics.date_day') }} <= coalesce(campaigns.valid_to, {{ timestamp_add('day', 1, dbt_utils.current_timestamp()) }})
    left join campaign_groups
        on campaigns.campaign_group_id = campaign_groups.campaign_group_id
        and {{ timestamp_add('day', 1, 'metrics.date_day') }} >= campaign_groups.valid_from
        and {{ timestamp_add('day', 1, 'metrics.date_day') }} <= coalesce(campaign_groups.valid_to, {{ timestamp_add('day', 1, dbt_utils.current_timestamp()) }})
    left join accounts
        on campaign_groups.account_id = accounts.account_id
        and {{ timestamp_add('day', 1, 'metrics.date_day') }} >= accounts.valid_from
        and {{ timestamp_add('day', 1, 'metrics.date_day') }} <= coalesce(accounts.valid_to, {{ timestamp_add('day', 1, dbt_utils.current_timestamp()) }})

)

select *
from joined