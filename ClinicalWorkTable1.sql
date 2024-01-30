select * from SeniorPrivacyLevelMapping




Declare @SeedDate date = getdate()
Declare @YTD_End date = convert(date,DATEADD(DAY, -(DAY(@SeedDate)), @SeedDate))
Declare @YTD_Begin date = DATEADD(yy, DATEDIFF(yy, 0, @YTD_End), 0)
Declare @MonthsLookBack int = 6 /* 6 for Normal Execution of Report */

Declare @EvalProperties table ( hprop int, name varchar(250))
insert into @EvalProperties select a.hProp, case when isnull(ltrim(rtrim(a.SubGroup2)),'') = '' then '???' else  ltrim(rtrim(a.SubGroup2)) end from attributes a where a.SubGroup3 in ('Stabilized','Focus','Start Up') and case when isnull(ltrim(rtrim(a.SubGroup2)),'') = '' then '???' else  ltrim(rtrim(a.SubGroup2)) end ='#selection#' 
insert into @EvalProperties select a.hProp, case when ltrim(rtrim(a.sPropName)) like '%Lantern%' then replace(replace(ltrim(rtrim(a.sPropName)),'The Lantern at Morning Pointe of ','') + ' ' +'Lantern',',','') else replace(replace(ltrim(rtrim(a.sPropName)),'Morning Pointe of ',''),',','') end from attributes a where a.SubGroup3 in ('Stabilized','Focus','Start Up') and case when ltrim(rtrim(a.sPropName)) like '%Lantern%' then replace(replace(ltrim(rtrim(a.sPropName)),'The Lantern at Morning Pointe of ','') + ' ' +'Lantern',',','') else replace(replace(ltrim(rtrim(a.sPropName)),'Morning Pointe of ',''),',','') end ='#selection#'   
/* insert into @EvalProperties select a.hProp from attributes a where a.SubGroup3 in ('Stabilized','Focus','Start Up')   */
insert into @EvalProperties Select 20, 'aths'

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


	select	
	rl.EvalMonth	
  	,Count(rl.EvalMonth) as Cell_Data
	from (select distinct hMyPerson, MoveIn_Date, EvalMonth from #Resident_List) rl
 	WHERE LEFT(CONVERT(varchar, rl.MoveIn_Date,112),6) = rl.EvalMonth
	Group by
	rl.EvalMonth


	drop table #DateList

drop table #Resident_List

select Ltrim(Rtrim(p.sAddr1))  from property p
select p.sAddr1  from property p
select * from ResidentHistoryCode

declare @hprop varchar(1000) set @hprop= 20
 SELECT DISTINCT p.hmy   PropertyID,     
                  p.scode PropertyCode,     
                  Ltrim(Rtrim(p.sAddr1)) PropertyName,    
      ''    
  FROM   dbo.Senior_listhandler(@hprop , 'hmy') pr     
  INNER JOIN Property p  ON (p.HMY = pr.hmy) 


select * from SeniorResidentHistoryStatus
where 
dtto between '2022-01-01' and '2022-01-31' 
and dtmoveout between '2022-01-01' and '2022-01-31' 
and dtmoveout is not null
and sPrivacyLevelCode = 'PRI'
and sContractTypeCode in ( 'PER' )

select distinct(sContractTypeCode) from SeniorResidentHistoryStatus

select * from ServiceInstance
select * from tenant
select istatus, * from tenant
where dtmoveout between '2022-01-01' and '2022-01-31' and HPROPERTY = 21

select * from property where saddr1 like '%Pointe of%' order by scode desc 

select p.SADDR1,p.SCODE,count(dtmoveout) from property p
join tenant t on t.HPROPERTY = p.hmy
where dtmoveout between '2022-01-01' and '2022-01-31' 
group by p.SADDR1,p.SCODE
order by 1 asc


select p.SADDR1,p.SCODE from property p
join tenant t on t.HPROPERTY = p.hmy
where dtmoveout between '2022-01-01' and '2022-01-31' 
group by p.SADDR1,p.SCODE
order by 1 asc



select p.SADDR1,p.SCODE,count(dtmovein) from property p
join tenant t on t.HPROPERTY = p.hmy
where dtmovein between '2022-01-01' and '2022-01-31' 
group by p.SADDR1,p.SCODE
order by 1 asc

select p.SADDR1,p.SCODE from property p
join tenant t on t.HPROPERTY = p.hmy
where dtmovein between '2022-01-01' and '2022-01-31' 
group by p.SADDR1,p.SCODE
order by 1 asc


select p.SADDR1,p.SCODE from property p
join tenant t on t.HPROPERTY = p.hmy
where dtmoveout between '2022-01-01' and '2022-01-31' 
group by p.SADDR1,p.SCODE
order by 1 desc



select count(ResidentID) from SeniorResidentHistory
where ResidentHistoryDate between '2022-01-01' and '2022-01-31' 
and MoveOutReasonCode is  null 
and ResidentHistoryCode in ('AUN', 'MIN', 'QIK','CMO','OUT','CVT')  
and ResidentStatusCode IN (0,1,4,11) 


--select * from property order by scode asc

SELECT      c.name  AS 'ColumnName'
            ,t.name AS 'TableName'
FROM        sys.columns c
JOIN        sys.tables  t   ON c.object_id = t.object_id
WHERE       c.name LIKE '%scontracttype'
ORDER BY    TableName
            ,ColumnName;



IF OBJECT_ID ('TempDb..#FinancialMoveOut') IS NOT NULL
DROP TABLE #FinancialMoveOut



Declare @SeedDate date = getdate()
Declare @YTD_End date = convert(date,DATEADD(DAY, -(DAY(@SeedDate)), @SeedDate))
Declare @YTD_Begin date = DATEADD(yy, DATEDIFF(yy, 0, @YTD_End), 0)
declare @propertycode varchar(1000)
set @propertycode = 20

CREATE TABLE #FinancialMoveOut (
phMy INT,
propname varchar(100),
sResidentName varchar(255),
istatus INT,
ThMy INT,
moveindate DATETIME ,
Noticedate DATETIME ,
moveoutdate DATETIME ,
uhmy NUMERIC,
uscode VARCHAR (8),
utscode VARCHAR (8),
utsdesc VARCHAR (40),
privacylevel VARCHAR (20) ,
carelevel VARCHAR (20) ,
Moveoutreason SmallInt ,
BillingEndDate DATETIME ,
ContTyp VARCHAR (20)
)

