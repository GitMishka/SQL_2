DECLARE
@wk_startdate DATETIME,
@wk_enddate DATETIME,
@mtd_startdate DATETIME,
@mtd_enddate DATETIME,
@lm_startdate DATETIME,
@lm_enddate DATETIME,
@lw_startdate datetime,
@lw_enddate datetime



SET @wk_enddate = dateadd(DAY,6,@wk_startdate) 
SET @mtd_startdate = DATEADD(month, DATEDIFF(month, 0, @wk_enddate), 0)



SET @wk_startdate = '2022-04-26'
SET @wk_enddate = dateadd(SECOND,604799,@wk_startdate) 

set @lw_startdate = dateadd(SECOND,-604800,@wk_startdate) 
set @lw_enddate = dateadd(hour,-1,@wk_startdate) 
/*
print @wk_enddate
print convert(varchar,@lw_startdate) + ' start'
print convert(varchar,@lw_enddate) + ' end'
*/

SET @mtd_startdate = DATEADD(month, DATEDIFF(month, 0, @wk_enddate), 0)
SET @mtd_enddate = @wk_enddate  

SET @lm_startdate = DATEADD(DAY,1,EOMONTH(@wk_enddate,-2)) 
SET @lm_enddate = EOMONTH(dateadd(month, -1, @wk_enddate)) 



print @wk_startdate 
print @wk_enddate
print @mtd_startdate
print @mtd_enddate
print @lm_startdate
print @lm_enddate