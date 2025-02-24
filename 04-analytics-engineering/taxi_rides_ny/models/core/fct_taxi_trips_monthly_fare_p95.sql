{{
    config(
        materialized='table'
    )
}}

with filtered_trips as (
    select 
        service_type,
        extract(year from pickup_datetime) as year,
        extract(month from pickup_datetime) as month,
        fare_amount
    from {{ ref('fact_trips') }}
    where 
        fare_amount > 0
        and trip_distance > 0
        and payment_type_description in ('Cash', 'Credit Card')
),

percentiles as (
    select 
        service_type,
        year,
        month,
        -- use BigQuery APPROX_QUANTILES 
        approx_quantiles(fare_amount, 100)[offset(97)] as p97,
        approx_quantiles(fare_amount, 100)[offset(95)] as p95,
        approx_quantiles(fare_amount, 100)[offset(90)] as p90
    from filtered_trips
    group by service_type, year, month
)

select 
    service_type,
    p97,
    p95,
    p90
from percentiles
where year = 2020 and month = 4