INSERT INTO #FinancialMoveOut
EXEC SeniorMoveInMoveOutDetailFinancial 'MoveOut'
	,@PropertyCode
	,NULL
	,'Actual'
	--,@carelev
	,NULL
	--,@ContTyp
	,@YTD_Begin
	,@YTD_End
	,NULL
	,NULL
	,NULL
	,'Yes'
	,NULL
--	,@OccType

IF OBJECT_ID ('TempDb..#MoveOutsFinal') IS NOT NULL
DROP TABLE #MoveOutsFinal

SELECT phMy,PropName,MONTH(BillingEndDate) Rep_Month, YEAR(BillingEndDate) Rep_Year,
sum(case 
when d.privacylevel = 'PRI' then 1
when d.privacylevel in ('SPA', 'SPB') then 0.5
when d.privacylevel in ('TOA', 'TOB', 'TOC') then 0.3
when d.privacylevel in ('QDA', 'QDB', 'QDC', 'QDD') then 0.25
else 0 end ) as Cnt
INTO #MoveOutsFinal
from #FinancialMoveOut d
GROUP BY phMy,PropName,MONTH(BillingEndDate), YEAR(BillingEndDate)


Declare @Report_Header_Description Varchar(MAX); 
Select @Report_Header_Description = COALESCE(@Report_Header_Description + ', ' + a.Name, a.Name) 
        From (select distinct Name from @EvalProperties) a



sp_helptext SeniorMoveInMoveOutDetailFinancial



