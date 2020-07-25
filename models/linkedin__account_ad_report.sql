with adapter as (

    select *
    from {{ ref('linkedin__ad_adapter') }}

), grouped as (

    select 
        date_day,
        account_id,
        account_name,
        sum(cost) as cost,
        sum(clicks) as clicks, 
        sum(impressions) as impressions
    from adapter
    {{ dbt_utils.group_by(3) }}

)

select *
from grouped