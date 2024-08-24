WITH los AS (
    SELECT 
        p.scode,
        SFIRSTNAME,
        SLASTname,
        dtmovein,
        dtmoveout, 
        DATEDIFF(day, DTMOVEIN, ISNULL(DTMOVEOUT, GETDATE())) AS LoS_days,
        YEAR(dtmovein) AS yr
    FROM 
        tenant t
        JOIN property p ON t.HPROPERTY = p.HMY
),
budgeted AS (
    SELECT
        SUBSTRING(Community, CHARINDEX('(', Community) + 1, CHARINDEX(')', Community) - CHARINDEX('(', Community) - 1) AS comcode
		,*
    FROM
        #ConsolidatedData
)
SELECT 
    b.year,
    b.Region AS region,
    b.Community AS community,
 --   SUM(b.TotalUnits) AS n_units,
 TotalUnits,
    COUNT(l.scode) AS move_ins,
    CAST(COUNT(dtmovein)) AS FLOAT) / TotalUnits AS move_in_ratio
FROM 
    budgeted b
    JOIN property p ON b.comcode = p.scode
    LEFT JOIN los l ON p.scode = l.scode AND b.year = l.yr
WHERE 
    l.LoS_days < 7000 AND l.yr > 2018
GROUP BY 
    b.year, b.Region, b.Community ,TotalUnits
ORDER BY 
    b.community asc;

WITH los AS (
    SELECT 
        p.scode,
        SFIRSTNAME,
        SLASTname,
        dtmovein,
        dtmoveout, 
        DATEDIFF(day, DTMOVEIN, ISNULL(DTMOVEOUT, GETDATE())) AS LoS_days,
        YEAR(dtmovein) AS movein_year,
        YEAR(dtmoveout) AS moveout_year
    FROM 
        tenant t
        JOIN property p ON t.HPROPERTY = p.HMY
),
budgeted AS (
    SELECT
        SUBSTRING(Community, CHARINDEX('(', Community) + 1, CHARINDEX(')', Community) - CHARINDEX('(', Community) - 1) AS comcode,
        Community,
        Region,
        TotalUnits,
        YEAR(DateField) AS year  -- Replace 'DateField' with the actual date field in #ConsolidatedData
    FROM
        #ConsolidatedData
)
SELECT 
    b.year,
    b.Region AS region,
    b.Community AS community,
    SUM(b.TotalUnits) AS n_units,
    COUNT(CASE WHEN l.movein_year = b.year THEN l.scode END) AS move_ins,
    COUNT(CASE WHEN l.moveout_year = b.year THEN l.scode END) AS move_outs,
    CAST(COUNT(CASE WHEN l.movein_year = b.year THEN l.scode END) AS FLOAT) / SUM(b.TotalUnits) AS move_in_ratio,
    CAST(COUNT(CASE WHEN l.moveout_year = b.year THEN l.scode END) AS FLOAT) / SUM(b.TotalUnits) AS move_out_ratio
FROM 
    budgeted b
    JOIN property p ON b.comcode = p.scode
    LEFT JOIN los l ON p.scode = l.scode
WHERE 
    l.LoS_days < 7000 AND l.movein_year > 2018
GROUP BY 
    b.year, b.Region, b.Community
ORDER BY 
    b.community ASC;
WITH los AS (
    SELECT 
        p.scode,
        SFIRSTNAME,
        SLASTname,
        dtmovein,
        dtmoveout, 
        DATEDIFF(day, DTMOVEIN, ISNULL(DTMOVEOUT, GETDATE())) AS LoS_days,
        YEAR(dtmovein) AS yr
    FROM 
        tenant t
        JOIN property p ON t.HPROPERTY = p.HMY
),
budgeted AS (
    SELECT
        SUBSTRING(Community, CHARINDEX('(', Community) + 1, CHARINDEX(')', Community) - CHARINDEX('(', Community) - 1) AS comcode,
        Community,
        Region,
        TotalUnits,
        YEAR(DateField) AS year  -- Adjust 'DateField' to the actual date field in your #ConsolidatedData table
    FROM
        #ConsolidatedData
)
SELECT 
    b.year,
    b.Region AS region,
    b.Community AS community,
    SUM(b.TotalUnits) AS n_units,
    COUNT(l.scode) AS move_ins,
    CAST(COUNT(l.scode) AS FLOAT) / SUM(b.TotalUnits) AS move_in_ratio
FROM 
    budgeted b
    JOIN property p ON b.comcode = p.scode
    LEFT JOIN los l ON p.scode = l.scode AND b.year = l.yr
WHERE 
    l.LoS_days < 7000 AND l.yr > 2018
GROUP BY 
    b.year, b.Region, b.Community
ORDER BY 
    b.year DESC;
SELECT 
    b.year,
    b.Region AS region,
    b.Community AS community,
    SUM(b.TotalUnits) AS n_units,
    COUNT(CASE WHEN l.moveout_year = b.year THEN l.scode END) AS move_outs,
    CAST(COUNT(CASE WHEN l.moveout_year = b.year THEN l.scode END) AS FLOAT) / SUM(b.TotalUnits) AS turnover_rate
FROM 
    budgeted b
    JOIN property p ON b.comcode = p.scode
    LEFT JOIN los l ON p.scode = l.scode
WHERE 
    l.LoS_days < 7000 AND l.moveout_year > 2018
GROUP BY 
    b.year, b.Region, b.Community
ORDER BY 
    b.community ASC;
