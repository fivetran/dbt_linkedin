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
        metrics.*,
        campaigns.campaign_name,
        campaigns.campaign_id,
        campaigns.campaign_version_id,
        campaign_groups.campaign_group_name,
        campaign_groups.campaign_group_id,
        campaign_groups.campaign_group_version_id,
        accounts.account_name,
        accounts.account_id,
        accounts.account_version_id
    from metrics
    left join creatives
        on metrics.creative_id = creatives.creative_id
        and metrics.date_day >= creatives.valid_from
        and metrics.date_day <= coalesce(creatives.valid_to, current_timestamp)
    left join campaigns
        on creatives.campaign_id = campaigns.campaign_id
        and metrics.date_day >= campaigns.valid_from
        and metrics.date_day <= coalesce(campaigns.valid_to, current_timestamp)
    left join campaign_groups
        on campaigns.campaign_group_id = campaign_groups.campaign_group_id
        and metrics.date_day >= campaign_groups.valid_from
        and metrics.date_day <= coalesce(campaign_groups.valid_to, current_timestamp)
    left join accounts
        on campaign_groups.account_id = accounts.account_id
        and metrics.date_day >= accounts.valid_from
        and metrics.date_day <= coalesce(accounts.valid_to, current_timestamp)

)

select *
from joined