select * from SeniorBICustom_IncidentsByRegion where propertyid = 46.00 and 
    incidentDate BETWEEN DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0)
AND DATEADD(SECOND, -1, DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0))



WITH totalfalls AS (
SELECT 
    COUNT(IncidentID) OVER (PARTITION BY propertyname) as fallcount,
    *

FROM 
    SeniorBICustom_IncidentsByRegion 
WHERE 
    timeofday BETWEEN DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0)
AND DATEADD(SECOND, -1, DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0))

),

cat AS (
    SELECT 
        CASE
            WHEN "PropType" = 'Alzheimer' THEN 'ALZ'
            WHEN "PropType" = 'Personal Care' THEN 'AL'
            WHEN "PropType" = 'Assisted Living' THEN 'AL'
            ELSE 'Combo'
        END AS category, 
        *
    FROM totalfalls
),

fallmath AS(
	SELECT
		(fallcount*1000/totalresidents) AS fallrate, *
	FROM cat
)

SELECT 
    CASE 
        WHEN "category" = 'ALZ' THEN (0.5*((1/(1+EXP(0.4*("fallrate"-19))))+(1/(1+EXP(0.4*("fallrate"-9))))+0.05*(1/(1+EXP(0.4*"fallrate")))))
        WHEN "category" = 'Combo' THEN (0.5*((1/(1+EXP(0.4*("fallrate"-15))))+(1/(1+EXP(0.4*("fallrate"-7.5))))+0.1*(1/(1+EXP(0.4*"fallrate")))))
        WHEN "category" = 'AL' THEN 0.5*((1/(1+EXP(0.4*("fallrate"-14))))+(1/(1+EXP(0.4*("fallrate"-6))))+0.15*(1/(1+EXP(0.4*"fallrate"))))
    END AS FallRateScore, 
    *
FROM fallmath;

