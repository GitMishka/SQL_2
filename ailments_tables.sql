
Declare @Date1 DateTime
Declare @Date2 DateTime

Set @Date1 = '07-01-2022'
Set @Date2 = '07-31-2022'

if @Date1 = '01/01/1900' 
	Begin
		Set @Date2 = '01/01/2100'
	End

If '#types#'='Resident'
Begin
   Select rtrim(ltrim(t.slastname))+', '+rtrim(ltrim(t.sfirstname))+ ' (' +t.scode+ ')'Name,
          t.sunitcode Unit,
          rtrim(ltrim(isnull(p.saddr1,''))) + ' ('+ rtrim(ltrim(p.scode))+ ')'property,
          t.hmyperson hperson,
          shi.dtstart StartDate,
          shi.dtend DCDate,
          memo.mem Memo,
          att.attch Attachments,
          lp1.listoptionname Route, 
          shi.sdosage Dosage,
          lp2.listoptionname Frequency,
          shi.hmy hmy,
          case when shn.itype=1
          then  shn.sname  + ' (' + 'ICD-9 : '+  isnull(shn.scode,'')+')'
		  when shn.itype=2 then  shn.sname  + ' (' + 'Diet'+  isnull(shn.scode,'')+')'
		  /* new */
		  when shn.itype=3 then  shn.sname  + ' (' + 'Allergy'+  isnull(shn.scode,'')+')' 
		  when shn.itype=4 then  shn.sname  + ' (' + 'Medication'+  isnull(shn.scode,'')+')'
		  when shn.itype=7 then  shn.sname  + ' (' + 'Throat related'+  isnull(shn.scode,'')+')'
		  when shn.itype=8 then  shn.sname  + ' (' + 'Therapy/Nursing'+  isnull(shn.scode,'')+')'
		  when shn.itype=9 then  shn.sname  + ' (' + 'Surgical intervention'+  isnull(shn.scode,'')+')'
          else shn.sname  end Clinicalname
          /*
		 case when shn.itype=1
         then  shn.sname  + ' (' + shn.scode+')'
         else shn.sname  end
		 */
     from tenant t 
          inner join property p on t.hproperty=p.hmy
          inner join person pr on pr.hmy = t.hmyperson 
          inner join shcrclinicalinfo shi on t.hmyperson = shi.htenant
          inner join shcrclinicalname shn on shi.hShCRClinicalName= shn.hmy
          left outer join listoption lp1 on shi.hroute=lp1.hmy
          left outer join listoption lp2 on shi.hfrequency=lp2.hmy
          left outer join (select m.hfilercd hfilercd,
                                  m.ifiletype ifiletype,
                                  case when (m.ifiletype=592) then 'Y' 
                                       else '-' end mem 
                             from memo m,shcrclinicalinfo shi)memo on  shi.hmy= memo.hfilercd and memo.ifiletype=592
          left outer join (select pm.hrecord hrecord,
                                  pm.itype itype ,
                                  case when pm.itype=592 then 'Y' 
                                       else '-' end Attch 
                             from pmdocs pm,shcrclinicalinfo shi)Att on shi.hmy=att.hrecord and att.itype=592
         left outer join seniorprospect sp on sp.htenant=t.hmyperson
   where 1=1
         and shi.bactive=1
         and shn.bactive=1
         AND shi.HMY IN ( ISNULL (( SELECT  MAX ( SHi1.HMY )
										                 FROM     shcrclinicalinfo SHi1
										                 WHERE    SHi1.htenant                        = SHi.htenant
										                 			 AND shi.Itype             = shi1.Itype
                                          AND shi.hshCRClinicalName = shi1.hshCRClinicalName		
										                      AND '#History#'                         = 'No'
										                      AND ISNULL ( shi1.dtstart,GETDATE ( ) ) IN ( ISNULL (
										                                                                  ( SELECT  MAX ( SHi2.dtstart )
										                                                                  FROM     shcrclinicalinfo SHi2
										                                                                  WHERE    SHi2.htenant           = SHi1.htenant
										                                                                       AND shi2.Itype             = shi1.Itype
										                                                                       AND shi2.hshCRClinicalName = shi1.hshCRClinicalName
										                                                                       AND '#History#'            = 'No'
										                                                                  GROUP BY shi2.Itype,
										                                                                           shi2.hshCRClinicalName
										                                                                  ) , GETDATE ( ) ) )
										                 GROUP BY shi1.Itype,shi1.hshCRClinicalName) ,shi.HMY ) )
         and shi.itype in (select hmy from SHCRClinicalType sct where 1=1)-- #condition4# )
         --#condition1#
         --#condition3#
         --#condition5#
         AND ((isnull(shi.dtstart,'01/01/1900') <= @Date2) AND (isnull(shi.dtend,'01/01/2100') >= @Date1))
