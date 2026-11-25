{{ config(materialized='table', schema='warehouse') }}

WITH vehicle_types AS (
    SELECT DISTINCT
        COALESCE(vehicle_type_code1, 'Unknown') AS vehicle_type
    FROM {{ ref('stg_motor_vehicle_collisions_2025') }}
)

SELECT
    TO_HEX(SHA256(vehicle_type)) AS vehicle_type_key,
    vehicle_type,
    CASE
        WHEN UPPER(vehicle_type) IN ('UNKNOWN', 'UNSPECIFIED')
            THEN 'Unknown'
        WHEN UPPER(vehicle_type) IN (
            'SEDAN', 'PASSENGER VEHICLE', 'STATION WAGON/SPORT UTILITY VEHICLE',
            'SUV', 'TAXI'
        ) THEN 'Passenger Vehicle'
        WHEN UPPER(vehicle_type) IN ('BIKE', 'BICYCLE', 'E-BIKE', 'E-SCOOTER')
            THEN 'Micromobility'
        WHEN UPPER(vehicle_type) IN ('MOTORCYCLE', 'MOPED')
            THEN 'Motorcycle or Moped'
        WHEN UPPER(vehicle_type) IN ('BUS', 'SCHOOL BUS')
            THEN 'Bus'
        WHEN UPPER(vehicle_type) IN (
            'PICK-UP TRUCK', 'PICKUP TRUCK', 'BOX TRUCK', 'DUMP', 'TRACTOR TRUCK DIESEL'
        ) THEN 'Truck'
        ELSE 'Other'
    END AS vehicle_category
FROM vehicle_types
