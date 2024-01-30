select 
	--p.hMy
	--,Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')'   PropertyName
	--, 'LM'
	--, 40
	--,'Leads/Inquiries'
	--, isnull(g.goal,0)
	--, 
  -- isnull(count(distinct sp.hMy),0) as NewLeads
   distinct(isnull(sp.hMy,0)) as NewLeads
   ,dtFirstContact
   ,sp.slastname
		,sp.sfirstname
from 
	Property p
	--left join #Sales_Goals g on p.scode = g.Community_Code and g.Period = 'LM' and g.Measure = 40
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
		ph.dtDate  between '2022-05-03' and '2022-05-09'
	        and sp.sStatus <> 'Referral' and sp.dtFirstContact is not null
	) sp on p.hMy = sp.hProperty

where saddr1 like '%Pointe of%'
--Group By
	--p.hMy, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')'--, g.goal