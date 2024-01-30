
DECLARE
@wk_startdate DATETIME,
@wk_enddate DATETIME,
@mtd_startdate DATETIME,
@mtd_enddate DATETIME,
@lm_startdate DATETIME,
@lm_enddate DATETIME

SET @wk_startdate = '2022-05-10'
SET @wk_enddate = dateadd(SECOND,604799,@wk_startdate) /* CHANGED: Time range from day to seconds 9-01-2022 */
SET @mtd_startdate = DATEADD(month, DATEDIFF(month, 0, @wk_enddate), 0)
SET @mtd_enddate = @wk_enddate  
SET @lm_startdate = CONVERT(DATE, DATEADD(d, -( DAY(DATEADD(m, -1, @wk_enddate - 2)) ), DATEADD(m, -1, @wk_enddate - 1))) 
SET @lm_enddate = DATEADD(d, -( DAY(@wk_enddate) ), @wk_enddate)


select 
	p.hMy
	,p.saddr1
	,sp.hProperty
	,ph.dtCompleted
	,ph.dtDate
	,pa.ActivityCategory 
	,sp.sfirstname
	,sp.slastname
	
from 
	SeniorProspect sp
	left join SeniorProspectHistory ph on sp.hMy = ph.hProspect
	left join Property p on p.hmy = ph.hproperty
	left join SeniorProspectActivity pa on ph.ActivityID = pa.ActivityID

where 
	ph.dtCompleted between '2022-05-10' and '2022-05-16' --@wk_startdate and @wk_enddate
 and pa.ActivityCategory not in ('NRF','RFF','STT','MSC') /* CHANGED: Put in MSC to filter out unwanted activities 5-10-2022*/
					and sp.sStatus <> 'Referral'  and p.hmy = 11
	
	--select * from property 

	--select distinct(ActivityName), ActivityCategory from SeniorProspectActivity order by ActivityName desc