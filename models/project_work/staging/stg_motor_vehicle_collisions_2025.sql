{{ config(materialized='table', schema='staging') }}

SELECT
    collision_id,
    crash_date,
    NULLIF(TRIM(crash_time), '') AS crash_time,
    NULLIF(UPPER(TRIM(borough)), '') AS borough,
    NULLIF(TRIM(zip_code), '') AS incident_zip,
    latitude,
    longitude,
    number_of_persons_injured,
    number_of_persons_killed,
    number_of_pedestrians_injured,
    number_of_cyclist_injured,
    number_of_motorist_injured,
    NULLIF(TRIM(contributing_factor_vehicle_1), '') AS contributing_factor_vehicle_1,
    NULLIF(TRIM(vehicle_type_code1), '') AS vehicle_type_code1
FROM {{ source('nyc_raw', 'source_motor_vehicle_collisions_2025') }}
