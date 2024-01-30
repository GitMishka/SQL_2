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
@lm_enddate DATETIME,
@onesecond DATETIME


SET @onesecond = DATEADD(SECOND,+86340,GETDATE())

SET @wk_startdate = '6/30/21'
--SET @wk_startdate = '7/06/21'


SET @wk_enddate = dateadd(SECOND,604799,@wk_startdate) 
--print @wk_enddate

print CONVERT(datetime, @wk_enddate,0)

SET @mtd_startdate = DATEADD(month, DATEDIFF(month, 0, @wk_enddate), 0)
SET @mtd_enddate = @wk_enddate  
--print CONVERT(datetime, @mtd_enddate,0)
SET @lm_startdate = CONVERT(DATE, DATEADD(d, -( DAY(DATEADD(m, -1, @wk_enddate - 2)) ), DATEADD(m, -1, @wk_enddate - 1))) 
--SET @lm_enddate = CONVERT(DATE, DATEADD(d, -( DAY(@wk_enddate) ), @wk_enddate))
SET @lm_enddate = DATEADD(d, -( DAY(@wk_enddate) ), @wk_enddate) - @onesecond


print @onesecond print @lm_startdate print @lm_enddate --print  @wk_enddate  

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
	, 40
	,'Leads/Inquiries'
	, isnull(g.goal,0)
	, isnull(count(distinct sp.hMy),0) as NewLeads
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
	) sp on p.hMy = sp.hProperty


Group By
	p.hMy, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')', g.goal


                 

/*
	Month-to-Date Leads
*/


insert into #Sales_KPI_Findings
select 
	p.hMy
	,Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')'   PropertyName
	, 'MTD'
	, 40
	,'Leads/Inquiries'
	, isnull(g.goal,0)
	, isnull(count(distinct sp.hMy),0) as NewLeads
from 
	Property p
	left join #Sales_Goals g on p.scode = g.Community_Code and g.Period = 'MTD' and g.Measure = 40
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
		ph.dtDate  between @mtd_startdate and @mtd_enddate
	        and sp.sStatus <> 'Referral'
	) sp on p.hMy = sp.hProperty


Group By
	p.hMy, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')', g.goal


/*
	Last Month Leads
*/


insert into #Sales_KPI_Findings
select 
	p.hMy
	,Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')'   PropertyName
	, 'LM'
	, 40
	,'Leads/Inquiries'
	, isnull(g.goal,0)
	, isnull(count(distinct sp.hMy),0) as NewLeads
from 
	Property p
	left join #Sales_Goals g on p.scode = g.Community_Code and g.Period = 'LM' and g.Measure = 40
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
		ph.dtDate  between @lm_startdate and @lm_enddate
	        and sp.sStatus <> 'Referral'
	) sp on p.hMy = sp.hProperty


Group By
	p.hMy, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')', g.goal

	
	

/*
	Week Tours
*/

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
 



/*
	Month-to-Date Tours
*/

insert into #Sales_KPI_Findings
select 
	p.hMy
	, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')'   PropertyName
	, 'MTD'
	, 50
	, 'Tours'
	, isnull(g.goal,0)
	, isnull(count(sp.hMY),0) 
from 
	Property p
	left join #Sales_Goals g on p.scode = g.Community_Code and g.Period = 'MTD' and g.Measure = 50
	left join (
      			select
                    p.hMy
                    ,sp.hProperty
                    ,ph.dtCompleted
                    ,pa.ActivityCategory
                from 
                    SeniorProspect sp
                    left join SeniorProspectHistory ph on sp.hMy = ph.hProspect
                    left join SeniorProspectActivity pa on ph.ActivityID = pa.ActivityID
		    left join Property p on p.hmy = ph.hproperty

                    where 
                    ph.dtCompleted between @mtd_startdate and @mtd_enddate
                    and pa.ActivityCategory = 'TOU'
					and sp.sStatus <> 'Referral'      
                  ) sp on p.hMy = sp.hMy


Group By
p.hMy, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')', g.goal


/*
	Last Month Tours
*/

insert into #Sales_KPI_Findings
select 
	p.hMy
	, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')'   PropertyName
	, 'LM'
	, 50
	, 'Tours'
	, isnull(g.goal,0)
	, isnull(count(sp.hMY),0)
