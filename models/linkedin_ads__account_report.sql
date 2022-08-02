with account as (

    select *
    from {{ var('account_history') }}
    where valid_to is null -- get latest
),

campaign as (

    select *
    from {{ var('campaign_history') }}
    where valid_to is null
),

report as (

    select *
    from {{ var('ad_analytics_by_campaign') }}
),

final as (

    select 
        report.date_day,
        account.account_id,
        account.account_name,
        account.version_tag,
        account.currency,
        account.status,
        account.type,
        account.last_modified_at,
        account.created_at,
        sum(report.clicks) as clicks,
        sum(report.impressions) as impressions,
        sum(report.cost) as cost

        {{ fivetran_utils.persist_pass_through_columns('linkedin_ads__passthrough_metrics', transform='sum') }}
    
    from report 
    left join campaign 
        on report.campaign_id = campaign.campaign_id
    left join account 
        on campaign.account_id = account.account_id

    {{ dbt_utils.group_by(n=9) }}

)

select *
from final