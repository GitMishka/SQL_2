SELECT * into #BI_tables FROM  INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME LIKE '%SeniorBI%'

SELECT * FROM  INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME LIKE '%SeniorBI%'

select * from pmuser
select top 1 * from person


select * from #BI_tables where table_name like '%Clinical%'

select * from SeniorBIClinicalCensus where moveoutdate between '2023-7-1' and '2023-7-31' order by moveoutdate desc
select * from SeniorBIClinical where propertyname = 'The Lantern at Morning Pointe of Lexington' where date


select * from tenant where hmyperson = 145408

select * from SeniorBIClinicalCensus where moveoutdate between '2023-7-1' and '2023-7-17' order by MoveOutDate desc

select * from SeniorBICustom_DischargesByRegion  where propertyname = 'The Lantern at Morning Pointe of Lexington' and moveoutdate between '2023-7-1' and '2023-7-31'