from 
	Property p
	left join #Sales_Goals g on p.scode = g.Community_Code and g.Period = 'LM' and g.Measure = 50
	left join (
      			select
                    p.hMy
                    ,sp.hProperty
                    ,ph.dtCompleted
                    ,pa.ActivityCategory
                from 
                    SeniorProspect sp
                    left join SeniorProspectHistory ph on sp.hMy = ph.hProspect
                    left join SeniorProspectActivity pa on ph.ActivityID = pa.ActivityID
		    left join Property p on p.hmy = ph.hproperty

                    where 
                    ph.dtCompleted between @lm_startdate and @lm_enddate
                    and pa.ActivityCategory = 'TOU'
					and sp.sStatus <> 'Referral'      
                  ) sp on p.hMy = sp.hMy


Group By
p.hMy, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')', g.goal




/*
	Week Prospect Follow-Up Activity
*/

insert into #Sales_KPI_Findings
select 
	p.hMy
	, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')'   PropertyName
	, 'WK'
	, 30
	, 'Prospect Follow-Up Activity'
	, isnull(g.goal,0)
	, isnull(count(sp.hMY),0)
from 
	Property p
	left join #Sales_Goals g on p.scode = g.Community_Code and g.Period = 'WK' and g.Measure = 30
	left join (
      			select
                    p.hMy
                    ,sp.hProperty
                    ,ph.dtCompleted
		    ,ph.dtDate
                    ,pa.ActivityCategory
                from 
                    SeniorProspect sp
                    left join SeniorProspectHistory ph on sp.hMy = ph.hProspect
		    left join Property p on p.hmy = ph.hproperty
                    left join SeniorProspectActivity pa on ph.ActivityID = pa.ActivityID

                    where 
                    ph.dtCompleted between @wk_startdate and @wk_enddate
                    and pa.ActivityCategory not in ('NRF','RFF','STT')
					and sp.sStatus <> 'Referral'      
                  ) sp on p.hMy = sp.hMy


Group By
p.hMy, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')', g.goal




/*
	Month-to-Date Prospect Follow-Up Activity
*/


insert into #Sales_KPI_Findings
select 
	p.hMy
	, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')'   PropertyName
	, 'MTD'
	, 30
	, 'Prospect Follow-Up Activity'
	, isnull(g.goal,0)
	, isnull(count(sp.hMY),0) 
from 
	Property p
	left join #Sales_Goals g on p.scode = g.Community_Code and g.Period = 'MTD' and g.Measure = 30
	left join (
      			select
                    p.hMy
                    ,sp.hProperty
                    ,ph.dtCompleted
		    ,ph.dtDate
                    ,pa.ActivityCategory
                from 
                    SeniorProspect sp
                    left join SeniorProspectHistory ph on sp.hMy = ph.hProspect
                    left join SeniorProspectActivity pa on ph.ActivityID = pa.ActivityID
		    left join Property p on p.hmy = ph.hproperty

                    where 
                    ph.dtCompleted between @mtd_startdate and @mtd_enddate
                    and pa.ActivityCategory not in ('NRF','RFF','STT')
					and sp.sStatus <> 'Referral'      
                  ) sp on p.hMy = sp.hMy


Group By
p.hMy, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')', g.goal


/*
	Last Month Prospect Follow-Up Activity
*/


insert into #Sales_KPI_Findings
select 
	p.hMy
	, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')'   PropertyName
	, 'LM'
	, 30
	, 'Prospect Follow-Up Activity'
	, isnull(g.goal,0)
	, isnull(count(sp.hMY),0) 
from 
	Property p
	left join #Sales_Goals g on p.scode = g.Community_Code and g.Period = 'LM' and g.Measure = 30
	left join (
      			select
                    p.hMy
                    ,sp.hProperty
                    ,ph.dtCompleted
		    ,ph.dtDate
                    ,pa.ActivityCategory
                from 
                    SeniorProspect sp
                    left join SeniorProspectHistory ph on sp.hMy = ph.hProspect
                    left join SeniorProspectActivity pa on ph.ActivityID = pa.ActivityID
		    left join Property p on p.hmy = ph.hproperty

                    where 
                    ph.dtCompleted between @lm_startdate and @lm_enddate
                    and pa.ActivityCategory not in ('NRF','RFF','STT')
					and sp.sStatus <> 'Referral'      
                  ) sp on p.hMy = sp.hMy


Group By
p.hMy, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')', g.goal



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
                and pa.ActivityCategory in ('NRF')
				and sp.sStatus = 'Referral'      
                  ) sp on p.hMy = sp.hMy


Group By
p.hMy, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')', g.goal




/*
	Month-to-Date Completed New Referral F to F Activity
*/

insert into #Sales_KPI_Findings
select 
	p.hMy
	, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')'   PropertyName
	, 'MTD'
	, 10	 
	, 'Sales Calls - New Referrals'
	, isnull(g.goal,0)
	, isnull(count(sp.hMY),0) 
