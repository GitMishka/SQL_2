
IHP SeniorBICustom_rawfoodresults as of 16-August-2024

After - added monthend to firstlast and 

declare @fromdate DATETIME='8/16/2020', @ToDate DATETIME='9/30/2024'

WITH census AS (
    SELECT 
        ROUND(SUM(week1) / DAY(EOMONTH(Date)), 0) AS census, 
        DAY(EOMONTH(Date)) AS Days, 
        PropertyID, 
        FORMAT(DATEADD(MONTH, 0, Date), 'yyyyMM') AS "Financial Period",
        EOMONTH(Date) AS MonthEnd 
    FROM SeniorBICustom_IHPCensusSummaryRpt 
    WHERE Date BETWEEN @FromDate AND @ToDate 
      AND carelevel NOT IN ('Other', 'NULL')
    GROUP BY 
        PropertyID, 
        FORMAT(DATEADD(MONTH, 0, Date), 'yyyyMM'), 
        EOMONTH(Date)
),

FirstLast AS (
    SELECT 
        LEFT(CostCenter1, 4) AS comcode,
        COUNT(CASE WHEN date = DATEADD(DAY,1,EOMONTH(Date,-1)) THEN 1 END) AS FirstDayCount,
        COUNT(CASE WHEN date = EOMONTH(Date) THEN 1 END) AS LastDayCount,
		EOMONTH(Date) AS MonthEnd 
    FROM seniorBICustom_PaylocityTurnover
    WHERE date BETWEEN @FromDate AND @ToDate 
      AND EmploymentType = 'Regular Full Time'
    GROUP BY LEFT(CostCenter1, 4), EOMONTH(Date)
), 
combined AS (
    SELECT 
        c.census, 
        c.days, 
        p.scode, 
        c.PropertyID,
        c."Financial Period", 
        fl.comcode, 
        CAST('7.75' AS float) AS Cash,
        ROUND((fl.FirstDayCount + fl.LastDayCount) / 2, 0) AS n_emp30dayavg,
        c.MonthEnd
    FROM census c
    JOIN property p ON c.PropertyID = p.hmy
    JOIN FirstLast fl ON fl.comcode = p.scode and c.MonthEnd = fl.MonthEnd 
    WHERE c."Financial Period" = FORMAT(c.MonthEnd, 'yyyyMM')
)
SELECT
scode,
    CASE
        WHEN UPPER(scode) = 'CHTL' THEN 'CHAT'
        WHEN UPPER(scode) = 'RUSS' THEN 'RIDG'
        ELSE UPPER(scode)
    END AS "DSSILocationID", 
    "Financial Period" AS "FinancialPeriod", 
    '620025' AS "GLAccount",
    ROUND((census * (days + (n_emp30dayavg / 3)) * Cash), 2) AS "BudgetAmount", 
    MonthEnd AS "Date",
	PropertyID AS PropertyID
FROM combined 
ORDER BY UPPER(scode) ASC;



---------------------------

Before


WITH census AS (
    SELECT 
        ROUND(SUM(week1) / DAY(EOMONTH(Date)), 0) AS census, 
        DAY(EOMONTH(Date)) AS Days, 
        PropertyID, 
        FORMAT(DATEADD(MONTH, 0, Date), 'yyyyMM') AS "Financial Period",
        EOMONTH(Date) AS MonthEnd 
    FROM SeniorBICustom_IHPCensusSummaryRpt 
    WHERE Date BETWEEN @FromDate AND @ToDate 
      AND carelevel NOT IN ('Other', 'NULL')
    GROUP BY 
        PropertyID, 
        FORMAT(DATEADD(MONTH, 0, Date), 'yyyyMM'), 
        EOMONTH(Date)
),
FirstLast AS (
    SELECT 
        LEFT(CostCenter1, 4) AS comcode,
        COUNT(CASE WHEN date = @FromDate THEN 1 END) AS FirstDayCount,
        COUNT(CASE WHEN date = @ToDate THEN 1 END) AS LastDayCount
    FROM seniorBICustom_PaylocityTurnover
    WHERE date BETWEEN @FromDate AND @ToDate 
      AND EmploymentType = 'Regular Full Time'
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
        ROUND((fl.FirstDayCount + fl.LastDayCount) / 2, 0) AS n_emp30dayavg,
        c.MonthEnd
    FROM census c
    JOIN property p ON c.PropertyID = p.hmy
    JOIN FirstLast fl ON fl.comcode = p.scode
    WHERE c."Financial Period" = FORMAT(@FromDate, 'yyyyMM')
)
SELECT
scode,
    CASE
        WHEN UPPER(scode) = 'CHTL' THEN 'CHAT'
        WHEN UPPER(scode) = 'RUSS' THEN 'RIDG'
        ELSE UPPER(scode)
    END AS "DSSILocationID", 
    "Financial Period" AS "FinancialPeriod", 
    '620025' AS "GLAccount",
    ROUND((census * (days + (n_emp30dayavg / 3)) * Cash), 2) AS "BudgetAmount", 
    MonthEnd AS "Date" 
FROM combined 
ORDER BY UPPER(scode) ASC;