declare
   --(    
    @Type VARCHAR(20)    
    ,@PropertyCode VARCHAR(MAX)    
    ,@grp VARCHAR(20)    
    ,@sStatus VARCHAR(30)    
    ,@carelev VARCHAR(MAX)    
    ,@ResStatus VARCHAR(MAX)    
    ,@ContTyp VARCHAR(MAX)    
    ,@sDat1 DATETIME    
    ,@sDat2 DATETIME    
    ,@srDat1 DATETIME    
    ,@srDat2 DATETIME    
    ,@DpDate DATETIME    
    ,@SecResident VARCHAR(3)    
    ,@DispRate VARCHAR(3)    
   ,@OccType VARCHAR(20)
   ,@BegDefault DATETIME,    
          @EndDefault DATETIME,    
    @BegVirtual DATETIME,    
          @EndVirtual DATETIME,    
    @BOMActual  DATETIME;    
  SET @BegDefault = '01/01/1900';    
  SET @EndDefault = '12/31/2200';    
  --???No Need this concept???    
  SET @BOMActual  = @sDat1  

   IF OBJECT_ID ('TempDb..#TempResidentHistoryStatusOut') IS NOT NULL    
                   DROP TABLE #TempResidentHistoryStatusOut  
				   
	CREATE TABLE #tmpProperty (    
        PropertyID  NUMERIC,      
        PropertyCode CHAR(8),      
        PropertyName VARCHAR(255),      
        Property  VARCHAR(266)      
  )    
  INSERT INTO #tmpProperty    
  SELECT DISTINCT p.hmy   PropertyID,     
                  p.scode PropertyCode,     
                  Ltrim(Rtrim(p.sAddr1)) PropertyName,    
      ''    
  FROM   dbo.Senior_listhandler(@PropertyCode , 'code') pr     
  INNER JOIN Property p  ON (RTRIM(p.scode) = RTRIM(pr.scode))   
     CREATE TABLE #TempResidentHistoryStatusOut    
     (    
       ID NUMERIC,    
       hResident NUMERIC(18, 0),    
       dtMoveIn DATETIME,    
       dtMoveOut DATETIME,    
       ServiceInstanceID NUMERIC(18, 0),    
       ServiceInstanceIDOut NUMERIC(18, 0),    
       iMoveOutReason NUMERIC(2, 0),    
       dtBillingEnd DATETIME,    
       dtNotice DATETIME,    
       dtServiceFrom DATETIME    
     )  
INSERT INTO #TempResidentHistoryStatusOut    
     SELECT Distinct 1, hResident, dtMovein, NULL dtMoveOut, NULL ServiceInstanceID, NULL ServiceInstanceIDOut, null, null, null, null--srh2.iMoveOutReason, srh2.dtBillingEnd    
     FROM #tmpProperty p     
      INNER JOIN ListProp2 l ON l.hProplist = p.PropertyID AND l.iType <> 11    
      INNER JOIN SeniorResidentHistoryStatus srh2  on p.PropertyID = srh2.hProperty    
      AND srh2.iStatusCode IN (0, 4,11, 1) --???DEBUG    
     WHERE srh2.dtFROM <= ISNULL(srh2.dtto, srh2.dtfrom)      
      AND srh2.dtFROM <= CONVERT(DATETIME, @EndVirtual, 101)    
     /* This will update ID in sequence of movein's*/    
     UPDATE  #TempResidentHistoryStatusOut SET ID = Rownum    
     FROM #TempResidentHistoryStatusOut tmp    
      Inner join (SELECT Row_Number() Over (partition by hResident ORDER BY dtMovein) rownum,* FROM #TempResidentHistoryStatusOut) a on a.hResident = tmp.hResident     
      AND a.dtMovein = tmp.dtMovein    
     /* Update correct Move-out date for respective movein*/    
     UPDATE  tmp SET tmp.dtMoveOut = srh2.dtMoveOut --???06/04/2021???    
     FROM SeniorResidentHistoryStatus srh2     
      INNER JOIN #TempResidentHistoryStatusOut tmp on tmp.hResident = srh2.hResident    
     WHERE Srh2.dtMovein  = tmp.dtMovein    
      --AND srh2.dtFROM <= ISNULL(srh2.dtto, srh2.dtfrom)  --Defect#180792    
      AND srh2.dtFROM <= CONVERT(DATETIME, @srDat2, 101)    
      AND srh2.istatuscode =1    

