{{ config(enabled=var('ad_reporting__linkedin_ads_enabled', True)) }}

with account as (

    select *
    from {{ var('account_history') }}
    where is_latest_version
),

campaign as (

    select *
    from {{ var('campaign_history') }}
    where is_latest_version
),

report as (

    select *,
        {% if var('linkedin_ads__conversion_fields', none) %}
            {{ var('linkedin_ads__conversion_fields') | join(' + ') }} as total_conversions
        {% else %}
            0 as total_conversions
        {% endif %}
    from {{ var('ad_analytics_by_campaign') }}
),

final as (

    select 
        report.source_relation,
        report.date_day,
        account.account_id,
        account.account_name,
        account.version_tag,
        account.currency,
        account.status,
        account.type,
        account.last_modified_at,
        account.created_at,
        report.total_conversions,
        sum(report.clicks) as clicks,
        sum(report.impressions) as impressions,
        sum(report.cost) as cost,
        sum(coalesce(report.conversion_value_in_local_currency)) as conversion_value_in_local_currency

        {{ linkedin_ads_persist_pass_through_columns(pass_through_variable='linkedin_ads__conversion_fields', transform='sum', coalesce_with=0, except_variable='linkedin_ads__campaign_passthrough_metrics', exclude_fields=['conversion_value_in_local_currency']) }}

        {{ fivetran_utils.persist_pass_through_columns('linkedin_ads__campaign_passthrough_metrics', transform='sum') }}


    from report 
    left join campaign 
        on report.campaign_id = campaign.campaign_id
        and report.source_relation = campaign.source_relation
    left join account 
        on campaign.account_id = account.account_id
        and campaign.source_relation = account.source_relation

    {{ dbt_utils.group_by(11) }}

)

select *
from final