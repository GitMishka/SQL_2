SELECT 
    COUNT(CASE WHEN date = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0) THEN 1 END) AS FirstDayCount,
    COUNT(CASE WHEN date = DATEADD(DAY, -1, DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)) THEN 1 END) AS LastDayCount
FROM seniorBICustom_PaylocityTurnover;