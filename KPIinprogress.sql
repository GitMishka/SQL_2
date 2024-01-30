--select * from SeniorProspectActivity where ActivityCategory = 'NRF'

DECLARE
@wk_startdate DATETIME,
@wk_enddate DATETIME,
@mtd_startdate DATETIME,
@mtd_enddate DATETIME,
@lm_startdate DATETIME,
@lm_enddate DATETIME

SET @wk_startdate = '8/04/21'
SET @wk_enddate = dateadd(SECOND,604799,@wk_startdate) 
SET @mtd_startdate = DATEADD(month, DATEDIFF(month, 0, @wk_enddate), 0)
SET @mtd_enddate = @wk_enddate  
SET @lm_startdate = CONVERT(DATE, DATEADD(d, -( DAY(DATEADD(m, -1, @wk_enddate - 2)) ), DATEADD(m, -1, @wk_enddate - 1))) 
SET @lm_enddate = DATEADD(d, -( DAY(@wk_enddate) ), @wk_enddate)


--select ActivityCategory,dtCompleted from 
--SeniorProspectHistory ph
--			left join Property p on p.hmy = ph.hproperty
--			left join SeniorProspectActivity pa on ph.ActivityID = pa.ActivityID
--			left join SeniorProspect sp on sp.hMy = ph.hProspect
--			where 
--                ph.dtCompleted between @wk_startdate and @wk_enddate
--                and pa.ActivityCategory in ('NRF')
--				and sp.sStatus = 'Referral'      
--                -- ) sp on p.hMy = sp.hMy

----------------------------------------------------------

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
        VALUECOUNT           int
		,Category Varchar(50)
		)

IF OBJECT_ID ('TempDb..#Sales_Goals') IS NOT NULL
DROP TABLE #Sales_Goals

Create Table #Sales_Goals
(
        Community_Code      varchar(300),
        Period          	varchar (3),
        Measure        		int,
		Goal				int
		,Category Varchar(50)
		
)



/*
	Week Completed New Referral F to F Activity
*/

insert into #Sales_KPI_Findings
select 
	p.hMy
	, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')'   PropertyName
	, 'WK'
	, 10
	, 'Sales Calls - New Referrals'
	, isnull(g.goal,0)
	, isnull(count(sp.hMY),0) 
	, ActivityCategory
from 
	Property p
	left join #Sales_Goals g on p.scode = g.Community_Code and g.Period = 'WK' and g.Measure = 10
	left join (
 		select 
			p.hMy
			,sp.hProperty
			,Ltrim(Rtrim(sp.sfirstname)) + ' ' + Ltrim(Rtrim(sp.slastname))            ProspectName
			,pa.ActivityCategory
			,pa.ActivityName
			,ph.dtCompleted
		from 
			SeniorProspectHistory ph
			left join Property p on p.hmy = ph.hproperty
			left join SeniorProspectActivity pa on ph.ActivityID = pa.ActivityID
			left join SeniorProspect sp on sp.hMy = ph.hProspect

                 where 
                ph.dtCompleted between @wk_startdate and @wk_enddate
                and pa.ActivityCategory in ('NRF','MSC','ERA','PFU','INI')
				and sp.sStatus = 'Referral'      
                  ) sp on p.hMy = sp.hMy

Group By
p.hMy, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')', g.goal,ActivityCategory



select sum(valuecount) from #Sales_KPI_Findings
where community like '%Morning Pointe%'

select 
community, valuecount, sum(valuecount)  over(partition by Category) [Total sum of category], category
from #Sales_KPI_Findings
where community like '%Morning Pointe%'



select * from #Sales_KPI_Findings

where community like '%Morning Pointe%'
order by community asc
