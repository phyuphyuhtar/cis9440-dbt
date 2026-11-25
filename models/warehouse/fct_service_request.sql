{{ config(materialized='table', schema='warehouse') }}

SELECT DISTINCT
    TO_HEX(SHA256(requests.service_request_id)) AS service_request_key,
    SAFE_CAST(requests.service_request_id AS INT64) AS unique_key,
    created.date_key AS created_date_key,
    closed.date_key AS closed_date_key,
    request_time.time_key AS created_time_key,
    location.location_key,
    problem.problem_key,
    request_status.request_status_key,
    CASE
        WHEN requests.closed_at >= requests.created_at THEN
            CAST(
                TIMESTAMP_DIFF(requests.closed_at, requests.created_at, SECOND)
                AS NUMERIC
            ) / NUMERIC '3600'
    END AS closure_hours,
    requests.community_board,
    requests.latitude,
    requests.longitude
FROM {{ ref('stg_service_requests_dot') }} AS requests
LEFT JOIN {{ ref('dim_date') }} AS created
    ON created.full_date = DATE(requests.created_at)
LEFT JOIN {{ ref('dim_date') }} AS closed
    ON closed.full_date = DATE(requests.closed_at)
LEFT JOIN {{ ref('dim_time_of_day') }} AS request_time
    ON request_time.time_key = COALESCE(EXTRACT(HOUR FROM requests.created_at), -1)
LEFT JOIN {{ ref('dim_location') }} AS location
    ON location.borough = COALESCE(NULLIF(requests.borough, 'UNSPECIFIED'), 'UNKNOWN')
    AND location.zip_code = COALESCE(requests.incident_zip, 'UNKNOWN')
LEFT JOIN {{ ref('dim_problem') }} AS problem
    ON problem.problem_type = COALESCE(requests.complaint_type, 'Unknown')
    AND problem.problem_detail = COALESCE(requests.descriptor, 'Unknown')
LEFT JOIN {{ ref('dim_request_status') }} AS request_status
    ON request_status.status = COALESCE(requests.status, 'Unknown')
    AND request_status.intake_channel = COALESCE(requests.intake_channel, 'Unknown')
    