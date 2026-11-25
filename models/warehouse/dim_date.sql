{{ config(materialized='table', schema='warehouse') }}

WITH source_dates AS (
    SELECT DATE(created_at) AS full_date
    FROM {{ ref('stg_service_requests_dot') }}

    UNION ALL

    SELECT DATE(closed_at) AS full_date
    FROM {{ ref('stg_service_requests_dot') }}

    UNION ALL

    SELECT DATE(crash_date) AS full_date
    FROM {{ ref('stg_motor_vehicle_collisions_2025') }}
),

date_bounds AS (
    SELECT
        MIN(full_date) AS first_date,
        MAX(full_date) AS last_date
    FROM source_dates
),

calendar AS (
    SELECT full_date
    FROM date_bounds
    CROSS JOIN UNNEST(GENERATE_DATE_ARRAY(first_date, last_date)) AS full_date
)

SELECT
    CAST(FORMAT_DATE('%Y%m%d', full_date) AS INT64) AS date_key,
    full_date,
    EXTRACT(YEAR FROM full_date) AS year,
    EXTRACT(MONTH FROM full_date) AS month,
    FORMAT_DATE('%B', full_date) AS month_name,
    EXTRACT(DAY FROM full_date) AS day,
    FORMAT_DATE('%A', full_date) AS day_of_week,
    EXTRACT(DAYOFWEEK FROM full_date) IN (1, 7) AS is_weekend
FROM calendar

