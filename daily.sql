SELECT 
    facility1_id, 
    DATEPART(YEAR, start_date) AS year,
    DATEPART(WEEK, start_date) AS week,
    COUNT(*) AS weekly_activity_count
FROM 
    activities_table
GROUP BY 
    facility1_id, 
    DATEPART(YEAR, start_date),
    DATEPART(WEEK, start_date)
ORDER BY 
    facility1_id, 
    year,
    week;
