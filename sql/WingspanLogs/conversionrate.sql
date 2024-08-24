WITH callin AS (
    SELECT 
        act.activityname, 
        his.hProspect,
        his.dtCompleted  
    FROM 
        seniorprospecthistory his 
    JOIN 
        SeniorProspectActivity act 
    ON 
        act.activityid = his.activityid 
    WHERE 
        act.activityname = 'Prospect Called In'
),
movein AS (
    SELECT 
        act.activityname, 
        his.hProspect,
        his.dtCompleted  
    FROM 
        seniorprospecthistory his 
    JOIN 
        SeniorProspectActivity act 
    ON 
        act.activityid = his.activityid 
    WHERE 
        act.activityname = 'Prospect Moved In'
)
SELECT 
    c.activityname AS CallInActivity, 
    c.hProspect, 
    c.dtCompleted AS CallInDate, 
    m.activityname AS MoveInActivity, 
    m.dtCompleted AS MoveInDate
FROM 
    callin c 
JOIN 
    movein m 
ON 
    c.hProspect = m.hProspect;
