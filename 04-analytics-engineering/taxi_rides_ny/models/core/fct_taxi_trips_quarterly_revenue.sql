WITH quarterly_revenue AS (
    SELECT 
        service_type,
        EXTRACT(YEAR FROM pickup_datetime) AS year,
        EXTRACT(QUARTER FROM pickup_datetime) AS quarter,
        CONCAT(EXTRACT(YEAR FROM pickup_datetime), '/Q', EXTRACT(QUARTER FROM pickup_datetime)) AS year_quarter,
        SUM(total_amount) AS total_revenue
    FROM {{ ref('fact_trips') }}
    GROUP BY 1, 2, 3, 4
),

all_quarters AS (
    SELECT DISTINCT service_type, year, quarter
    FROM quarterly_revenue
    WHERE year IN (2019, 2020)
),

yoy_growth AS (
    SELECT 
        q1.service_type,
        q1.year_quarter,
        q1.total_revenue,
        SAFE_DIVIDE(q1.total_revenue - COALESCE(q2.total_revenue, 0), NULLIF(q2.total_revenue, 0)) * 100 AS yoy_growth
    FROM quarterly_revenue q1
    LEFT JOIN quarterly_revenue q2
        ON q1.service_type = q2.service_type
        AND q1.year = q2.year + 1
        AND q1.quarter = q2.quarter
    WHERE q1.year = 2020
)

SELECT * FROM yoy_growth
