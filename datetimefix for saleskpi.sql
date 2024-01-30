
--DECLARE
--@wk_startdate DATETIME,
--@wk_enddate DATETIME,
--@mtd_startdate DATETIME,
--@mtd_enddate DATETIME,
--@lm_startdate DATETIME,
--@lm_enddate DATETIME

--SET @wk_startdate = '06/30/2021'
--SET @wk_enddate = dateadd(SECOND,604799,@wk_startdate) 
--SET @mtd_startdate = DATEADD(month, DATEDIFF(month, 0, @wk_enddate), 0)
--SET @mtd_enddate = @wk_enddate  
--SET @lm_startdate = CONVERT(DATE, DATEADD(d, -( DAY(DATEADD(m, -1, @wk_enddate - 2)) ), DATEADD(m, -1, @wk_enddate - 1))) 
--SET @lm_enddate = DATEADD(d, -( DAY(@wk_enddate) ), @wk_enddate)
----SET @lm_enddate = CONVERT(DATE, DATEADD(d, -( DAY(@wk_enddate) ), @wk_enddate))

----print @lm_startdate --
--print @lm_enddate --print @mtd_startdate print @wk_enddate print @mtd_enddate

 select convert(varchar(10),a.ItemDate,101) as Week_Beginning  from	
 (SELECT	top 380 DATEADD(DAY, (ROW_NUMBER() OVER (ORDER BY a.object_id ) - 1) * -1, CONVERT(DATETIME, getdate())) AS ItemDate FROM	
 sys.columns a CROSS JOIN sys.columns b	) a where datepart(dw,a.ItemDate) = 3 and datediff(day,a.ItemDate,getdate()) > 6;

 
 select convert(varchar(10),a.ItemDate,101) as Week_Beginning  from	
 (SELECT	top 380 DATEADD(DAY, (ROW_NUMBER() OVER (ORDER BY a.object_id ) - 1) * -1, CONVERT(DATETIME, getdate())) AS ItemDate FROM	
 sys.columns a CROSS JOIN sys.columns b	) a where datepart(dw,a.ItemDate) = 4 and datediff(day,a.ItemDate,getdate()) > 7;

  select convert(varchar(10),a.ItemDate,101) as Week_Beginning  from	
 (SELECT	top 380 DATEADD(DAY, (ROW_NUMBER() OVER (ORDER BY a.object_id ) - 1) * -1, CONVERT(DATETIME, getdate())) AS ItemDate FROM	
 sys.columns a CROSS JOIN sys.columns b	) a where datepart(dw,a.ItemDate) = 4 and datediff(day,a.ItemDate,getdate()) > 6;

 DECLARE
@dat1 datetime
set @dat1 = '09/01/2021'
print @dat1