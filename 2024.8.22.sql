WITH required_counts AS (
    SELECT 
        'physical' AS type, 1 AS daily_required, 7 AS weekly_required
    UNION ALL
    SELECT 
        'intellectual', 1, 7
    UNION ALL
    SELECT 
        'inmotion', 0, 1
    UNION ALL
    SELECT 
        'outings', 0, 2
    UNION ALL
    SELECT 
        'spiritual', 1, 7
    UNION ALL
    SELECT 
        'creative', 0, 2
    UNION ALL
    SELECT 
        'monthlytheme', 0, 1
)
SELECT 
    a.propertyid,
    a.type,
    a.date,
    COUNT(a.type) AS activity_count,
    r.daily_required,
    r.weekly_required
FROM 
    SeniorBICustom_lifeloopactivities a
JOIN 
    required_counts r
ON 
    a.type = r.type
GROUP BY 
    a.propertyid,
    a.type,
    a.date,
    r.daily_required,
    r.weekly_required;
-----------------

WITH required_counts AS (
    SELECT 
        'physical' AS type, 1 AS daily_required
    UNION ALL
    SELECT 
        'intellectual', 1
    UNION ALL
    SELECT 
        'inmotion', 0
    UNION ALL
    SELECT 
        'outings', 0
    UNION ALL
    SELECT 
        'spiritual', 1
    UNION ALL
    SELECT 
        'creative', 0
    UNION ALL
    SELECT 
        'monthlytheme', 0
),
calendar AS (
    SELECT 
        CAST('2024-08-01' AS DATE) AS date
    UNION ALL
    SELECT 
        DATEADD(DAY, 1, date)
    FROM 
        calendar
    WHERE 
        date < '2024-08-31'  -- Adjust the end date as needed
),
property_type_combinations AS (
    SELECT 
        c.date, 
        p.propertyid, 
        r.type, 
        r.daily_required
    FROM 
        (SELECT DISTINCT propertyid FROM SeniorBICustom_lifeloopactivities) p
    CROSS JOIN 
        calendar c
    CROSS JOIN 
        required_counts r
    WHERE 
        r.daily_required > 0  -- Exclude types with daily_required = 0
)
SELECT 
    ptc.propertyid,
    ptc.type,
    ptc.date,
    COALESCE(COUNT(a.type), 0) AS activity_count,
    ptc.daily_required
FROM 
    property_type_combinations ptc
LEFT JOIN 
    SeniorBICustom_lifeloopactivities a
ON 
    ptc.propertyid = a.propertyid 
    AND ptc.type = a.type 
    AND ptc.date = a.date
GROUP BY 
    ptc.propertyid,
    ptc.type,
    ptc.date,
    ptc.daily_required
ORDER BY 
    ptc.propertyid, 
    ptc.date, 
    ptc.type
OPTION (MAXRECURSION 0);
