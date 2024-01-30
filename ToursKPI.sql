--select * from seniorprospectactivity
--where activitycategory in ('TOU','INI') AND bUseForReporting = 1
--select * from property  where scode = 'colm'      


--tours 

--                    where 
--                    ph.dtCompleted between @mtd_startdate and @mtd_enddate
--                    and pa.ActivityCategory = 'TOU'
--					and sp.sStatus <> 'Referral'      
--                  ) sp on p.hMy = sp.hMy
--firsttours

--                    where 
--                    ph.dtCompleted between @wk_startdate and @wk_enddate
--                    and pa.ActivityCategory = 'TOU' and pa.ActivityID = 1
--		    and sp.sStatus <> 'Referral'
--                  ) sp on p.hMy = sp.hMy


DECLARE
@wk_startdate DATETIME,
@wk_enddate DATETIME,
@mtd_startdate DATETIME,
@mtd_enddate DATETIME,
@lm_startdate DATETIME,
@lm_enddate DATETIME

SET @wk_startdate = '6/30/21'
--SET @wk_startdate = '7/06/21'


SET @wk_enddate = dateadd(HOUR,167,@wk_startdate) 

print CONVERT(datetime, @wk_enddate,0)

SET @mtd_startdate = DATEADD(month, DATEDIFF(month, 0, @wk_enddate), 0)
SET @mtd_enddate = @wk_enddate  
print CONVERT(datetime, @mtd_enddate,0)
SET @lm_startdate = CONVERT(DATE, DATEADD(d, -( DAY(DATEADD(m, -1, @wk_enddate - 2)) ), DATEADD(m, -1, @wk_enddate - 1))) 
SET @lm_enddate = CONVERT(DATE, DATEADD(d, -( DAY(@wk_enddate) ), @wk_enddate))
print CONVERT(datetime, @lm_enddate,0)
Create Table #Sales_Goals
(
        Community_Code      varchar(300),
        Period          	varchar (3),
        Measure        		int,
		Goal				int
)

IF OBJECT_ID ('TempDb..#Sales_KPI') IS NOT NULL
DROP TABLE #Sales_KPI

CREATE TABLE [dbo].[#Sales_KPI](
	[hprop] [int] ,
	[Community] [varchar](300) ,
	[Community_Abbr] [varchar](300) ,
	[Region] [varchar](300) ,
	[CRD] [varchar](300) ,
	[RDSM] [varchar](300) ,
	[Report_Index] [varchar](300) ,
	[Report_Index_Desc] [varchar](300) ,	
	[Period] [varchar](3) ,
	[Measure] int ,
	[Measure_Desc]	[varchar](100),	
	[Goal] [int] ,
	[Count] [int] ,
	[Percentage] [decimal](18, 5) ,
	[Score] [decimal](18, 5) ,
	[wk_startdate] [datetime] ,
	[wk_enddate] [datetime] ,
	[mtd_startdate] [datetime] ,
	[mtd_enddate] [datetime] ,
	[lm_startdate] [datetime] ,
	[lm_enddate] [datetime] 	
) 
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
)
insert into #Sales_KPI_Findings
select 
	p.hMy
	, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')'   PropertyName
	, 'WK'
	, 50
	, 'Tours'
	, isnull(g.goal,0)
	, isnull(count(sp.hMY),0) 
from 
	Property p
	left join #Sales_Goals g on p.scode = g.Community_Code and g.Period = 'WK' and g.Measure = 50
	left join (
      			select
                    p.hMy
                    ,sp.hProperty
                    ,ph.dtCompleted
                    ,pa.ActivityCategory
					,sp.sStatus
                from 
                    SeniorProspect sp
                    left join SeniorProspectHistory ph on sp.hMy = ph.hProspect
                    left join SeniorProspectActivity pa on ph.ActivityID = pa.ActivityID
      				left join Property p on p.hmy = ph.hproperty

                    where 
                    ph.dtCompleted between @wk_startdate and @wk_enddate
                    and pa.ActivityCategory = 'TOU'
					and sp.sStatus <> 'Referral'
				 ) sp on p.hMy = sp.hMy


Group By
p.hMy, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')', g.goal


select * from #Sales_KPI_Findings
where community like '%(colm)%'

drop table #Sales_Goals
drop table #Sales_KPI_Findings
drop table #Sales_KPI

-- select * from #Sales_KPI_Findings where Count <> 0