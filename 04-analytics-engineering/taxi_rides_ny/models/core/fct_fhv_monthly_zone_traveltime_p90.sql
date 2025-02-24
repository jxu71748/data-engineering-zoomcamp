-- models/core/fct_fhv_monthly_zone_traveltime_p90.sql
{{
    config(
        materialized='table'
    )
}}

with trip_durations as (
    select 
        year,
        month,
        pickup_zone,
        dropoff_zone,
        timestamp_diff(dropoff_datetime, pickup_datetime, second) as trip_duration
    from {{ ref('dim_fhv_trips') }}
    where 
        pickup_zone is not null
        and dropoff_zone is not null
        and dropoff_datetime > pickup_datetime  
),

p90_calculation as (
    select 
        year,
        month,
        pickup_zone,
        dropoff_zone,
        approx_quantiles(trip_duration, 100)[offset(90)] as p90_trip_duration
    from trip_durations
    group by year, month, pickup_zone, dropoff_zone
),

ranked_dropoffs as (
    select 
        *,
        row_number() over (
            partition by pickup_zone 
            order by p90_trip_duration desc
        ) as rank
    from p90_calculation
    where 
        year = 2019 
        and month = 11
        and pickup_zone in ('Newark Airport', 'SoHo', 'Yorkville East')
)

select 
    pickup_zone,
    dropoff_zone,
    p90_trip_duration
from ranked_dropoffs
where rank = 2