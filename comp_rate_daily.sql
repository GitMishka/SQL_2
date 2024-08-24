https://independent56474.yardione.com/

DECLARE @FromDate DATE = '2024-07-31';  -- Adjust as needed
DECLARE @ToDate DATE = '2024-08-31';    -- Adjust as needed

WITH required_counts AS (
    SELECT 'physical' AS type
    UNION ALL
    SELECT 'intellectual'
    UNION ALL
    SELECT 'spiritual'
),
calendar AS (
    SELECT @FromDate AS date
    UNION ALL
    SELECT DATEADD(DAY, 1, date)
    FROM calendar
    WHERE date < @ToDate
),
property_type_combinations AS (
    SELECT 
        p.propertyid, 
        c.date, 
        r.type
    FROM 
        (SELECT DISTINCT propertyid FROM SeniorBICustom_lifeloopactivities) p
    CROSS JOIN 
        calendar c
    CROSS JOIN 
        required_counts r
)
SELECT 
    ptc.propertyid,
    ptc.type,
    ptc.date,
    COALESCE(COUNT(a.type), 0) AS activity_count,
    1 AS required_activities,  -- Adding required_activities with a constant value of 1
    COALESCE(COUNT(a.type), 0) * 100.0 / 1.0 AS completion_rate_percentage  -- Calculating completion_rate as a percentage
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
    ptc.date
ORDER BY 
    ptc.date, 
    ptc.propertyid, 
    ptc.type
OPTION (MAXRECURSION 0);
