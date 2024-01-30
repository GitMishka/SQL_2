select Distinct(ActivityName),activityid,ActivityCategory from seniorprospectactivity
--where ActivityCategory = 'PFU'
where ActivityCategory in ('NRF','MSC','ERA','PFU','INI')
select * from seniorprospectactivity

--where ActivityName = 'Walk in'
where activitycategory = 'INI'

select * from seniorprospectactivity
where ActivityName = 'Attended Event'

--select * from seniorProspectHistory
--where ActivityID in (
--'119'
--,'121'
--,'122'
--,'123'
--,'126'
--,'120'
--,'124'
--,'125'
--,'133'
--,'134'
--,'135'
--,'136') and dtCompleted between '2021-08-04' and '2021-08-10'


--DECLARE
--@wk_startdate DATETIME,
--@wk_enddate DATETIME,
--@mtd_startdate DATETIME,
--@mtd_enddate DATETIME,
--@lm_startdate DATETIME,
--@lm_enddate DATETIME

--SET @wk_startdate = '8/04/21'
--SET @wk_enddate = dateadd(SECOND,604799,@wk_startdate) 
--SET @mtd_startdate = DATEADD(month, DATEDIFF(month, 0, @wk_enddate), 0)
--SET @mtd_enddate = @wk_enddate  
--SET @lm_startdate = CONVERT(DATE, DATEADD(d, -( DAY(DATEADD(m, -1, @wk_enddate - 2)) ), DATEADD(m, -1, @wk_enddate - 1))) 
--SET @lm_enddate = DATEADD(d, -( DAY(@wk_enddate) ), @wk_enddate)

--select * from SeniorProspectActivity
