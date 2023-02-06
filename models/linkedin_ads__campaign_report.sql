{{ config(enabled=var('ad_reporting__linkedin_ads_enabled', True)) }}

with campaign as (

    select *
    from {{ var('campaign_history') }}
    where is_latest_version
),

campaign_group as (

    select *
    from {{ var('campaign_group_history') }}
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
        report.campaign_id,
        campaign.campaign_name,
        campaign.version_tag,
        campaign_group.campaign_group_id,
        campaign_group.campaign_group_name,
        account.account_id,
        account.account_name,
        campaign.status as campaign_status,
        campaign_group.status as campaign_group_status,
        campaign.type,
        campaign.cost_type,
        campaign.creative_selection,
        campaign.daily_budget_amount,
        campaign.daily_budget_currency_code,
        campaign.unit_cost_amount,
        campaign.unit_cost_currency_code,
        account.currency,
        campaign.format,
        campaign.locale_country,
        campaign.locale_language,
        campaign.objective_type,
        campaign.optimization_target_type,
        campaign.is_audience_expansion_enabled,
        campaign.is_offsite_delivery_enabled,
        campaign.run_schedule_start_at,
        campaign.run_schedule_end_at,
        campaign.last_modified_at,
        campaign.created_at,
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

    {{ dbt_utils.group_by(n=29) }}

)

select *
from final