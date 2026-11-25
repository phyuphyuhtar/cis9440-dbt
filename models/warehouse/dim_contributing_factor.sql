{{ config(materialized='table', schema='warehouse') }}

WITH factors AS (
    SELECT DISTINCT
        COALESCE(contributing_factor_vehicle_1, 'Unknown') AS contributing_factor
    FROM {{ ref('stg_motor_vehicle_collisions_2025') }}
)

SELECT
    TO_HEX(SHA256(contributing_factor)) AS contributing_factor_key,
    contributing_factor,
    UPPER(contributing_factor) IN (
        'PAVEMENT DEFECTIVE',
        'PAVEMENT SLIPPERY',
        'OBSTRUCTION/DEBRIS',
        'TRAFFIC CONTROL DEVICE IMPROPER/NON-WORKING',
        'LANE MARKING IMPROPER/INADEQUATE'
    ) AS is_roadway_related
FROM factors
