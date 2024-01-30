select top 10 * from seniorresidenthistory

--select * from listoption
select ireason from TENANT
select top 10 * from ServiceInstance si
	join service s on s.serviceid = si.ServiceID
	join seniorresidenthistory srh on srh.ResidentID = si.ResidentID
where ServiceClassID = 1 and ServiceInstanceActiveFlag = 1 and ServiceInstanceFromDate <= ISNULL(ServiceInstanceToDate,ServiceInstanceFromDate)
	
select name from syscolumns sc1 where id = object_id('seniorresidenthistory') 
and exists(select 1 from syscolumns sc2 where sc2.name = sc1.name and sc2.id = object_id('ServiceInstance'))
select distinct(ireason) from tenant

SELECT      c.name  AS 'ColumnName'
            ,t.name AS 'TableName'
FROM        sys.columns c
JOIN        sys.tables  t   ON c.object_id = t.object_id
WHERE       c.name LIKE '%ListOptionName%'
ORDER BY    TableName
            ,ColumnName;


select distinct(residentstatuscode) from seniorresidenthistory
where residentstatuscode IN (0, 1, 4, 11 )

select * from seniorprospectsource


select * from ListOption
where listoptionname in ('Internet','Other','Referral') and listname ='SourceType'
order by listoptionname desc

select * from ListOption
where 
--listname = 'SourceType' and  
listoptionname in ( 'Higher LOC-Nursing Home',
	   'Higher LOC-Hospice','Death-At Community','Death-Outside Community',
	   'Dissatisfied-Family Home','Financial-Competitor','Financial-Family Home','Health improved')
order by listoptionname desc

where listname like '%MoveOutReason'
where listname = 'SourceType' and (ListName = 'MoveOutReason')

select htenant from seniorprospect 
s join tenant t on s.htenant = t.HMYPERSON
where 1=1
--select 
hmyperson from tenant
where 1=1

select * from SeniorResidentHistoryStatus shrs left join seniorresidenthistory srs on shrs.hresident = srs.ResidentID
where dtmoveout between '2021-07-01 00:00:00.000' and '2021-07-31 00:00:00.000' and hproperty = 25
/*
select * 
from SeniorResidentHistoryStatus
*/

