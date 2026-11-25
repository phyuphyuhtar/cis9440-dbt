{{ config(materialized='table', schema='warehouse') }}

WITH request_statuses AS (
    SELECT DISTINCT
        COALESCE(status, 'Unknown') AS status,
        COALESCE(intake_channel, 'Unknown') AS intake_channel
    FROM {{ ref('stg_service_requests_dot') }}
)

SELECT
    TO_HEX(SHA256(TO_JSON_STRING(STRUCT(status, intake_channel)))) AS request_status_key,
    status,
    intake_channel
FROM request_statuses
