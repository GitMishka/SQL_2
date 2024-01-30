DECLARE
@wk_startdate DATETIME,
@wk_enddate DATETIME,
@mtd_startdate DATETIME,
@mtd_enddate DATETIME,
@lm_startdate DATETIME,
@lm_enddate DATETIME

SET @wk_startdate = '2022-04-26'
SET @wk_enddate = dateadd(DAY,6,@wk_startdate) 
SET @mtd_startdate = DATEADD(month, DATEDIFF(month, 0, @wk_enddate), 0)
SET @mtd_enddate = @wk_enddate  
SET @lm_startdate = CONVERT(DATE, DATEADD(d, -( DAY(DATEADD(m, -1, @wk_enddate - 2)) ), DATEADD(m, -1, @wk_enddate - 1))) 
SET @lm_enddate = CONVERT(DATE, DATEADD(d, -( DAY(@wk_enddate) ), @wk_enddate))


print @wk_startdate 
print @wk_enddate
print @mtd_startdate
print @mtd_enddate
print @lm_startdate
print @lm_enddate
