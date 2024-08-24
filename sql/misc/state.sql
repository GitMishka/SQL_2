WITH unt AS (
    SELECT p.sstate AS state, COUNT(*) AS n_units
    FROM unit u
    JOIN attributes a ON u.HPROPERTY = a.hprop
    JOIN property p ON p.scode = a.SCODE
    GROUP BY p.sstate
)

SELECT 
    COUNT(t.hmyperson) AS counts, 
    unt.n_units, 
    p.sstate,
    CAST(COUNT(t.hmyperson) AS DECIMAL(10,4)) / unt.n_units AS ratio
FROM tenant t
JOIN attributes a ON t.HPROPERTY = a.hprop
JOIN property p ON p.scode = a.SCODE
JOIN unt ON unt.state = p.sstate
WHERE YEAR(t.dtmoveout) = 2024 
  AND MONTH(t.dtmoveout) NOT IN (7)
GROUP BY p.sstate, unt.n_units 
ORDER BY ratio;
