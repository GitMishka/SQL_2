select distinct(saddr1) 
from property 
where saddr1 like '%Morning%'


select * from property


select * from SeniorCRMGoalMeasures
select * from SeniorCRMCommunityMonthlyMeasures
select * from SeniorCRMCommunityWeeklyMeasures
select * from SeniorCRMCommunityWeeklyMeasuresDetail

insert into #Sales_Goals select 'aths','WK',20, (select dDefault from SeniorCRMCommunityMonthlyMeasures 
where dtcreated = (select max(dtcreated) from SeniorCRMCommunityMonthlyMeasures) and hProperty = 1 and hSeniorCRMGoalMeasures = 19)

select *--, max(w.dtlastmodified)--, max(m.dtlastmodified) 
from SeniorCRMCommunityMonthlyMeasures m  
	left join SeniorCRMCommunityWeeklyMeasures w 
		on m.hProperty = w.hProperty
--group by m.hProperty, m.hMy


select * from SeniorCRMCommunityMonthlyMeasures 
where dtcreated = (select max(dtcreated) 
from SeniorCRMCommunityMonthlyMeasures) and hProperty = 1 and hSeniorCRMGoalMeasures = 19


select distinct(hSeniorCRMGoalMeasures) from SeniorCRMCommunityMonthlyMeasures order by 1 asc