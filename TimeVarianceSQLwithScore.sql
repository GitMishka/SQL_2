WITH medpasscount AS(
	SELECT 
		PropertyId,
		COUNT(Variance) as medsgiven
	FROM SeniorBICustom_MissedMeds
	WHERE 
		ActualGiveTime BETWEEN DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0)
        AND DATEADD(SECOND, -1, DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 0, 0))
		AND MedAction = 'Given'
	GROUP BY PropertyId
),
medpassontime AS(
	SELECT 
		PropertyId,
		COUNT(Variance) as medslate
	FROM SeniorBICustom_MissedMeds
	WHERE 
		ActualGiveTime BETWEEN DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0)
        AND DATEADD(SECOND, -1, DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 0, 0))
		AND ABS(Variance) > 60
		AND MedAction = 'Given'
	GROUP BY PropertyId
),
medpasspercent AS(
	SELECT
		c.PropertyId,
		c.medsgiven,
		ot.medslate,
		(CAST(ot.medslate AS FLOAT)/CAST(c.medsgiven AS FLOAT)) AS medpercent
	FROM medpasscount c 
	JOIN medpassontime ot ON c.PropertyId = ot.PropertyId
)

SELECT 
	p.SCODE,
	tv.medsgiven,
	tv.medslate,
	ROUND((tv.medpercent*100),2) AS MissedMedsPercent,
    ROUND(((0.8 * EXP(-0.27 * (100 * medpercent - 1.5)) - (0.8 * EXP(0.405) - 1) * EXP(-2.2 * POWER(100 * medpercent, 2)))*100),2) AS MedPassScore
FROM medpasspercent tv
JOIN property p ON tv.PropertyId = p.HMY
ORDER BY p.SCODE;