select 
	distinct(hresident)
	,t.dtmovein 
	--,nullif(
	,*
from SeniorResidentHistoryStatus shrs
LEFT JOIN tenant t on shrs.hresident = t.HMYPERSON
where t.dtmovein  between '2021-07-1 00:00:00.000' 
and '2021-07-30 00:00:00.000' and shrs.hproperty = 25 
and 
hresident in (115067,117107,116936)-- and istatuscode = 0


select 
	distinct(hresident)
	,t.dtmovein 
	--,nullif(
	,*
from SeniorResidentHistoryStatus shrs
LEFT JOIN tenant t on shrs.hresident = t.HMYPERSON
where t.dtmovein  between '2021-07-1 00:00:00.000' 
and '2021-07-30 00:00:00.000' and shrs.hproperty = 25-- and istatuscode = 0



select 
	distinct(hresident)
	,t.dtmoveout 
	--,nullif(
from SeniorResidentHistoryStatus shrs
LEFT JOIN tenant t on shrs.hresident = t.HMYPERSON
where t.dtmoveout  between '2021-07-1 00:00:00.000' 
and '2021-07-30 00:00:00.000' and shrs.hproperty = 25-- and istatuscode = 0

--select * from seniorresidenthistory 
select hmyperson from tenant 
where dtmovein ='2021-07-28 00:00:00.000'
declare @month datetime
declare @year datetime
set @Month = DATEPART(MONTH FROM '2021-07-01 00:00:00.000')
set @year = DATEPART(YEAR FROM '2021-07-01 00:00:00.000')
select DATEPART(month from dtmoveout) as monthmoveout from SeniorResidentHistoryStatus
where DATEPART(month from dtmoveout) = @month and hProperty = 25 and DATEPART(year from dtmoveout) = @year and istatuscode not in (11)

select 


where listoptioncode in ( '31',
'21',
'27')
where ListName = 'MoveOutReason'
in ( 'Higher LOC-Nursing Home',
	   'Higher LOC-Hospice','Death-At Community','Death-Outside Community',
	   'Dissatisfied-Family Home','Financial-Competitor','Financial-Family Home','Health improved')
select * from SeniorETLResident
select distinct(residentstatuscode) from SeniorResidentHistoryView

select * from INFORMATION_SCHEMA.COLUMNS 
where COLUMN_NAME like '%residentstatuscode%' 
order by TABLE_NAME


select * 
from SeniorResidentHistoryStatus


select 
	COUNT(distinct hResident) as MoveOutCount
	--,hmy
	--,t.scode
	--,t.DTMOVEIN
	--,t.DTMOVEOUT
	--,t.slastname
	--,t.sfirstname
	--,shrs.hproperty
	--,ServiceInstanceActiveFlag
	--,iStatusCode
	,Isnull(l3.listoptionname, '*None')	AS Description
	--*
from SeniorResidentHistoryStatus shrs
INNER JOIN tenant t on shrs.hresident = t.HMYPERSON
INNER JOIN ServiceInstance si on shrs.hresident = si.ResidentID
left join service  s on s.serviceid = si.ServiceID and ServiceClassID = 1 and ServiceInstanceFromDate <= ISNULL(ServiceInstanceToDate,ServiceInstanceFromDate)
join seniorprospect sp on sp.htenant=t.hmyperson
LEFT JOIN seniorprospectsource sps	ON sps.sourceid = sp.hsource
       LEFT JOIN listoption ls	ON ls.listoptioncode = sps.sourcetypecode --AND ls.listoptionname in ('12','14','20','21','25','2','31','5')
       LEFT JOIN listoption l3	ON (convert(varchar(10),t.ireason) = l3.listoptioncode and l3.ListName = 'MoveOutReason')
where t.DTMOVEOUT  between '2021-07-1 00:00:00.000' 
and '2021-07-31 00:00:00.000' and shrs.hproperty = 27
and ServiceInstanceActiveFlag = 1
--where t.DTMOVEOUT  between '2021-07-1 00:00:00.000' 
--and '2021-07-31 00:00:00.000' and shrs.hproperty = 1
and iStatusCode = 0
group by l3.listoptionname

order by t.DTMOVEOUT

select * from seniorunit

select * from SeniorResidentHistory
where hResident = 116810

select * from tenant
--where scode = '00007872'
where slastname = 'Rasey' and sfirstname = 'Jack'
select * from tenant
where hmyperson = 117571

select 
*
	--ServiceInstanceActiveFlag
	--,t.DTMOVEIN
	--,t.DTMOVEOUT 
	from tenant t
join ServiceInstance si on t.HMYPERSON = si.ResidentID
where scode in ( '00008833' , '00009010')
slastname = 'Thomson' and sfirstname = 'Jimmy Ray'

select scode,hmy from property order by hmy asc where scode = 'mpall'
select ServiceInstanceToDate,* from ServiceInstance
order by serviceInstanceAmount desc
select * from property
select * from tenant
select * from ListOptionValue




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
  FROM   dbo.Senior_listhandler(@hprop , 'hmy') pr     
  INNER JOIN Property p  ON (p.HMY = pr.hmy)   



CREATE TABLE #tmpPrivacyListOptionValue(    
      ListName varchar(50),    
      ListOptionCode varchar(50),    
      ListColumnID numeric(18,0),    
      ListOptionValue varchar(200)    
  )    
  INSERT INTO #tmpPrivacyListOptionValue    
  SELECT lv.ListName, lv.ListOptionCode, lv.ListColumnID,     
      CASE WHEN lv.ListOptionCode in ('SEC') THEN 1    
      WHEN lv.ListOptionCode in ('DAS','DBS') THEN 0.5    
      WHEN lv.ListOptionCode in ('TAS','TBS','TCS') THEN 0.333    
      WHEN lv.ListOptionCode in ('QAS','QBS','QCS','QDS') THEN 0.25      
     ELSE lv.ListOptionValue    
         END    
  FROM ListOptionValue Lv WHERE Lv.listname = 'PrivacyLevel'   

  select * from #tmpPrivacyListOptionValue