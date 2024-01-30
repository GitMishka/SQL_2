select dateadd(mm, 0, 0) as BeginningOfTime
      ,dateadd(dd, datediff(dd, 0, getdate()), 0) as Today
      ,dateadd(wk, datediff(wk, 0, getdate()), 0) as ThisWeekStart
      ,dateadd(mm, datediff(mm, 0, getdate()), 0) as ThisMonthStart
      ,dateadd(qq, datediff(qq, 0, getdate()), 0) as ThisQuarterStart
      ,dateadd(yy, datediff(yy, 0, getdate()), 0) as ThisYearStart
      ,dateadd(dd, datediff(dd, 0, getdate()) + 1, 0) as Tomorrow
      ,dateadd(wk, datediff(wk, 0, getdate()) + 1, 0) as NextWeekStart
      ,dateadd(mm, datediff(mm, 0, getdate()) + 1, 0) as NextMonthStart
      ,dateadd(qq, datediff(qq, 0, getdate()) + 1, 0) as NextQuarterStart
      ,dateadd(yy, datediff(yy, 0, getdate()) + 1, 0) as NextYearStart
      ,dateadd(ms, -3, dateadd(dd, datediff(dd, 0, getdate()) + 1, 0)) as TodayEnd
      ,dateadd(ms, -3, dateadd(wk, datediff(wk, 0, getdate()) + 1, 0)) as ThisWeekEnd
      ,dateadd(ms, -3, dateadd(mm, datediff(mm, 0, getdate()) + 1, 0)) as ThisMonthEnd
      ,dateadd(ms, -3, dateadd(qq, datediff(qq, 0, getdate()) + 1, 0)) as ThisQuarterEnd
      ,dateadd(ms, -3, dateadd(yy, datediff(yy, 0, getdate()) + 1, 0)) as ThisYearEnd