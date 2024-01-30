select
ph.hAgent,
  p.hMy,
  p.saddr1,
  sp.hProperty,
  ph.dtCompleted,
  ph.dtDate,
  pa.ActivityCategory,
  sp.sfirstname,
  sp.slastname
from
  SeniorProspect sp
  left join SeniorProspectHistory ph on sp.hMy = ph.hProspect
  left join Property p on p.hmy = ph.hproperty
  left join SeniorProspectActivity pa on ph.ActivityID = pa.ActivityID
where
  ph.dtCompleted between '2022-05-01'
  and '2022-05-25' --@wk_startdate and @wk_enddate
  and pa.ActivityCategory not in ('NRF', 'RFF', 'STT')--,--'PMA')
  and sp.sStatus <> 'Referral'
 and p.hmy in (79)
 --and slastname = 'Wynegar'
 order by dtCompleted desc
 select * from SeniorProspectHistory