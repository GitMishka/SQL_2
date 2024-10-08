--//Vista

--//Notes
--  Script Name : rs_sql_IHP_Inventory_Occupancy.DATA.txt
--  Client Name : Independent Healthcare Properties LLC
--  Date        : 07/01/2019
--  Description : Inventory Roster - Populate IHP Community Inventory with Resident Information and Summary Info.
--//End Notes



--//Title
--IHP Inventory Occupancy
--//end title




--//Select

Declare
@Eval_Date datetime =  CAST(getdate() AS DATE)


/*
	Pull together Units
*/

select 
	p.hmy as hProp
	,ltrim(rtrim(P.sAddr1)) as Community
	,case 
		when ltrim(rtrim(P.sAddr1)) like '%Lantern%' then replace(ltrim(rtrim(P.sAddr1)),'The Lantern at Morning Pointe of ','') + ' ' +'Lantern'
		else replace(ltrim(rtrim(P.sAddr1)),'Morning Pointe of ','') 
	end as Community_Abbr
	,ltrim(rtrim(p.scode)) as Community_Code
	,u.hMy as uhMy
    ,u.scode Unit
    ,case ltrim(rtrim(ut.scode))
		when 'al1bed' then 'AL 1BR'
		when 'al1bedc' then 'AL 1BR'
		when 'al1bedd' then 'AL 1BR D'
		when 'al1bedg' then 'AL 1BR G'
		when 'al1bedgc' then 'AL 1BR GC'
		when 'al2bed' then 'AL 2BR'
		when 'al2bedd' then 'AL 2BR D'
		when 'alalcv' then 'AL ALCV'
		when 'alalcvd' then 'AL ALCV D'
		when 'alalcvs' then 'AL ALCV S'
		when 'alcmp' then 'AL CMP'
		when 'alstdo' then 'AL STDO'
		when 'alstdoc' then 'AL STDO C'
		when 'alstdod' then 'AL STDO D'
		when 'alstdosm' then 'AL STDO S'
		when 'alz1bed' then 'ALZ 1BR'
		when 'alz2bed' then 'ALZ 2BR'
		when 'alzalc' then 'ALZ AL C'
		when 'alzalcv' then 'ALZ ALCV'
		when 'alzalcvd' then 'ALZ ALCV D'
		when 'alzalcvs' then 'ALZ ALCV S'
		when 'alzcmp' then 'ALZ CMP'
		when 'alzstdd' then 'ALZ STD D'
		when 'alzstdo' then 'ALZ STDO'
		when 'alzstdsm' then 'ALZ STDO S'
		when 'beautysh' then 'BEAUTYSH'
		when 'll1bed' then 'LL 1BR'
		when 'll1bedd' then 'LL 1BR D'
		when 'll2bedd' then 'LL 2BR D'
		when 'llalcbd' then 'LL ALCB D'
		when 'llalcdc' then 'LL ALCD C'
		when 'llalcv' then 'LL ALCV'
		when 'llalcvc' then 'LL ALCV C'
		when 'llalcvd' then 'LL ALCV D'
		when 'llcmp' then 'LL CMP'
		when 'llcomp' then 'LL COMP'
		when 'llstdd' then 'LL STD D'
		when 'llstdo' then 'LL STDO'
		when 'llsstdoc' then 'LL SSTDO C'
		when 'llstdoc' then 'LL STDO C'
		when 'pc1bed' then 'PC 1BR'
		when 'pc1bedd' then 'PC 1BR D'
		when 'pc2bed' then 'PC 2BR'
		when 'pc2bedd' then 'PC 2BR D'
		when 'pcalcv' then 'PC ALCV'
		when 'pcstdo' then 'PC STDO'
		when 'pcstdod' then 'PC STDO D'
		when 'pt' then 'PT'
		when 'WAITALZ2' then 'WAIT AL Z2'
		when 'WAITALZ3' then 'WAIT AL Z3'
		when 'WAITALZ4' then 'WAIT AL Z4'
		when 'WAITALZ5' then 'WAIT AL Z5'
	end as Unit_Code
	,ltrim(rtrim(isnull(ut.sDesc,'')))  Unit_Type
	,ltrim(rtrim(lo.listoptionname)) Carelevel
	,suh.UnitCapacityCount Capacity
