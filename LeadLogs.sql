select * into #imported22 from SeniorProspectLeadsImportLog where year(dtcreated) = 2022 and message in ('Prospect imported successfully.')

select distinct* from #imported22 where DupProspect = 0 

select sstatus,count(sstatus) cnt,p.scode community from seniorprospect sp join #imported22 imp on sp.hMy = imp.DupProspect join property p on sp.hProperty = p.HMY
where DupProspect = 0 
group by sstatus,p.scode 

select * from property

select cast(hmy as varchar(10))+ ',',cast(DupProspect as varchar(10))+ ',' from seniorprospect a left join #imported22 b on  b.DupProspect = a.hMy where sCustomer = 'Morningpointe-Yardi' 
and year(a.dtcreated) = 2022 and DupProspect is NULL 
for XML PATH('')

select hmy, DupProspect from seniorprospect a left join #imported22 b on  b.DupProspect = a.hMy where sCustomer = 'Morningpointe-Yardi' 
and year(a.dtcreated) = 2022 and DupProspect is not NULL 
order by hmy asc


select hmy, DupProspect from seniorprospect a left join #imported22 b on  b.DupProspect = a.hMy where sCustomer = 'Morningpointe-Yardi' 
and year(a.dtcreated) = 2022 and DupProspect is NULL 
order by hmy asc

select * from seniorprospect where hmy in (125987,128291,129501,129827,129913,130534,131060,131132,131328,131424,131797,131953,133716,133854,133881,134043,134045,134049,134051,134119,134129,134141,134143,134149,134247,134374,134802,134804,134806,134808,134810,134812,134814,134816,134818,134820,134822,134824,134826,134828,134830,134832,134834,134836,134838,134840,134842,134846,134850,134852,134854,134856,134858,134860,134863,134865,134867,134870,134872,134874,134880,134882,134884,134886,134888,134895,134897,134899,135093,135095,135097,135364,135366,135368,135737,135743,135754,135832,135834,136007,136045,136179,136450,136587,136593,136595,136598,136600,136719,137137,137459,137596,137715,137866,137870,137884,137911,137913,137915)
order by hmy asc


select * from SeniorProspect where hmy in ( 


select distinct hmy from seniorprospect where sCustomer = 'Morningpointe-Yardi' 
and year(dtcreated) = 2022 order by hmy asc
and sStatus != 'Web' and sStatus != 'Inactive'