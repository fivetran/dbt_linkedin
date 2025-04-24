{{ config(
    tags="fivetran_validations",
    enabled=fivetran_utils.enabled_vars(['ad_reporting__linkedin_ads_enabled','linkedin_ads__using_geo','linkedin_ads__using_monthly_ad_analytics_by_member_country'])
) }}

with staging as (
    select 
        campaign_id,
        member_country,
        count(campaign_id) as count_campaign,
        count(distinct date_month) as count_unique_months,
        sum(impressions) as total_impressions,
        sum(clicks) as total_clicks, 
        sum(cost) as total_cost, 
        sum(conversion_value_in_local_currency) as total_conversion_value
    from {{ ref('stg_linkedin_ads__monthly_ad_analytics_by_country') }}
    group by 1, 2
),

end_model as (
    select 
        campaign_id,
        member_country,
        count(campaign_id) as count_campaign,
        count(distinct date_month) as count_unique_months,
        sum(impressions) as total_impressions,
        sum(clicks) as total_clicks, 
        sum(cost) as total_cost, 
        sum(conversion_value_in_local_currency) as total_conversion_value
    from {{ ref('linkedin_ads__monthly_campaign_country_report') }}
    group by 1, 2
),

combined as (
    select 
        end_model.campaign_id,
        end_model.member_country,
        end_model.count_campaign as end_count_campaign,
        staging.count_campaign as staging_count_campaign,
        end_model.count_unique_months as end_count_unique_months,
        staging.count_unique_months as staging_count_unique_months,
        end_model.total_impressions as end_total_impressions,
        staging.total_impressions as staging_total_impressions,
        end_model.total_clicks as end_total_clicks,
        staging.total_clicks as staging_total_clicks,
        end_model.total_cost as end_total_cost,
        staging.total_cost as staging_total_cost,
        end_model.total_conversion_value as end_total_conversion_value,
        staging.total_conversion_value as staging_total_conversion_value
    from end_model
    full outer join staging
        on end_model.campaign_id = staging.campaign_id
        and end_model.member_country = staging.member_country
)

select *
from combined
where end_count_campaign != staging_count_campaign or
    end_count_unique_months != staging_count_unique_months or
    end_total_impressions != staging_total_impressions or
    end_total_clicks != staging_total_clicks or
    end_total_cost != staging_total_cost or
    end_total_conversion_value != staging_total_conversion_value