from 
	Property p
	left join #Sales_Goals g on p.scode = g.Community_Code and g.Period = 'MTD' and g.Measure = 10
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
                ph.dtCompleted between @mtd_startdate and @mtd_enddate
                and pa.ActivityCategory in ('NRF')
				and sp.sStatus = 'Referral'      
                  ) sp on p.hMy = sp.hMy


Group By
p.hMy, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')', g.goal


/*
	Last Month Completed New Referral F to F Activity
*/

insert into #Sales_KPI_Findings
select 
	p.hMy
	, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')'   PropertyName
	, 'LM'
	, 10	 
	, 'Sales Calls - New Referrals'
	, isnull(g.goal,0)
	, isnull(count(sp.hMY),0) 
from 
	Property p
	left join #Sales_Goals g on p.scode = g.Community_Code and g.Period = 'LM' and g.Measure = 10
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
                ph.dtCompleted between @lm_startdate and @lm_enddate
                and pa.ActivityCategory in ('NRF')
				and sp.sStatus = 'Referral'      
                  ) sp on p.hMy = sp.hMy


Group By
p.hMy, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')', g.goal





/*
	Week Completed Existing Referral F to F Activity
*/

insert into #Sales_KPI_Findings
select 
	p.hMy
	, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')'   PropertyName
	, 'WK'
	, 20
	, 'Sales Calls - Existing Referrals (in person only)'
	, isnull(g.goal,0)
	, isnull(count(sp.hMY),0) 
from 
	Property p
	left join #Sales_Goals g on p.scode = g.Community_Code and g.Period = 'WK' and g.Measure = 20
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
                and pa.ActivityCategory in ('ERA')
				and sp.sStatus = 'Referral'      
                  ) sp on p.hMy = sp.hMy


Group By
p.hMy, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')', g.goal


/*
	Month-to-Date Completed Existing Referral F to F Activity
*/

insert into #Sales_KPI_Findings
select 
	p.hMy
	, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')'   PropertyName
	, 'MTD'
	, 20
	, 'Sales Calls - Existing Referrals (in person only)'
	, isnull(g.goal,0)
	, isnull(count(sp.hMY),0) 
from 
	Property p
	left join #Sales_Goals g on p.scode = g.Community_Code and g.Period = 'MTD' and g.Measure = 20
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
                ph.dtCompleted between @mtd_startdate and @mtd_enddate
                and pa.ActivityCategory in ('ERA')
				and sp.sStatus = 'Referral'      
                  ) sp on p.hMy = sp.hMy


Group By
p.hMy, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')', g.goal


/*
	Last Month Completed Existing Referral F to F Activity
*/

insert into #Sales_KPI_Findings
select 
	p.hMy
	, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')'   PropertyName
	, 'LM'
	, 20
	, 'Sales Calls - Existing Referrals (in person only)'
	, isnull(g.goal,0)
	, isnull(count(sp.hMY),0) 
from 
	Property p
	left join #Sales_Goals g on p.scode = g.Community_Code and g.Period = 'LM' and g.Measure = 20
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
                ph.dtCompleted between @lm_startdate and @lm_enddate
                and pa.ActivityCategory in ('ERA')
				and sp.sStatus = 'Referral'      
                  ) sp on p.hMy = sp.hMy


Group By
p.hMy, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')', g.goal


select * from #Sales_KPI_Findings
where community like '%(lexe)%'
order by period desc



drop table #Sales_Goals
drop table #Sales_KPI_Findings
drop table #Sales_KPI

-- select * from #Sales_KPI_Findings where Count <> 0
--DECLARE
--@doru1 DATETIME,
--@doru2 DATETIME,
--@wk_startdate DATETIME,
--@wk_enddate DATETIME,
--@mtd_startdate DATETIME,
--@mtd_enddate DATETIME,
--@lm_startdate DATETIME,
--@lm_enddate DATETIME

--SET @wk_startdate = '6/30/21'
----SET @wk_startdate = '7/06/21'


--SET @wk_enddate = dateadd(HOUR,167,@wk_startdate) 
--set @doru1 = DATEADD(DAY, DATEDIFF(DAY, '19000101', GETDATE()), '19000101')
--set @doru2 = DATEADD(DAY, DATEDIFF(DAY, '18991231', GETDATE()), '19000101')
--print CONVERT(datetime, @wk_enddate,0)
--print CONVERT(datetime, @doru1,0)
--print CONVERT(datetime, @doru2,0)