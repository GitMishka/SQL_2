--//Vista

--//Notes
--  Script Name : rs_sql_IHP_Leads.txt
--  Client Name : Independent Healthcare Properties LLC
--  Date        : 05/02/2022
--  Description : Populate IHP Leads
--//End Notes


--//Database
--SSRS rs_IHP_Sales_KPI_EXCEL.rdlc
--//End Database


--//Title
--Leads 
--//end title




--//SELECT Dataset1


DECLARE
@wk_startdate DATETIME,
@wk_enddate DATETIME,
@mtd_startdate DATETIME,
@mtd_enddate DATETIME,
@lm_startdate DATETIME,
@lm_enddate DATETIME,
@lw_startdate datetime,
@lw_enddate datetime


SET @wk_startdate = '2022-04-19'
SET @wk_enddate = dateadd(SECOND,604799,@wk_startdate) 
--set @lw_startdate = dateadd(SECOND,-604799,@wk_startdate) 
--set @lw_enddate = dateadd(SECOND,-864399,@wk_startdate) 
print @lw_startdate
print @lw_enddate
SET @mtd_startdate = DATEADD(month, DATEDIFF(month, 0, @wk_enddate), 0)
SET @mtd_enddate = @wk_enddate  
SET @lm_startdate = CONVERT(DATE, DATEADD(d, -( DAY(DATEADD(m, -1, @wk_enddate - 2)) ), DATEADD(m, -1, @wk_enddate - 1))) 
SET @lm_enddate = DATEADD(d, -( DAY(@wk_enddate) ), @wk_enddate)

IF OBJECT_ID ('TempDb..#Sales_KPI_Findings') IS NOT NULL
DROP TABLE #Sales_KPI_Findings

IF OBJECT_ID ('TempDb..#pivoted') IS NOT NULL
DROP TABLE #pivoted


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

IF OBJECT_ID ('TempDb..#Sales_Goals') IS NOT NULL
DROP TABLE #Sales_Goals

Create Table #Sales_Goals
(
        Community_Code      varchar(300),
        Period          	varchar (3),
        Measure        		int,
		Goal				int
)



/*
	Week Leads
*/



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
	        and sp.sStatus <> 'Referral' and sp.dtFirstContact is not null
	) sp on p.hMy = sp.hProperty


Group By
	p.hMy, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')', g.goal


/* Last Week Leads */



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
		ph.dtDate  between @LW_startdate and @LW_enddate
	        and sp.sStatus <> 'Referral' and sp.dtFirstContact is not null
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
	        and sp.sStatus <> 'Referral' and sp.dtFirstContact is not null
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
	        and sp.sStatus <> 'Referral' and sp.dtFirstContact is not null
	) sp on p.hMy = sp.hProperty


Group By
	p.hMy, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')', g.goal


create table #pivoted
(
community varchar(100),
WK numeric,
MTD numeric,
LM numeric
)


insert into #pivoted
select * from (
	select 
		[community],
		Period,
		Count
	from #Sales_KPI_Findings ) KPI
pivot  
	(
	sum(count)
	for [Period]
	in 
	(
	[WK], [MTD], [LM]
	)
) as pivottable
where Community like '%pointe of%' 

insert into #pivoted
select 'Total', sum(WK) as WK ,sum(MTD) as MTD ,sum(LM) as LM from #pivoted --group by community
select * from #pivoted

--//end select



--//Columns
--//Type,  Name,  Head1,  Head2,  Head3,  Head4,  Show,  Color,  Formula,  Drill,  Key,  Width 
--T,  ,  ,  ,  ,      Community,  Y,  ,  ,  ,  ,  500,  
--I,  ,  ,  ,  ,          LW,  Y,  ,  ,  ,  ,  500, 
--I,  ,  ,  ,  ,          WK,  Y,  ,  ,  ,  ,  500,  
--I,  ,  ,  ,  ,          MTD,  Y,  ,  ,  ,  ,  500,  
--I,  ,  ,  ,  ,          LM,  Y,  ,  ,  ,  ,  500,  
--//End Columns



--//Filter
--//Type, DataTyp,Name,           Caption,      Key,   List,         Val1,                    Val2, 	Mandatory,Multi-Type, Title  Title
--L,      T,       			dat1,     Report Week Beginning,      ,  "select convert(varchar(10),a.ItemDate,101) as Week_Beginning  from	(SELECT  top 380 DATEADD(DAY, (ROW_NUMBER() OVER (ORDER BY a.object_id ) - 1) * -1, CONVERT(DATETIME, getdate())) AS ItemDate FROM   sys.columns a CROSS JOIN sys.columns b	) a where datepart(dw,a.ItemDate) = 3 and datediff(day,a.ItemDate,getdate()) > 6", 										 , 			 , 				 Y, 				 , 			 ,
--//end filter