{{ config(materialized='table', schema='warehouse') }}

WITH collisions AS (
    SELECT
        *,
        COALESCE(
            SAFE_CAST(crash_time AS TIME),
            SAFE.PARSE_TIME('%H:%M', crash_time)
        ) AS parsed_crash_time
    FROM {{ ref('stg_motor_vehicle_collisions_2025') }}
)

SELECT DISTINCT
    TO_HEX(SHA256(collision.collision_id)) AS collision_key,
    collision.collision_id,
    crash_day.date_key AS crash_date_key,
    crash_hour.time_key AS crash_time_key,
    location.location_key,
    factor.contributing_factor_key,
    vehicle.vehicle_type_key,
    COALESCE(collision.number_of_persons_injured, 0) AS persons_injured,
    COALESCE(collision.number_of_persons_killed, 0) AS persons_killed,
    COALESCE(collision.number_of_pedestrians_injured, 0) AS pedestrians_injured,
    COALESCE(collision.number_of_cyclist_injured, 0) AS cyclists_injured,
    COALESCE(collision.number_of_motorist_injured, 0) AS motorists_injured,
    COALESCE(collision.number_of_persons_injured, 0) > 0 AS is_injury_crash,
    COALESCE(NULLIF(collision.borough, 'UNSPECIFIED'), 'UNKNOWN') AS borough_source,
    collision.latitude,
    collision.longitude
FROM collisions AS collision
LEFT JOIN {{ ref('dim_date') }} AS crash_day
    ON crash_day.full_date = DATE(collision.crash_date)
LEFT JOIN {{ ref('dim_time_of_day') }} AS crash_hour
    ON crash_hour.time_key = COALESCE(
        EXTRACT(HOUR FROM collision.parsed_crash_time), -1
    )
LEFT JOIN {{ ref('dim_location') }} AS location
    ON location.borough = COALESCE(NULLIF(collision.borough, 'UNSPECIFIED'), 'UNKNOWN')
    AND location.zip_code = COALESCE(collision.incident_zip, 'UNKNOWN')
LEFT JOIN {{ ref('dim_contributing_factor') }} AS factor
    ON factor.contributing_factor = COALESCE(
        collision.contributing_factor_vehicle_1, 'Unknown'
    )
LEFT JOIN {{ ref('dim_vehicle_type') }} AS vehicle
    ON vehicle.vehicle_type = COALESCE(collision.vehicle_type_code1, 'Unknown')
    
    