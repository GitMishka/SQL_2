select * from information_schema.tables where table_name like '%login%'

select * from auditlogin  
where table_name like '%user%'
select * from person where ulastname like '%Grigoryan%'
select datename(month,datepart(month,[date])),* from SeniorBIDashboardLog order by sname desc

select * from [EMAIL_QUE] where ssender like '%Lauren%'

select sname,
case
	when sname like '%CRD%' then 'DON'
	when sname like '%ED%' then 'ED' 
	when sname like '%DON%' then 'DON'
	when sname like '%ihpllc%' then 'Home Office'
	end as position,
case  
	when sname like '%louisville then louisville'
when sname like '%knoxville then knoxville'
when sname like '%clinton then clinton'
when sname like '%danville then danville'
when sname like '%hardinvalley then hardinvalley'
when sname like '%lenoir then lenoir'
when sname like '%chattanooga then chattanooga'
when sname like '%hixson then hixson'
when sname like '%collegedale then collegedale'
when sname like '%louisville then louisville'
when sname like '%frankfort then frankfort'
when sname like '%greeneville then greeneville'
when sname like '%lenoir then lenoir'
when sname like '%franklintn then franklintn'
when sname like '%hardinvalley then hardinvalley'
when sname like '%athens then athens'
when sname like '%franklin then franklin'
when sname like '%lexington then lexington'
when sname like '%springhill then springhill'
when sname like '%tullahoma then tullahoma'
when sname like '%brentwood then brentwood'
when sname like '%calhoun then calhoun'
when sname like '%russell then russell'
when sname like '%springhill then springhill'
when sname like '%tuscaloosa then tuscaloosa'
when sname like '%greenbriar then greenbriar'
when sname like '%lexington then lexington'
when sname like '%danville then danville'
when sname like '%springhill then springhill'
when sname like '%lexingtoneast then lexingtoneast'
when sname like '%knoxville then knoxville'
when sname like '%clinton then clinton'
when sname like '%louisville then louisville'
when sname like '%tullahoma then tullahoma'
when sname like '%jhubbard@morningpointe.com then jhubbard@morningpointe.com'
when sname like '%columbia then columbia'
when sname like '%powell then powell'
when sname like '%richmond then richmond'
when sname like '%lexington then lexington'
when sname like '%russell then russell'
when sname like '%powell then powell'
when sname like '%hixson then hixson'
when sname like '%lexingtoneast then lexingtoneast'
when sname like '%louisville then louisville'
when sname like '%russell then russell'
when sname like '%calhoun then calhoun'
end as Community
count(sname) view_count from SeniorBIDashboardLog 
group by sname,dashboardname
order by sname desc

select distinct(sname) from SeniorBIDashboardLog where sname like '%morning%'

select distinct(sourcetype) from SeniorBICommunityMIMODetail

select ReferralCategory,* from SeniorProspectSource
select distinct(ReferralCategory) from SeniorProspectSource order by 1 asc

select * from users

select sname
,case
when sname like '%ihp%' or sname like '%morning%' then concat(sfirstname,' ',ulastname)
else sname
end as full_name
,case
	when sname like '%CRD%' then 'DON'
	when sname like '%ED%' then 'ED' 
	when sname like '%DON%' then 'DON'
	when sname like '%ihpllc%' then 'IHP'
	when sname like '%yardi%' then 'Yardi'
	end as position
,case  
	when sname like '%louisville-lan%' then 'louisville-lan'
	when sname like '%knoxville-lan%' then 'knoxville-lan'
	when sname like '%clinton-lan%' then 'clinton-lan'
	when sname like '%danville%' then 'danville'
	when sname like '%hardinvalley%' then 'hardinvalley'
	when sname like '%lenoir%' then 'lenoir'
	when sname like '%chattanooga%' then 'chattanooga'
	when sname like '%hixson%' then 'hixson'
	when sname like '%collegedale-lan%' then 'collegedale-lan'
	when sname like '%louisville%' then 'louisville'
	when sname like '%frankfort%' then 'frankfort'
	when sname like '%greeneville%' then 'greeneville'
	when sname like '%lenoir-lan%' then 'lenoir-lan'
	when sname like '%franklintn-lan%' then 'franklintn-lan'
	when sname like '%hardinvalley%' then 'hardinvalley'
	when sname like '%athens%' then 'athens'
	when sname like '%franklin%' then 'franklin'
	when sname like '%lexington-lan%' then 'lexington-lan'
	when sname like '%springhill%' then 'springhill'
	when sname like '%tullahoma%' then 'tullahoma'
	when sname like '%brentwood%' then 'brentwood'
	when sname like '%calhoun%' then 'calhoun'
	when sname like '%russell%' then 'russell'
	when sname like '%springhill-lan%' then 'springhill-lan'
	when sname like '%tuscaloosa%' then 'tuscaloosa'
	when sname like '%greenbriar%' then 'greenbriar'
	when sname like '%lexington%' then 'lexington'
	when sname like '%danville%' then 'danville'
	when sname like '%springhill-lan%' then 'springhill-lan'
	when sname like '%lexingtoneast%' then 'lexingtoneast'
	when sname like '%knoxville%' then 'knoxville'
	when sname like '%clinton-lan%' then 'clinton-lan'
	when sname like '%louisville%' then 'louisville'
	when sname like '%tullahoma%' then 'tullahoma'
	when sname like '%jhubbard@morningpointe.com%' then 'jhubbard@morningpointe.com'
	when sname like '%columbia%' then 'columbia'
	when sname like '%powell-lan%' then 'powell-lan'
	when sname like '%richmond%' then 'richmond'
	when sname like '%lexington-lan%' then 'lexington-lan'
	when sname like '%russell-lan%' then 'russell-lan'
	when sname like '%powell%' then 'powell'
	when sname like '%hixson%' then 'hixson'
	when sname like '%lexingtoneast%' then 'lexingtoneast'
	when sname like '%louisville-lan%' then 'louisville-lan'
	when sname like '%russell-lan%' then 'russell-lan'
	when sname like '%calhoun%' then 'calhoun'
	when sname like '%ihp%' then 'Home Office'
	when sname like '%yardi%' then 'Yardi'
	end as Community
	,bi.hmy
	,cast([date] as date) date_accessed
	,scode
	,dashboardname
	,dashboardid
from SeniorBIDashboardLog BI
join person p on bi.sName = p.SEMAIL
order by hmy asc


select date from SeniorBIDashboardLog where date = getdate() -30