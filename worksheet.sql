WITH DailyActivities AS (
    SELECT 
        PropertyId, 
        type, 
        COUNT(*) AS CompletedDaily,
        DATE(Date) AS ActivityDate
    FROM 
        SeniorBICustom_lifeloopactivities
    GROUP BY 
        PropertyId, type, DATE(Date)
),
WeeklyActivities AS (
    SELECT 
        PropertyId, 
        type, 
        COUNT(*) AS CompletedWeekly,
        DATE_TRUNC('week', DATE(Date)) AS WeekStart
    FROM 
        SeniorBICustom_lifeloopactivities
    GROUP BY 
        PropertyId, type, DATE_TRUNC('week', DATE(Date))
),
MonthlyActivities AS (
    SELECT 
        PropertyId, 
        type, 
        COUNT(*) AS CompletedMonthly,
        DATE_TRUNC('month', DATE(Date)) AS MonthStart
    FROM 
        SeniorBICustom_lifeloopactivities
    GROUP BY 
        PropertyId, type, DATE_TRUNC('month', DATE(Date))
)
SELECT
    d.PropertyId,
    d.type,
    d.ActivityDate,
    d.CompletedDaily,
    na.daily AS RequiredDaily,
    w.CompletedWeekly,
    na.weekly AS RequiredWeekly,
    m.CompletedMonthly,
    na.weekly * 4 AS RequiredMonthly -- Assuming 4 weeks per month
FROM 
    DailyActivities d
JOIN 
    SeniorBICustom_lifeloop_nactivities na ON d.type = na.type AND d.ActivityDate = DATE(na.Date)
LEFT JOIN 
    WeeklyActivities w ON d.PropertyId = w.PropertyId AND d.type = w.type AND DATE_TRUNC('week', d.ActivityDate) = w.WeekStart
LEFT JOIN 
    MonthlyActivities m ON d.PropertyId = m.PropertyId AND d.type = m.type AND DATE_TRUNC('month', d.ActivityDate) = m.MonthStart
ORDER BY 
    d.PropertyId, d.ActivityDate;
