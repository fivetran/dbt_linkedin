{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false)
) }}

with prod as (
    select
        creative_id,
        sum(clicks) as clicks, 
        sum(impressions) as impressions,
        sum(cost) as cost,
        sum(total_conversions) as total_conversions,
        sum(conversion_value_in_local_currency) as conversion_value_in_local_currency
    from {{ target.schema }}_linkedin_prod.linkedin_ads__creative_report
    group by 1
),

dev as (
    select
        creative_id,
        sum(clicks) as clicks, 
        sum(impressions) as impressions,
        sum(cost) as cost,
        sum(total_conversions) as total_conversions,
        sum(conversion_value_in_local_currency) as conversion_value_in_local_currency
    from {{ target.schema }}_linkedin_dev.linkedin_ads__creative_report
    group by 1
),

final as (
    select 
        prod.creative_id,
        prod.clicks as prod_clicks,
        dev.clicks as dev_clicks,
        prod.impressions as prod_impressions,
        dev.impressions as dev_impressions,
        prod.cost as prod_cost,
        dev.cost as dev_cost,
        prod.total_conversions as prod_total_conversions,
        dev.total_conversions as dev_total_conversions,
        prod.conversion_value_in_local_currency as prod_conversion_value_in_local_currency,
        dev.conversion_value_in_local_currency as dev_conversion_value_in_local_currency
    from prod
    full outer join dev 
        on dev.creative_id = prod.creative_id
)

select *
from final
where
    abs(prod_clicks - dev_clicks) >= .01
    or abs(prod_impressions - dev_impressions) >= .01
    or abs(prod_cost - dev_cost) >= .01
    or abs(prod_total_conversions - dev_total_conversions) >= .01
    or abs(prod_conversion_value_in_local_currency - dev_conversion_value_in_local_currency) >= .01