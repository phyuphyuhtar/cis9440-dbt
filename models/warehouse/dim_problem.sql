{{ config(materialized='table', schema='warehouse') }}

WITH problems AS (
    SELECT DISTINCT
        COALESCE(complaint_type, 'Unknown') AS problem_type,
        COALESCE(descriptor, 'Unknown') AS problem_detail
    FROM {{ ref('stg_service_requests_dot') }}
)

SELECT
    TO_HEX(SHA256(TO_JSON_STRING(STRUCT(problem_type, problem_detail)))) AS problem_key,
    problem_type,
    problem_detail,
    UPPER(problem_type) IN (
        'STREET CONDITION',
        'HIGHWAY CONDITION',
        'SIDEWALK CONDITION',
        'TRAFFIC SIGNAL CONDITION',
        'STREET LIGHT CONDITION',
        'STREET SIGN - DAMAGED',
        'STREET SIGN - DANGLING',
        'STREET SIGN - MISSING'
    ) AS is_infrastructure_request
FROM problems
