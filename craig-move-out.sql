select 
		
		
		sum(CASE 
		WHEN (si.PrivacyLevelCode ='PRI') then 1
	
		WHEN (si.PrivacyLevelCode IN ('SPA', 'SPB')
		) then 0.50 end) NumOfMoveouts
		--,
--prop.scode as PropCode,
----, 
--p.sfirstname +' '+ p.ulastname 'ResidentName'
----, t.scode as ResCode 
----, srh.CreateDate
--, SRH.ResidentHistoryCode
----, lo2.ListOptionName as 'ResHistory'
----, srs.status
--, srh.ResidentHistoryDate
----, pm.scode as [user_Code]
----, rtrim(pers.sfirstname)+' '+rtrim(pers.ulastname) as 'Name'
--, lo1.ListOptionName
--, si.privacylevelcode
--, sc.ServiceClassName 
from SeniorResidentHistory SRH
left join person p on srh.residentID = p.hmy
left join tenant t on srh.residentID = t.hmyperson
left join pmuser pm on srh.createuserid = pm.hmy
left join SeniorResident SR on t.hmyperson = sr.residentID
left join SeniorResidentStatus SRS on t.istatus = srs.istatus
left join property prop on t.hproperty = prop.hmy
left join person pers on pm.scode = pers.ucode and pers.ipersontype = '79'
left join ListOption LO1 on SRH.MoveOutReasonCode = lo1.ListOptionCode and LO1.Listname = 'MoveOutReason'
left join ListOPtion Lo2 on SRH.ResidentHistoryCode = lo2.ListOPtionCode and lo2.ListName = 'ResidentHistory'
left join ServiceInstance SI on SI.ResidentID = SR.ResidentID
              and srh.ResidentHistoryDate between si.serviceinstancefromdate and isnull(si.serviceinstancetodate,getdate())
left join [Service] S on si.ServiceID = S.ServiceID
left join ServiceClass SC on S.ServiceClassID = SC.ServiceClassID
where 1=1
and srh.ResidentHistoryDate between '06-30-2021' and '07-31-2021'
--and prop.scode = 'frkt'
--and srh.residentid = 75939
and SRH.ResidentHistoryCode in ('QIK', 'OUT')
and (sc.ServiceClassName IS NULL OR sc.ServiceClassName = 'Accommodation')
--group by p.sfirstname +' '+ p.ulastname
----, t.scode as ResCode 
----, srh.CreateDate
--, SRH.ResidentHistoryCode
----, lo2.ListOptionName as 'ResHistory'
----, srs.status
--, srh.ResidentHistoryDate
----, pm.scode as [user_Code]
----, rtrim(pers.sfirstname)+' '+rtrim(pers.ulastname) as 'Name'
--, lo1.ListOptionName
--, si.privacylevelcode
--, sc.ServiceClassName 
--,prop.scode
--order by srh.CreateDate desc



--select * from SeniorResidentHistory
----select * from ServiceClass
----select * from serviceinstance where residentid=75939
--select * from tenant where SLASTNAME = 'Barnes' and SFIRSTNAME = 'Norma'
----where ipersontype = '79'
