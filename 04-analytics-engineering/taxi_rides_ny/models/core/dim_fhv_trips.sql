{{
    config(
        materialized='table'
    )
}}

with fhv_tripdata as (
    select 
        dispatching_base_num,
        pickup_datetime,
        dropoff_datetime,
        cast(pulocationid as string) as pickup_locationid,
        cast(dolocationid as string) as dropoff_locationid,
        affiliated_base_number,
        'FHV' as service_type,
        extract(year from pickup_datetime) as year,
        extract(month from pickup_datetime) as month
    from {{ ref('stg_fhv_tripdata') }}
),

dim_zones as (
    select 
        cast(locationid as string) as locationid,
        borough,
        zone
    from {{ ref('dim_zones') }}
    where borough != 'Unknown'
)

select 
    fhv_tripdata.*,
    pickup_zone.zone as pickup_zone,
    dropoff_zone.zone as dropoff_zone
from fhv_tripdata
left join dim_zones as pickup_zone
    on fhv_tripdata.pickup_locationid = pickup_zone.locationid
left join dim_zones as dropoff_zone
    on fhv_tripdata.dropoff_locationid = dropoff_zone.locationid