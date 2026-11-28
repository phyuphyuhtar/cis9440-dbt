{{ config(materialized='table', schema='warehouse') }}

WITH problems AS (
    SELECT DISTINCT
        COALESCE(NULLIF(TRIM(complaint_type), ''), 'UNKNOWN') AS problem_type,
        COALESCE(NULLIF(TRIM(descriptor), ''), 'UNKNOWN') AS problem_detail
    FROM {{ ref('stg_service_requests_dot') }}
)

SELECT
    TO_HEX(SHA256(TO_JSON_STRING(
        STRUCT(problem_type, problem_detail)
    ))) AS problem_key,
    problem_type,
    problem_detail,
    REGEXP_CONTAINS(
        LOWER(CONCAT(problem_type, ' ', problem_detail)),
        r'pothole|sidewalk|street|highway|bridge|traffic signal|bike lane'
    ) AS is_infrastructure_request
FROM problems