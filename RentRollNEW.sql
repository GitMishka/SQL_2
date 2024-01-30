 
 
--select * from property
 select 
*,
p.scode,
HPROPERTY,
sc.unitid,
sc.PrivacyLevelCode
,UnitRentMonthlyAmount
,PayorFirstName
,PayorLastName
 from seniorpayor sp 
 join seniorrecurringcharge sc
	on sp.payorid = sc.payorid
join (	SELECT  
	PrivacyLevelCode
	,unitid

        FROM SeniorUnitHistory suh
        INNER JOIN  SeniorUnitRentHistory surh on surh.UnitHistoryId = suh.UnitHistoryId 
		where unithistorytodate is null
		and UnitRentMonthlyAmount > 0
--		and unitid = 1734
)suh on sc.unitid = suh.unitid and  suh.PrivacyLevelCode = sc.PrivacyLevelCode

join (	SELECT  
	
distinct(unitid)
,PrivacyLevelCode
,UnitRentMonthlyAmount

        FROM SeniorUnitHistory suh
        INNER JOIN  SeniorUnitRentHistory surh on surh.UnitHistoryId = suh.UnitHistoryId 
		where unithistorytodate is null
		and UnitRentMonthlyAmount > 0) unit	on unit.UnitID = sc.UnitID and unit.PrivacyLevelCode = sc.PrivacyLevelCode

join unit u on u.HMY = sc.UnitID
join property p on p.HMY = u.HPROPERTY
where 


PayorLastName = 'Springfield' and PayorFirstName = 'Donna' 
and RecurringChargeToDate is NULL and RecurringChargeAmount > 0