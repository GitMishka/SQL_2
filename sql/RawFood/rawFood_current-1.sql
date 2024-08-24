WITH census AS (
    SELECT 
        ROUND(SUM(week1) / DAY(EOMONTH(Date)), 0) AS census, 
        DAY(EOMONTH(Date)) AS Days, 
        PropertyID, 
        FORMAT(DATEADD(MONTH, 0, Date), 'yyyyMM') AS "Financial Period"
    FROM SeniorBICustom_IHPCensusSummaryRpt 
    WHERE EOMONTH(Date) < GETDATE() 
      AND carelevel NOT IN ('Other', 'NULL')
    GROUP BY 
        PropertyID, 
        FORMAT(DATEADD(MONTH, 0, Date), 'yyyyMM'), 
        EOMONTH(Date)
),
FirstLast AS (
    SELECT 
        LEFT(CostCenter1, 4) AS comcode,
        COUNT(CASE WHEN date = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 2, 0) THEN 1 END) AS FirstDayCount,
        COUNT(CASE WHEN date = DATEADD(DAY, -1, DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0)) THEN 1 END) AS LastDayCount
    FROM seniorBICustom_PaylocityTurnover
    WHERE EmploymentType = 'Regular Full Time'
    GROUP BY LEFT(CostCenter1, 4)
), 
combined AS (
    SELECT 
        c.census, 
        c.days, 
        p.scode, 
        c."Financial Period", 
        fl.comcode, 
        CAST('7.75' AS float) AS Cash,
        ROUND((fl.FirstDayCount + fl.LastDayCount) / 2, 0) AS n_emp30dayavg
    FROM census c
    JOIN property p ON c.PropertyID = p.hmy
    JOIN FirstLast fl ON fl.comcode = p.scode
    WHERE c."Financial Period" = FORMAT(DATEADD(MONTH, -2, GETDATE()), 'yyyyMM')
)
SELECT 
    CASE
        WHEN UPPER(scode) = 'CHTL' THEN 'CHAT'
        WHEN UPPER(scode) = 'RUSS' THEN 'RIDG'
        ELSE UPPER(scode)
    END AS "DSSI Location ID*", 
    "Financial Period" AS "Financial Period*", 
    '620025' AS "GL Account*",
    ROUND((census * (days + (n_emp30dayavg / 3)) * Cash), 2) AS "Budget Amount*" 
FROM combined 
ORDER BY UPPER(scode) ASC;
