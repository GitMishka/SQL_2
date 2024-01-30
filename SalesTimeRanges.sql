declare @mydate datetime = getdate()
set @mydate = DATEADD(month, DATEDIFF(month, 0, @mydate), 0) --first day of the month
print @mydate



DECLARE
@current_date INT ,
@current_date2 datetime = getdate(),
@wk_startdate DATETIME,
@wk_enddate DATETIME,
@mtd_startdate DATETIME,
@mtd_enddate DATETIME,
@lm_startdate DATETIME,
@lm_enddate DATETIME
,@testdate DATETIME

--print eomonth(getdate())

SET @current_date = DATEPART(WEEKDAY, GETDATE())
SET @wk_startdate = DATEADD(day, -1 * (( @current_date % 7) - 1), GETDATE())
print  @wk_startdate

SET @wk_enddate = dateadd(SECOND, 21600, @wk_startdate)
print @wk_enddate
SET @mtd_startdate = DATEADD(month, DATEDIFF(month, 0, @current_date2), 0) --first day of the month
--print @mtd_startdate
SET @mtd_enddate = eomonth(getdate()) 
print @mtd_enddate
set @testdate = dateadd(second,86399, @mtd_enddate)
print @testdate
SET @lm_startdate = CONVERT(DATE, DATEADD(d, -( DAY(DATEADD(m, -1, @wk_enddate - 2)) ), DATEADD(m, -1, @wk_enddate - 1))) 
--print @lm_startdate
SET @lm_enddate = CONVERT(DATE, DATEADD(d, -( DAY(@wk_enddate) ), @wk_enddate))
--print @lm_enddate



--select distinct case when isnull(ltrim(rtrim(a.SubGroup2)),'') = '' then '???' else  ltrim(rtrim(a.SubGroup2)) end as Region 
--from Attributes a where a.SubGroup3 in ('Stabilized','Focus','Start Up') order by Region",ltrim(rtrim(Region))='#regions#'



