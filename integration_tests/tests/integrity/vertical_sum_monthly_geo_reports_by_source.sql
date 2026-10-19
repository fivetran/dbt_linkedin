{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false) and fivetran_utils.enabled_vars(['ad_reporting__linkedin_ads_enabled','linkedin_ads__using_geo','linkedin_ads__using_monthly_ad_analytics_by_member_country','linkedin_ads__using_monthly_ad_analytics_by_member_region'])
) }}

-- Confirms metrics are not multiplied when multiple LinkedIn connections are unioned.
-- Totals are compared per source_relation between staging and each geo end model.

with staging as (
    select
        'country' as report,
        source_relation,
        sum(impressions) as total_impressions,
        sum(clicks) as total_clicks,
        sum(cost) as total_cost
    from {{ ref('stg_linkedin_ads__monthly_ad_analytics_by_country') }}
    group by 1, 2

    union all

    select
        'region' as report,
        source_relation,
        sum(impressions) as total_impressions,
        sum(clicks) as total_clicks,
        sum(cost) as total_cost
    from {{ ref('stg_linkedin_ads__monthly_ad_analytics_by_region') }}
    group by 1, 2
),

end_model as (
    select
        'country' as report,
        source_relation,
        sum(impressions) as total_impressions,
        sum(clicks) as total_clicks,
        sum(cost) as total_cost
    from {{ ref('linkedin_ads__monthly_campaign_country_report') }}
    group by 1, 2

    union all

    select
        'region' as report,
        source_relation,
        sum(impressions) as total_impressions,
        sum(clicks) as total_clicks,
        sum(cost) as total_cost
    from {{ ref('linkedin_ads__monthly_campaign_region_report') }}
    group by 1, 2
)

select
    coalesce(end_model.report, staging.report) as report,
    coalesce(end_model.source_relation, staging.source_relation) as source_relation,
    end_model.total_impressions as end_total_impressions,
    staging.total_impressions as staging_total_impressions,
    end_model.total_clicks as end_total_clicks,
    staging.total_clicks as staging_total_clicks,
    end_model.total_cost as end_total_cost,
    staging.total_cost as staging_total_cost
from end_model
full outer join staging
    on end_model.report = staging.report
    and end_model.source_relation = staging.source_relation
where end_model.total_impressions != staging.total_impressions
    or end_model.total_clicks != staging.total_clicks
    or abs(end_model.total_cost - staging.total_cost) > 0.01
    or end_model.report is null
    or staging.report is null
