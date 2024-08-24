WITH GLAcctsActual AS(
	SELECT distinct
		a.SCODE as PropertyName,
		a.SUBGROUP1 AS BuildingType,
		FORMAT(DATEADD(month, 0, Date), 'yyyyMM') as YearMonth,
		DAY(EOMONTH(Date)) as Days,
		GLGroup,
		SUM(ActualAmount) as ActAmount
	FROM SeniorBICustom_OperationalEfficiency s
	JOIN ATTRIBUTES a ON s.PropertyId = a.HPROP
	WHERE BookType = 'Actual' AND Month(Date) < Month(GetDate())
	GROUP BY a.SCODE, GLGroup, FORMAT(DATEADD(month, 0, Date), 'yyyyMM'), DAY(EOMONTH(Date)), a.SUBGROUP1
),
 
GLAcctsBudget AS(
	SELECT distinct
		a.SCODE as PropertyName,
		FORMAT(DATEADD(month, 0, Date), 'yyyyMM') as YearMonth,
		GLGroup,
		SUM(ActualAmount) as BudAmount
	FROM SeniorBICustom_OperationalEfficiency s
	JOIN ATTRIBUTES a ON s.PropertyId = a.HPROP
	WHERE BookType = 'Budget' AND Month(Date) < Month(GetDate())
	GROUP BY PropertyName, GLGroup, FORMAT(DATEADD(month, 0, Date), 'yyyyMM'), a.SCODE
),
 
GLAccts AS(
	SELECT
		a.PropertyName,
		a.YearMonth,
		a.BuildingType,
		a.Days,
		a.GLGroup,
		ActAmount,
		BudAmount
	FROM GLAcctsActual a
	LEFT JOIN GLAcctsBudget b ON Concat(a.PropertyName, a.GLGroup, a.YearMonth) = Concat(b.PropertyName, b.GLGroup, b.YearMonth)
),
 
GLAccts_Pivot AS(
	SELECT
		PropertyName,
		YearMonth,
		BuildingType,
		(MAX(CASE WHEN GLGroup = 'Total Resident Census' THEN ActAmount END) * Days) AS OccUnitDays,
		(MAX(CASE WHEN GLGroup = 'Total Resident Census' THEN BudAmount END) * Days) AS BudUnitDays,
		MAX(CASE WHEN GLGroup = 'Total Ancillary Revenue' THEN ActAmount END) AS TotalAncillaryRevenue_ActAmount,
		MAX(CASE WHEN GLGroup = 'Total Ancillary Revenue' THEN BudAmount END) AS TotalAncillaryRevenue_BudAmount,
		-MAX(CASE WHEN GLGroup = 'Total Care Labor Costs' THEN ActAmount END) AS TotalCareLaborCosts_ActAmount,
		-MAX(CASE WHEN GLGroup = 'Total Care Labor Costs' THEN BudAmount END) AS TotalCareLaborCosts_BudAmount,
		-MAX(CASE WHEN GLGroup = 'Raw Food' THEN ActAmount END) AS RawFood_ActAmount,
		-MAX(CASE WHEN GLGroup = 'Raw Food' THEN BudAmount END) AS RawFood_BudAmount,
		-MAX(CASE WHEN GLGroup = 'Total Resident Care' THEN ActAmount END) AS TotalResidentCare_ActAmount,
		-MAX(CASE WHEN GLGroup = 'Total Resident Care' THEN BudAmount END) AS TotalResidentCare_BudAmount
	FROM
		GLAccts
	GROUP BY
		PropertyName, YearMonth, BuildingType, Days
),
 
SCORES AS (
	SELECT
		PropertyName,
		YearMonth,
		BuildingType,
		(((TotalResidentCare_ActAmount + RawFood_ActAmount - TotalAncillaryRevenue_ActAmount)/OccUnitDays)
		- ((TotalResidentCare_BudAmount + RawFood_BudAmount - TotalAncillaryRevenue_BudAmount)/BudUnitDays))
		/ ((TotalResidentCare_BudAmount + RawFood_BudAmount - TotalAncillaryRevenue_BudAmount)/BudUnitDays) AS DVA,
		1 - (((TotalCareLaborCosts_ActAmount/OccUnitDays) - (TotalCareLaborCosts_BudAmount/BudUnitDays)) / (TotalCareLaborCosts_BudAmount/BudUnitDays)) AS CareLaborScore,
		1 - (((RawFood_ActAmount/OccUnitDays) - (RawFood_BudAmount/BudUnitDays)) / (RawFood_BudAmount/BudUnitDays)) AS RawFoodScore,
		1 + (((TotalAncillaryRevenue_ActAmount/OccUnitDays) - (TotalAncillaryRevenue_BudAmount/BudUnitDays)) / (TotalAncillaryRevenue_BudAmount/BudUnitDays)) AS AncillaryScore
	FROM
		GLAccts_Pivot
)
 
SELECT
	PropertyName,
	YearMonth,
	(1 / (1 + EXP(-5 + 30 * DVA))) - (1 / (1 + EXP(6 + 10 * DVA))) AS DVAScore,
	(1 / (1 + EXP(7 - 9.5 * (
	CASE
		WHEN BuildingType IN ('Assisted Living','Personal Care') THEN (0.55 * CareLaborScore) + (0.15 * RawFoodScore) + (AncillaryScore * 0.3)
		WHEN BuildingType IN ('Alzheimer') THEN (0.65 * CareLaborScore) + (0.125 * RawFoodScore) + (AncillaryScore * 0.225)
		ELSE (0.8 * CareLaborScore) + (0.15 * RawFoodScore) + (AncillaryScore * 0.05)
	END
	)))) AS VOAScore,
	((1 / (1 + EXP(-5 + 30 * DVA))) - (1 / (1 + EXP(6 + 10 * DVA))) + (1 / (1 + EXP(7 - 9.5 * (
	CASE
		WHEN BuildingType IN ('Assisted Living','Personal Care') THEN (0.55 * CareLaborScore) + (0.15 * RawFoodScore) + (AncillaryScore * 0.3)
		WHEN BuildingType IN ('Alzheimer') THEN (0.65 * CareLaborScore) + (0.125 * RawFoodScore) + (AncillaryScore * 0.225)
		ELSE (0.8 * CareLaborScore) + (0.15 * RawFoodScore) + (AncillaryScore * 0.05)
	END
	)))))/2 AS FinancialIndex
FROM
	SCORES
ORDER BY
	YearMonth desc, PropertyName;