group by shi.hmy,t.slastname,t.sfirstname,t.scode,t.SUNITCODE,shi.dtStart,
         shi.dtEnd,shi.hRoute,shi.sDosage,shi.hFrequency,memo.mem,shn.sname,
         lp1.listoptionname,lp2.listoptionname,att.attch,shn.scode,shn.itype,
         t.hmyperson,p.saddr1,p.scode
order by shi.dtstart desc
end
else
begin
   Select rtrim(ltrim(sp.slastname))+', '+rtrim(ltrim(sp.sfirstname))+ ' (' +ltrim(rtrim(pr.ucode))+ ')' Name,
          u.scode Unit,
          rtrim(ltrim(isnull(p.saddr1,''))) + ' ('+ rtrim(ltrim(p.scode))+ ')'property,
          sp.hmy hperson,
          shi.dtstart StartDate,
          shi.dtend DCDate,
          memo.mem Memo,
          att.attch Attachments,
          lp1.listoptionname Route, 
          shi.sdosage Dosage,
          lp2.listoptionname Frequency,
          shi.hmy hmy,
          case 
		  when shn.itype=1 then  shn.sname  + ' (' + 'ICD-9 : '+  isnull(shn.scode,'')+')'
		  /* new */
		  --when shn.itype=3 then  shn.sname  + ' (' + 'Allergy'+  isnull(shn.scode,'')+')' 
		  --when shn.itype=4 then  shn.sname  + ' (' + 'Medication'+  isnull(shn.scode,'')+')'
		  --when shn.itype=7 then  shn.sname  + ' (' + 'Throat related'+  isnull(shn.scode,'')+')'
		  --when shn.itype=8 then  shn.sname  + ' (' + 'Therapy/Nursing'+  isnull(shn.scode,'')+')'
		  --when shn.itype=9 then  shn.sname  + ' (' + 'Surgical intervention'+  isnull(shn.scode,'')+')'
          else shn.sname  end Clinicalname,
		 
		  case 
		  when shn.itype=1 then  ' (' + 'ICD-9 : '+  isnull(shn.scode,'')+')'
		  when shn.itype=2 then  ' (' + 'Diet : '+  isnull(shn.scode,'')+')'
		  /* new */
		  when shn.itype=3 then  ' (' + 'Allergy'+  isnull(shn.scode,'')+')' 
		  when shn.itype=4 then  ' (' + 'Medication'+  isnull(shn.scode,'')+')'
		  when shn.itype=7 then  ' (' + 'Throat related'+  isnull(shn.scode,'')+')'
		  when shn.itype=8 then  ' (' + 'Therapy/Nursing'+  isnull(shn.scode,'')+')'
		  when shn.itype=9 then  ' (' + 'Surgical intervention'+  isnull(shn.scode,'')+')'
          else shn.sname  end Medical_Type

     from seniorprospect sp
     	  inner join person pr on pr.hmy = sp.hmy
          left join unit u on sp.hunit=u.hmy 
          left join property p on sp.hproperty=p.hmy
          inner join shcrclinicalinfo shi on sp.hmy = shi.hprospect
          inner join shcrclinicalname shn on shi.hShCRClinicalName= shn.hmy
          left outer join listoption lp1 on shi.hroute=lp1.hmy
          left outer join listoption lp2 on shi.hfrequency=lp2.hmy
          left outer join (select m.hfilercd hfilercd,
                                  m.ifiletype ifiletype,
                                  case when (m.ifiletype=592) then 'Y' 
                                       else '-' end mem 
                             from memo m,shcrclinicalinfo shi)memo on  shi.hmy= memo.hfilercd and memo.ifiletype=592
          left outer join (select pm.hrecord hrecord,
                                  pm.itype itype ,
                                  case when pm.itype=592 then 'Y' 
                                       else '-' end Attch 
                             from pmdocs pm,shcrclinicalinfo shi)Att on shi.hmy=att.hrecord and att.itype=592
         left outer join tenant t on sp.htenant=t.hmyperson
   where 1=1
         and shi.bactive=1
         and shn.bactive=1
         and sp.sstatus not in ('Moved In','Future Resident','Referral')
         /*and isnull(shi.dtstart,getdate()) = isnull((select  max(dtstart) from shcrclinicalinfo where case when '#types#' like 'Resident' then htenant else hprospect end = case when '#types#' like 'Resident' then t.hmyperson else sp.hmy end and '#History#'= 'No'),isnull(shi.dtstart,getdate()))*/
        AND shi.HMY IN ( ISNULL (( SELECT  MAX ( SHi1.HMY )
										                 FROM     shcrclinicalinfo SHi1
										                 WHERE    SHi1.hprospect                        = SHi.hprospect
										                 			 AND shi.Itype             = shi1.Itype
                                          AND shi.hshCRClinicalName = shi1.hshCRClinicalName		
										                      AND '#History#'                         = 'No'
										                      AND ISNULL ( shi1.dtstart,GETDATE ( ) ) IN ( ISNULL (
										                                                                  ( SELECT  MAX ( SHi2.dtstart )
										                                                                  FROM     shcrclinicalinfo SHi2
										                                                                  WHERE    SHi2.hprospect           = SHi1.hprospect
										                                                                       AND shi2.Itype             = shi1.Itype
										                                                                       AND shi2.hshCRClinicalName = shi1.hshCRClinicalName
										                                                                       AND '#History#'            = 'No'
										                                                                  GROUP BY shi2.Itype,
										                                                                           shi2.hshCRClinicalName
										                                                                  ) , GETDATE ( ) ) )
										                 GROUP BY shi1.Itype,shi1.hshCRClinicalName) ,shi.HMY ) ) 	
         	
        and shi.itype in (select hmy from SHCRClinicalType sct where 1=1)-- #condition4# )
         --#condition1#
         --#condition3#
         --#condition5#
          AND ((isnull(shi.dtstart,'01/01/1900') <= @Date2) AND (isnull(shi.dtend,'01/01/2100') >= @Date1))
