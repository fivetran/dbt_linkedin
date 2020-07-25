with adapter as (

    select *
    from {{ ref('linkedin__ad_adapter') }}

), grouped as (

    select 
        date_day,
        campaign_id,
        campaign_name,
        campaign_group_id,
        campaign_group_name,
        account_id,
        account_name,
        sum(cost) as cost,
        sum(clicks) as clicks, 
        sum(impressions) as impressions
    from adapter
    {{ dbt_utils.group_by(7) }}

)

select *
from grouped