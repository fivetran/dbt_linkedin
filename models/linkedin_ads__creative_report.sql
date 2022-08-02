with creative as (

    select *
    from {{ var('creative_history') }}
),

campaign as (

    select *
    from {{ var('campaign_history') }}
    where valid_to is null
),

campaign_group as (

    select *
    from {{ var('campaign_group_history') }}
    where valid_to is null -- get latest
),

account as (

    select *
    from {{ var('account_history') }}
    where valid_to is null
),

report as (

    select *
    from {{ var('ad_analytics_by_creative') }}
),

final as (

    select 
        report.date_day,
        creative.creative_id,
        creative.version_tag,
        creative.creative_version_id,
        campaign.campaign_id,
        campaign.campaign_name,
        campaign_group.campaign_group_id,
        campaign_group.campaign_group_name,
        account.account_id,
        account.account_name,
        creative.type,
        creative.click_uri,
        creative.status as creative_status,
        campaign.status as campaign_status,
        campaign_group.status as campaign_group_status,
        creative.call_to_action_label_type,
        account.currency,
        creative.last_modified_at,
        creative.created_at,
        sum(report.clicks) as clicks,
        sum(report.impressions) as impressions,
        sum(report.cost) as cost

        {{ fivetran_utils.persist_pass_through_columns('linkedin_ads__passthrough_metrics', transform='sum') }}
    
    from report 
    left join creative 
        on report.creative_id = creative.creative_id
    left join campaign 
        on creative.campaign_id = campaign.campaign_id
    left join campaign_group
        on campaign.campaign_group_id = campaign_group.campaign_group_id
    left join account 
        on campaign.account_id = account.account_id

    {{ dbt_utils.group_by(n=19) }}

)

select *
from final