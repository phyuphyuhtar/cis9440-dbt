{{ config(materialized='table', schema='staging') }}

SELECT
    unique_key AS service_request_id,
    created_date AS created_at,
    closed_date AS closed_at,
    NULLIF(TRIM(complaint_type), '') AS complaint_type,
    NULLIF(TRIM(descriptor), '') AS descriptor,
    NULLIF(UPPER(TRIM(borough)), '') AS borough,
    NULLIF(TRIM(incident_zip), '') AS incident_zip,
        NULLIF(TRIM(status), '') AS status,
        NULLIF(TRIM(open_data_channel_type), '') AS intake_channel,
    NULLIF(TRIM(community_board), '') AS community_board,
    latitude,
    longitude
FROM {{ source('nyc_raw', 'source_service_requests_dot') }}
