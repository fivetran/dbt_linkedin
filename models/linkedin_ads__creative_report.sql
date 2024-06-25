{{ config(enabled=var('ad_reporting__linkedin_ads_enabled', True)) }}

with creative as (

    select *
    from {{ var('creative_history') }}
    where is_latest_version
),

campaign as (

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

    select *,
        {% if var('linkedin_ads__conversion_fields', none) %}
            {{ var('linkedin_ads__conversion_fields') | join(' + ') }} as total_conversions
        {% else %}
            0 as total_conversions
        {% endif %}
    from {{ var('ad_analytics_by_creative') }}
),

final as (

    select 
        report.source_relation,
        report.date_day,
        report.creative_id,
        campaign.campaign_id,
        campaign.campaign_name,
        campaign_group.campaign_group_id,
        campaign_group.campaign_group_name,
        account.account_id,
        account.account_name,
        creative.click_uri,
        creative.status as creative_status,
        campaign.status as campaign_status,
        campaign_group.status as campaign_group_status,
        account.currency,
        creative.last_modified_at,
        creative.created_at,
        report.total_conversions,
        sum(report.clicks) as clicks,
        sum(report.impressions) as impressions,
        sum(report.cost) as cost,
        sum(coalesce(report.conversion_value_in_local_currency)) as conversion_value_in_local_currency  

        {{ linkedin_ads_persist_pass_through_columns(pass_through_variable='linkedin_ads__conversion_fields', transform='sum', coalesce_with=0, except_variable='linkedin_ads__creative_passthrough_metrics', exclude_fields=['conversion_value_in_local_currency']) }}

        {{ fivetran_utils.persist_pass_through_columns('linkedin_ads__creative_passthrough_metrics', transform='sum') }}
    
    from report 
    left join creative 
        on report.creative_id = creative.creative_id
        and report.source_relation = creative.source_relation
    left join campaign 
        on creative.campaign_id = campaign.campaign_id
        and creative.source_relation = campaign.source_relation
    left join campaign_group
        on campaign.campaign_group_id = campaign_group.campaign_group_id
        and campaign.source_relation = campaign_group.source_relation
    left join account 
        on campaign.account_id = account.account_id
        and campaign.source_relation = account.source_relation

    {{ dbt_utils.group_by(17) }}

)

select *
from final