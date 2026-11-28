{{ config(materialized='table') }}

-- Location dimension shared by both data sources.
-- Grain: one row per distinct combination of borough and zip.

WITH stg_311 AS (
    SELECT borough, zip
    FROM {{ ref('stg_nyc_311_dot') }}
),

stg_second AS (
    SELECT borough, zip
    FROM {{ ref('stg_motor_vehicle_collisions_2025') }}
),

all_locations AS (
    SELECT borough, zip
    FROM stg_311
    WHERE borough IS NOT NULL OR zip IS NOT NULL

    UNION DISTINCT

    SELECT borough, zip
    FROM stg_second
    WHERE borough IS NOT NULL OR zip IS NOT NULL
),

location_dimension AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['borough', 'zip']) }} AS location_key,
        borough,
        zip,
        zip AS zip_code
    FROM all_locations
),

null_placeholder AS (
    SELECT
        '-1' AS location_key,
        CAST(NULL AS STRING) AS borough,
        CAST(NULL AS STRING) AS zip,
        CAST(NULL AS STRING) AS zip_code
)

SELECT * FROM location_dimension
UNION ALL
SELECT * FROM null_placeholder