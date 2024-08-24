WITH LeadToMoveIn AS (
    SELECT 
        p.scode,  -- Assuming you want to include the property code
        his.hprospect,
        t.hmyperson,
        his.dtdate AS dtWebLead,
        t.dtmovein AS dtMoveIn, 
        his.hproperty,
        DATEDIFF(day, his.dtdate, t.dtmovein) AS DaysToMoveIn
    FROM 
        seniorprospecthistory his 
    JOIN 
        seniorresident sr 
    ON 
        sr.prospectid = his.hprospect
    JOIN 
        tenant t 
    ON 
        sr.residentid = t.hmyperson
    JOIN 
        property p 
    ON 
        his.hproperty = p.hmy
    WHERE 
        his.activityid = 154 and dtdate > '2024-01-01'
),
RankedDays AS (
    SELECT
        scode,
        DaysToMoveIn,
        ROW_NUMBER() OVER (PARTITION BY hproperty ORDER BY DaysToMoveIn) AS RowAsc,
        COUNT(*) OVER (PARTITION BY hproperty) AS TotalCount
    FROM
        LeadToMoveIn
)
SELECT 
    scode,
    AVG(DaysToMoveIn) AS MedianDaysToMoveIn
FROM 
    RankedDays
WHERE 
    RowAsc IN ((TotalCount + 1) / 2, (TotalCount + 2) / 2)
GROUP BY 
    scode;
