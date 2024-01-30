


DECLARE
@wk_startdate DATETIME,
@wk_enddate DATETIME,
@mtd_startdate DATETIME,
@mtd_enddate DATETIME,
@lm_startdate DATETIME,
@lm_enddate DATETIME

SET @wk_startdate = '2022-3-15'
SET @wk_enddate = dateadd(SECOND,604799,@wk_startdate) 
SET @mtd_startdate = DATEADD(month, DATEDIFF(month, 0, @wk_enddate), 0)
SET @mtd_enddate = @wk_enddate  
SET @lm_startdate = CONVERT(DATE, DATEADD(d, -( DAY(DATEADD(m, -1, @wk_enddate - 2)) ), DATEADD(m, -1, @wk_enddate - 1))) 
SET @lm_enddate = DATEADD(d, -( DAY(@wk_enddate) ), @wk_enddate)



IF OBJECT_ID ('TempDb..#Sales_KPI_Findings') IS NOT NULL
DROP TABLE #Sales_KPI_Findings

Create Table #Sales_KPI_Findings
(
        
		
		
		
		
		hprop           int,
        Community       varchar(300),
        Period          varchar (3),
        Measure         int,
		Measure_Desc	varchar(100),
		Goal			int,
        Count           int
		,contactdate varchar(50)
	--	,lastname varchar(50)
		--,firstname varchar(50)
)

IF OBJECT_ID ('TempDb..#Sales_Goals') IS NOT NULL
DROP TABLE #Sales_Goals

Create Table #Sales_Goals
(
        Community_Code      varchar(300),
        Period          	varchar (3),
        Measure        		int,
		Goal				int
		,contactdate varchar(50)
)

--insert into #Sales_KPI_Findings
select 
	p.hMy
	, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')'   PropertyName
	, 'WK'
	, 40
	,'Leads/Inquiries'
	, isnull(g.goal,0)
	, sp.hMy as NewLeads
	, sp.dtFirstContact
	,sp.slastname
	,sp.sfirstname
from 
	Property p
	left join #Sales_Goals g on p.scode = g.Community_Code and g.Period = 'WK' and g.Measure = 40

	left join (
	select 
		ph.hProperty
		,sp.hMy
		,sp.slastname
		,sp.sfirstname
		,sp.dtFirstContact
        ,ph.dtDate

	from 
		SeniorProspect sp
		left join 
      (SELECT tbl.*
FROM SeniorProspectHistory tbl
  INNER JOIN
  (
    SELECT hProspect, MIN(hMy) hMy
    FROM SeniorProspectHistory
    group by hProspect
  ) tbl1
   ON tbl1.hmy = tbl.hmy

) ph 
      on sp.hMy = ph.hProspect

	where  
		ph.dtDate  between @wk_startdate and @wk_enddate
	        and sp.sStatus <> 'Referral'
	) sp on p.hMy = sp.hProperty order by propertyname desc



