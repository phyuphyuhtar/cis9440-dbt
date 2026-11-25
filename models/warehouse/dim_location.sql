{{ config(materialized='table', schema='warehouse') }}

WITH source_locations AS (
    SELECT borough, incident_zip
    FROM {{ ref('stg_service_requests_dot') }}

    UNION ALL

    SELECT borough, incident_zip
    FROM {{ ref('stg_motor_vehicle_collisions_2025') }}
),

locations AS (
    SELECT DISTINCT
        COALESCE(NULLIF(borough, 'UNSPECIFIED'), 'UNKNOWN') AS borough,
        COALESCE(incident_zip, 'UNKNOWN') AS zip_code
    FROM source_locations
)

SELECT
    TO_HEX(SHA256(TO_JSON_STRING(STRUCT(borough, zip_code)))) AS location_key,
    borough,
    zip_code
FROM locations
