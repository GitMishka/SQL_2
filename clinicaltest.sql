


Declare @SeedDate date = getdate()
Declare @YTD_End date = convert(date,DATEADD(DAY, -(DAY(@SeedDate)), @SeedDate))
Declare @YTD_Begin date = DATEADD(yy, DATEDIFF(yy, 0, @YTD_End), 0)
Declare @MonthsLookBack int = 6 /* 6 for Normal Execution of Report */
Declare @Eval_Date datetime =  CAST(getdate() AS DATE)
Declare @EvalProperties table ( hprop int, name varchar(250))
insert into @EvalProperties select a.hProp, case when isnull(ltrim(rtrim(a.SubGroup2)),'') = '' then '???' else  ltrim(rtrim(a.SubGroup2)) end from attributes a where a.SubGroup3 in ('Stabilized','Focus','Start Up') and case when isnull(ltrim(rtrim(a.SubGroup2)),'') = '' then '???' else  ltrim(rtrim(a.SubGroup2)) end ='#selection#' 
insert into @EvalProperties select a.hProp, case when ltrim(rtrim(a.sPropName)) like '%Lantern%' then replace(replace(ltrim(rtrim(a.sPropName)),'The Lantern at Morning Pointe of ','') + ' ' +'Lantern',',','') else replace(replace(ltrim(rtrim(a.sPropName)),'Morning Pointe of ',''),',','') end from attributes a where a.SubGroup3 in ('Stabilized','Focus','Start Up') and case when ltrim(rtrim(a.sPropName)) like '%Lantern%' then replace(replace(ltrim(rtrim(a.sPropName)),'The Lantern at Morning Pointe of ','') + ' ' +'Lantern',',','') else replace(replace(ltrim(rtrim(a.sPropName)),'Morning Pointe of ',''),',','') end ='#selection#'   
/* insert into @EvalProperties select a.hProp from attributes a where a.SubGroup3 in ('Stabilized','Focus','Start Up')   */

/*
 insert into @EvalProperties Select 20, 'AAA'
 insert into @EvalProperties Select 2, 'BBB'
 insert into @EvalProperties Select 11, 'CCC'
*/


Declare @Report_Header_Description Varchar(MAX); 
Select @Report_Header_Description = COALESCE(@Report_Header_Description + ', ' + a.Name, a.Name) 
        From (select distinct Name from @EvalProperties) a

/*

	Create Results Staging Table
*/

IF OBJECT_ID ('TempDb..#Clinical_KPI_Results_Staging') IS NOT NULL
DROP TABLE #Clinical_KPI_Results_Staging

Create Table #Clinical_KPI_Results_Staging
(
Column_Index varchar(25)
,Cell_Data varchar(100)
)


/*

	Create Results Table
*/

IF OBJECT_ID ('TempDb..#Clinical_KPI_Results') IS NOT NULL
DROP TABLE #Clinical_KPI_Results

Create Table #Clinical_KPI_Results
(
Row_Color int
,Report_Header_Description varchar(Max)
,Report_Index varchar(10)
,Description varchar(100)
,Period_1 varchar(100)
,Period_2 varchar(100)
,Period_1v2 varchar(100)
,Period_3 varchar(100)
,Period_2v3 varchar(100)
,Period_4 varchar(100)
,Period_3v4 varchar(100)
,Period_5 varchar(100)
,Period_4v5 varchar(100)
,Period_6 varchar(100)
,Period_5v6 varchar(100)
,YTD varchar(100)  
)


/*

	Create and Populate a Date Table for Prior 6 Months
*/

IF OBJECT_ID ('TempDb..#DateList') IS NOT NULL
DROP TABLE #DateList

create table #DateList
(
      EvalDate   Date
	  ,EvalMonth varchar(6)
	  ,Column_Index varchar(25)
)


insert into #DateList
select
dl.EvalDate
,LEFT(CONVERT(varchar, dl.EvalDate,112),6) as EvalMonth
,'Period_' + cast(7- datediff(mm,DATEADD(month, DATEDIFF(month, 0, dl.EvalDate), 0),DATEADD(month, DATEDIFF(month, 0, @SeedDate), 0)) as varchar(2))as Column_Index
from
(
SELECT	top (SELECT 1 + DATEDIFF(DD,convert(date,DATEADD(mm, DATEDIFF(mm, 0, @SeedDate) - @MonthsLookBack, 0)),convert(date,DATEADD(DAY, -(DAY(@SeedDate)), @SeedDate))))
DATEADD(DAY, (ROW_NUMBER() OVER (ORDER BY a.object_id ) - 1) * -1, convert(date,DATEADD(DAY, -(DAY(@SeedDate)), @SeedDate))) AS EvalDate 
FROM	sys.columns a CROSS JOIN sys.columns b
) dl


/*

	Create and Populate a Date Table for YTD
*/

IF OBJECT_ID ('TempDb..#DateList_YTD') IS NOT NULL
DROP TABLE #DateList_YTD

create table #DateList_YTD
(
      EvalDate   Date
	  ,EvalMonth varchar(6)
	  ,Column_Index varchar(25)
)


insert into #DateList_YTD
select
dl.EvalDate
,'YTD' as EvalMonth
,'YTD ' + ''''+ right(cast(Year(@YTD_End) as char(4)),2) as Column_Index
from
(
SELECT	top (1 + DATEDIFF(DD,@YTD_Begin, @YTD_End))
DATEADD(DAY, (ROW_NUMBER() OVER (ORDER BY a.object_id ) ) , convert(date,DATEADD(DAY, -(DAY(@YTD_Begin)), @YTD_Begin))) AS EvalDate 
FROM	sys.columns a CROSS JOIN sys.columns b
) dl



/*
	Dynamic Report Headers based on Date Criteria
*/

IF OBJECT_ID ('TempDb..#Report_Header') IS NOT NULL
DROP TABLE #Report_Header

Create Table #Report_Header
(
Column_Index varchar(25)
,Cell_Data varchar(100)
)

insert into #Report_Header select 'Report_Index', 'S0000'
insert into #Report_Header select 'Description', 'Morning Pointe Clinical KPIs'

insert into #Report_Header
select distinct 
Column_Index , left(convert(varchar,cast(right(EvalMonth,2) + '/01/' +left(EvalMonth,4) as datetime),107),3) + ' ''' + right(convert(varchar,cast(right(EvalMonth,2) + '/01/' +left(EvalMonth,4) as datetime),107),2) as Cell_Data
from #DateList

insert into #Report_Header select 'Period_1v2', (select Left(Cell_Data,3) from #Report_Header where Column_Index = 'Period_1') + ' v ' + (select Left(Cell_Data,3) from #Report_Header where Column_Index = 'Period_2') 
insert into #Report_Header select 'Period_2v3', (select Left(Cell_Data,3) from #Report_Header where Column_Index = 'Period_2') + ' v ' + (select Left(Cell_Data,3) from #Report_Header where Column_Index = 'Period_3') 
insert into #Report_Header select 'Period_3v4', (select Left(Cell_Data,3) from #Report_Header where Column_Index = 'Period_3') + ' v ' + (select Left(Cell_Data,3) from #Report_Header where Column_Index = 'Period_4') 
insert into #Report_Header select 'Period_4v5', (select Left(Cell_Data,3) from #Report_Header where Column_Index = 'Period_4') + ' v ' + (select Left(Cell_Data,3) from #Report_Header where Column_Index = 'Period_5') 
insert into #Report_Header select 'Period_5v6', (select Left(Cell_Data,3) from #Report_Header where Column_Index = 'Period_5') + ' v ' + (select Left(Cell_Data,3) from #Report_Header where Column_Index = 'Period_6') 

insert into #Report_Header select 'YTD', 'YTD ' + ''''+ right(cast(Year(@YTD_End) as char(4)),2)

/* select * from #Age */

insert into #Clinical_KPI_Results
SELECT 
1,'Header Info',*
FROM
 
(SELECT 
	Column_Index, Cell_Data	
FROM 
	#Report_Header
)
AS DataTable
PIVOT(
	Max(Cell_Data) 
FOR Column_Index IN ([Report_Index],[Description],[Period_1],[Period_2],[Period_1v2],[Period_3],[Period_2v3],[Period_4],[Period_3v4],[Period_5],[Period_4v5],[Period_6],[Period_5v6],[YTD]) 
) AS PivotTable




/*

	Populate a Temp Table with a Census for each day of Prior 6 Months

*/


Select 
r.*
,(select LTRIM(RTRIM(s.ServiceName)) 
   from ServiceInstance c 
   INNER JOIN Service s on s.ServiceId = c.ServiceId
   INNER JOIN ServiceClass sc on sc.ServiceClassId = s.ServiceClassId AND sc.ServiceClassName IN ('Care Level')
   where c.ResidentID = r.hMyPerson
                AND c.ServiceInstanceActiveFlag <> 0
                AND c.ServiceInstanceFromDate <= r.EvalDate
               AND ISNULL(c.ServiceInstanceToDate,r.EvalDate) >= r.EvalDate
              AND isnull(c.ServiceInstanceToDate,r.EvalDate) >=  c.ServiceInstanceFromDate
  ) as CareLevel
into #Resident_List
from
(
SELECT 
	d.EvalDate
        ,LEFT(CONVERT(varchar, d.EvalDate,112),6) EvalMonth
  	,P.hmy PropertyID
	,ltrim(rtrim(P.sAddr1)) as Community
	,case 
		when ltrim(rtrim(P.sAddr1)) like '%Lantern%' then replace(ltrim(rtrim(P.sAddr1)),'The Lantern at Morning Pointe of ','') + ' ' +'Lantern'
		else replace(ltrim(rtrim(P.sAddr1)),'Morning Pointe of ','') 
	end as Community_Abbr
	,ltrim(rtrim(p.scode)) as Community_Code
	,lv.listoptionValue Occupancy_Value
	,l2.ListOptionName Pri_Sec	
	,t.istatus as Tenant_Status
	, case 
		when t.istatus in (2,8) then 'R' 
		when t.istatus = 4 then 'N' 
		when t.istatus = 11 then 'L'
		when t.istatus = 0 and t.dtmovein > @Eval_Date then 'C' 
		else 'O' 
	end as Unit_Status
	,ltrim(rtrim(u.scode)) as Unit
	,t.hMyPerson
	,ltrim(rtrim(t.sLastName))+', '+ltrim(rtrim(t.sFirstName)) AS Resident_Name 
	,sr.ResidentBirthDate
	,DateDIFF(yy,sr.ResidentBirthDate,d.EvalDate)-CASE WHEN sr.ResidentBirthDate<=DateAdd(yy,DateDIFF(yy,d.EvalDate,sr.ResidentBirthDate), d.EvalDate) THEN 0 ELSE 1 END AS Age
	,t.dtmovein as MoveIn_Date 
	,t.dtmoveout as MoveOut_Date
	,ts.status ResStatus

from  #DateList d
left join property P  on 1=1
INNER JOIN Tenant T ON T.Hproperty = P.hmy
INNER JOIN unit u ON u.hmy = t.hunit AND isnull(u.exclude, 0) = 0
INNER JOIN Serviceinstance Si ON (T.Hmyperson = Si.Residentid) AND si.carelevelcode IN ('AL','ALZ','PC','LL','BUN')
INNER JOIN Service S ON (Si.Serviceid = S.Serviceid AND S.Serviceclassid = 1)
INNER JOIN Seniorresident sr ON (T.Hmyperson = sr.Residentid)
inner join SeniorResidentStatus ts on (ts.istatus = t.istatus)
INNER JOIN Listoption L1 ON (Si.Carelevelcode = L1.Listoptioncode AND L1.Listname = 'CareLevel')
INNER JOIN Listoption L2 ON (Si.Privacylevelcode = L2.Listoptioncode AND L2.Listname = 'PrivacyLevel')
INNER JOIN Listoptionvalue Lv ON Lv.Listname = 'PrivacyLevel' AND Lv.Listoptioncode = L2.Listoptioncode

Where  p.hmy in (select a.hProp from @EvalProperties a)
	    and Si.Serviceinstanceid = (
		SELECT Max(Si3.Serviceinstanceid)
		FROM Serviceinstance Si3
		INNER JOIN Service S1 ON Si3.Serviceid = S1.Serviceid AND S1.Serviceclassid = 1
		WHERE Si3.Residentid = Si.Residentid
			AND Si3.Serviceinstanceactiveflag <> 0
			AND Isnull(CONVERT(DATETIME, CONVERT(VARCHAR(11), si3.ServiceInstanceTODate), 101), d.EvalDate) > = CONVERT(DATETIME, CONVERT(VARCHAR(11), si3.ServiceInstanceFromDate), 101)
			AND Si3.Serviceinstancefromdate = (
				SELECT Max(Si2.Serviceinstancefromdate)
				FROM Serviceinstance Si2
				INNER JOIN Service S ON Si2.Serviceid = S.Serviceid
					AND S.Serviceclassid = 1
				WHERE Si2.Residentid = Si.Residentid
					AND Si2.Serviceinstanceactiveflag <> 0
					AND Isnull(CONVERT(DATETIME, CONVERT(VARCHAR(11), si2.ServiceInstanceTODate), 101), d.EvalDate) > = CONVERT(DATETIME, CONVERT(VARCHAR(11), si2.ServiceInstanceFromDate), 101)
					AND CONVERT(DATETIME, CONVERT(VARCHAR(11), si2.ServiceInstanceFromDate), 101) <= d.EvalDate
					AND d.EvalDate <= Isnull(CONVERT(DATETIME, CONVERT(VARCHAR(11), si2.ServiceInstanceTODate), 101), d.EvalDate)
				)
		)



UNION ALL

/*   Units that have Physical Therapy Rent */


SELECT 
	d.EvalDate
	,LEFT(CONVERT(varchar, d.EvalDate,112),6) EvalMonth  
	,P.hmy PropertyID
	,ltrim(rtrim(P.sAddr1)) as Community
	,case 
		when ltrim(rtrim(P.sAddr1)) like '%Lantern%' then replace(ltrim(rtrim(P.sAddr1)),'The Lantern at Morning Pointe of ','') + ' ' +'Lantern'
		else replace(ltrim(rtrim(P.sAddr1)),'Morning Pointe of ','') 
	end as Community_Abbr
	,ltrim(rtrim(p.scode)) as Community_Code
	,lv.listoptionValue Occupancy_Value
	,l2.ListOptionName Pri_Sec	
	,t.istatus as Tenant_Status
	, case 
		when t.istatus in (2,8) then 'R' 
		when t.istatus = 4 then 'N' 
		when t.istatus = 11 then 'L' 
		when t.istatus = 0 and t.dtmovein > @Eval_Date then 'C' 
		else 'O' 
	end as Unit_Status
	,ltrim(rtrim(u.scode)) as Unit
	,t.hMyPerson	
	,ltrim(rtrim(t.sLastName))+', '+ltrim(rtrim(t.sFirstName)) AS Resident_Name
	,sr.ResidentBirthDate
	,DateDIFF(yy,sr.ResidentBirthDate,d.EvalDate)-CASE WHEN sr.ResidentBirthDate<=DateAdd(yy,DateDIFF(yy,d.EvalDate,sr.ResidentBirthDate), d.EvalDate) THEN 0 ELSE 1 END AS Age
	,t.dtmovein as MoveIn_Date 
	,t.dtmoveout as MoveOut_Date
	,ts.status ResStatus

from  #DateList d
left join property P  on 1=1
INNER JOIN Tenant T ON T.Hproperty = P.hmy
INNER JOIN unit u ON u.hmy = t.hunit AND isnull(u.exclude, 0) = 0
INNER JOIN Serviceinstance Si ON (T.Hmyperson = Si.Residentid) 
INNER JOIN Service S ON (Si.Serviceid = S.Serviceid AND S.Serviceclassid = 1)
INNER JOIN servicechargetype sct ON s.serviceid = sct.serviceid
INNER JOIN Chargtyp ct ON ct.hmy = sct.ChargeTypeID AND ct.SCODE = 'PT'
INNER JOIN Seniorresident sr ON (T.Hmyperson = sr.Residentid)
inner join SeniorResidentStatus ts on (ts.istatus = t.istatus)
INNER JOIN Listoption L2 ON (Si.Privacylevelcode = L2.Listoptioncode AND L2.Listname = 'PrivacyLevel')
INNER JOIN Listoptionvalue Lv ON Lv.Listname = 'PrivacyLevel' AND Lv.Listoptioncode = L2.Listoptioncode

Where  p.hmy in (select a.hProp from @EvalProperties a) 
	   and Si.Serviceinstanceid = (
		SELECT Max(Si3.Serviceinstanceid)
		FROM Serviceinstance Si3
		INNER JOIN Service S1 ON Si3.Serviceid = S1.Serviceid AND S1.Serviceclassid = 1
		WHERE Si3.Residentid = Si.Residentid
			AND Si3.Serviceinstanceactiveflag <> 0
			AND Isnull(Si3.Serviceinstancetodate, d.EvalDate) > = Si3.Serviceinstancefromdate
			AND Si3.Serviceinstancefromdate = (
				SELECT Max(Si2.Serviceinstancefromdate)
				FROM Serviceinstance Si2
				INNER JOIN Service S ON Si2.Serviceid = S.Serviceid
					AND S.Serviceclassid = 1
				WHERE Si2.Residentid = Si.Residentid
					AND Si2.Serviceinstanceactiveflag <> 0
					AND Isnull(Si2.Serviceinstancetodate, d.EvalDate) > = Si2.Serviceinstancefromdate
					AND Si2.Serviceinstancefromdate <= d.EvalDate
					AND d.EvalDate <= Isnull(Si2.Serviceinstancetodate, d.EvalDate)
				)
		)

) r


/*

	Populate a Temp Table with a Census for each day of YTD

*/
/* to save processing time, insert any records from existing Resident List */

