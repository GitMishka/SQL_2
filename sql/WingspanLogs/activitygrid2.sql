SELECT
    his.hprospect,
    his.hproperty,
    MAX(CASE WHEN lg.dtCreated IS NOT NULL THEN lg.dtcreated ELSE NULL END) AS WebLead,
	    MAX(CASE WHEN his.ActivityID = 52 THEN his.dtDate ELSE NULL END) AS ProspectCallIn,
    MAX(CASE WHEN his.ActivityID IN (1, 84) THEN his.dtDate ELSE NULL END) AS FirstTour,

	MAX(CASE WHEN t.dtmovein IS NOT NULL THEN t.dtmovein ELSE NULL END) AS MoveIn,
    MAX(CASE WHEN his.ActivityID NOT IN (154, 1, 84, 52) THEN his.dtDate ELSE NULL END) AS AllOther
FROM seniorprospecthistory his
JOIN seniorprospectactivity act ON act.activityid = his.activityid
join seniorresident sr on sr.ProspectID = his.hProspect
join tenant t on t.hmyperson = sr.ResidentID
join SeniorProspectLeadsImportLog lg on lg.DupProspect = his.hProspect
where lg.dtcreated > '2024-08-01' and his.hProspect not in (0)
GROUP BY his.hprospect, his.hproperty;