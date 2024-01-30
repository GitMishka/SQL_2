Select p.saddr1+' (' +rtrim(p.scode)+')' 'Community', pers.sfirstname+' '+pers.ulastname+' ('+rtrim(t.scode)+')' 'Resident Name', u.scode 'Unit'
, c.sname ServiceName
, src.RecurringChargeFromDate 'From Date', src.RecurringChargeToDate 'To Date', src.RecurringChargeAmount 'Amount'
, src.CareLevelCode 'Care Level', src.PrivacyLevelCode 'Privacy Level', src.RateTypeCode 'Rate Type'
, 'Other Recurring' as ServiceClassName
, t.DTLEASETO
, srs.Status
, datediff(d,t.dtmovein, isnull(t.dtmoveout, getdate())) as 'Length_of_stay'
from seniorRecurringCharge SRC
left join SeniorResident SR on Src.ResidentID = SR.ResidentID
left join Person Pers on Src.ResidentID = pers.hmy
left join Tenant T on pers.hmy = t.hmyperson
left join Property P on t.hproperty = p.hmy
left join Unit U on src.UnitID = u.hmy
left join chargtyp c on src.chargetypeid = c.hmy
left join SeniorResidentSTatus SRS on t.istatus = srs.iStatus
where 1=1
and Src.RecurringChargeActiveFlag = 1
--and getdate() between src.RecurringChargeFromDate and isnull(src.RecurringChargeToDate,getdate())
and src.RecurringChargeAmount < 0
and t.dtmovein >='1/1/2021'
and SRS.Status not in ('Cancelled')
Order by 1,2




Select p.saddr1+' (' +rtrim(p.scode)+')' 'Community', pers.sfirstname+' '+pers.ulastname+' ('+rtrim(t.scode)+')' 'Resident Name', u.scode 'Unit'
, c.sname 'Discount Type'
, t.dtmovein 'Move In'
, DTMOVEOUT 'Moved Out'
, src.RecurringChargeFromDate 'From Date', src.RecurringChargeToDate 'To Date', src.RecurringChargeAmount 'Amount'
, src.CareLevelCode 'Care Level', src.PrivacyLevelCode 'Privacy Level', src.RateTypeCode 'Rate Type'
, 'Other Recurring' as ServiceClassName
, t.DTLEASETO
, srs.Status
, datediff(d,t.dtmovein, isnull(t.dtmoveout, getdate())) as 'Length_of_stay'

from seniorRecurringCharge SRC
left join SeniorResident SR on Src.ResidentID = SR.ResidentID
left join Person Pers on Src.ResidentID = pers.hmy
left join Tenant T on pers.hmy = t.hmyperson
left join Property P on t.hproperty = p.hmy
left join Unit U on src.UnitID = u.hmy
left join chargtyp c on src.chargetypeid = c.hmy
left join SeniorResidentSTatus SRS on t.istatus = srs.iStatus
where 1=1
and c.sname like '%Room Discount%'
and Src.RecurringChargeActiveFlag = 1
--and getdate() between src.RecurringChargeFromDate and isnull(src.RecurringChargeToDate,getdate())
and src.RecurringChargeAmount < 0
and t.dtmovein >='2021-01-01'
and SRS.Status not in ('Cancelled')
Order by 1,2;




