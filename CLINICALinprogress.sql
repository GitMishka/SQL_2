Declare @Eval_Date datetime =  CAST(getdate() AS DATE)
IF OBJECT_ID ('TempDb..#Clinical_KPI_Results_Staging') IS NOT NULL
DROP TABLE #Clinical_KPI_Results_Staging


IF OBJECT_ID ('TempDb..#DateList') IS NOT NULL
DROP TABLE #DateList


IF OBJECT_ID ('TempDb..#Resident_List') IS NOT NULL
DROP TABLE #Resident_List




IF OBJECT_ID('TempDb..#Inventory_Occupancy_Residents') IS NOT NULL
DROP TABLE #Inventory_Occupancy_Residents

Declare @EvalProperties table ( hprop int, name varchar(250))
insert into @EvalProperties select a.hProp, case when isnull(ltrim(rtrim(a.SubGroup2)),'') = '' then '???' else  ltrim(rtrim(a.SubGroup2)) end from attributes a where a.SubGroup3 in ('Stabilized','Focus','Start Up') and case when isnull(ltrim(rtrim(a.SubGroup2)),'') = '' then '???' else  ltrim(rtrim(a.SubGroup2)) end ='#selection#' 
insert into @EvalProperties select a.hProp, case when ltrim(rtrim(a.sPropName)) like '%Lantern%' then replace(replace(ltrim(rtrim(a.sPropName)),'The Lantern at Morning Pointe of ','') + ' ' +'Lantern',',','') else replace(replace(ltrim(rtrim(a.sPropName)),'Morning Pointe of ',''),',','') end from attributes a where a.SubGroup3 in ('Stabilized','Focus','Start Up') and case when ltrim(rtrim(a.sPropName)) like '%Lantern%' then replace(replace(ltrim(rtrim(a.sPropName)),'The Lantern at Morning Pointe of ','') + ' ' +'Lantern',',','') else replace(replace(ltrim(rtrim(a.sPropName)),'Morning Pointe of ',''),',','') end ='#selection#'   
/* insert into @EvalProperties select a.hProp from attributes a where a.SubGroup3 in ('Stabilized','Focus','Start Up')   */


Create Table #Clinical_KPI_Results_Staging
(
Column_Index varchar(25)
,Cell_Data varchar(100)
)
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
create table #DateList
(
      EvalDate   Date
	  ,EvalMonth varchar(6)
	  ,Column_Index varchar(25)
)
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


select  *  from #Clinical_KPI_Results_Staging
select  *  from #Clinical_KPI_Results
