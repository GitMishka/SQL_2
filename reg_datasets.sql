select datediff(day,DTMOVEIN,dtmoveout)as LoS,* from [Assessment] a
join tenant t on a.residentid = t.HMYPERSON
where assessmentcompleteflag = 1


select-- name as therapyname,
--datediff(day,DTMOVEIN,dtmoveout)as LoS, 
t.dtmovein as movein,t.dtmoveout as moveout,
case
	when name = 'Physical Therapy' then 1
end Physical,
case
	when name = 'Occupational Therapy' then 1
end Occupational,
case
	when name = 'Speech Therapy' then 1
end Speech,
--orderid,

residentid
--,so.dtcreated,so.dtlastmodified, active,physicianorderdate 
--into #table1
from seniororder so
join tenant t on so.ResidentID = t.HMYPERSON
where name like '%Therapy%'

drop table #table1
select datediff(day,movein,moveout)as LoS,COUNT('therapyname') OVER (PARTITION BY residentid) AS total_count, *  into #table2 from #table1
where los < 90

select * from seniororderstanding

update #table1
set moveout = (getdate()-30)
where moveout is null
print(getdate()-30)

select * from #table2 where los < 90 order by total_count desc
select count(distinct(residentid)) from #table2 where los < 90
select therapyname,count(therapyname) from #table2 where los < 90 group by therapyname 
select therapyname,count(therapyname) from #table2  group by therapyname 