/*	,case when suh.UnitExcludeFlag  <> 0 then 'Yes' else 'No' end UnitExcludeFlag */
/*  ,case when suh.UnitWaitListFlag <> 0 then 'Yes' else 'No' end UnitWaitListFlag */

into #Inventory_Occupancy_Units
from unit u
	inner join seniorunithistory suh on suh.unitid = u.hmy and suh.UnitHistoryActiveflag = 1
	inner join property p on p.hmy = u.hproperty
	inner join unittype ut on ut.hmy = u.hunittype
	inner join listoption lo on lo.listoptioncode = suh.carelevelcode and lo.listname ='Carelevel'
	where 
    	--1=1 #Condition1#
       -- and 
		suh.UnitExcludeFlag = 0
	and u.exclude = 0

		/* and p.hMy in (1,2,3,4,5,6,10,11,12,13,14,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,46,52,61,63,76,79) */
	and  @Eval_Date between DATEADD(dd, 0, DATEDIFF(dd, 0, suh.UnitHistoryFromDate)) and DATEADD(dd, 0, DATEDIFF(dd, 0,  ISNULL(suh.UnitHistorytoDate,getdate())))

/*
	Pull together Residents
*/

SELECT 
	p.hmy as hprop
	,t.istatus as Tenant_Status
	, case 
		when t.istatus in (2,8) then 'R' 
		when t.istatus = 4 then 'N' 
		when t.istatus = 11 then 'L' 
		else 'O' 
	end as Unit_Status
	,ltrim(rtrim(u.scode)) as Unit
	,ltrim(rtrim(t.sLastName))+', '+ltrim(rtrim(t.sFirstName)) AS Resident_Name /* +' ('+ ltrim(rtrim(t.scode))+')' AS Resident_Name */
	,t.dtmovein as MoveIn_Date 
	,t.dtmoveout as MoveOut_Date
	,lo.ListOptionName Pri_Sec
	,ts.status ResStatus
	,u.hmy uhmy

into #Inventory_Occupancy_Residents
from property p 
inner join tenant t on t.hproperty = p.hmy 
inner join SeniorResidentStatus ts on (ts.istatus = t.istatus)
inner join seniorresident sr on t.hmyperson = sr.residentid 
inner join unit u on u.hmy = t.hunit 
inner join unittype ut on ut.hmy = u.hunittype 
left outer join listoption lo on (sr.PrivacyLevelcode = lo.listoptioncode AND lo.listname = 'PrivacyLevel')
left join seniorprospect sp on isnull(sp.htenant,-1)=t.hmyperson
--where 1=1 #Condition1#
/* and p.hMy in (1,2,3,4,5,6,10,11,12,13,14,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,46,52,61,63,76,79) */
and (t.istatus   in (2, 8) /*Future, Waitlisted*/
     or (t.istatus   in (0,4,11) and t.dtmovein is not null)) /*Current,On Notice, On Leave*/



/*
	Put Results in Temporary Table so they can be split into Columns on Report
*/ 

select
	ROW_NUMBER() OVER(Partition by u.hprop ORDER BY u.hprop, u.unit) AS Row_Number
	,u.*
	,r.Tenant_Status
	,r.Unit_Status
	,r.Resident_Name
	,r.MoveIn_Date 
	,r.MoveOut_Date
	,r.Pri_Sec
	,r.ResStatus
into #Results
from #Inventory_Occupancy_Units u
left join #Inventory_Occupancy_Residents r on u.uhmy = r.uhmy
order by u.hprop, u.unit, r.Pri_Sec desc, r.Resident_Name

select 
r.hprop
,count(*) as Row_Count

, case ((count(*) * 1.00000) % 3) 
	when 2 then (count(*)  - Floor((count(*) * 1.00000) / 3) - Floor((count(*) * 1.00000) / 3)) - 1 
	else count(*)  - Floor((count(*) * 1.00000) / 3) - Floor((count(*) * 1.00000) / 3)
  end  as Col1_End_Row
