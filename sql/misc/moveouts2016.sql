WITH DateParts AS (
    SELECT 
        DATEPART(year, Billing_End_Date) AS endYear,
        FORMAT(Billing_End_Date, 'MMMM') AS endMonth,
		Move_Out_Reason
    FROM [dbo].[moveouts]
)
SELECT 
    endYear,
    endMonth,
    COUNT(endMonth) AS n_monthmoveouts,
    RANK() OVER (ORDER BY COUNT(endMonth) DESC) AS rank
FROM DateParts
GROUP BY endYear, endMonth
ORDER BY rank;


WITH DateParts AS (
    SELECT 
        DATEPART(year, Billing_End_Date) AS endYear,
        FORMAT(Billing_End_Date, 'MMMM') AS endMonth
    FROM [dbo].[moveouts]
)
SELECT 
    endYear,
    endMonth,
    COUNT(endMonth) AS n_monthmoveouts,
    RANK() OVER (ORDER BY COUNT(endMonth) DESC) AS rank
FROM DateParts
GROUP BY endYear, endMonth
ORDER BY rank;

WITH YearlyMoveOuts AS (
    SELECT 
        DATEPART(year, Billing_End_Date) AS endYear,
        Move_Out_Reason,
        COUNT(*) AS n_moveouts
    FROM [dbo].[moveouts]
    GROUP BY DATEPART(year, Billing_End_Date), Move_Out_Reason
)
SELECT 
    endYear,
    Move_Out_Reason,
    n_moveouts,
    RANK() OVER (PARTITION BY endYear ORDER BY n_moveouts DESC) AS rank
FROM YearlyMoveOuts
ORDER BY endYear, rank;
WITH MonthlyMoveOuts AS (
    SELECT 
        DATEPART(year, Billing_End_Date) AS endYear,
        FORMAT(Billing_End_Date, 'MMMM') AS endMonth,
        Move_Out_Reason,
        COUNT(*) AS n_moveouts
    FROM [dbo].[moveouts]
    GROUP BY DATEPART(year, Billing_End_Date), FORMAT(Billing_End_Date, 'MMMM'), Move_Out_Reason
)
SELECT 
    endYear,
    endMonth,
    Move_Out_Reason,
    n_moveouts,
    RANK() OVER (PARTITION BY endYear, endMonth ORDER BY n_moveouts DESC) AS rank
FROM MonthlyMoveOuts
ORDER BY endYear, endMonth, rank;


WITH YearlyMoveOuts AS (
    SELECT 
        DATEPART(year, Billing_End_Date) AS endYear,
        Move_Out_Reason,
        COUNT(*) AS n_moveouts
    FROM [dbo].[moveouts]
    GROUP BY DATEPART(year, Billing_End_Date), Move_Out_Reason
)
SELECT 
    endYear,
    Move_Out_Reason,
    n_moveouts,
    ROW_NUMBER() OVER (PARTITION BY endYear ORDER BY n_moveouts DESC) AS rank
FROM YearlyMoveOuts
ORDER BY endYear, rank;


WITH MonthlyMoveOuts AS (
    SELECT 
        DATEPART(year, Billing_End_Date) AS endYear,
        FORMAT(Billing_End_Date, 'MMMM') AS endMonth,
        Move_Out_Reason,
        COUNT(*) AS n_moveouts
    FROM [dbo].[moveouts]
    GROUP BY DATEPART(year, Billing_End_Date), FORMAT(Billing_End_Date, 'MMMM'), Move_Out_Reason
)
SELECT 
    endYear,
    endMonth,
    Move_Out_Reason,
    n_moveouts,
    RANK() OVER (PARTITION BY endYear, endMonth ORDER BY n_moveouts DESC) AS rank
FROM MonthlyMoveOuts
ORDER BY endYear, endMonth, rank;
