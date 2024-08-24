--select * from seniorprospect 
--select * from SeniorResidentStatus 
--select * from attributes
--select * from  Country_info  
--select * from property


WITH unt AS (
    SELECT a.SUBGROUP2 AS region, COUNT(*) AS n_units
    FROM unit u
    JOIN attributes a ON u.HPROPERTY = a.hprop
    WHERE a.SUBGROUP2 IS NOT NULL
    GROUP BY a.SUBGROUP2
)
SELECT 
    COUNT(t.hmyperson) AS counts, 
    unt.n_units, 
    a.SUBGROUP2,
    CAST(COUNT(t.hmyperson) AS DECIMAL(10,4)) / unt.n_units AS ratio
FROM tenant t
JOIN attributes a ON t.HPROPERTY = a.hprop
JOIN unt ON unt.region = a.SUBGROUP2
WHERE YEAR(t.dtmoveout) = 2024 
  AND MONTH(t.dtmoveout) NOT IN (7)
  and datediff(day, dtmovein,dtmoveout) < 90
GROUP BY a.SUBGROUP2, unt.n_units;