,count(*)  - Floor((count(*) * 1.00000) / 3) as Col2_End_Row
into #Report_Index_Splits
from #Results r
group by hprop

select
case 
	when row_number <= ris.Col1_End_Row then 'D1'
    when row_number > ris.Col2_End_Row then 'D3'
    else 'D2'
end as Report_Index
,r.*
into #Results_Detail
from #Results r
left join #Report_Index_Splits ris on ris.hprop = r.hprop


/*
	Add the Summary Info
*/

alter table #Results_Detail
add Summary_Unit_Count int
,Summary_Vacant_Count int
,Summary_Occupied_Count int
,Summary_Resident_Count int
,Summary_Scheduled_MoveIn_Count int
,Summary_Scheduled_MoveOut_Count int



insert into #Results_Detail
select distinct
'S1' as [Report_Index]
,0 [Row_Number]
,a.hprop [Property_KEY]
,a.Community [Community]
,a.Community_Abbr [Community_Abbr]
,a.Community_Code [Community_Code]
,0 [Unit_Key]
,'' [Unit]
,'' [Unit_Code]
, a.Unit_Type [Unit_Type]
,'' [Care_Level]
,0 [Capacity]
,0 [Tenant_Status]
,'' [Unit_Status]
,'' [Resident_Name]
,'1/1/1900' [MoveIn_Date]
,'1/1/1900' [MoveOut_Date]
,'' [Pri_Sec]
,'' [Resident_Status]
, (select count(distinct Unit) from #Results_Detail where Report_Index like 'D%' and a.hprop = hprop and  a.Unit_Type = Unit_Type) as Summary_Unit_Count 
, (select count(distinct Unit) from #Results_Detail where Report_Index like 'D%' and a.hprop = hprop and  a.Unit_Type = Unit_Type)
   -
  (select count(distinct Unit) from #Results_Detail where Report_Index like 'D%' and a.hprop = hprop and  a.Unit_Type = Unit_Type and Unit_Status not in ('', 'R'))
   as Summary_Vacant_Count /* Units - Oppupied = Vacant */
, (select count(distinct Unit) from #Results_Detail where Report_Index like 'D%' and a.hprop = hprop and  a.Unit_Type = Unit_Type and Unit_Status not in ('', 'R')) as Summary_Occupied_Count 
, (select count(distinct Resident_Name) from #Results_Detail where Report_Index like 'D%' and a.hprop = hprop and  a.Unit_Type = Unit_Type and Unit_Status <> 'R' ) as Summary_Resident_Count 
, (select count(distinct Unit) from #Results_Detail where Report_Index like 'D%' and a.hprop = hprop and  a.Unit_Type = Unit_Type and Unit_Status = 'R') as Summary_Scheduled_MoveIn_Count 
, (select count(distinct Unit) from #Results_Detail where Report_Index like 'D%' and a.hprop = hprop and  a.Unit_Type = Unit_Type and Unit_Status = 'N' ) as Summary_Scheduled_MoveOut_Count 

from #Results_Detail  a
where a.Report_Index like 'D%'






/*
	Final Select Output
*/


select
r.Report_Index
,r.Row_Number
,r.hprop
,r.Community
,r.Community_Abbr
,r.Community_Code
,r.uhMy
,r.Unit
,r.Unit_Code
,r.Unit_Type
,r.CareLevel
,r.Capacity
,r.Tenant_Status
,r.Unit_Status
,case 
	when r.Unit_Status = 'R' then '(MI) ' + r.Resident_Name
	when r.Unit_Status = 'N' then '(MO) ' + r.Resident_Name
	when r.Unit_Status = 'L' then '(OL) ' + r.Resident_Name	
	else r.Resident_Name
end as Resident_Name
,r.MoveIn_Date
,r.MoveOut_Date
,r.Pri_Sec
,r.ResStatus
,r.Summary_Unit_Count
,r.Summary_Vacant_Count
,r.Summary_Occupied_Count
,r.Summary_Resident_Count
,r.Summary_Scheduled_MoveIn_Count
,r.Summary_Scheduled_MoveOut_Count
,b.Budget as Budget
from #Results_Detail r

/*  Census Budget   */

left join (

SELECT 
	p.hMy as hprop
    , abs(sum(t.sBudget)) as Budget
	from Property p
	left join Total t on p.hmy = t.hppty
	Inner join acct a on a.hmy = t.hAcct
	WHERE 
		a.scode IN ( '001005', '001006', '001007' ) AND t.iBook = 1	AND  DATEADD(month, DATEDIFF(month, 0, getdate()), 0) = t.uMonth
	Group By 
		p.hmy

) b on r.hprop = b.hprop



drop table #Results_Detail
drop table #Report_Index_Splits
drop table #Results
drop table #Inventory_Occupancy_Units
drop table #Inventory_Occupancy_Residents







--//end select



--//Columns
--//Type,  Name,  Head1,  Head2,  Head3,  Head4,  Show,  Color,  Formula,  Drill,  Key,  Width
--T,  ,  ,  ,  ,   Report Index,  Y,  ,  ,  ,  ,  500,  
--I,  ,  ,  ,  ,     Row Number,  Y,  ,  ,  ,  ,  500,  
--I,  ,  ,  ,  ,   Property KEY,  Y,  ,  ,  ,  ,  500,  
--T,  ,  ,  ,  ,      Community,  Y,  ,  ,  ,  ,  500,  
--T,  ,  ,  ,  , Community Abbr,  Y,  ,  ,  ,  ,  500,  
--T,  ,  ,  ,  , Community Code,  Y,  ,  ,  ,  ,  500,  
--I,  ,  ,  ,  ,       Unit Key,  Y,  ,  ,  ,  ,  500,  
--T,  ,  ,  ,  ,           Unit,  Y,  ,  ,  ,  ,  500,  
--T,  ,  ,  ,  ,      Unit Code,  Y,  ,  ,  ,  ,  500, 
--T,  ,  ,  ,  ,      Unit Type,  Y,  ,  ,  ,  ,  500,  
--T,  ,  ,  ,  ,     Care Level,  Y,  ,  ,  ,  ,  500,  
--I,  ,  ,  ,  ,       Capacity,  Y,  ,  ,  ,  ,  500,  
--I,  ,  ,  ,  ,  Tenant Status,  Y,  ,  ,  ,  ,  500,  
--T,  ,  ,  ,  ,    Unit Status,  Y,  ,  ,  ,  ,  500,  
--T,  ,  ,  ,  ,  Resident Name,  Y,  ,  ,  ,  ,  500, 
--A,  ,  ,  ,  ,    MoveIn Date,  Y,  ,  ,  ,  ,  500,
--A,  ,  ,  ,  ,   MoveOut Date,  Y,  ,  ,  ,  ,  500,
--T,  ,  ,  ,  ,        Pri/Sec,  Y,  ,  ,  ,  ,  500, 
--T,  ,  ,  ,  ,Resident Status,  Y,  ,  ,  ,  ,  500, 
--T,  ,  ,  ,  ,Summary_Unit_Count,  Y,  ,  ,  ,  ,  500, 
--T,  ,  ,  ,  ,Summary_Vacant_Count,  Y,  ,  ,  ,  ,  500, 
--T,  ,  ,  ,  ,Summary_Occupied_Count,  Y,  ,  ,  ,  ,  500, 
--T,  ,  ,  ,  ,Summary_Resident_Count,  Y,  ,  ,  ,  ,  500, 
--T,  ,  ,  ,  ,Summary_Scheduled_MoveIn_Count,  Y,  ,  ,  ,  ,  500, 
--T,  ,  ,  ,  ,Summary_Scheduled_MoveOut_Count,  Y,  ,  ,  ,  ,  500, 
--I,  ,  ,  ,  ,     Budget,  Y,  ,  ,  ,  ,  500, 
--//End Columns

--//Filter
--//Type, DataTyp,Name,           Caption,      Key,   List,         Val1,                    Val2, 	Mandatory,Multi-Type, Title  Title
--C,       T,       p.hmy,                        Community,     ,         61,         p.hmy=#p.hmy#,        ,         N,     Y,    Y,
--//end filter
