-- models/staging/stg_fhv_tripdata.sql
{{
    config(
        materialized='view'
    )
}}

select 
    dispatching_base_num,
    pickup_datetime,
    dropoff_datetime,
    pulocationid as pickup_locationid,
    dolocationid as dropoff_locationid,
    affiliated_base_number
from {{ source('staging', 'fhv_tripdata') }}
where dispatching_base_num is not null