group by shi.hmy,shi.dtStart,sp.slastname,sp.sfirstname,sp.hmy,
         shi.dtEnd,shi.hRoute,shi.sDosage,shi.hFrequency,memo.mem,shn.sname,
         lp1.listoptionname,lp2.listoptionname,att.attch,shn.scode,shn.itype,
         p.saddr1,p.scode,u.SCODE,sp.scode,pr.ucode
		 order by hmy desc
end

--Declare @Date1 DateTime
--Declare @Date2 DateTime

Set @Date1 = '07-01-2022'
Set @Date2 = '07-31-2022'

if @Date1 = '01/01/1900' 
	Begin
		Set @Date2 = '01/01/2100'
	End

	 
If '#types#'='Resident'
Begin
  Select case when shn.itype=1
         then  shn.sname  + ' (' + shn.scode+')'
         else shn.sname  end Clinicalname, 
         count ( Distinct shi.hTenant) count
    from tenant t
         inner join property p on t.hproperty=p.hmy 
         inner join person pr on pr.hmy = t.hmyperson
         inner join shcrclinicalinfo shi on t.hmyperson = shi.htenant
         inner join shcrclinicalname shn on shi.hShCRClinicalName= shn.hmy
         left outer join seniorprospect sp on sp.htenant=t.hmyperson
   where 1=1
         and shi.bactive=1
         and shn.bactive=1
        /* and isnull(shi.dtstart,getdate()) = isnull((select  max(dtstart) from shcrclinicalinfo where case when '#types#' like 'Resident' then htenant else hprospect end = case when '#types#' like 'Resident' then t.hmyperson else sp.hmy end and '#History#'= 'No'),isnull(shi.dtstart,getdate()))*/
        AND shi.HMY IN ( ISNULL (( SELECT  MAX ( SHi1.HMY )
										                 FROM     shcrclinicalinfo SHi1
										                 WHERE    SHi1.htenant                        = SHi.htenant
										                 		  AND shi.Itype             = shi1.Itype
                                          AND shi.hshCRClinicalName = shi1.hshCRClinicalName		
										                      AND '#History#'                         = 'No'
										                      AND ISNULL ( shi1.dtstart,GETDATE ( ) ) IN ( ISNULL (
										                                                                  ( SELECT  MAX ( SHi2.dtstart )
										                                                                  FROM     shcrclinicalinfo SHi2
										                                                                  WHERE    SHi2.htenant           = SHi1.htenant
										                                                                       AND shi2.Itype             = shi1.Itype
										                                                                       AND shi2.hshCRClinicalName = shi1.hshCRClinicalName
										                                                                       AND '#History#'            = 'No'
										                                                                  GROUP BY shi2.Itype,
										                                                                           shi2.hshCRClinicalName
										                                                                  ) , GETDATE ( ) ) )
										                 GROUP BY shi1.Itype,shi1.hshCRClinicalName) ,shi.HMY ) )
         and shi.itype in (select hmy from SHCRClinicalType sct where 1=1)-- #condition4# )
         --#condition1#
         --#condition3#               	
         --#condition5#
          AND ((isnull(shi.dtstart,'01/01/1900') <= @Date2) AND (isnull(shi.dtend,'01/01/2100') >= @Date1))
