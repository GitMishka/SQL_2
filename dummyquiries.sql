select ActivityCategory,activityname,ActivityID from SeniorProspectActivity
where ActivityCategory = 'TOU'

select * from seniorprospectsource
--where activityname = 'INI' ;

--select * from SeniorProspectActivity where activitycategory = 'TOU'
exec [dbo].[IHPCommunityAnalytics_ConversionReport]
@propcode = 'colm',
@startd = '2021-06-01', 
@endd = '2021-07-30'




declare @date1 DATETIME
print @date1


select * from property
where scode = 'colm'