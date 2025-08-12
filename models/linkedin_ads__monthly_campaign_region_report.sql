{{ config(enabled=fivetran_utils.enabled_vars(['ad_reporting__linkedin_ads_enabled','linkedin_ads__using_geo','linkedin_ads__using_monthly_ad_analytics_by_member_region'])) }}

with campaign as (

    select *
    from {{ ref('stg_linkedin_ads__campaign_history') }}
    where is_latest_version
),

campaign_group as (

    select *
    from {{ ref('stg_linkedin_ads__campaign_group_history') }}
    where is_latest_version
),

account as (

    select *
    from {{ ref('stg_linkedin_ads__account_history') }}
    where is_latest_version
),

geo as (

    select *
    from {{ ref('stg_linkedin_ads__geo') }}
),

report as (

    select *,
        {% if var('linkedin_ads__conversion_fields', none) %}
            {{ var('linkedin_ads__conversion_fields') | join(' + ') }} as total_conversions
        {% else %}
            0 as total_conversions
        {% endif %}
    from {{ ref('stg_linkedin_ads__monthly_ad_analytics_by_region') }}
),

final as (

    select 
        report.source_relation,
        report.date_month,
        geo.value as region_name,
        report.campaign_id,
        campaign.campaign_name,
        campaign.version_tag,
        campaign_group.campaign_group_id,
        campaign_group.campaign_group_name,
        account.account_id,
        account.account_name,
        campaign.status as campaign_status,
        campaign_group.status as campaign_group_status,
        campaign.type as campaign_type,
        campaign.cost_type,
        campaign.creative_selection,
        campaign.daily_budget_amount,
        campaign.daily_budget_currency_code,
        campaign.unit_cost_amount,
        campaign.unit_cost_currency_code,
        account.currency as account_currency,
        campaign.format,
        campaign.locale_country as campaign_locale_country,
        campaign.locale_language as campaign_locale_language,
        campaign.objective_type,
        campaign.optimization_target_type,
        campaign.is_audience_expansion_enabled,
        campaign.is_offsite_delivery_enabled,
        campaign.run_schedule_start_at,
        campaign.run_schedule_end_at,
        campaign.last_modified_at,
        campaign.created_at,
        sum(report.total_conversions) as total_conversions,
        sum(report.clicks) as clicks,
        sum(report.impressions) as impressions,
        sum(report.cost) as cost,
        sum(coalesce(report.conversion_value_in_local_currency, 0)) as conversion_value_in_local_currency

        {{ linkedin_ads_persist_pass_through_columns(pass_through_variable='linkedin_ads__conversion_fields', transform='sum', coalesce_with=0) }}
        
        {{ linkedin_ads_persist_pass_through_columns(pass_through_variable='linkedin_ads__monthly_ad_analytics_by_member_region_passthrough_metrics', transform='sum') }}

    from report
    left join geo
        on geo.geo_id = report.member_region_geo_id
        and report.source_relation = report.source_relation
    left join campaign 
        on report.campaign_id = campaign.campaign_id
        and report.source_relation = campaign.source_relation
    left join campaign_group
        on campaign.campaign_group_id = campaign_group.campaign_group_id
        and campaign.source_relation = campaign_group.source_relation
    left join account 
        on campaign.account_id = account.account_id
        and campaign.source_relation = account.source_relation

    {{ dbt_utils.group_by(31) }}

)

select *
from final