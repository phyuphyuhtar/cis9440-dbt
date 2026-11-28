{{ config(materialized='table') }}

WITH source AS (
    SELECT *
    FROM {{ source('nyc_raw', 'source_motor_vehicle_collisions_2025') }}
)

SELECT
    collision_id,
    CAST(crash_date AS DATE) AS crash_date,
    NULLIF(TRIM(crash_time), '') AS crash_time,

    CASE
        WHEN UPPER(TRIM(borough)) IN ('MANHATTAN', 'NEW YORK COUNTY') THEN 'Manhattan'
        WHEN UPPER(TRIM(borough)) IN ('BRONX', 'THE BRONX') THEN 'Bronx'
        WHEN UPPER(TRIM(borough)) IN ('BROOKLYN', 'KINGS COUNTY') THEN 'Brooklyn'
        WHEN UPPER(TRIM(borough)) IN ('QUEENS', 'QUEEN', 'QUEENS COUNTY') THEN 'Queens'
        WHEN UPPER(TRIM(borough)) IN ('STATEN ISLAND', 'RICHMOND COUNTY') THEN 'Staten Island'
        ELSE 'UNKNOWN or CITYWIDE'
    END AS borough,

    CASE
        WHEN UPPER(TRIM(CAST(zip_code AS STRING))) IN ('N/A', 'NA') THEN NULL
        WHEN UPPER(TRIM(CAST(zip_code AS STRING))) = 'ANONYMOUS' THEN 'Anonymous'
        WHEN LENGTH(CAST(zip_code AS STRING)) = 5 THEN CAST(zip_code AS STRING)
        WHEN LENGTH(CAST(zip_code AS STRING)) = 9 THEN CAST(zip_code AS STRING)
        WHEN LENGTH(CAST(zip_code AS STRING)) = 10
            AND REGEXP_CONTAINS(CAST(zip_code AS STRING), r'^\d{5}-\d{4}')
        THEN CAST(zip_code AS STRING)
        ELSE NULL
    END AS zip,

    NULLIF(TRIM(CAST(zip_code AS STRING)), '') AS incident_zip,
    latitude,
    longitude,
    number_of_persons_injured,
    number_of_persons_killed,
    number_of_pedestrians_injured,
    number_of_cyclist_injured,
    number_of_motorist_injured,
    NULLIF(TRIM(contributing_factor_vehicle_1), '') AS contributing_factor_vehicle_1,
    NULLIF(TRIM(vehicle_type_code1), '') AS vehicle_type_code1
FROM source