select 
*
into #Resident_List_YTD
from #Resident_List
where EvalDate in (select EvalDate from #DateList_YTD)

update #Resident_List_YTD set EvalMonth = 'YTD'


/* insert any records NOT in existing Resident List */

insert into #Resident_List_YTD
Select 
r.*
,(select LTRIM(RTRIM(s.ServiceName)) 
   from ServiceInstance c 
   INNER JOIN Service s on s.ServiceId = c.ServiceId
   INNER JOIN ServiceClass sc on sc.ServiceClassId = s.ServiceClassId AND sc.ServiceClassName IN ('Care Level')
   where c.ResidentID = r.hMyPerson
                AND c.ServiceInstanceActiveFlag <> 0
                AND c.ServiceInstanceFromDate <= r.EvalDate
               AND ISNULL(c.ServiceInstanceToDate,r.EvalDate) >= r.EvalDate
              AND isnull(c.ServiceInstanceToDate,r.EvalDate) >=  c.ServiceInstanceFromDate
  ) as CareLevel
from
(
SELECT 
	d.EvalDate
        ,'YTD' EvalMonth
  	,P.hmy PropertyID
	,ltrim(rtrim(P.sAddr1)) as Community
	,case 
		when ltrim(rtrim(P.sAddr1)) like '%Lantern%' then replace(ltrim(rtrim(P.sAddr1)),'The Lantern at Morning Pointe of ','') + ' ' +'Lantern'
		else replace(ltrim(rtrim(P.sAddr1)),'Morning Pointe of ','') 
	end as Community_Abbr
	,ltrim(rtrim(p.scode)) as Community_Code
	,lv.listoptionValue Occupancy_Value
	,l2.ListOptionName Pri_Sec	
	,t.istatus as Tenant_Status
	, case 
		when t.istatus in (2,8) then 'R' 
		when t.istatus = 4 then 'N' 
		when t.istatus = 11 then 'L' 
		when t.istatus = 0 and t.dtmovein > @Eval_Date then 'C' 
		else 'O' 
	end as Unit_Status
	,ltrim(rtrim(u.scode)) as Unit
	,t.hMyPerson
	,ltrim(rtrim(t.sLastName))+', '+ltrim(rtrim(t.sFirstName)) AS Resident_Name 
	,sr.ResidentBirthDate
	,DateDIFF(yy,sr.ResidentBirthDate,d.EvalDate)-CASE WHEN sr.ResidentBirthDate<=DateAdd(yy,DateDIFF(yy,d.EvalDate,sr.ResidentBirthDate), d.EvalDate) THEN 0 ELSE 1 END AS Age
	,t.dtmovein as MoveIn_Date 
	,t.dtmoveout as MoveOut_Date
	,ts.status ResStatus

from  #DateList_YTD d
left join property P  on 1=1
INNER JOIN Tenant T ON T.Hproperty = P.hmy
INNER JOIN unit u ON u.hmy = t.hunit AND isnull(u.exclude, 0) = 0
INNER JOIN Serviceinstance Si ON (T.Hmyperson = Si.Residentid) AND si.carelevelcode IN ('AL','ALZ','PC','LL','BUN')
INNER JOIN Service S ON (Si.Serviceid = S.Serviceid AND S.Serviceclassid = 1)
INNER JOIN Seniorresident sr ON (T.Hmyperson = sr.Residentid)
inner join SeniorResidentStatus ts on (ts.istatus = t.istatus)
INNER JOIN Listoption L1 ON (Si.Carelevelcode = L1.Listoptioncode AND L1.Listname = 'CareLevel')
INNER JOIN Listoption L2 ON (Si.Privacylevelcode = L2.Listoptioncode AND L2.Listname = 'PrivacyLevel')
INNER JOIN Listoptionvalue Lv ON Lv.Listname = 'PrivacyLevel' AND Lv.Listoptioncode = L2.Listoptioncode

Where  p.hmy in (select a.hProp from @EvalProperties a)
		and d.EvalDate not in (select EvalDate from #DateList)
	    and Si.Serviceinstanceid = (
		SELECT Max(Si3.Serviceinstanceid)
		FROM Serviceinstance Si3
		INNER JOIN Service S1 ON Si3.Serviceid = S1.Serviceid AND S1.Serviceclassid = 1
		WHERE Si3.Residentid = Si.Residentid
			AND Si3.Serviceinstanceactiveflag <> 0
			AND Isnull(CONVERT(DATETIME, CONVERT(VARCHAR(11), si3.ServiceInstanceTODate), 101), d.EvalDate) > = CONVERT(DATETIME, CONVERT(VARCHAR(11), si3.ServiceInstanceFromDate), 101)
			AND Si3.Serviceinstancefromdate = (
				SELECT Max(Si2.Serviceinstancefromdate)
				FROM Serviceinstance Si2
				INNER JOIN Service S ON Si2.Serviceid = S.Serviceid
					AND S.Serviceclassid = 1
				WHERE Si2.Residentid = Si.Residentid
					AND Si2.Serviceinstanceactiveflag <> 0
					AND Isnull(CONVERT(DATETIME, CONVERT(VARCHAR(11), si2.ServiceInstanceTODate), 101), d.EvalDate) > = CONVERT(DATETIME, CONVERT(VARCHAR(11), si2.ServiceInstanceFromDate), 101)
					AND CONVERT(DATETIME, CONVERT(VARCHAR(11), si2.ServiceInstanceFromDate), 101) <= d.EvalDate
					AND d.EvalDate <= Isnull(CONVERT(DATETIME, CONVERT(VARCHAR(11), si2.ServiceInstanceTODate), 101), d.EvalDate)
				)
		)



UNION ALL

/*   Units that have Physical Therapy Rent */


SELECT 
	d.EvalDate
	,'YTD' EvalMonth  
	,P.hmy PropertyID
	,ltrim(rtrim(P.sAddr1)) as Community
	,case 
		when ltrim(rtrim(P.sAddr1)) like '%Lantern%' then replace(ltrim(rtrim(P.sAddr1)),'The Lantern at Morning Pointe of ','') + ' ' +'Lantern'
		else replace(ltrim(rtrim(P.sAddr1)),'Morning Pointe of ','') 
	end as Community_Abbr
	,ltrim(rtrim(p.scode)) as Community_Code
	,lv.listoptionValue Occupancy_Value
	,l2.ListOptionName Pri_Sec	
	,t.istatus as Tenant_Status
	, case 
		when t.istatus in (2,8) then 'R' 
		when t.istatus = 4 then 'N' 
		when t.istatus = 11 then 'L' 
		when t.istatus = 0 and t.dtmovein > @Eval_Date then 'C' 
		else 'O' 
	end as Unit_Status
	,ltrim(rtrim(u.scode)) as Unit
	,t.hMyPerson	
	,ltrim(rtrim(t.sLastName))+', '+ltrim(rtrim(t.sFirstName)) AS Resident_Name
	,sr.ResidentBirthDate
	,DateDIFF(yy,sr.ResidentBirthDate,d.EvalDate)-CASE WHEN sr.ResidentBirthDate<=DateAdd(yy,DateDIFF(yy,d.EvalDate,sr.ResidentBirthDate), d.EvalDate) THEN 0 ELSE 1 END AS Age
	,t.dtmovein as MoveIn_Date 
	,t.dtmoveout as MoveOut_Date
	,ts.status ResStatus

from  #DateList_YTD d
left join property P  on 1=1
INNER JOIN Tenant T ON T.Hproperty = P.hmy
INNER JOIN unit u ON u.hmy = t.hunit AND isnull(u.exclude, 0) = 0
INNER JOIN Serviceinstance Si ON (T.Hmyperson = Si.Residentid) 
INNER JOIN Service S ON (Si.Serviceid = S.Serviceid AND S.Serviceclassid = 1)
INNER JOIN servicechargetype sct ON s.serviceid = sct.serviceid
INNER JOIN Chargtyp ct ON ct.hmy = sct.ChargeTypeID AND ct.SCODE = 'PT'
INNER JOIN Seniorresident sr ON (T.Hmyperson = sr.Residentid)
inner join SeniorResidentStatus ts on (ts.istatus = t.istatus)
INNER JOIN Listoption L2 ON (Si.Privacylevelcode = L2.Listoptioncode AND L2.Listname = 'PrivacyLevel')
INNER JOIN Listoptionvalue Lv ON Lv.Listname = 'PrivacyLevel' AND Lv.Listoptioncode = L2.Listoptioncode

Where  p.hmy in (select a.hProp from @EvalProperties a) 
		and d.EvalDate not in (select EvalDate from #DateList)
	   and Si.Serviceinstanceid = (
		SELECT Max(Si3.Serviceinstanceid)
		FROM Serviceinstance Si3
		INNER JOIN Service S1 ON Si3.Serviceid = S1.Serviceid AND S1.Serviceclassid = 1
		WHERE Si3.Residentid = Si.Residentid
			AND Si3.Serviceinstanceactiveflag <> 0
			AND Isnull(Si3.Serviceinstancetodate, d.EvalDate) > = Si3.Serviceinstancefromdate
			AND Si3.Serviceinstancefromdate = (
				SELECT Max(Si2.Serviceinstancefromdate)
				FROM Serviceinstance Si2
				INNER JOIN Service S ON Si2.Serviceid = S.Serviceid
					AND S.Serviceclassid = 1
				WHERE Si2.Residentid = Si.Residentid
					AND Si2.Serviceinstanceactiveflag <> 0
					AND Isnull(Si2.Serviceinstancetodate, d.EvalDate) > = Si2.Serviceinstancefromdate
					AND Si2.Serviceinstancefromdate <= d.EvalDate
					AND d.EvalDate <= Isnull(Si2.Serviceinstancetodate, d.EvalDate)
				)
		)

) r



/*
	Count of Hospital LOA for Selected Communities/Regions
*/



insert into #Clinical_KPI_Results_Staging
select distinct
dl.Column_Index
,cast(r.Cell_Data as Int) as Cell_Data
from
(	select	
    rl.EvalMonth	
  	,count(rl.LOAID) as Cell_Data
	from 
    (select distinct
     r.EvalMonth
     , sloa.LOAID, r.hMyPerson
     from #Resident_List r
     Left Join SeniorLOA sloa on sloa.ResidentID = r.hMyPerson 
     	where sloa.LOAReasonCode = 'HOS' and sloa.LOAStatusCode <> 'CAN'
     	and r.EvalDate >= convert(date,sloa.LOAStartDate) and r.EvalDate <=  convert(date,isnull(sloa.LOAEndDate,r.EvalDate ) ) 
	) rl
 	Group by
	rl.EvalMonth
) r
left join #DateList dl on r.EvalMonth = dl.EvalMonth

/*
	Add Report Index and Row Description
*/

insert into #Clinical_KPI_Results_Staging select 'Report_Index', 'S0000'
insert into #Clinical_KPI_Results_Staging select 'Description', 'Total Hospital LOA'

/*
	Add Comparison of Periods
*/

insert into #Clinical_KPI_Results_Staging select 'Period_1v2', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_1'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_2v3', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_3v4', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_4v5', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_5v6', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_6'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) as varchar(100))


insert into #Clinical_KPI_Results
SELECT 
0,'Header Info',*
FROM
 
(SELECT 
	Column_Index, Cell_Data	
FROM 
	#Clinical_KPI_Results_Staging
)
AS DataTable
PIVOT(
	Max(Cell_Data) 
FOR Column_Index IN ([Report_Index],[Description],[Period_1],[Period_2],[Period_1v2],[Period_3],[Period_2v3],[Period_4],[Period_3v4],[Period_5],[Period_4v5],[Period_6],[Period_5v6],[YTD]) 
) AS PivotTable




truncate table #Clinical_KPI_Results_Staging

/*
	MoveIns for Selected Communities/Regions
	Sum of ALL with MoveIn Dated in EvalMonth
*/

insert into #Clinical_KPI_Results_Staging
select distinct
dl.Column_Index
,cast(r.Cell_Data as Int) as Cell_Data
from
(
	select	
	rl.EvalMonth	
  	,Count(rl.EvalMonth) as Cell_Data
	from (select distinct hMyPerson, MoveIn_Date, EvalMonth from #Resident_List) rl
 	WHERE LEFT(CONVERT(varchar, rl.MoveIn_Date,112),6) = rl.EvalMonth
	Group by
	rl.EvalMonth
) r
left join #DateList dl on r.EvalMonth = dl.EvalMonth

/*
	MoveIns for Selected Communities/Regions
	Sum of ALL with MoveIn Dated in YTD
*/



insert into #Clinical_KPI_Results_Staging
select distinct
'YTD'
,Count(rl.EvalMonth) as Cell_Data
from (select distinct hMyPerson, MoveIn_Date, EvalMonth from #Resident_List_YTD where MoveIn_Date between @YTD_Begin and @YTD_End) rl



/*
	Add Report Index and Row Description
*/

insert into #Clinical_KPI_Results_Staging select 'Report_Index', 'S0000'
insert into #Clinical_KPI_Results_Staging select 'Description', 'Total New Move Ins'

/*
	Add Comparison of Periods
*/

insert into #Clinical_KPI_Results_Staging select 'Period_1v2', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_1'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_2v3', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_3v4', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_4v5', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_5v6', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_6'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) as varchar(100))


insert into #Clinical_KPI_Results
SELECT 
0,'Header Info',*
FROM
 
(SELECT 
	Column_Index, Cell_Data	
FROM 
	#Clinical_KPI_Results_Staging
)
AS DataTable
PIVOT(
	Max(Cell_Data) 
FOR Column_Index IN ([Report_Index],[Description],[Period_1],[Period_2],[Period_1v2],[Period_3],[Period_2v3],[Period_4],[Period_3v4],[Period_5],[Period_4v5],[Period_6],[Period_5v6],[YTD]) 
) AS PivotTable




truncate table #Clinical_KPI_Results_Staging







/*
	Average Daily Census for Selected Communities/Regions
	Round (Sum of ALL Occupancy_Values Grouped by Month   /   Days on Month)
*/



insert into #Clinical_KPI_Results_Staging
select distinct
dl.Column_Index
,cast(r.Cell_Data as Int) as Cell_Data
from
(
	select	
    rl.EvalMonth	
  	,round(sum(cast(rl.Occupancy_Value as numeric(10,2))) / datediff(day, right(rl.EvalMonth,2) + '/01/' + left(rl.EvalMonth,4), dateadd(month, 1, right(rl.EvalMonth,2) + '/01/' + left(rl.EvalMonth,4))),0) as Cell_Data
	from #Resident_List rl
 	Group by
	rl.EvalMonth
) r
left join #DateList dl on r.EvalMonth = dl.EvalMonth

/*
	Add Report Index and Row Description
*/

insert into #Clinical_KPI_Results_Staging select 'Report_Index', 'S0000'
insert into #Clinical_KPI_Results_Staging select 'Description', 'Average Daily Census'

/*
	Add Comparison of Periods
*/

insert into #Clinical_KPI_Results_Staging select 'Period_1v2', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_1'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_2v3', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_3v4', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_4v5', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_5v6', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_6'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) as varchar(100))


insert into #Clinical_KPI_Results
SELECT 
0,'Header Info',*
FROM
 
(SELECT 
	Column_Index, Cell_Data	
FROM 
	#Clinical_KPI_Results_Staging
)
AS DataTable
PIVOT(
	Max(Cell_Data) 
FOR Column_Index IN ([Report_Index],[Description],[Period_1],[Period_2],[Period_1v2],[Period_3],[Period_2v3],[Period_4],[Period_3v4],[Period_5],[Period_4v5],[Period_6],[Period_5v6],[YTD]) 
) AS PivotTable




truncate table #Clinical_KPI_Results_Staging




/*
	Average Age of Residents for Selected Communities/Regions
	Round (Sum of ALL Ages Grouped by Month   /   Number of Residents)
	Only Residents with DOB in Database (Some like Therapy Rooms have no DOB)
*/



insert into #Clinical_KPI_Results_Staging
select distinct
dl.Column_Index
,cast(r.Cell_Data as Int) as Cell_Data
from
(
	select	
		rl.EvalMonth	
  		,round(sum(cast(rl.Age as numeric(10,2))) / Count(rl.EvalMonth),0) as Cell_Data
	from #Resident_List rl
	where rl.ResidentBirthDate is not null
 	Group by
	rl.EvalMonth
) r
left join #DateList dl on r.EvalMonth = dl.EvalMonth

/*
	Add Report Index and Row Description
*/

insert into #Clinical_KPI_Results_Staging select 'Report_Index', 'S0000'
insert into #Clinical_KPI_Results_Staging select 'Description', 'Average Age of Residents'

/*
	Add Comparison of Periods
*/

insert into #Clinical_KPI_Results_Staging select 'Period_1v2', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_1'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_2v3', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_3v4', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_4v5', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_5v6', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_6'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) as varchar(100))


insert into #Clinical_KPI_Results
SELECT 
0,'Header Info',*
FROM
 
(SELECT 
	Column_Index, Cell_Data	
FROM 
	#Clinical_KPI_Results_Staging
)
AS DataTable
PIVOT(
	Max(Cell_Data) 
FOR Column_Index IN ([Report_Index],[Description],[Period_1],[Period_2],[Period_1v2],[Period_3],[Period_2v3],[Period_4],[Period_3v4],[Period_5],[Period_4v5],[Period_6],[Period_5v6],[YTD]) 
) AS PivotTable


truncate table #Clinical_KPI_Results_Staging




/*
	Concierge for Selected Communities/Regions for New Move Ins
	Sum of ALL with MoveIn Dated in  EvalMonth
*/



insert into #Clinical_KPI_Results_Staging
select distinct
dl.Column_Index
,cast(r.Cell_Data as Int) as Cell_Data
from
(
	select	
	rl.EvalMonth	
  	,Count(rl.EvalMonth) as Cell_Data
	from (select distinct hMyPerson, MoveIn_Date, EvalMonth, CareLevel, EvalDate from #Resident_List) rl
 	WHERE 
		rl.CareLevel = 'Concierge'
		and LEFT(CONVERT(varchar, rl.MoveIn_Date,112),6) = rl.EvalMonth /* Move In in Eval Month */
		and rl.EvalDate = convert(date,(DATEADD (dd, -1, DATEADD(mm, DATEDIFF(mm, 0, right(rl.EvalMonth,2) + '/01/' + left(rl.EvalMonth,4)) + 1, 0))))
	Group by
	rl.EvalMonth
) r
left join #DateList dl on r.EvalMonth = dl.EvalMonth


/*
	Concierge for Selected Communities/Regions for New Move Ins
	Sum of ALL with MoveIn Dated in  YTD
*/



insert into #Clinical_KPI_Results_Staging
select distinct
'YTD'
,Count(rl.EvalMonth) as Cell_Data
from (select distinct hMyPerson, MoveIn_Date, EvalMonth from #Resident_List_YTD where CareLevel = 'Concierge' and MoveIn_Date between @YTD_Begin and @YTD_End) rl



/*
	Add Report Index and Row Description
*/

insert into #Clinical_KPI_Results_Staging select 'Report_Index', 'S0000'
insert into #Clinical_KPI_Results_Staging select 'Description', 'Total Concierge for New Move Ins'

/*
	Add Comparison of Periods
*/

insert into #Clinical_KPI_Results_Staging select 'Period_1v2', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_1'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_2v3', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_3v4', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_4v5', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_5v6', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_6'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) as varchar(100))


insert into #Clinical_KPI_Results
SELECT 
0,'Header Info',*
FROM
 
(SELECT 
	Column_Index, Cell_Data	
FROM 
	#Clinical_KPI_Results_Staging
)
AS DataTable
PIVOT(
	Max(Cell_Data) 
FOR Column_Index IN ([Report_Index],[Description],[Period_1],[Period_2],[Period_1v2],[Period_3],[Period_2v3],[Period_4],[Period_3v4],[Period_5],[Period_4v5],[Period_6],[Period_5v6],[YTD]) 
) AS PivotTable




truncate table #Clinical_KPI_Results_Staging

insert into #Clinical_KPI_Results_Staging
select distinct
dl.Column_Index
,cast(r.Cell_Data as Int) as Cell_Data
from
(
	select	
	rl.EvalMonth	
  	,Count(rl.EvalMonth) as Cell_Data
	from (select distinct hMyPerson, MoveIn_Date, EvalMonth, CareLevel, EvalDate,Unit_Status from #Resident_List) rl
 	WHERE 
		rl.Unit_Status = 'C'
		and rl.EvalDate = convert(date,(DATEADD (dd, -1, DATEADD(mm, DATEDIFF(mm, 0, right(rl.EvalMonth,2) + '/01/' + left(rl.EvalMonth,4)) + 1, 0))))
	Group by
	rl.EvalMonth
) r
left join #DateList dl on r.EvalMonth = dl.EvalMonth 
--select * from #Inventory_Occupancy_Residents
	-- drop table #Inventory_Occupancy_Residents


/*
	Add Report Index and Row Description
*/

insert into #Clinical_KPI_Results_Staging select 'Report_Index', 'S0000'
insert into #Clinical_KPI_Results_Staging select 'Description', 'NEW ADD1'

/*
	Add Comparison of Periods
*/

insert into #Clinical_KPI_Results_Staging select 'Period_1v2', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_1'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_2v3', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_3v4', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_4v5', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_5v6', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_6'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) as varchar(100))


insert into #Clinical_KPI_Results
SELECT 
0,'Header Info',*
FROM
 
(SELECT 
	Column_Index, Cell_Data	
FROM 
	#Clinical_KPI_Results_Staging
)
AS DataTable
PIVOT(
	Max(Cell_Data) 
FOR Column_Index IN ([Report_Index],[Description],[Period_1],[Period_2],[Period_1v2],[Period_3],[Period_2v3],[Period_4],[Period_3v4],[Period_5],[Period_4v5],[Period_6],[Period_5v6],[YTD]) 
) AS PivotTable
truncate table #Clinical_KPI_Results_Staging

/*
	Premium for Selected Communities/Regions for New Move Ins
	Sum of ALL with MoveIn Dated in EvalMonth
*/



insert into #Clinical_KPI_Results_Staging
select distinct
dl.Column_Index
,cast(r.Cell_Data as Int) as Cell_Data
from
(
	select	
	rl.EvalMonth	
  	,Count(rl.EvalMonth) as Cell_Data
	from (select distinct hMyPerson, MoveIn_Date, EvalMonth, CareLevel, EvalDate from #Resident_List) rl
 	WHERE 
		rl.CareLevel = 'Premium'
		and LEFT(CONVERT(varchar, rl.MoveIn_Date,112),6) = rl.EvalMonth /* Move In in Eval Month */
		and rl.EvalDate = convert(date,(DATEADD (dd, -1, DATEADD(mm, DATEDIFF(mm, 0, right(rl.EvalMonth,2) + '/01/' + left(rl.EvalMonth,4)) + 1, 0))))
	Group by
	rl.EvalMonth
) r
left join #DateList dl on r.EvalMonth = dl.EvalMonth

/*
	Concierge for Selected Communities/Regions for New Move Ins
	Sum of ALL with MoveIn Dated in  YTD
*/



insert into #Clinical_KPI_Results_Staging
select distinct
'YTD'
,Count(rl.EvalMonth) as Cell_Data
from (select distinct hMyPerson, MoveIn_Date, EvalMonth from #Resident_List_YTD where CareLevel = 'Premium' and MoveIn_Date between @YTD_Begin and @YTD_End) rl


/*
	Add Report Index and Row Description
*/

insert into #Clinical_KPI_Results_Staging select 'Report_Index', 'S0000'
insert into #Clinical_KPI_Results_Staging select 'Description', 'Total Premium for New Move Ins'

/*
	Add Comparison of Periods
*/

insert into #Clinical_KPI_Results_Staging select 'Period_1v2', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_1'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_2v3', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_3v4', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_4v5', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_5v6', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_6'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) as varchar(100))


insert into #Clinical_KPI_Results
SELECT 
0,'Header Info',*
FROM
 
(SELECT 
	Column_Index, Cell_Data	
FROM 
	#Clinical_KPI_Results_Staging
)
AS DataTable
PIVOT(
	Max(Cell_Data) 
FOR Column_Index IN ([Report_Index],[Description],[Period_1],[Period_2],[Period_1v2],[Period_3],[Period_2v3],[Period_4],[Period_3v4],[Period_5],[Period_4v5],[Period_6],[Period_5v6],[YTD]) 
) AS PivotTable




truncate table #Clinical_KPI_Results_Staging



/*
	Concierge for Selected Communities/Regions On Last Day on Month
	Sum of ALL with MoveIn Dated on the LAST DAY of EvalMonth
*/



insert into #Clinical_KPI_Results_Staging
select distinct
dl.Column_Index
,cast(r.Cell_Data as Int) as Cell_Data
from
(
	select	
	rl.EvalMonth	
  	,Count(rl.EvalMonth) as Cell_Data
	from (select distinct hMyPerson, MoveIn_Date, EvalMonth, CareLevel, EvalDate from #Resident_List) rl
 	WHERE 
		rl.CareLevel = 'Concierge'
		and rl.EvalDate = convert(date,(DATEADD (dd, -1, DATEADD(mm, DATEDIFF(mm, 0, right(rl.EvalMonth,2) + '/01/' + left(rl.EvalMonth,4)) + 1, 0))))
	Group by
	rl.EvalMonth
) r
left join #DateList dl on r.EvalMonth = dl.EvalMonth


/*
	Add Report Index and Row Description
*/

insert into #Clinical_KPI_Results_Staging select 'Report_Index', 'S0000'
insert into #Clinical_KPI_Results_Staging select 'Description', 'Total Concierge at Month End'

/*
	Add Comparison of Periods
*/

insert into #Clinical_KPI_Results_Staging select 'Period_1v2', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_1'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_2v3', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_3v4', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_4v5', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_5v6', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_6'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) as varchar(100))


insert into #Clinical_KPI_Results
SELECT 
0,'Header Info',*
FROM
 
(SELECT 
	Column_Index, Cell_Data	
FROM 
	#Clinical_KPI_Results_Staging
)
AS DataTable
PIVOT(
	Max(Cell_Data) 
FOR Column_Index IN ([Report_Index],[Description],[Period_1],[Period_2],[Period_1v2],[Period_3],[Period_2v3],[Period_4],[Period_3v4],[Period_5],[Period_4v5],[Period_6],[Period_5v6],[YTD]) 
) AS PivotTable




truncate table #Clinical_KPI_Results_Staging

/*
	Premium for Selected Communities/Regions On Last Day on Month
	Sum of ALL with MoveIn Dated on the LAST DAY of EvalMonth
*/



insert into #Clinical_KPI_Results_Staging
select distinct
dl.Column_Index
,cast(r.Cell_Data as Int) as Cell_Data
from
(
	select	
	rl.EvalMonth	
  	,Count(rl.EvalMonth) as Cell_Data
	from (select distinct hMyPerson, MoveIn_Date, EvalMonth, CareLevel, EvalDate from #Resident_List) rl
 	WHERE 
		rl.CareLevel = 'Premium'
		and rl.EvalDate = convert(date,(DATEADD (dd, -1, DATEADD(mm, DATEDIFF(mm, 0, right(rl.EvalMonth,2) + '/01/' + left(rl.EvalMonth,4)) + 1, 0))))
	Group by
	rl.EvalMonth
) r
left join #DateList dl on r.EvalMonth = dl.EvalMonth


/*
	Add Report Index and Row Description
*/

insert into #Clinical_KPI_Results_Staging select 'Report_Index', 'S0000'
insert into #Clinical_KPI_Results_Staging select 'Description', 'Total Premium at Month End'

/*
	Add Comparison of Periods
*/

insert into #Clinical_KPI_Results_Staging select 'Period_1v2', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_1'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_2v3', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_3v4', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_4v5', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_5v6', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_6'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) as varchar(100))


insert into #Clinical_KPI_Results
SELECT 
0,'Header Info',*
FROM
 
(SELECT 
	Column_Index, Cell_Data	
FROM 
	#Clinical_KPI_Results_Staging
)
AS DataTable
PIVOT(
	Max(Cell_Data) 
FOR Column_Index IN ([Report_Index],[Description],[Period_1],[Period_2],[Period_1v2],[Period_3],[Period_2v3],[Period_4],[Period_3v4],[Period_5],[Period_4v5],[Period_6],[Period_5v6],[YTD]) 
) AS PivotTable




truncate table #Clinical_KPI_Results_Staging

insert into #Clinical_KPI_Results_Staging
select distinct
dl.Column_Index
,cast(r.Cell_Data as Int) as Cell_Data
from
(
	select	
	rl.EvalMonth	
  	,Count(rl.EvalMonth) as Cell_Data
	from (select distinct hMyPerson, MoveIn_Date, EvalMonth, CareLevel, EvalDate,Unit_Status from #Resident_List) rl
 	WHERE 
		rl.Unit_Status = 'C'
		and rl.EvalDate = convert(date,(DATEADD (dd, -1, DATEADD(mm, DATEDIFF(mm, 0, right(rl.EvalMonth,2) + '/01/' + left(rl.EvalMonth,4)) + 1, 0))))
	Group by
	rl.EvalMonth
) r
left join #DateList dl on r.EvalMonth = dl.EvalMonth
--select * from #Inventory_Occupancy_Residents
	-- drop table #Inventory_Occupancy_Residents


/*
	Add Report Index and Row Description
*/

insert into #Clinical_KPI_Results_Staging select 'Report_Index', 'S3040'
insert into #Clinical_KPI_Results_Staging select 'Description', 'NEW ADD1'

/*
	Add Comparison of Periods
*/

insert into #Clinical_KPI_Results_Staging select 'Period_1v2', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_1'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_2v3', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_3v4', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_4v5', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_5v6', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_6'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) as varchar(100))


insert into #Clinical_KPI_Results
SELECT 
0,'Header Info',*
FROM
 
(SELECT 
	Column_Index, Cell_Data	
FROM 
	#Clinical_KPI_Results_Staging
)
AS DataTable
PIVOT(
	Max(Cell_Data) 
FOR Column_Index IN ([Report_Index],[Description],[Period_1],[Period_2],[Period_1v2],[Period_3],[Period_2v3],[Period_4],[Period_3v4],[Period_5],[Period_4v5],[Period_6],[Period_5v6],[YTD]) 
) AS PivotTable

truncate table #Clinical_KPI_Results_Staging


/*

	Populate a Temp Table with a Discharges for each day of Prior 6 Months

*/

Select r.*
into #Discharge_List
from
(
SELECT 
	d.EvalDate,
        LEFT(CONVERT(varchar, d.EvalDate,112),6) EvalMonth,
	ltrim(rtrim(p.saddr1))+ ' ('+ltrim(rtrim(p.scode))+')' propname,
	t.istatus,
	t.hmyperson ThMy,
	t.scode AS hTcode, 
	RTRIM(t.sLastName)+', '+RTRIM(t.sFirstName)+' ('+rtrim(t.scode)+')' AS sResidentName, 
	ISNULL(srh.dtmovein,t.dtMoveIn) moveindate,
	ISNULL(srh.dtnotice,t.dtnotice)  Noticedate, 
	ISNULL(srh.dtmoveout,t.dtmoveout) moveoutdate, 
	datediff(mm,convert(datetime,convert(varchar(10),ISNULL(srh.dtmovein,t.dtMoveIn),121),101),convert(datetime,convert(varchar(10),ISNULL(srh.dtmoveout,t.dtmoveout),121),101)) LOS_Months,
	datediff(dd,convert(datetime,convert(varchar(10),ISNULL(srh.dtmovein,t.dtMoveIn),121),101),convert(datetime,convert(varchar(10),ISNULL(srh.dtmoveout,t.dtmoveout),121),101)) LOS_Days,
	u.scode ucode, 
	ltrim(rtrim(isnull(ut.sdesc,''))) + ' ('+ ( ltrim(rtrim(isnull(ut.Scode,'')))) +')' utdesc, 
	l2.ListOptionName privacylevel, 
	l1.ListOptionName carelevel,
	l3.ListOptionName Moveoutreason,
	Case ltrim(rtrim(l3.ListOptionName))
      when 'Contract Terminated' then 'Other'
      when 'Cost' then 'Financial'
      when 'Death' then 'Death'
      when 'Death-At Community' then 'Death'
      when 'Death-Outside Community' then 'Death'
      when 'Dissatisfied-Competitor' then 'Dissatisfied'
      when 'Dissatisfied-Family Home' then 'Dissatisfied'
      when 'Dissatisfied-Own Home' then 'Dissatisfied'
      when 'End of Respite' then 'End R-D'
      when 'End of Respite/Daycare' then 'End R-D'
      when 'Evicted' then 'Evicted'
      when 'Evicted-Behavior' then 'Evicted'
      when 'Evicted-Financial' then 'Evicted'
      when 'Evicted-Medical' then 'Evicted'
      when 'Financial-Competitor' then 'Financial'
      when 'Financial-Family Home' then 'Financial'
      when 'Financial-Own Home' then 'Financial'
      when 'Health improved' then 'Other'
      when 'Higher Care Needed' then 'Higher LOC'
      when 'Higher LOC-Geri/Psych' then 'Higher LOC'
      when 'Higher LOC-Hospice' then 'Higher LOC'
      when 'Higher LOC-Memory Care' then 'Higher LOC'
      when 'Higher LOC-Nursing Home' then 'Higher LOC'
      when 'Medical' then 'Other'
      when 'Moved to Competitor' then 'Other'
      when 'Relocating to other area' then 'Other'
      when 'Transfer to Sister MP' then 'Other'
      when 'Unknown' then 'Other'
	else 'Other' end as MoveOut_Category,
	ts.status ResStatus,
	isnull(srh.dtBillingEnd,'01/01/1900')BillingEndDate
from  #DateList d
	left join property p on 1=1
	inner join tenant t on t.hproperty = p.hmy 
	Inner Join SeniorResidentStatus srs on (srs.iStatus = t.iStatus)
	inner join seniorresident sr on t.hmyperson = sr.residentid 
	INNER JOIN SeniorResidentHistoryStatus  Srh ON Srh.hResident  = sr.ResidentId 
	ANd srh.hmy in (SELECT MAX(srh1.hmy)
      	From SeniorResidentHistoryStatus srh1 
      	where  1=1 
				AND Srh1.hResident  = sr.ResidentId
      	and srh1.dtfrom <= isnull(srh1.dtto, srh1.dtfrom)  
   			AND srh1.dtfrom <= CONVERT(DATETIME, d.EvalDate, 101)
   			AND ( srh1.istatuscode =1 OR srh1.bOnNotice = 1 )
				and srh1.dtMoveOut in (Select Distinct dtMoveOut
      							From SeniorResidentHistoryStatus srh2 
							  		where  1=1  
										AND Srh2.hResident  = sr.ResidentId
      							and  srh2.dtfrom <= isnull(srh2.dtto, srh2.dtfrom)  
   									AND srh2.dtfrom <= CONVERT(DATETIME, d.EvalDate, 101)
   									AND ( srh2.istatuscode =1 )
										)   	
				group by hResident,dtMoveOut)
	left outer join listoption l1 on (isnull(srh.sCareLevelCode,sr.CareLevelcode) = l1.listoptioncode AND l1.listname = 'CareLevel')	
	left outer join listoption l3 on (convert(varchar(10),isnull(srh.iMoveOutReason,t.ireason)) = l3.listoptioncode and l3.listname = 'MoveOutReason' /*and l3.listoptionactiveflag = 1*/)
 	INNER JOIN unit u ON u.hmy = ISNULL(SRH.hunit,t.hunit) 
	INNER JOIN unittype ut ON ut.hmy = u.hunittype
	left outer join SeniorResidentStatus ts on (ts.istatus = t.iStatus)
	left outer join listoption l2 on (isnull(srh.sPrivacyLevelCode,sr.PrivacyLevelCode) = l2.listoptioncode AND l2.listname = 'PrivacyLevel')
where p.hmy in (select a.hProp from @EvalProperties a)
	AND t.iStatus <> 6
	AND ISNULL(srh.iStatuscode,t.iStatus) =1 
	and ISNULL(srh.dtmoveout,t.dtmoveout) = d.EvalDate 
/*	and isnull(srh.sPrivacyLevelCode,sr.PrivacyLevelCode) NOT IN ( SELECT case when '#SecResident#' = 'No' then secondaryprivacylevel else '' End from SeniorPrivacyLevelMapping) */

) r


/*

	Populate a Temp Table with a Discharges for each day of YTD

*/

/* to save processing time, insert any records from existing Discharge List */

select 
*
into #Discharge_List_YTD
from #Discharge_List
where EvalDate in (select EvalDate from #DateList_YTD)


/* insert any records NOT in existing Discharge List */

insert into #Discharge_List_YTD
Select r.*
from
(
SELECT 
	d.EvalDate,
        LEFT(CONVERT(varchar, d.EvalDate,112),6) EvalMonth,
	ltrim(rtrim(p.saddr1))+ ' ('+ltrim(rtrim(p.scode))+')' propname,
	t.istatus,
	t.hmyperson ThMy,
	t.scode AS hTcode, 
	RTRIM(t.sLastName)+', '+RTRIM(t.sFirstName)+' ('+rtrim(t.scode)+')' AS sResidentName, 
	ISNULL(srh.dtmovein,t.dtMoveIn) moveindate,
	ISNULL(srh.dtnotice,t.dtnotice)  Noticedate, 
	ISNULL(srh.dtmoveout,t.dtmoveout) moveoutdate, 
	datediff(mm,convert(datetime,convert(varchar(10),ISNULL(srh.dtmovein,t.dtMoveIn),121),101),convert(datetime,convert(varchar(10),ISNULL(srh.dtmoveout,t.dtmoveout),121),101)) LOS_Months,
	datediff(dd,convert(datetime,convert(varchar(10),ISNULL(srh.dtmovein,t.dtMoveIn),121),101),convert(datetime,convert(varchar(10),ISNULL(srh.dtmoveout,t.dtmoveout),121),101)) LOS_Days,
	u.scode ucode, 
	ltrim(rtrim(isnull(ut.sdesc,''))) + ' ('+ ( ltrim(rtrim(isnull(ut.Scode,'')))) +')' utdesc, 
	l2.ListOptionName privacylevel, 
	l1.ListOptionName carelevel,
	l3.ListOptionName Moveoutreason,
	Case ltrim(rtrim(l3.ListOptionName))
      when 'Contract Terminated' then 'Other'
      when 'Cost' then 'Financial'
      when 'Death' then 'Death'
      when 'Death-At Community' then 'Death'
      when 'Death-Outside Community' then 'Death'
      when 'Dissatisfied-Competitor' then 'Dissatisfied'
      when 'Dissatisfied-Family Home' then 'Dissatisfied'
      when 'Dissatisfied-Own Home' then 'Dissatisfied'
      when 'End of Respite' then 'End R-D'
      when 'End of Respite/Daycare' then 'End R-D'
      when 'Evicted' then 'Evicted'
      when 'Evicted-Behavior' then 'Evicted'
      when 'Evicted-Financial' then 'Evicted'
      when 'Evicted-Medical' then 'Evicted'
      when 'Financial-Competitor' then 'Financial'
      when 'Financial-Family Home' then 'Financial'
      when 'Financial-Own Home' then 'Financial'
      when 'Health improved' then 'Other'
      when 'Higher Care Needed' then 'Higher LOC'
      when 'Higher LOC-Geri/Psych' then 'Higher LOC'
      when 'Higher LOC-Hospice' then 'Higher LOC'
      when 'Higher LOC-Memory Care' then 'Higher LOC'
      when 'Higher LOC-Nursing Home' then 'Higher LOC'
      when 'Medical' then 'Other'
      when 'Moved to Competitor' then 'Other'
      when 'Relocating to other area' then 'Other'
      when 'Transfer to Sister MP' then 'Other'
      when 'Unknown' then 'Other'
	else 'Other' end as MoveOut_Category,
	ts.status ResStatus,
	isnull(srh.dtBillingEnd,'01/01/1900')BillingEndDate
from  #DateList_YTD d
	left join property p on 1=1
	inner join tenant t on t.hproperty = p.hmy 
	Inner Join SeniorResidentStatus srs on (srs.iStatus = t.iStatus)
	inner join seniorresident sr on t.hmyperson = sr.residentid 
	INNER JOIN SeniorResidentHistoryStatus  Srh ON Srh.hResident  = sr.ResidentId 
	ANd srh.hmy in (SELECT MAX(srh1.hmy)
      	From SeniorResidentHistoryStatus srh1 
      	where  1=1 
				AND Srh1.hResident  = sr.ResidentId
      	and srh1.dtfrom <= isnull(srh1.dtto, srh1.dtfrom)  
   			AND srh1.dtfrom <= CONVERT(DATETIME, d.EvalDate, 101)
   			AND ( srh1.istatuscode =1 OR srh1.bOnNotice = 1 )
				and srh1.dtMoveOut in (Select Distinct dtMoveOut
      							From SeniorResidentHistoryStatus srh2 
							  		where  1=1  
										AND Srh2.hResident  = sr.ResidentId
      							and  srh2.dtfrom <= isnull(srh2.dtto, srh2.dtfrom)  
   									AND srh2.dtfrom <= CONVERT(DATETIME, d.EvalDate, 101)
   									AND ( srh2.istatuscode =1 )
										)   	
				group by hResident,dtMoveOut)
	left outer join listoption l1 on (isnull(srh.sCareLevelCode,sr.CareLevelcode) = l1.listoptioncode AND l1.listname = 'CareLevel')	
	left outer join listoption l3 on (convert(varchar(10),isnull(srh.iMoveOutReason,t.ireason)) = l3.listoptioncode and l3.listname = 'MoveOutReason' /*and l3.listoptionactiveflag = 1*/)
 	INNER JOIN unit u ON u.hmy = ISNULL(SRH.hunit,t.hunit) 
	INNER JOIN unittype ut ON ut.hmy = u.hunittype
	left outer join SeniorResidentStatus ts on (ts.istatus = t.iStatus)
	left outer join listoption l2 on (isnull(srh.sPrivacyLevelCode,sr.PrivacyLevelCode) = l2.listoptioncode AND l2.listname = 'PrivacyLevel')
where p.hmy in (select a.hProp from @EvalProperties a)
		and d.EvalDate not in (select EvalDate from #DateList)
	AND t.iStatus <> 6
	AND ISNULL(srh.iStatuscode,t.iStatus) =1 
	and ISNULL(srh.dtmoveout,t.dtmoveout) = d.EvalDate 
/*	and isnull(srh.sPrivacyLevelCode,sr.PrivacyLevelCode) NOT IN ( SELECT case when '#SecResident#' = 'No' then secondaryprivacylevel else '' End from SeniorPrivacyLevelMapping) */

) r



/*
	Total Number of Discharges for Month

*/


insert into #Clinical_KPI_Results_Staging
select distinct dl.Column_Index,cast(r.Cell_Data as Int) as Cell_Data
from
(select	rl.EvalMonth ,Count(rl.EvalMonth) as Cell_Data
	from #Discharge_List rl
 	Group by
	rl.EvalMonth
) r

left join #DateList dl on r.EvalMonth = dl.EvalMonth

/*
	Total Number of Discharges for YTD

*/


insert into #Clinical_KPI_Results_Staging
select distinct
'YTD'
,Count(EvalMonth) as Cell_Data
from #Discharge_List_YTD


/*
	Add Report Index and Row Description
*/

insert into #Clinical_KPI_Results_Staging select 'Report_Index', 'S0000'
insert into #Clinical_KPI_Results_Staging select 'Description', 'Total Discharges'

/*
	Add Comparison of Periods
*/

insert into #Clinical_KPI_Results_Staging select 'Period_1v2', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_1'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_2v3', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_3v4', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_4v5', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_5v6', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_6'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) as varchar(100))

insert into #Clinical_KPI_Results
SELECT +
0,'Header Info',*
FROM
 
(SELECT 
	Column_Index, Cell_Data	
FROM 
	#Clinical_KPI_Results_Staging
)
AS DataTable
PIVOT(
	Max(Cell_Data) 
FOR Column_Index IN ([Report_Index],[Description],[Period_1],[Period_2],[Period_1v2],[Period_3],[Period_2v3],[Period_4],[Period_3v4],[Period_5],[Period_4v5],[Period_6],[Period_5v6],[YTD]) 
) AS PivotTable


truncate table #Clinical_KPI_Results_Staging



/*
	Average LOS Months
	Round (Sum of ALL LOS Months Grouped by Month   /   Discharges )
*/



insert into #Clinical_KPI_Results_Staging
select distinct
dl.Column_Index
,cast(r.Cell_Data as Int) as Cell_Data
from
(
	select	
    rl.EvalMonth	
  	,cast(round(sum(cast(rl.LOS_Months as numeric(10,2))) / Count(rl.EvalMonth),0) as int) as Cell_Data
	from #Discharge_List rl
 	Group by
	rl.EvalMonth
) r
left join #DateList dl on r.EvalMonth = dl.EvalMonth


/*
	Average LOS Months
	Round (Sum of ALL LOS Months Grouped by Month   /   Discharges )
*/


insert into #Clinical_KPI_Results_Staging
select distinct
'YTD'
,cast(round(sum(cast(LOS_Months as numeric(10,2))) / Count(EvalMonth),0) as int) as Cell_Data
from #Discharge_List_YTD


/*
	Add Report Index and Row Description
*/

insert into #Clinical_KPI_Results_Staging select 'Report_Index', 'S0000'
insert into #Clinical_KPI_Results_Staging select 'Description', 'Average LOS of Discharges (Months)'

/*
	Add Comparison of Periods
*/

insert into #Clinical_KPI_Results_Staging select 'Period_1v2', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_1'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_2v3', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_3v4', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_4v5', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_5v6', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_6'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) as varchar(100))

insert into #Clinical_KPI_Results
SELECT 
0,'Header Info',*
FROM
 
(SELECT 
	Column_Index, Cell_Data	
FROM 
	#Clinical_KPI_Results_Staging
)
AS DataTable
PIVOT(
	Max(Cell_Data) 
FOR Column_Index IN ([Report_Index],[Description],[Period_1],[Period_2],[Period_1v2],[Period_3],[Period_2v3],[Period_4],[Period_3v4],[Period_5],[Period_4v5],[Period_6],[Period_5v6],[YTD]) 
) AS PivotTable


truncate table #Clinical_KPI_Results_Staging

/*
	Total Number of Discharges LOS < 90 Days

*/



insert into #Clinical_KPI_Results_Staging
select distinct dl.Column_Index,cast(r.Cell_Data as Int) as Cell_Data
from
(select	rl.EvalMonth ,Count(rl.EvalMonth) as Cell_Data
	from #Discharge_List rl
	where LOS_Days < 90
 	Group by
	rl.EvalMonth
) r

left join #DateList dl on r.EvalMonth = dl.EvalMonth

/*
	Total Number of Discharges LOS < 90 Days for YTD

*/

insert into #Clinical_KPI_Results_Staging
select distinct
'YTD'
,Count(EvalMonth) as Cell_Data
from #Discharge_List_YTD
	where LOS_Days < 90


/*
	Add Report Index and Row Description
*/

insert into #Clinical_KPI_Results_Staging select 'Report_Index', 'S0000'
insert into #Clinical_KPI_Results_Staging select 'Description', 'Discharges with LOS < 90 Days'

/*
	Add Comparison of Periods
*/

insert into #Clinical_KPI_Results_Staging select 'Period_1v2', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_1'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_2v3', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_3v4', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_4v5', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_5v6', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_6'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) as varchar(100))

insert into #Clinical_KPI_Results
SELECT +
0,'Header Info',*
FROM
 
(SELECT 
	Column_Index, Cell_Data	
FROM 
	#Clinical_KPI_Results_Staging
)
AS DataTable
PIVOT(
	Max(Cell_Data) 
FOR Column_Index IN ([Report_Index],[Description],[Period_1],[Period_2],[Period_1v2],[Period_3],[Period_2v3],[Period_4],[Period_3v4],[Period_5],[Period_4v5],[Period_6],[Period_5v6],[YTD]) 
) AS PivotTable


truncate table #Clinical_KPI_Results_Staging


/*
	Total Number of Death

*/



insert into #Clinical_KPI_Results_Staging
select distinct dl.Column_Index,cast(r.Cell_Data as Int) as Cell_Data
from
(select	rl.EvalMonth ,Count(rl.EvalMonth) as Cell_Data
	from #Discharge_List rl
	where MoveOut_Category = 'Death'
 	Group by
	rl.EvalMonth
) r

left join #DateList dl on r.EvalMonth = dl.EvalMonth

/*
	Total Number of Death for YTD

*/

insert into #Clinical_KPI_Results_Staging
select distinct
'YTD'
,Count(EvalMonth) as Cell_Data
from #Discharge_List_YTD
	where MoveOut_Category = 'Death'


/*
	Add Report Index and Row Description
*/

insert into #Clinical_KPI_Results_Staging select 'Report_Index', 'S0000'
insert into #Clinical_KPI_Results_Staging select 'Description', 'Discharges due to Death'

/*
	Add Comparison of Periods
*/

insert into #Clinical_KPI_Results_Staging select 'Period_1v2', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_1'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_2v3', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_3v4', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_4v5', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_5v6', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_6'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) as varchar(100))

insert into #Clinical_KPI_Results
SELECT +
0,'Header Info',*
FROM
 
(SELECT 
	Column_Index, Cell_Data	
FROM 
	#Clinical_KPI_Results_Staging
)
AS DataTable
PIVOT(
	Max(Cell_Data) 
FOR Column_Index IN ([Report_Index],[Description],[Period_1],[Period_2],[Period_1v2],[Period_3],[Period_2v3],[Period_4],[Period_3v4],[Period_5],[Period_4v5],[Period_6],[Period_5v6],[YTD]) 
) AS PivotTable


truncate table #Clinical_KPI_Results_Staging


/*
	Total Number of Higher Acuity

*/



insert into #Clinical_KPI_Results_Staging
select distinct dl.Column_Index,cast(r.Cell_Data as Int) as Cell_Data
from
(select	rl.EvalMonth ,Count(rl.EvalMonth) as Cell_Data
	from #Discharge_List rl
	where MoveOut_Category = 'Higher LOC'
 	Group by
	rl.EvalMonth
) r

left join #DateList dl on r.EvalMonth = dl.EvalMonth

/*
	Total Number of Higher for YTD

*/


insert into #Clinical_KPI_Results_Staging
select distinct
'YTD'
,Count(EvalMonth) as Cell_Data
from #Discharge_List_YTD
	where MoveOut_Category = 'Higher LOC'


/*
	Add Report Index and Row Description
*/

insert into #Clinical_KPI_Results_Staging select 'Report_Index', 'S0000'
insert into #Clinical_KPI_Results_Staging select 'Description', 'Discharges due to Higher Acuity'

/*
	Add Comparison of Periods
*/

insert into #Clinical_KPI_Results_Staging select 'Period_1v2', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_1'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_2v3', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_3v4', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_4v5', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_5v6', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_6'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) as varchar(100))

insert into #Clinical_KPI_Results
SELECT +
0,'Header Info',*
FROM
 
(SELECT 
	Column_Index, Cell_Data	
FROM 
	#Clinical_KPI_Results_Staging
)
AS DataTable
PIVOT(
	Max(Cell_Data) 
FOR Column_Index IN ([Report_Index],[Description],[Period_1],[Period_2],[Period_1v2],[Period_3],[Period_2v3],[Period_4],[Period_3v4],[Period_5],[Period_4v5],[Period_6],[Period_5v6],[YTD]) 
) AS PivotTable


truncate table #Clinical_KPI_Results_Staging


/*

/*
	Total Number of Financial Discharges

*/



insert into #Clinical_KPI_Results_Staging
select distinct dl.Column_Index,cast(r.Cell_Data as Int) as Cell_Data
from
(select	rl.EvalMonth ,Count(rl.EvalMonth) as Cell_Data
	from #Discharge_List rl
	where MoveOut_Category = 'Financial'
 	Group by
	rl.EvalMonth
) r

left join #DateList dl on r.EvalMonth = dl.EvalMonth

/*
	Total Number of Financial Discharges for YTD

*/


insert into #Clinical_KPI_Results_Staging
select distinct
'YTD'
,Count(EvalMonth) as Cell_Data
from #Discharge_List_YTD
	where MoveOut_Category = 'Financial'



/*
	Add Report Index and Row Description
*/

insert into #Clinical_KPI_Results_Staging select 'Report_Index', 'S0000'
insert into #Clinical_KPI_Results_Staging select 'Description', 'Discharges due to Financial'

/*
	Add Comparison of Periods
*/

insert into #Clinical_KPI_Results_Staging select 'Period_1v2', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_1'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_2v3', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_3v4', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_4v5', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_5v6', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_6'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) as varchar(100))

insert into #Clinical_KPI_Results
SELECT +
0,'Header Info',*
FROM
 
(SELECT 
	Column_Index, Cell_Data	
FROM 
	#Clinical_KPI_Results_Staging
)
AS DataTable
PIVOT(
	Max(Cell_Data) 
FOR Column_Index IN ([Report_Index],[Description],[Period_1],[Period_2],[Period_1v2],[Period_3],[Period_2v3],[Period_4],[Period_3v4],[Period_5],[Period_4v5],[Period_6],[Period_5v6],[YTD]) 
) AS PivotTable


truncate table #Clinical_KPI_Results_Staging

*/


/*

/*
	Total Number of End of Respite / Daycare Discharges

*/



insert into #Clinical_KPI_Results_Staging
select distinct dl.Column_Index,cast(r.Cell_Data as Int) as Cell_Data
from
(select	rl.EvalMonth ,Count(rl.EvalMonth) as Cell_Data
	from #Discharge_List rl
	where MoveOut_Category = 'End R-D'
 	Group by
	rl.EvalMonth
) r

left join #DateList dl on r.EvalMonth = dl.EvalMonth

/*
	Total Number of End of Respite / Daycare Discharges for YTD

*/


insert into #Clinical_KPI_Results_Staging
select distinct
'YTD'
,Count(EvalMonth) as Cell_Data
from #Discharge_List_YTD
	where MoveOut_Category = 'End R-D'


/*
	Add Report Index and Row Description
*/

insert into #Clinical_KPI_Results_Staging select 'Report_Index', 'S0000'
insert into #Clinical_KPI_Results_Staging select 'Description', 'Discharges due to End of Respite/Daycare'

/*
	Add Comparison of Periods
*/

insert into #Clinical_KPI_Results_Staging select 'Period_1v2', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_1'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_2v3', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_3v4', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_4v5', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_5v6', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_6'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) as varchar(100))

insert into #Clinical_KPI_Results
SELECT +
0,'Header Info',*
FROM
 
(SELECT 
	Column_Index, Cell_Data	
FROM 
	#Clinical_KPI_Results_Staging
)
AS DataTable
PIVOT(
	Max(Cell_Data) 
FOR Column_Index IN ([Report_Index],[Description],[Period_1],[Period_2],[Period_1v2],[Period_3],[Period_2v3],[Period_4],[Period_3v4],[Period_5],[Period_4v5],[Period_6],[Period_5v6],[YTD]) 
) AS PivotTable


truncate table #Clinical_KPI_Results_Staging

*/


/*
	Total Number of Dissatified Discharges

*/



insert into #Clinical_KPI_Results_Staging
select distinct dl.Column_Index,cast(r.Cell_Data as Int) as Cell_Data
from
(select	rl.EvalMonth ,Count(rl.EvalMonth) as Cell_Data
	from #Discharge_List rl
	where MoveOut_Category = 'Dissatisfied'
 	Group by
	rl.EvalMonth
) r

left join #DateList dl on r.EvalMonth = dl.EvalMonth

/*
	Total Number of Dissatified Discharges for YTD

*/


insert into #Clinical_KPI_Results_Staging
select distinct
'YTD'
,Count(EvalMonth) as Cell_Data
from #Discharge_List_YTD
	where MoveOut_Category = 'Dissatisfied'


/*
	Add Report Index and Row Description
*/

insert into #Clinical_KPI_Results_Staging select 'Report_Index', 'S0000'
insert into #Clinical_KPI_Results_Staging select 'Description', 'Discharges due to Dissatisfaction'

/*
	Add Comparison of Periods
*/

insert into #Clinical_KPI_Results_Staging select 'Period_1v2', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_1'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_2v3', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_3v4', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_4v5', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_5v6', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_6'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) as varchar(100))

insert into #Clinical_KPI_Results
SELECT +
0,'Header Info',*
FROM
 
(SELECT 
	Column_Index, Cell_Data	
FROM 
	#Clinical_KPI_Results_Staging
)
AS DataTable
PIVOT(
	Max(Cell_Data) 
FOR Column_Index IN ([Report_Index],[Description],[Period_1],[Period_2],[Period_1v2],[Period_3],[Period_2v3],[Period_4],[Period_3v4],[Period_5],[Period_4v5],[Period_6],[Period_5v6],[YTD]) 
) AS PivotTable


truncate table #Clinical_KPI_Results_Staging


/*
	Total Number of Eviction Discharges

*/



insert into #Clinical_KPI_Results_Staging
select distinct dl.Column_Index,cast(r.Cell_Data as Int) as Cell_Data
from
(select	rl.EvalMonth ,Count(rl.EvalMonth) as Cell_Data
	from #Discharge_List rl
	where MoveOut_Category = 'Evicted'
 	Group by
	rl.EvalMonth
) r

left join #DateList dl on r.EvalMonth = dl.EvalMonth

/*
	Total Number of Eviction Discharges for YTD

*/


insert into #Clinical_KPI_Results_Staging
select distinct
'YTD'
,Count(EvalMonth) as Cell_Data
from #Discharge_List_YTD
	where MoveOut_Category = 'Evicted'


/*
	Add Report Index and Row Description
*/

insert into #Clinical_KPI_Results_Staging select 'Report_Index', 'S0000'
insert into #Clinical_KPI_Results_Staging select 'Description', 'Discharges due to Eviction'

/*
	Add Comparison of Periods
*/

insert into #Clinical_KPI_Results_Staging select 'Period_1v2', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_1'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_2v3', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_3v4', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_4v5', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_5v6', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_6'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) as varchar(100))

insert into #Clinical_KPI_Results
SELECT +
0,'Header Info',*
FROM
 
(SELECT 
	Column_Index, Cell_Data	
FROM 
	#Clinical_KPI_Results_Staging
)
AS DataTable
PIVOT(
	Max(Cell_Data) 
FOR Column_Index IN ([Report_Index],[Description],[Period_1],[Period_2],[Period_1v2],[Period_3],[Period_2v3],[Period_4],[Period_3v4],[Period_5],[Period_4v5],[Period_6],[Period_5v6],[YTD]) 
) AS PivotTable


truncate table #Clinical_KPI_Results_Staging


/*

/*
	Total Number of Unknown / Other Discharges

*/



insert into #Clinical_KPI_Results_Staging
select distinct dl.Column_Index,cast(r.Cell_Data as Int) as Cell_Data
from
(select	rl.EvalMonth ,Count(rl.EvalMonth) as Cell_Data
	from #Discharge_List rl
	where MoveOut_Category = 'Other'
 	Group by
	rl.EvalMonth
) r

left join #DateList dl on r.EvalMonth = dl.EvalMonth

/*
	Total Number of Unknown / Other Discharges for YTD

*/


insert into #Clinical_KPI_Results_Staging
select distinct
'YTD'
,Count(EvalMonth) as Cell_Data
from #Discharge_List_YTD
	where MoveOut_Category = 'Other'


/*
	Add Report Index and Row Description
*/

insert into #Clinical_KPI_Results_Staging select 'Report_Index', 'S0000'
insert into #Clinical_KPI_Results_Staging select 'Description', 'Discharges due Unknown or Other Reasons'

/*
	Add Comparison of Periods
*/

insert into #Clinical_KPI_Results_Staging select 'Period_1v2', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_1'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_2v3', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_3v4', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_4v5', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_5v6', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_6'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) as varchar(100))

insert into #Clinical_KPI_Results
SELECT +
0,'Header Info',*
FROM
 
(SELECT 
	Column_Index, Cell_Data	
FROM 
	#Clinical_KPI_Results_Staging
)
AS DataTable
PIVOT(
	Max(Cell_Data) 
FOR Column_Index IN ([Report_Index],[Description],[Period_1],[Period_2],[Period_1v2],[Period_3],[Period_2v3],[Period_4],[Period_3v4],[Period_5],[Period_4v5],[Period_6],[Period_5v6],[YTD]) 
) AS PivotTable


truncate table #Clinical_KPI_Results_Staging

*/

/*

	Populate a Temp Table with Incidents each day of Prior 6 Months

*/

select  
	d.EvalDate
	,LEFT(CONVERT(varchar, d.EvalDate,112),6) EvalMonth
  	,P.hmy PropertyID
	,ltrim(rtrim(P.sAddr1)) as Community
	,case 
		when ltrim(rtrim(P.sAddr1)) like '%Lantern%' then replace(ltrim(rtrim(P.sAddr1)),'The Lantern at Morning Pointe of ','') + ' ' +'Lantern'
		else replace(ltrim(rtrim(P.sAddr1)),'Morning Pointe of ','') 
	end as Community_Abbr
	,ltrim(rtrim(p.scode)) as Community_Code
	,convert(date,dtIncidentDate) as Incident_Date
	,i.hProperty as hProp
	,i.sIncidentType as Incident_Type
	,l1.ListoptionName as Incident_Description
	,i.sIncidentTitle as Incident
into #Incident_List	
from  #DateList d
left join property P  on 1=1
left join seniorincident i on p.hMy = i.hProperty
left join LIstoption l1 ON l1.ListOptionCode = i.sIncidentType AND  l1.listname = 'IncidentTypeResident' 
Where  p.hmy in (select a.hProp from @EvalProperties a)
and convert(date,i.dtIncidentDate)= d.EvalDate
AND i.bActive = 1 AND i.sIncidentCategory = 'RES'



/*

	Populate a Temp Table with Incidents each day of YTD

*/

/* to save processing time, insert any records from existing Discharge List */

select 
*
into #Incident_List_YTD
from #Incident_List
where EvalDate in (select EvalDate from #DateList_YTD)


/* insert any records NOT in existing Discharge List */

insert into #Incident_List_YTD
select  
	d.EvalDate
	,LEFT(CONVERT(varchar, d.EvalDate,112),6) EvalMonth
  	,P.hmy PropertyID
	,ltrim(rtrim(P.sAddr1)) as Community
	,case 
		when ltrim(rtrim(P.sAddr1)) like '%Lantern%' then replace(ltrim(rtrim(P.sAddr1)),'The Lantern at Morning Pointe of ','') + ' ' +'Lantern'
		else replace(ltrim(rtrim(P.sAddr1)),'Morning Pointe of ','') 
	end as Community_Abbr
	,ltrim(rtrim(p.scode)) as Community_Code
	,convert(date,dtIncidentDate) as Incident_Date
	,i.hProperty as hProp
	,i.sIncidentType as Incident_Type
	,l1.ListoptionName as Incident_Description
	,i.sIncidentTitle as Incident

from  #DateList_YTD d
left join property P  on 1=1
left join seniorincident i on p.hMy = i.hProperty
left join LIstoption l1 ON l1.ListOptionCode = i.sIncidentType AND  l1.listname = 'IncidentTypeResident' 
Where  p.hmy in (select a.hProp from @EvalProperties a)
and d.EvalDate not in (select EvalDate from #DateList)
and convert(date,i.dtIncidentDate)= d.EvalDate
AND i.bActive = 1 AND i.sIncidentCategory = 'RES'




/*
	Total Number of Incidents

*/



insert into #Clinical_KPI_Results_Staging
select distinct dl.Column_Index,cast(r.Cell_Data as Int) as Cell_Data
from
(select	rl.EvalMonth ,Count(rl.EvalMonth) as Cell_Data
	from #Incident_List rl
 	Group by
	rl.EvalMonth
) r

left join #DateList dl on r.EvalMonth = dl.EvalMonth


/*
	Total Number of Incidents for YTD
*/


insert into #Clinical_KPI_Results_Staging
select distinct
'YTD'
,Count(EvalMonth) as Cell_Data
from #Incident_List_YTD


/*
	Add Report Index and Row Description
*/

insert into #Clinical_KPI_Results_Staging select 'Report_Index', 'S0000'
insert into #Clinical_KPI_Results_Staging select 'Description', 'Total Incidents'

/*
	Add Comparison of Periods
*/

insert into #Clinical_KPI_Results_Staging select 'Period_1v2', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_1'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_2v3', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_3v4', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_4v5', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_5v6', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_6'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) as varchar(100))

insert into #Clinical_KPI_Results
SELECT +
0,'Header Info',*
FROM
 
(SELECT 
	Column_Index, Cell_Data	
FROM 
	#Clinical_KPI_Results_Staging
)
AS DataTable
PIVOT(
	Max(Cell_Data) 
FOR Column_Index IN ([Report_Index],[Description],[Period_1],[Period_2],[Period_1v2],[Period_3],[Period_2v3],[Period_4],[Period_3v4],[Period_5],[Period_4v5],[Period_6],[Period_5v6],[YTD]) 
) AS PivotTable


truncate table #Clinical_KPI_Results_Staging

/*
	Total Number of Abuse Incidents

*/



insert into #Clinical_KPI_Results_Staging
select distinct dl.Column_Index,cast(r.Cell_Data as Int) as Cell_Data
from
(select	rl.EvalMonth ,Count(rl.EvalMonth) as Cell_Data
	from #Incident_List rl
	where Incident_Type = 'TEA'
 	Group by
	rl.EvalMonth
) r

left join #DateList dl on r.EvalMonth = dl.EvalMonth

/*
	Total Number of Abuse Incidents for YTD
*/


insert into #Clinical_KPI_Results_Staging
select distinct
'YTD'
,Count(EvalMonth) as Cell_Data
from #Incident_List_YTD
where Incident_Type = 'TEA'

/*
	Add Report Index and Row Description
*/

insert into #Clinical_KPI_Results_Staging select 'Report_Index', 'S0000'
insert into #Clinical_KPI_Results_Staging select 'Description', 'Total Abuse Incidents'

/*
	Add Comparison of Periods
*/

insert into #Clinical_KPI_Results_Staging select 'Period_1v2', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_1'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_2v3', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_3v4', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_4v5', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_5v6', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_6'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) as varchar(100))

insert into #Clinical_KPI_Results
SELECT +
0,'Header Info',*
FROM
 
(SELECT 
	Column_Index, Cell_Data	
FROM 
	#Clinical_KPI_Results_Staging
)
AS DataTable
PIVOT(
	Max(Cell_Data) 
FOR Column_Index IN ([Report_Index],[Description],[Period_1],[Period_2],[Period_1v2],[Period_3],[Period_2v3],[Period_4],[Period_3v4],[Period_5],[Period_4v5],[Period_6],[Period_5v6],[YTD]) 
) AS PivotTable


truncate table #Clinical_KPI_Results_Staging




/*
	Total Number of Behavior Incidents

*/



insert into #Clinical_KPI_Results_Staging
select distinct dl.Column_Index,cast(r.Cell_Data as Int) as Cell_Data
from
(select	rl.EvalMonth ,Count(rl.EvalMonth) as Cell_Data
	from #Incident_List rl
	where Incident_Type = 'AUB'
 	Group by
	rl.EvalMonth
) r

left join #DateList dl on r.EvalMonth = dl.EvalMonth

/*
	Total Number of Behavior Incidents for YTD
*/


insert into #Clinical_KPI_Results_Staging
select distinct
'YTD'
,Count(EvalMonth) as Cell_Data
from #Incident_List_YTD
where Incident_Type = 'AUB'


/*
	Add Report Index and Row Description
*/

insert into #Clinical_KPI_Results_Staging select 'Report_Index', 'S0000'
insert into #Clinical_KPI_Results_Staging select 'Description', 'Total Behavior Incidents'

/*
	Add Comparison of Periods
*/

insert into #Clinical_KPI_Results_Staging select 'Period_1v2', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_1'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_2v3', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_3v4', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_4v5', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_5v6', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_6'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) as varchar(100))

insert into #Clinical_KPI_Results
SELECT +
0,'Header Info',*
FROM
 
(SELECT 
	Column_Index, Cell_Data	
FROM 
	#Clinical_KPI_Results_Staging
)
AS DataTable
PIVOT(
	Max(Cell_Data) 
FOR Column_Index IN ([Report_Index],[Description],[Period_1],[Period_2],[Period_1v2],[Period_3],[Period_2v3],[Period_4],[Period_3v4],[Period_5],[Period_4v5],[Period_6],[Period_5v6],[YTD]) 
) AS PivotTable


truncate table #Clinical_KPI_Results_Staging


/*
	Total Number of Death Incidents

*/



insert into #Clinical_KPI_Results_Staging
select distinct dl.Column_Index,cast(r.Cell_Data as Int) as Cell_Data
from
(select	rl.EvalMonth ,Count(rl.EvalMonth) as Cell_Data
	from #Incident_List rl
	where Incident_Type = 'TDU'
 	Group by
	rl.EvalMonth
) r

left join #DateList dl on r.EvalMonth = dl.EvalMonth

/*
	Total Number of Death Incidents for YTD
*/


insert into #Clinical_KPI_Results_Staging
select distinct
'YTD'
,Count(EvalMonth) as Cell_Data
from #Incident_List_YTD
where Incident_Type = 'TDU'


/*
	Add Report Index and Row Description
*/

insert into #Clinical_KPI_Results_Staging select 'Report_Index', 'S0000'
insert into #Clinical_KPI_Results_Staging select 'Description', 'Total Death Incidents'

/*
	Add Comparison of Periods
*/

insert into #Clinical_KPI_Results_Staging select 'Period_1v2', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_1'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_2v3', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_3v4', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_4v5', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_5v6', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_6'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) as varchar(100))

insert into #Clinical_KPI_Results
SELECT +
0,'Header Info',*
FROM
 
(SELECT 
	Column_Index, Cell_Data	
FROM 
	#Clinical_KPI_Results_Staging
)
AS DataTable
PIVOT(
	Max(Cell_Data) 
FOR Column_Index IN ([Report_Index],[Description],[Period_1],[Period_2],[Period_1v2],[Period_3],[Period_2v3],[Period_4],[Period_3v4],[Period_5],[Period_4v5],[Period_6],[Period_5v6],[YTD]) 
) AS PivotTable


truncate table #Clinical_KPI_Results_Staging


/*
	Total Number of Elopement Incidents

*/



insert into #Clinical_KPI_Results_Staging
select distinct dl.Column_Index,cast(r.Cell_Data as Int) as Cell_Data
from
(select	rl.EvalMonth ,Count(rl.EvalMonth) as Cell_Data
	from #Incident_List rl
	where Incident_Type = 'WDR'
 	Group by
	rl.EvalMonth
) r

left join #DateList dl on r.EvalMonth = dl.EvalMonth

/*
	Total Number of Elopement Incidents for YTD
*/


insert into #Clinical_KPI_Results_Staging
select distinct
'YTD'
,Count(EvalMonth) as Cell_Data
from #Incident_List_YTD
where Incident_Type = 'WDR'


/*
	Add Report Index and Row Description
*/

insert into #Clinical_KPI_Results_Staging select 'Report_Index', 'S0000'
insert into #Clinical_KPI_Results_Staging select 'Description', 'Total Elopement Incidents'

/*
	Add Comparison of Periods
*/

insert into #Clinical_KPI_Results_Staging select 'Period_1v2', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_1'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_2v3', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_3v4', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_4v5', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_5v6', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_6'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) as varchar(100))

insert into #Clinical_KPI_Results
SELECT +
0,'Header Info',*
FROM
 
(SELECT 
	Column_Index, Cell_Data	
FROM 
	#Clinical_KPI_Results_Staging
)
AS DataTable
PIVOT(
	Max(Cell_Data) 
FOR Column_Index IN ([Report_Index],[Description],[Period_1],[Period_2],[Period_1v2],[Period_3],[Period_2v3],[Period_4],[Period_3v4],[Period_5],[Period_4v5],[Period_6],[Period_5v6],[YTD]) 
) AS PivotTable


truncate table #Clinical_KPI_Results_Staging


/*
	Total Number of Fall Incidents

*/



insert into #Clinical_KPI_Results_Staging
select distinct dl.Column_Index,cast(r.Cell_Data as Int) as Cell_Data
from
(select	rl.EvalMonth ,Count(rl.EvalMonth) as Cell_Data
	from #Incident_List rl
	where Incident_Type = 'FAL'
 	Group by
	rl.EvalMonth
) r

left join #DateList dl on r.EvalMonth = dl.EvalMonth

/*
	Total Number of Fall Incidents for YTD
*/


insert into #Clinical_KPI_Results_Staging
select distinct
'YTD'
,Count(EvalMonth) as Cell_Data
from #Incident_List_YTD
where Incident_Type = 'FAL'

/*
	Add Report Index and Row Description
*/

insert into #Clinical_KPI_Results_Staging select 'Report_Index', 'S0000'
insert into #Clinical_KPI_Results_Staging select 'Description', 'Total Fall Incidents'

/*
	Add Comparison of Periods
*/

insert into #Clinical_KPI_Results_Staging select 'Period_1v2', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_1'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_2v3', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_3v4', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_4v5', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_5v6', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_6'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) as varchar(100))

insert into #Clinical_KPI_Results
SELECT +
0,'Header Info',*
FROM
 
(SELECT 
	Column_Index, Cell_Data	
FROM 
	#Clinical_KPI_Results_Staging
)
AS DataTable
PIVOT(
	Max(Cell_Data) 
FOR Column_Index IN ([Report_Index],[Description],[Period_1],[Period_2],[Period_1v2],[Period_3],[Period_2v3],[Period_4],[Period_3v4],[Period_5],[Period_4v5],[Period_6],[Period_5v6],[YTD]) 
) AS PivotTable


truncate table #Clinical_KPI_Results_Staging


/*
	Total Number of Injury Incidents

*/



insert into #Clinical_KPI_Results_Staging
select distinct dl.Column_Index,cast(r.Cell_Data as Int) as Cell_Data
from
(select	rl.EvalMonth ,Count(rl.EvalMonth) as Cell_Data
	from #Incident_List rl
	where Incident_Type = 'OIJ'
 	Group by
	rl.EvalMonth
) r

left join #DateList dl on r.EvalMonth = dl.EvalMonth

/*
	Total Number of Injury Incidents for YTD
*/


insert into #Clinical_KPI_Results_Staging
select distinct
'YTD'
,Count(EvalMonth) as Cell_Data
from #Incident_List_YTD
where Incident_Type = 'OIJ'

/*
	Add Report Index and Row Description
*/

insert into #Clinical_KPI_Results_Staging select 'Report_Index', 'S0000'
insert into #Clinical_KPI_Results_Staging select 'Description', 'Total Injury Incidents'

/*
	Add Comparison of Periods
*/

insert into #Clinical_KPI_Results_Staging select 'Period_1v2', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_1'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_2v3', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_3v4', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_4v5', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_5v6', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_6'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) as varchar(100))

insert into #Clinical_KPI_Results
SELECT +
0,'Header Info',*
FROM
 
(SELECT 
	Column_Index, Cell_Data	
FROM 
	#Clinical_KPI_Results_Staging
)
AS DataTable
PIVOT(
	Max(Cell_Data) 
FOR Column_Index IN ([Report_Index],[Description],[Period_1],[Period_2],[Period_1v2],[Period_3],[Period_2v3],[Period_4],[Period_3v4],[Period_5],[Period_4v5],[Period_6],[Period_5v6],[YTD]) 
) AS PivotTable


truncate table #Clinical_KPI_Results_Staging


/*
	Total Number of Medication Error Incidents

*/



insert into #Clinical_KPI_Results_Staging
select distinct dl.Column_Index,cast(r.Cell_Data as Int) as Cell_Data
from
(select	rl.EvalMonth ,Count(rl.EvalMonth) as Cell_Data
	from #Incident_List rl
	where Incident_Type = 'TME'
 	Group by
	rl.EvalMonth
) r

left join #DateList dl on r.EvalMonth = dl.EvalMonth

/*
	Total Number of Medication Error Incidents for YTD
*/


insert into #Clinical_KPI_Results_Staging
select distinct
'YTD'
,Count(EvalMonth) as Cell_Data
from #Incident_List_YTD
where Incident_Type = 'TME'

/*
	Add Report Index and Row Description
*/

insert into #Clinical_KPI_Results_Staging select 'Report_Index', 'S0000'
insert into #Clinical_KPI_Results_Staging select 'Description', 'Total Medication Error Incidents'

/*
	Add Comparison of Periods
*/

insert into #Clinical_KPI_Results_Staging select 'Period_1v2', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_1'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_2v3', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_3v4', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_4v5', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_5v6', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_6'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) as varchar(100))

insert into #Clinical_KPI_Results
SELECT +
0,'Header Info',*
FROM
 
(SELECT 
	Column_Index, Cell_Data	
FROM 
	#Clinical_KPI_Results_Staging
)
AS DataTable
PIVOT(
	Max(Cell_Data) 
FOR Column_Index IN ([Report_Index],[Description],[Period_1],[Period_2],[Period_1v2],[Period_3],[Period_2v3],[Period_4],[Period_3v4],[Period_5],[Period_4v5],[Period_6],[Period_5v6],[YTD]) 
) AS PivotTable


truncate table #Clinical_KPI_Results_Staging

/*

/*
	Total Number of Missing/Wandering Incidents

*/



insert into #Clinical_KPI_Results_Staging
select distinct dl.Column_Index,cast(r.Cell_Data as Int) as Cell_Data
from
(select	rl.EvalMonth ,Count(rl.EvalMonth) as Cell_Data
	from #Incident_List rl
	where Incident_Type = 'TMW'
 	Group by
	rl.EvalMonth
) r

left join #DateList dl on r.EvalMonth = dl.EvalMonth

/*
	Total Number of Missing/Wandering Incidents for YTD
*/


insert into #Clinical_KPI_Results_Staging
select distinct
'YTD'
,Count(EvalMonth) as Cell_Data
from #Incident_List_YTD
where Incident_Type = 'TMW'

/*
	Add Report Index and Row Description
*/

insert into #Clinical_KPI_Results_Staging select 'Report_Index', 'S0000'
insert into #Clinical_KPI_Results_Staging select 'Description', 'Total Missing/Wandering Incidents'

/*
	Add Comparison of Periods
*/

insert into #Clinical_KPI_Results_Staging select 'Period_1v2', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_1'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_2v3', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_3v4', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_4v5', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_5v6', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_6'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) as varchar(100))

insert into #Clinical_KPI_Results
SELECT +
0,'Header Info',*
FROM
 
(SELECT 
	Column_Index, Cell_Data	
FROM 
	#Clinical_KPI_Results_Staging
)
AS DataTable
PIVOT(
	Max(Cell_Data) 
FOR Column_Index IN ([Report_Index],[Description],[Period_1],[Period_2],[Period_1v2],[Period_3],[Period_2v3],[Period_4],[Period_3v4],[Period_5],[Period_4v5],[Period_6],[Period_5v6],[YTD]) 
) AS PivotTable


truncate table #Clinical_KPI_Results_Staging

*/


/*
	Total Number of ALL Other Incidents

*/



insert into #Clinical_KPI_Results_Staging
select distinct dl.Column_Index,cast(r.Cell_Data as Int) as Cell_Data
from
(select	rl.EvalMonth ,Count(rl.EvalMonth) as Cell_Data
	from #Incident_List rl
	where Incident_Type not in ('TEA','AUB','TDU','WDR','FAL','OIJ','TME','TMW')
 	Group by
	rl.EvalMonth
) r

left join #DateList dl on r.EvalMonth = dl.EvalMonth

/*
	Total Number of ALL Other Incidents for YTD
*/


insert into #Clinical_KPI_Results_Staging
select distinct
'YTD'
,Count(EvalMonth) as Cell_Data
from #Incident_List_YTD
where Incident_Type not in ('TEA','AUB','TDU','WDR','FAL','OIJ','TME','TMW')


/*
	Add Report Index and Row Description
*/

insert into #Clinical_KPI_Results_Staging select 'Report_Index', 'S0000'
insert into #Clinical_KPI_Results_Staging select 'Description', 'Total All Other Incidents'

/*
	Add Comparison of Periods
*/

insert into #Clinical_KPI_Results_Staging select 'Period_1v2', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_1'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_2v3', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_3v4', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_4v5', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_5v6', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_6'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) as varchar(100))

insert into #Clinical_KPI_Results
SELECT +
0,'Header Info',*
FROM
 
(SELECT 
	Column_Index, Cell_Data	
FROM 
	#Clinical_KPI_Results_Staging
)
AS DataTable
PIVOT(
	Max(Cell_Data) 
FOR Column_Index IN ([Report_Index],[Description],[Period_1],[Period_2],[Period_1v2],[Period_3],[Period_2v3],[Period_4],[Period_3v4],[Period_5],[Period_4v5],[Period_6],[Period_5v6],[YTD]) 
) AS PivotTable


truncate table #Clinical_KPI_Results_Staging



/*   Assessments for Period  */


SELECT  distinct
	p.hmy												AS PropId,
	ltrim(rtrim(isnull(p.saddr1, ''))) 
	+ ' (' + ltrim(rtrim(p.scode)) + ')' 								AS PropName	   ,
	ltrim(rtrim(t.sLastName)) + ', ' 
	+ ltrim(rtrim(t.sFirstName)) + ' (' 
	+ ltrim(rtrim(t.scode)) + ')' 									AS Resident	   ,
	srs.Status											AS Status	   ,
    t.DTMoveIn											as MoveInDate,
    t.DTMoveOut											as MoveOutDate,   
 	alz.ALZEntryDate   ,	
	u.hmy												AS UnitId	   ,
	u.sCode												AS Unit		   ,
	ut.sDesc											AS UnitType	   ,
	l1.ListOptionName 										AS PrivacyLevel    ,
    ard.ActiveFlag,
    ast.AssessmentClass										AS AssessmentClass  ,
	ast.AssessmentTypeName										AS AssessmentType  ,
	a.AssessmentDate			AS AssessmentDate  ,
	ard.NextReviewDate			AS NextReviewDate  ,	
	isnull(a.AssessmentCompleteFlag,0) as AssessmentCompleteFlag,
    LEFT(CONVERT(varchar, ard.NextReviewDate,112),6) AssessmentMonth,
	l.ListOptionName 										AS AssessmentReason,
	cast(a.AssessmentComment as varchar(max))				AS AssessmentNote  ,
	a.iPersonType  											AS PersonType      ,
        t.hmyperson    											AS ResidentId      ,
	a.AssessmentId 											AS AssessmentId    ,
	CASE
                WHEN a.hProspect = 0
                THEN a.ResidentId
                ELSE a.hProspect
        END 												AS ProspectId
       
into #Assessment_List
   from property p
	inner join  tenant t on t.hproperty=p.hmy 
	inner JOIN SeniorResidentStatus srs 	ON srs.iStatus			= t.iStatus    
	INNER JOIN Unit 		u 	ON u.hmy 			= t.hunit
	INNER JOIN UnitType 		ut	ON ut.hmy 			= u.hUnitType    
	inner join seniorresident sr on sr.residentid = t.hmyperson 
	inner join SeniorAssessmentReviewDate ard on ard.residentid =sr.residentid 
      		AND CONVERT(CHAR(10),CONVERT(DATETIME,LEFT(CONVERT(VARCHAR(20),ard.NextReviewDate,121),10),101),101)
			BETWEEN (select dateadd(mm,-6,Min(EvalDate)) from #DateList)  AND (select Max(EvalDate) from #DateList)
	inner join AssessmentType ast ON (ard.AssessmentTypeID = ast.AssessmentTypeID)
	left JOIN Assessment a ON (a.assessmentid = ard.assessmentid AND a.AssessmentActiveFlag	= 1) 
	left join serviceinstance si on si.ResidentID = t.hMyPerson and si.ServiceInstanceActiveFlag = 1 
	left join  Service s on  si.ServiceID     = s.ServiceID   and  ServiceClassID = 1  
	left join serviceclass scl on scl.serviceclassid=s.ServiceClassID  and scl.ServiceClassID = 1  and ServiceClassActiveFlag = 1
	LEFT  JOIN ListOption 		l  	ON a.AssessmentreasonCode 	= l.ListOptionCode and listname='Assessmentreason'
	LEFT  JOIN ListOption 		l1 	ON sr.PrivacyLevelCode 		= l1.ListOptionCode AND L1.ListName = 'PrivacyLevel'    
    left join (select ResidentID,min(serviceinstancefromdate) as ALZEntryDate 
               from serviceinstance 
               where
               CONVERT(CHAR(10),CONVERT(DATETIME,LEFT(CONVERT(VARCHAR(20),ServiceInstanceFromDate,121),10),101),101)
				BETWEEN (select dateadd(mm,-6,Min(EvalDate)) from #DateList)  AND (select Max(EvalDate) from #DateList)
               and CareLevelCode = 'ALZ'
               group by ResidentID
              ) alz on  alz.residentid = t.hmyperson	
WHERE   

	1 = 1
	AND t.iStatus <> 6 /* Not Prospect */
	and p.hmy in (select a.hProp from @EvalProperties a) 

ORDER BY 
	ResidentId,
	AssessmentId

    




/*Get the Scores of Type Elopement Assessments during period */
SELECT  
	a.AssessmentId				AS AssessmentId,
        LEFT(CONVERT(varchar, pr.AssessmentDate,112),6) AssessmentMonth,
        pr.AssessmentDate as AssessmentCompleteDate,
        SUM(CASE WHEN ai.datatypecode <> 'MLT' 
		 THEN isnull(ail.AssessmentItemListScore,0) 
		 ELSE c.AssessmentItemListScore 
	    END ) 				AS Score,
        t.hproperty 				AS hProp,  
        t.hmyperson 				AS ResidentId,
        pr.Resident,
        pr.MoveOutDate,
        pr.ALZEntryDate		
        
INTO    #Assessment_Score
FROM    
	Tenant t  
        INNER JOIN Assessment a                	ON (a.residentId           = t.hmyperson )
		INNER JOIN #Assessment_List pr 										ON pr.assessmentid 	   		 = a.assessmentid  
        INNER JOIN Assessmenttype a_t           ON (a_t.assessmenttypeid   = a.assessmenttypeid)  
        INNER JOIN Assessmenttypesection ats    ON ats.assessmenttypeid    = a.assessmenttypeid  
        INNER JOIN Assessmentsection a_s        ON a_s.AssessmentSectionId = ats.AssessmentSectionId  
        INNER JOIN Assessmentsectionresult asr 	ON asr.assessmentsectionid = a_s.assessmentsectionId AND asr.assessmentId = a.assessmentid  
        INNER JOIN AssessmentItem ai           	ON ai.AssessmentSectionId  = a_s.AssessmentSectionId AND ai.AssessmentItemActiveFlag <> 0  
        INNER JOIN AssessmentResult ar         	ON ar.assessmentid         = a.assessmentid AND ai.assessmentitemid = ar.assessmentitemid  
        LEFT  JOIN   /* Additional Assissment Information */
        (
          SELECT pr.AssessmentID,ail.*  
			FROM    assessmentresult ar  
			INNER JOIN #Assessment_List pr		ON pr.AssessmentId	= ar.AssessmentId
		 	INNER JOIN assessmentitemlist ail ON ail.assessmentitemid = ar.assessmentitemid  
			INNER JOIN  
				(
				SELECT 	assessmentresultvalue val , ai.assessmentitemid aid ,ar.AssessmentId AS AssessmentID
					FROM    assessmentresult ar  
					INNER JOIN assessmentitem ai 	ON ai.assessmentitemid 	= ar.assessmentitemid  
					INNER JOIN #Assessment_List pr		ON pr.AssessmentId	= ar.AssessmentId
					WHERE   ai.datatypecode                                 	= 'MLT'  
			)x ON x.aid = ail.assessmentitemid AND x.AssessmentID = pr.AssessmentID 

			WHERE patindex('%,' + ail.assessmentitemlistvalue + ',%' , ','+x.val+',' ) > 0 
          )    c                   ON c.assessmentitemid      = ai.assessmentitemid AND c.assessmentid = pr.assessmentid 
        LEFT  JOIN paramopt2 po                	ON po.sType                ='SeniorIncludeOutsideService'  
        LEFT  JOIN paramopt2 po1               	ON po1.sType               ='SeniorSharedResponsibilityAllowOverride'  
        LEFT  JOIN paramopt2 po2               	ON po2.sType               ='SeniorSharedResponsibilityPercentage'  
        INNER JOIN AssessmentItemList ail      	ON (ar.AssessmentItemID   = ail.AssessmentItemID AND ltrim(RTRIM(ail.AssessmentItemListValue)) = CASE WHEN ai.datatypecode <> 'MLT' THEN ltrim(RTRIM(ar.AssessmentResultValue)) ELSE ltrim(RTRIM(c.AssessmentItemListValue)) END 
        																						AND ail.AssessmentItemId = ai.AssessmentItemId)  
 WHERE  
 	1 =1  
	AND ats.AssessmentTypeId = (SELECT assessmenttypeid FROM assessment a WHERE a.assessmentid=pr.assessmentid)  
    and a.AssessmentCompleteFlag = 1 /* Completed Assessments' */
    and a_t.AssessmentClass	= 'ELP'
	AND a.assessmentid=pr.assessmentid  
GROUP BY 
	a.AssessmentId,
    LEFT(CONVERT(varchar, pr.NextReviewDate,112),6),
    pr.AssessmentDate,
    t.hproperty,  
    t.hmyperson,
    pr.Resident,
    pr.MoveOutDate,
	pr.ALZEntryDate	



/*
	Total Number of Elopement Assessments for Period scored >= 10

*/




insert into #Clinical_KPI_Results_Staging
select dl1.Column_Index,cast(count(r2.score) as Int) as Cell_Data
from (select distinct Column_Index, EvalMonth from #DateList) dl1
left join 
(select  r1.*, r2.score

		from (select 
			dl.Column_Index, dl.EvalMonth
			,hprop
			,ResidentID
			,Resident
			,Max(AssessmentCompleteDate) as MaxAssessmentDate 
            ,Max(MoveOutDate) as MaxMoveOutDate
		from (select distinct Column_Index, EvalMonth from #DateList) dl 
     	left join #Assessment_Score r 
        	on dl.EvalMonth <= LEFT(CONVERT(varchar, isnull(r.MoveOutDate,'12/31/9999'),112),6)  /* Dischage after Period */
            and dl.EvalMonth <= LEFT(CONVERT(varchar, isnull(r.ALZEntryDate,'12/31/9999'),112),6)  /* ALZ Entry after Period */			
        	and r.AssessmentMonth <= dl.EvalMonth
		group by 
        	dl.Column_Index,dl.EvalMonth
			,hprop
			,ResidentID
			,Resident 
        ) r1  
        left join #Assessment_Score r2 on r1.residentID = r2.ResidentID and r1.MaxAssessmentDate = r2.AssessmentCompleteDate and r2.score >= 10
) r2 on dl1.Column_Index = r2.Column_Index and r2.score is not null
left join property p on r2.hprop = p.hMy
group by dl1.Column_Index

/*
 Validation Script
 
 select dl1.*, r2.hprop, p.sAddr1, r2.ResidentID, r2.Resident, r2.MaxAssessmentDate as AssessmentCompleteDT, r2.MaxALZEntryDate as AlzEntryDate, r2.Score,  r2.MaxMoveOutDate as MoveOutDate
from (select distinct Column_Index, EvalMonth from #DateList) dl1
left join 
(select  r1.*, r2.score

		from (select 
			dl.Column_Index, dl.EvalMonth
			,hprop
			,ResidentID
			,Resident
			,Max(AssessmentCompleteDate) as MaxAssessmentDate 
            ,Max(MoveOutDate) as MaxMoveOutDate
            ,max(ALZEntryDate) as MaxALZEntryDate
		from (select distinct Column_Index, EvalMonth from #DateList) dl 
     	left join #Assessment_Score r 
        	on dl.EvalMonth <= LEFT(CONVERT(varchar, isnull(r.MoveOutDate,'12/31/9999'),112),6)  /* Dischage after Period */
            and dl.EvalMonth <= LEFT(CONVERT(varchar, isnull(r.ALZEntryDate,'12/31/9999'),112),6)  /* ALZ Entry after Period */
        	and r.AssessmentMonth <= dl.EvalMonth
		group by 
        	dl.Column_Index,dl.EvalMonth
			,hprop
			,ResidentID
			,Resident 
        ) r1  
        left join #Assessment_Score r2 on r1.residentID = r2.ResidentID and r1.MaxAssessmentDate = r2.AssessmentCompleteDate and r2.score >= 10
) r2 on dl1.Column_Index = r2.Column_Index and r2.score is not null
left join property p on r2.hprop = p.hMy
order by dl1.Column_Index,r2.Resident


*/



/*

Replaced 2019-10-07

select distinct dl.Column_Index,cast(r.Cell_Data as Int) as Cell_Data
from
(select	rl.AssessmentMonth ,Count(rl.AssessmentMonth) as Cell_Data
	from #Assessment_Score rl
	where rl.Score >= 10
 	Group by
	rl.AssessmentMonth
) r

left join #DateList dl on r.AssessmentMonth = dl.EvalMonth

*/


/*
	Add Report Index and Row Description
*/

insert into #Clinical_KPI_Results_Staging select 'Report_Index', 'S0000'
insert into #Clinical_KPI_Results_Staging select 'Description', 'Total Elopement Scored >= 10'

/*
	Add Comparison of Periods
*/

insert into #Clinical_KPI_Results_Staging select 'Period_1v2', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_1'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_2v3', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_3v4', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_4v5', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_5v6', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_6'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) as varchar(100))

insert into #Clinical_KPI_Results
SELECT +
0,'Header Info',*
FROM
 
(SELECT 
	Column_Index, Cell_Data	
FROM 
	#Clinical_KPI_Results_Staging
)
AS DataTable
PIVOT(
	Max(Cell_Data) 
FOR Column_Index IN ([Report_Index],[Description],[Period_1],[Period_2],[Period_1v2],[Period_3],[Period_2v3],[Period_4],[Period_3v4],[Period_5],[Period_4v5],[Period_6],[Period_5v6],[YTD]) 
) AS PivotTable


truncate table #Clinical_KPI_Results_Staging



/*
	Total Number of Past Due Lantern Assessments for Period

*/


insert into #Clinical_KPI_Results_Staging
select distinct dl.Column_Index,cast(r.Cell_Data as Int) as Cell_Data
from
(select	
rl.AssessmentMonth 
/*,rl.AssessmentCompleteFlag
,rl.AssessmentClass
,rl.AssessmentType
*/
,Count(rl.AssessmentMonth) as Cell_Data
	from #Assessment_List rl
	where    
    rl.AssessmentCompleteFlag = 0 /* Completed Assessments' */
    and rl.AssessmentType like '%Lantern%'
	and rl.Status in ('Current')	
	and rl.ActiveFlag = 1
 	Group by
	rl.AssessmentMonth
    /* ,rl.AssessmentCompleteFlag,rl.AssessmentClass,rl.AssessmentType */
) r

left join #DateList dl on r.AssessmentMonth = dl.EvalMonth

/*
	Add Report Index and Row Description
*/

insert into #Clinical_KPI_Results_Staging select 'Report_Index', 'S0000'
insert into #Clinical_KPI_Results_Staging select 'Description', 'Total Past Due Lantern Assessments'

/*
	Add Comparison of Periods
*/

insert into #Clinical_KPI_Results_Staging select 'Period_1v2', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_1'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_2v3', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_3v4', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_4v5', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_5v6', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_6'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) as varchar(100))

insert into #Clinical_KPI_Results
SELECT +
0,'Header Info',*
FROM
 
(SELECT 
	Column_Index, Cell_Data	
FROM 
	#Clinical_KPI_Results_Staging
)
AS DataTable
PIVOT(
	Max(Cell_Data) 
FOR Column_Index IN ([Report_Index],[Description],[Period_1],[Period_2],[Period_1v2],[Period_3],[Period_2v3],[Period_4],[Period_3v4],[Period_5],[Period_4v5],[Period_6],[Period_5v6],[YTD]) 
) AS PivotTable


truncate table #Clinical_KPI_Results_Staging



/*
	Total Number of Past Due AL-PC LOC Assessments for Period

*/


insert into #Clinical_KPI_Results_Staging
select distinct dl.Column_Index,cast(r.Cell_Data as Int) as Cell_Data
from
(select	
rl.AssessmentMonth 
/*,rl.AssessmentCompleteFlag
,rl.AssessmentClass
,rl.AssessmentType
*/
,Count(rl.AssessmentMonth) as Cell_Data
	from #Assessment_List rl
	where    
    rl.AssessmentCompleteFlag = 0 /* Completed Assessments' */
    and rl.AssessmentType like '%LOC Resident%'
	and rl.Status in ('Current')	
	and rl.ActiveFlag = 1
 	Group by
	rl.AssessmentMonth
    /* ,rl.AssessmentCompleteFlag,rl.AssessmentClass,rl.AssessmentType */
) r

left join #DateList dl on r.AssessmentMonth = dl.EvalMonth

/*
	Add Report Index and Row Description
*/

insert into #Clinical_KPI_Results_Staging select 'Report_Index', 'S0000'
insert into #Clinical_KPI_Results_Staging select 'Description', 'Total Past Due AL-PC LOC Assessments'

/*
	Add Comparison of Periods
*/

insert into #Clinical_KPI_Results_Staging select 'Period_1v2', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_1'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_2v3', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_3v4', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_4v5', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_5v6', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_6'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) as varchar(100))

insert into #Clinical_KPI_Results
SELECT +
0,'Header Info',*
FROM
 
(SELECT 
	Column_Index, Cell_Data	
FROM 
	#Clinical_KPI_Results_Staging
)
AS DataTable
PIVOT(
	Max(Cell_Data) 
FOR Column_Index IN ([Report_Index],[Description],[Period_1],[Period_2],[Period_1v2],[Period_3],[Period_2v3],[Period_4],[Period_3v4],[Period_5],[Period_4v5],[Period_6],[Period_5v6],[YTD]) 
) AS PivotTable


truncate table #Clinical_KPI_Results_Staging





/*
	Count of those with Physical Therapy Orders for Selected Communities/Regions
*/



insert into #Clinical_KPI_Results_Staging
select distinct
dl.Column_Index
,cast(r.Cell_Data as Int) as Cell_Data
from
(	select	
    rl.EvalMonth	
  	,count(rl.OrderID) as Cell_Data
	from 
    (select distinct
     r.EvalMonth
     , so.OrderID, r.hMyPerson
     from #Resident_List r
     Left Join seniororder so on so.ResidentID = r.hMyPerson 
	 Left Join seniororderstanding sos on sos.OrderID = so.OrderID
/*	 Left Join SeniorOrderMedType sot on sot.OrderID = so.OrderID
	 Left Join seniorordermedtypeInternal soti on soti.orderMedTypeInternalID = sot.OrderMedTypesID
     	where (so.Name = 'Physical Therapy' or soti.Name = 'Physical Therapy')
*/
     	where so.Name = 'Physical Therapy'
     	and r.EvalDate >= convert(date,sos.dtStartDate) and r.EvalDate <=  convert(date,isnull(sos.dtEndDate,r.EvalDate ) ) 
	) rl
 	Group by
	rl.EvalMonth
) r
left join #DateList dl on r.EvalMonth = dl.EvalMonth

/*
	Add Report Index and Row Description
*/

insert into #Clinical_KPI_Results_Staging select 'Report_Index', 'S0000'
insert into #Clinical_KPI_Results_Staging select 'Description', 'Total Physical Therapy'

/*
	Add Comparison of Periods
*/

insert into #Clinical_KPI_Results_Staging select 'Period_1v2', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_1'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_2v3', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_3v4', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_4v5', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_5v6', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_6'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) as varchar(100))


insert into #Clinical_KPI_Results
SELECT 
0,'Header Info',*
FROM
 
(SELECT 
	Column_Index, Cell_Data	
FROM 
	#Clinical_KPI_Results_Staging
)
AS DataTable
PIVOT(
	Max(Cell_Data) 
FOR Column_Index IN ([Report_Index],[Description],[Period_1],[Period_2],[Period_1v2],[Period_3],[Period_2v3],[Period_4],[Period_3v4],[Period_5],[Period_4v5],[Period_6],[Period_5v6],[YTD]) 
) AS PivotTable




truncate table #Clinical_KPI_Results_Staging




/*
	Count of those with Occupational Therapy Orders for Selected Communities/Regions
*/



insert into #Clinical_KPI_Results_Staging
select distinct
dl.Column_Index
,cast(r.Cell_Data as Int) as Cell_Data
from
(	select	
    rl.EvalMonth	
  	,count(rl.OrderID) as Cell_Data
	from 
    (select distinct
     r.EvalMonth
     , so.OrderID, r.hMyPerson
     from #Resident_List r
     Left Join seniororder so on so.ResidentID = r.hMyPerson 
	 Left Join seniororderstanding sos on sos.OrderID = so.OrderID
/*	 Left Join SeniorOrderMedType sot on sot.OrderID = so.OrderID
	 Left Join seniorordermedtypeInternal soti on soti.orderMedTypeInternalID = sot.OrderMedTypesID
     	where (so.Name = 'Occupational Therapy' or soti.Name = 'Occupational Therapy')
*/
     	where so.Name = 'Occupational Therapy'
     	and r.EvalDate >= convert(date,sos.dtStartDate) and r.EvalDate <=  convert(date,isnull(sos.dtEndDate,r.EvalDate ) ) 
	) rl
 	Group by
	rl.EvalMonth
) r
left join #DateList dl on r.EvalMonth = dl.EvalMonth

/*
	Add Report Index and Row Description
*/

insert into #Clinical_KPI_Results_Staging select 'Report_Index', 'S0000'
insert into #Clinical_KPI_Results_Staging select 'Description', 'Total Occupational Therapy'

/*
	Add Comparison of Periods
*/

insert into #Clinical_KPI_Results_Staging select 'Period_1v2', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_1'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_2v3', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_3v4', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_4v5', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_5v6', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_6'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) as varchar(100))


insert into #Clinical_KPI_Results
SELECT 
0,'Header Info',*
FROM
 
(SELECT 
	Column_Index, Cell_Data	
FROM 
	#Clinical_KPI_Results_Staging
)
AS DataTable
PIVOT(
	Max(Cell_Data) 
FOR Column_Index IN ([Report_Index],[Description],[Period_1],[Period_2],[Period_1v2],[Period_3],[Period_2v3],[Period_4],[Period_3v4],[Period_5],[Period_4v5],[Period_6],[Period_5v6],[YTD]) 
) AS PivotTable




truncate table #Clinical_KPI_Results_Staging


/*
	Count of those with Speech Therapy Orders for Selected Communities/Regions
*/



insert into #Clinical_KPI_Results_Staging
select distinct
dl.Column_Index
,cast(r.Cell_Data as Int) as Cell_Data
from
(	select	
    rl.EvalMonth	
  	,count(rl.OrderID) as Cell_Data
	from 
    (select distinct
     r.EvalMonth
     , so.OrderID, r.hMyPerson
     from #Resident_List r
     Left Join seniororder so on so.ResidentID = r.hMyPerson 
	 Left Join seniororderstanding sos on sos.OrderID = so.OrderID
/*	 Left Join SeniorOrderMedType sot on sot.OrderID = so.OrderID
	 Left Join seniorordermedtypeInternal soti on soti.orderMedTypeInternalID = sot.OrderMedTypesID
     	where (so.Name = 'Speech Therapy' or soti.Name = 'Speech Therapy')
*/
     	where so.Name = 'Speech Therapy'
     	and r.EvalDate >= convert(date,sos.dtStartDate) and r.EvalDate <=  convert(date,isnull(sos.dtEndDate,r.EvalDate ) ) 
	) rl
 	Group by
	rl.EvalMonth
) r
left join #DateList dl on r.EvalMonth = dl.EvalMonth

/*
	Add Report Index and Row Description
*/

insert into #Clinical_KPI_Results_Staging select 'Report_Index', 'S0000'
insert into #Clinical_KPI_Results_Staging select 'Description', 'Total Speech Therapy'

/*
	Add Comparison of Periods
*/

insert into #Clinical_KPI_Results_Staging select 'Period_1v2', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_1'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_2v3', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_3v4', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_4v5', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_5v6', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_6'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) as varchar(100))


insert into #Clinical_KPI_Results
SELECT 
0,'Header Info',*
FROM
 
(SELECT 
	Column_Index, Cell_Data	
FROM 
	#Clinical_KPI_Results_Staging
)
AS DataTable
PIVOT(
	Max(Cell_Data) 
FOR Column_Index IN ([Report_Index],[Description],[Period_1],[Period_2],[Period_1v2],[Period_3],[Period_2v3],[Period_4],[Period_3v4],[Period_5],[Period_4v5],[Period_6],[Period_5v6],[YTD]) 
) AS PivotTable




truncate table #Clinical_KPI_Results_Staging


/*
	Count of those with Home Health Orders for Selected Communities/Regions
*/



insert into #Clinical_KPI_Results_Staging
select distinct
dl.Column_Index
,cast(r.Cell_Data as Int) as Cell_Data
from
(	select	
    rl.EvalMonth	
  	,count(rl.OrderID) as Cell_Data
	from 
    (select distinct
     r.EvalMonth
     , so.OrderID, r.hMyPerson
     from #Resident_List r
     Left Join seniororder so on so.ResidentID = r.hMyPerson 
	 Left Join seniororderstanding sos on sos.OrderID = so.OrderID
/*	 Left Join SeniorOrderMedType sot on sot.OrderID = so.OrderID
	 Left Join seniorordermedtypeInternal soti on soti.orderMedTypeInternalID = sot.OrderMedTypesID
     	where (so.Name = 'Home Health' or soti.Name = 'Home Health')
*/
     	where so.Name = 'Home Health'
     	and r.EvalDate >= convert(date,sos.dtStartDate) and r.EvalDate <=  convert(date,isnull(sos.dtEndDate,r.EvalDate ) ) 
	) rl
 	Group by
	rl.EvalMonth
) r
left join #DateList dl on r.EvalMonth = dl.EvalMonth

/*
	Add Report Index and Row Description
*/

insert into #Clinical_KPI_Results_Staging select 'Report_Index', 'S0000'
insert into #Clinical_KPI_Results_Staging select 'Description', 'Total Home Health'

/*
	Add Comparison of Periods
*/

insert into #Clinical_KPI_Results_Staging select 'Period_1v2', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_1'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_2v3', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_3v4', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_4v5', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_5v6', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_6'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) as varchar(100))


insert into #Clinical_KPI_Results
SELECT 
0,'Header Info',*
FROM
 
(SELECT 
	Column_Index, Cell_Data	
FROM 
	#Clinical_KPI_Results_Staging
)
AS DataTable
PIVOT(
	Max(Cell_Data) 
FOR Column_Index IN ([Report_Index],[Description],[Period_1],[Period_2],[Period_1v2],[Period_3],[Period_2v3],[Period_4],[Period_3v4],[Period_5],[Period_4v5],[Period_6],[Period_5v6],[YTD]) 
) AS PivotTable




truncate table #Clinical_KPI_Results_Staging



/*
	Count of those with Hospice Orders for Selected Communities/Regions
*/



insert into #Clinical_KPI_Results_Staging
select distinct
dl.Column_Index
,cast(r.Cell_Data as Int) as Cell_Data
from
(	select	
    rl.EvalMonth	
  	,count(rl.OrderID) as Cell_Data
	from 
    (select distinct
     r.EvalMonth
     , so.OrderID, r.hMyPerson
     from #Resident_List r
     Left Join seniororder so on so.ResidentID = r.hMyPerson 
	 Left Join seniororderstanding sos on sos.OrderID = so.OrderID
/*	 Left Join SeniorOrderMedType sot on sot.OrderID = so.OrderID
	 Left Join seniorordermedtypeInternal soti on soti.orderMedTypeInternalID = sot.OrderMedTypesID
     	where (so.Name = 'Hospice' or soti.Name = 'Hospice')
*/
     	where so.Name = 'Hospice'
     	and r.EvalDate >= convert(date,sos.dtStartDate) and r.EvalDate <=  convert(date,isnull(sos.dtEndDate,r.EvalDate ) ) 
	) rl
 	Group by
	rl.EvalMonth
) r
left join #DateList dl on r.EvalMonth = dl.EvalMonth

/*
	Add Report Index and Row Description
*/

insert into #Clinical_KPI_Results_Staging select 'Report_Index', 'S0000'
insert into #Clinical_KPI_Results_Staging select 'Description', 'Total Hospice'

/*
	Add Comparison of Periods
*/

insert into #Clinical_KPI_Results_Staging select 'Period_1v2', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_1'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_2v3', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_3v4', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_4v5', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_5v6', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_6'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) as varchar(100))


insert into #Clinical_KPI_Results
SELECT 
0,'Header Info',*
FROM
 
(SELECT 
	Column_Index, Cell_Data	
FROM 
	#Clinical_KPI_Results_Staging
)
AS DataTable
PIVOT(
	Max(Cell_Data) 
FOR Column_Index IN ([Report_Index],[Description],[Period_1],[Period_2],[Period_1v2],[Period_3],[Period_2v3],[Period_4],[Period_3v4],[Period_5],[Period_4v5],[Period_6],[Period_5v6],[YTD]) 
) AS PivotTable




truncate table #Clinical_KPI_Results_Staging



/*
	Count of those with Skilled Nursing Orders for Selected Communities/Regions
*/



insert into #Clinical_KPI_Results_Staging
select distinct
dl.Column_Index
,cast(r.Cell_Data as Int) as Cell_Data
from
(	select	
    rl.EvalMonth	
  	,count(rl.OrderID) as Cell_Data
	from 
    (select distinct
     r.EvalMonth
     , so.OrderID, r.hMyPerson
     from #Resident_List r
     Left Join seniororder so on so.ResidentID = r.hMyPerson 
	 Left Join seniororderstanding sos on sos.OrderID = so.OrderID
/*	 Left Join SeniorOrderMedType sot on sot.OrderID = so.OrderID
	 Left Join seniorordermedtypeInternal soti on soti.orderMedTypeInternalID = sot.OrderMedTypesID
     	where (so.Name = 'Skilled Nursing' or soti.Name = 'Skilled Nursing')
*/
     	where so.Name = 'Skilled Nursing'
     	and r.EvalDate >= convert(date,sos.dtStartDate) and r.EvalDate <=  convert(date,isnull(sos.dtEndDate,r.EvalDate ) ) 
	) rl
 	Group by
	rl.EvalMonth
) r
left join #DateList dl on r.EvalMonth = dl.EvalMonth

/*
	Add Report Index and Row Description
*/

insert into #Clinical_KPI_Results_Staging select 'Report_Index', 'S0000'
insert into #Clinical_KPI_Results_Staging select 'Description', 'Total Skilled Nursing'

/*
	Add Comparison of Periods
*/

insert into #Clinical_KPI_Results_Staging select 'Period_1v2', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_1'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_2v3', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_3v4', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_4v5', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_5v6', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_6'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) as varchar(100))


insert into #Clinical_KPI_Results
SELECT 
0,'Header Info',*
FROM
 
(SELECT 
	Column_Index, Cell_Data	
FROM 
	#Clinical_KPI_Results_Staging
)
AS DataTable
PIVOT(
	Max(Cell_Data) 
FOR Column_Index IN ([Report_Index],[Description],[Period_1],[Period_2],[Period_1v2],[Period_3],[Period_2v3],[Period_4],[Period_3v4],[Period_5],[Period_4v5],[Period_6],[Period_5v6],[YTD]) 
) AS PivotTable




truncate table #Clinical_KPI_Results_Staging













/*
	Total Number of Past Due Other Assessments for Period

*/


insert into #Clinical_KPI_Results_Staging
select distinct dl.Column_Index,cast(r.Cell_Data as Int) as Cell_Data
from
(select	
rl.AssessmentMonth 
/*,rl.AssessmentCompleteFlag
,rl.AssessmentClass
,rl.AssessmentType
*/
,Count(rl.AssessmentMonth) as Cell_Data
	from #Assessment_List rl
	where    
    rl.AssessmentCompleteFlag = 0 /* Completed Assessments' */
    and rl.AssessmentType Not like '%LOC Resident%'
	and rl.AssessmentType Not like '%Lantern%'
	and rl.Status in ('Current')	
	and rl.ActiveFlag = 1
 	Group by
	rl.AssessmentMonth
    /* ,rl.AssessmentCompleteFlag,rl.AssessmentClass,rl.AssessmentType */
) r

left join #DateList dl on r.AssessmentMonth = dl.EvalMonth

/*
	Add Report Index and Row Description
*/

insert into #Clinical_KPI_Results_Staging select 'Report_Index', 'S0000'
insert into #Clinical_KPI_Results_Staging select 'Description', 'Total Past Due Other Assessments'

/*
	Add Comparison of Periods
*/

insert into #Clinical_KPI_Results_Staging select 'Period_1v2', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_1'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_2v3', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_3v4', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_4v5', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_5v6', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_6'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) as varchar(100))

insert into #Clinical_KPI_Results
SELECT +
0,'Header Info',*
FROM
 
(SELECT 
	Column_Index, Cell_Data	
FROM 
	#Clinical_KPI_Results_Staging
)
AS DataTable
PIVOT(
	Max(Cell_Data) 
FOR Column_Index IN ([Report_Index],[Description],[Period_1],[Period_2],[Period_1v2],[Period_3],[Period_2v3],[Period_4],[Period_3v4],[Period_5],[Period_4v5],[Period_6],[Period_5v6],[YTD]) 
) AS PivotTable


truncate table #Clinical_KPI_Results_Staging


/*
	Total Number of Shared Risk Agreements Active for Period
	Once a resident moves out, they drop off list


*/


insert into #Clinical_KPI_Results_Staging 
select d.Column_Index, Count(l.sharedriskactive) as Cell_Data
	from  (Select Distinct Column_Index,EvalMonth from #DateList) d
	Left Join Tenant t on 1=1
	INNER JOIN  SENIORRESIDENT sr  ON ( t.HMYPERSON = sr.RESIDENTID )
	LEFT JOIN LEASEBUT18 l ON (l.hCode = sr.RESIDENTID) 
	where 
	t.hProperty in (select a.hProp from @EvalProperties a)
	and l.sharedriskactive = 'yes'
	and isnull(t.dtmoveout,'12/31/9999') >= convert(varchar,cast(right(d.EvalMonth,2) + '/01/' +left(d.EvalMonth,4) as datetime),101)
	group by d.Column_Index,d.EvalMonth

/*
	Add Report Index and Row Description
*/

insert into #Clinical_KPI_Results_Staging select 'Report_Index', 'S0000'
insert into #Clinical_KPI_Results_Staging select 'Description', 'Total Active Shared Risk Agreements'

/*
	Add Comparison of Periods
*/

insert into #Clinical_KPI_Results_Staging select 'Period_1v2', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_1'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_2v3', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_2'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_3v4', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_3'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_4v5', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_4'),0) as varchar(100))
insert into #Clinical_KPI_Results_Staging select 'Period_5v6', cast(isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_6'),0) - isnull((select cast(Cell_Data as int) from #Clinical_KPI_Results_Staging where Column_Index = 'Period_5'),0) as varchar(100))

insert into #Clinical_KPI_Results
SELECT +
0,'Header Info',*
FROM
 
(SELECT 
	Column_Index, Cell_Data	
FROM 
	#Clinical_KPI_Results_Staging
)
AS DataTable
PIVOT(
	Max(Cell_Data) 
FOR Column_Index IN ([Report_Index],[Description],[Period_1],[Period_2],[Period_1v2],[Period_3],[Period_2v3],[Period_4],[Period_3v4],[Period_5],[Period_4v5],[Period_6],[Period_5v6],[YTD]) 
) AS PivotTable


truncate table #Clinical_KPI_Results_Staging

/*
	Just for Proof that this uses same logic of Weekly Census Report Summary
	Lists out Each Communitie's Rounded Census for Each Day
*/

/*
select 
rl.EvalDate
, rl.PropertyID
, rl.Community
, rl.Community_Abbr
, rl.Community_Code
, round(sum(cast(rl.Occupancy_Value as numeric(10,1))),0)  as Occupancy
from #Resident_List rl

where rl.EvalDate = '6/30/2019'

Group by
rl.EvalDate
, rl.PropertyID
, rl.Community
, rl.Community_Abbr
, rl.Community_Code


order by rl.Community_Code
*/






/*
	Final Select Output
*/

/*
	Insert Final Section Headers
*/
insert into #Clinical_KPI_Results select 2,'Header Info','S0000','Census KPIs',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '
insert into #Clinical_KPI_Results select 2,'Header Info','S0000','Discharge KPIs',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '
insert into #Clinical_KPI_Results select 2,'Header Info','S0000','Incident KPIs',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '
insert into #Clinical_KPI_Results select 2,'Header Info','S0000','Clinical KPIs',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '

/*

	Update Sort Order of All Rowes

*/

update #Clinical_KPI_Results set Report_Index = 'S0000' where Description = 'Morning Pointe Clinical KPIs'
update #Clinical_KPI_Results set Report_Index = 'S1000' where Description = 'Census KPIs'
update #Clinical_KPI_Results set Report_Index = 'S1010' where Description = 'Average Daily Census'
update #Clinical_KPI_Results set Report_Index = 'S1020' where Description = 'Average Age of Residents'
update #Clinical_KPI_Results set Report_Index = 'S1030' where Description = 'Total Concierge at Month End'
update #Clinical_KPI_Results set Report_Index = 'S1040' where Description = 'Total Premium at Month End'
update #Clinical_KPI_Results set Report_Index = 'S3040' where Description = 'NEWADD1'
update #Clinical_KPI_Results set Report_Index = 'S1050' where Description = 'Total New Move Ins'
update #Clinical_KPI_Results set Report_Index = 'S1060' where Description = 'Total Concierge for New Move Ins'
update #Clinical_KPI_Results set Report_Index = 'S1070' where Description = 'Total Premium for New Move Ins'
update #Clinical_KPI_Results set Report_Index = 'S2000' where Description = 'Discharge KPIs'
update #Clinical_KPI_Results set Report_Index = 'S2010' where Description = 'Total Discharges'
update #Clinical_KPI_Results set Report_Index = 'S2020' where Description = 'Average LOS of Discharges (Months)'
update #Clinical_KPI_Results set Report_Index = 'S2030' where Description = 'Discharges with LOS < 90 Days'
update #Clinical_KPI_Results set Report_Index = 'S2040' where Description = 'Discharges due to Death'
update #Clinical_KPI_Results set Report_Index = 'S2050' where Description = 'Discharges due to Higher Acuity'
/* update #Clinical_KPI_Results set Report_Index = 'S2060' where Description = 'Discharges due to Financial' */
/* update #Clinical_KPI_Results set Report_Index = 'S2070' where Description = 'Discharges due to End of Respite/Daycare' */
update #Clinical_KPI_Results set Report_Index = 'S2080' where Description = 'Discharges due to Dissatisfaction'
update #Clinical_KPI_Results set Report_Index = 'S2090' where Description = 'Discharges due to Eviction'
/* update #Clinical_KPI_Results set Report_Index = 'S2100' where Description = 'Discharges due Unknown or Other Reasons' */
update #Clinical_KPI_Results set Report_Index = 'S2110' where Description = 'Incident KPIs'
update #Clinical_KPI_Results set Report_Index = 'S3000' where Description = 'Total Incidents'
update #Clinical_KPI_Results set Report_Index = 'S3010' where Description = 'Total Abuse Incidents'
update #Clinical_KPI_Results set Report_Index = 'S3020' where Description = 'Total Behavior Incidents'
update #Clinical_KPI_Results set Report_Index = 'S3030' where Description = 'Total Death Incidents'
update #Clinical_KPI_Results set Report_Index = 'S3040' where Description = 'Total Elopement Incidents'
update #Clinical_KPI_Results set Report_Index = 'S3050' where Description = 'Total Fall Incidents'
update #Clinical_KPI_Results set Report_Index = 'S3060' where Description = 'Total Injury Incidents'
update #Clinical_KPI_Results set Report_Index = 'S3070' where Description = 'Total Medication Error Incidents'
/* update #Clinical_KPI_Results set Report_Index = 'S3080' where Description = 'Total Missing/Wandering Incidents' */
update #Clinical_KPI_Results set Report_Index = 'S3090' where Description = 'Total All Other Incidents'
update #Clinical_KPI_Results set Report_Index = 'S4000' where Description = 'Clinical KPIs'
update #Clinical_KPI_Results set Report_Index = 'S4010' where Description = 'Total Hospital LOA'
update #Clinical_KPI_Results set Report_Index = 'S4020' where Description = 'Total Elopement Scored >= 10'
update #Clinical_KPI_Results set Report_Index = 'S4030' where Description = 'Total Past Due AL-PC LOC Assessments'
update #Clinical_KPI_Results set Report_Index = 'S4040' where Description = 'Total Past Due Lantern Assessments'
update #Clinical_KPI_Results set Report_Index = 'S4040' where Description = 'Total Past Due Other Assessments'
update #Clinical_KPI_Results set Report_Index = 'S4050' where Description = 'Total Active Shared Risk Agreements'

update #Clinical_KPI_Results set Report_Index = 'S4060' where Description = 'Total Physical Therapy'
update #Clinical_KPI_Results set Report_Index = 'S4070' where Description = 'Total Occupational Therapy'
update #Clinical_KPI_Results set Report_Index = 'S4080' where Description = 'Total Speech Therapy'
update #Clinical_KPI_Results set Report_Index = 'S4090' where Description = 'Total Home Health'
update #Clinical_KPI_Results set Report_Index = 'S4100' where Description = 'Total Hospice'
update #Clinical_KPI_Results set Report_Index = 'S4110' where Description = 'Total Skilled Nursing'


/*
	Display Final Results
*/

select 
ckpi.Row_Color
,'Report Selection: ' + @Report_Header_Description as Report_Header_Description
,ckpi.Report_Index
,ckpi.Description
,isnull(ckpi.Period_1,0) as Period_1
,isnull(ckpi.Period_2,0) as Period_2
,isnull(ckpi.Period_1v2,0) as Period_1v2
,isnull(ckpi.Period_3,0) as Period_3
,isnull(ckpi.Period_2v3,0) as Period_2v3
,isnull(ckpi.Period_4,0) as Period_4
,isnull(ckpi.Period_3v4,0) as Period_3v4
,isnull(ckpi.Period_5,0) as Period_5
,isnull(ckpi.Period_4v5,0) as Period_4v5
,isnull(ckpi.Period_6,0) as Period_6
,isnull(ckpi.Period_5v6,0) as Period_5v6
,isnull(ckpi.YTD,'') as YTD

from #Clinical_KPI_Results ckpi

/*
select top 100 * from #DateList
select top 100 * from #Resident_List
select top 100 * from #Clinical_KPI_Results
*/

    
drop table #DateList
drop table #DateList_YTD
drop table #Report_Header
drop table #Resident_List
drop table #Resident_List_YTD
drop table #Discharge_List
drop table #Discharge_List_YTD
drop table #Incident_List
drop table #Incident_List_YTD
drop table #Clinical_KPI_Results_Staging
drop table #Clinical_KPI_Results 
drop table #Assessment_List
drop table #Assessment_Score





