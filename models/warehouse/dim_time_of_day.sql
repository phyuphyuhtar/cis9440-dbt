{{ config(materialized='table', schema='warehouse') }}

SELECT
    hour AS time_key,
    FORMAT('%02d:00', hour) AS hour_label,
    CASE
        WHEN hour BETWEEN 6 AND 11 THEN 'Morning'
        WHEN hour BETWEEN 12 AND 17 THEN 'Afternoon'
        WHEN hour BETWEEN 18 AND 21 THEN 'Evening'
        ELSE 'Night'
    END AS day_part
FROM UNNEST(GENERATE_ARRAY(0, 23)) AS hour

UNION ALL

SELECT -1 AS time_key, 'Unknown' AS hour_label, 'Unknown' AS day_part