group by shn.sName,shn.sCode,shn.iType
end 
else 
begin 
  Select case when shn.itype=1
         then  shn.sname  + ' (' + shn.scode+')'
         else shn.sname  end Clinicalname, 
         count ( Distinct shi.hprospect) count
    from seniorprospect sp
    	   inner join person pr on pr.hmy = sp.hmy
         left join property p on sp.hproperty=p.hmy 
         inner join shcrclinicalinfo shi on sp.hmy = shi.hprospect
         inner join shcrclinicalname shn on shi.hShCRClinicalName= shn.hmy
         left outer join tenant t on sp.htenant=t.hmyperson
   where 1=1
         and shi.bactive=1
         and shn.bactive=1
         and sp.sstatus not in ('Moved In','Future Resident','Referral')
         /*and isnull(shi.dtstart,getdate()) = isnull((select  max(dtstart) from shcrclinicalinfo where case when '#types#' like 'Resident' then htenant else hprospect end = case when '#types#' like 'Resident' then t.hmyperson else sp.hmy end and '#History#'= 'No'),isnull(shi.dtstart,getdate()))*/
         AND shi.HMY IN ( ISNULL (( SELECT  MAX ( SHi1.HMY )
										                 FROM     shcrclinicalinfo SHi1
										                 WHERE    SHi1.hprospect                        = SHi.hprospect
										                 			 AND shi.Itype             = shi1.Itype
                                          AND shi.hshCRClinicalName = shi1.hshCRClinicalName		
										                      AND '#History#'                         = 'No'
										                      AND ISNULL ( shi1.dtstart,GETDATE ( ) ) IN ( ISNULL (
										                                                                  ( SELECT  MAX ( SHi2.dtstart )
										                                                                  FROM     shcrclinicalinfo SHi2
										                                                                  WHERE    SHi2.hprospect           = SHi1.hprospect
										                                                                       AND shi2.Itype             = shi1.Itype
										                                                                       AND shi2.hshCRClinicalName = shi1.hshCRClinicalName
										                                                                       AND '#History#'            = 'No'
										                                                                  GROUP BY shi2.Itype,
										                                                                           shi2.hshCRClinicalName
										                                                                  ) , GETDATE ( ) ) )
										                 GROUP BY shi1.Itype,shi1.hshCRClinicalName) ,shi.HMY ) )	
         and shi.itype in (select hmy from SHCRClinicalType sct where 1=1)-- #condition4# )
         --#condition1#
         --#condition3#
         --#condition5#
          AND ((isnull(shi.dtstart,'01/01/1900') <= @Date2) AND (isnull(shi.dtend,'01/01/2100') >= @Date1)) 
group by shn.sName,shn.sCode,shn.iType
end
