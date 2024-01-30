select * from [dbo].[SeniorProspectSource] 
select * from SeniorContact
select * from SeniorResidentAdditionalInfo
select * from [dbo].[SeniorBIMarketingSource]
select count(distinct(sourceid)) from [dbo].[SeniorBIProspectMarketing]
select * from [dbo].[SeniorBIProspectMarketing]


select gender, count(gender) from [dbo].[SeniorBIProspectMarketing] where BillingEndDate is NULL
group by gender
select * from SeniorConvertUniqueListOption