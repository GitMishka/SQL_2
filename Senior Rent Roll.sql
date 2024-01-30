//Vista

//Notes
Senior Housing:  Rent Roll
Modifications 
 03/31/06 Created by RK based 
 03/31/06 Sent for Testing to be included in the 23.02 build.
 04/27/06 added name of the property to the HTML version's title
 06/20/06 rewrote to look a the most current "primary" service within the daterange. The unit history is reflected in terms of a waitlisted unit / excluded unit and the rent.
 06/28/06 TR 75225 -- this report works through Conductor
 07/12/06 TR 76171 -- Filter item  exclude "excluded & waitlisted Units?" 
 07/18/06 RK TR 76469 -- Update Version Numbers
 09/21/06 RK TR 78987 add the cancelled service instance condition,  where the ServiceInstanceToDate is less than the ServiceInstanceFromDate 
 09/29/06 RK TR#79345 Check for active seniorunithistory records for the excluded etc unit status.
 10/30/06 RK TR#80653 Reformat the report ; move the second occupant data on to the second line. Suppress second line if no second occupant data is available. 
 		        Remove daily rate column, add a rate type, do not pro-rate the amount.  
 		        Add filter item to display / suppress vacant units.
 11/16/06 RK TR#81707 The files show a path file access error when run by a user with property security. Claremont house reported the issue. 
            			 The error is because of the word "PropertyName" as a field in the virtual table that this report creates. 
            			 Replaced by "PropName".
 12/05/06 RK TR#82588 Show Vacant Units? FIlter item causes the display of vacant units to be suppressed corectly but makes the summary counts 
 		      wrong. Also verify that the occupancy calculation considers completly occupied capacity as 1. so partial occupancy is 
 		      calulated as fractions of 1.
 02/27/07 RK TR#84873 Added Legend,detailsection,other monthly charges,second occ. rent
 03/14/07 RK TR#86495 Unit History Date issue. the unit history from and to dates fields record "Date and Time". Strip the time from the to and from dates to compare against the @asofdate.
 05/16/07 RK TR#99673 Total Deposits - wrapped an isnull clause around all the deposits 
 05/16/07 RK TR#99770 Negative Concession Charges not showing up on the crystal report. Modified the formula to suppress charges that are less than .01.
 05/30/07 RK TR#99665 Add the resident's current status in front of the resident's name. Abbriviate the current status to a letter 'C for current'. Add a key at the end of the report.
 		      Also add a filter item to hide or show current status, and the key.
 05/30/07 RK TR#100354 HTML version of the rent roll shows vacant units even if the filter "Show Vacant Units?" = 'No'.
 02/22/08 SM TR#106986 Changed the title to maintain consistency between report filters and the actual report titles and done formatting changes
 06/03/08 SM TR#117544 Changed the column headers labeled "(Actual)" and "(Monthly)" to "Per Period" and "Monthly"
 06/26/08 SM TR#118891 Report was returning error: "VB Code error: Subscript out of range" when the selected destination is "Save to XLS".
 09/02/08 PP TR#124119 Rent Roll report  'detail'  link showing no info
 3/17/2009 PD TR#119629 :getting error on report "Subquery returned more than 1 value. This is not permitted when the subquery follows =, !=, <, <= , >, >= or when the subquery is used as an expression "
                         Counts Mismatch
 03/26/009 NG TR#119629 -Unit Roster and Rent Roll's count for Total Unit was not matching.
 6/4/2009 PD TR#188734- Rent Roll report:Summary of all selected communities are repeating after the end of detail of each community.
 07/15/2010 NG TR#218965 Unit Capacity should show 1 if its SPA and 2 if its private.
 10/13/2010 NG TR#208856 - if we give Move out date of any resident as a filter date then that resident was showing on the report.
 11/02/2010 NKG TR#227184 : Added sqft column to the report.
 11/07/2011 AN TR#227540 - Updated the join for the seniorContact table to validate the senarioes if the "Deactivate prospect on 'Move Out Resident'" option is checked.
 01/18/2012 BB TR#258605 Report is showing same number of second (2nd) residents as primary residents
 06/15/2012 - TR#244599 - NG - Enhancement to add additional occupancy methods 
 03/08/2013 - TR#285472 - NG - Fixes to Rent Roll report. rs_SeniorRentRoll_Crystal.txt and rs_SeniorRentRoll_HTML.txt files are created
 05/13/2013 - BB - TR#269444 - second resident changes 
 06/18/2013 - NKG - TR#306036 - Report converted to SSRS.
 05/25/2018 - MK - TR #480225 - Updated report to include 'Addition of multiple units to a single resident' functionality. 
 07/09/2018 - VCH - TR#458483 - Modified for issues in Rent Roll Project 2018
//End Notes

//Database
SSRS rs_SeniorRentRoll.rdlc
//End Database

//Crystal
CryActive Y
Crytree y
param rptVersion=50.12.20 23.08
param Month=#begmonth#
param rptProperty=#phmy#
param rptSecOccService=#ServiceName#
param rptPrimarySerName=select ServiceClassName from serviceclass where serviceclassid = 1
param rptExclude=#bExclude#
param rptVacant=#bVacant#
param rptResStatus=#bStatus#
param idrill=PageASPX/YSIEntry.aspx?e=ResidentCensus&ResidentID=
param OccType=#OccType#
param MedicaidFactor=#MedicaidFactor#
param datemask=SELECT ISNULL((SELECT REPLACE(REPLACE(ci.sdatemask,'D','d'),'Y','y') FROM country_info ci, pmuser pm where pm.scountry = ci.scode and pm.uname = ltrim(rtrim( '#@@USERNAME#' ))),'MM/dd/yyyy')
//End Crystal


--//Title
Rent Roll
select 'x: Show Excluded /w: Waitlisted Units:' + case when '#bExclude#' = 'Yes' then 'Yes' else 'No' end where '#Output#' like 'Html'
--//end title

--//select no crystal
declare @AsOfDate datetime,
@startDate datetime,
@BOM DATETIME,
@EOM DATETIME, 

@propCode VARCHAR(4000),
@flag integer

set @AsOfDate  = '#begmonth#'
set @startDate= cast(cast(month('#begmonth#') as varchar(2))+'/01'+ '/' +cast(Year('#begmonth#') as varchar(4)) as date)


SET @BOM = CONVERT(VARCHAR, Datepart(mm, @AsOfDate)) 
           + '/01/' 
           + CONVERT(VARCHAR, Datepart(yyyy, @AsOfDate)) 
SET @EOM = Dateadd(dd, -1, Dateadd(mm, 1, @BOM)) 

SET @propCode = ''
DECLARE @encryptionEnabled INTEGER
SET @encryptionEnabled=isnull( (SELECT svalue
                         FROM   paramopt2
                         WHERE  Upper(stype) = 'ENABLEDATAENCRYPTION'),0)

SELECT @propCode = @propCode + Ltrim( Rtrim( P.Scode ) ) + ',' FROM
  Property P
WHERE
  1 = 1
 #condition1# 
 
SET @propCode = LEFT( @propCode, Len( @propCode ) - 1 )

Select @flag = case '#OccType#' when 'Physical Unit Based' then 1 
when 'Physical Lease Based' then 2
when 'Physical Unit Based (disregarding capacity)' then 3
when 'Financial Unit Based' then 4
when 'Financial Lease Based' then 5
else  6 end


Create Table #RentRoll
(
PropId Numeric(18,0),
PropName varchar(100) ,
UnitId numeric(18,0),
UnitCode varchar(8),
UnitType varchar(50),
UnitSqft numeric(19,2),
UnitCareLevelCode  VArchar(3),
Capacity	   smallint,
PriLC varchar(3),
ResId numeric(18,0),
ResName varchar(100),
ResBDt datetime,
ResAge numeric(18,2),
ResMoveInDt datetime,
ResPriLC varchar(3),
ResCLC varchar(3), 
OccPerc numeric(18,2),
OccUnit  numeric(18,2),
OccResident  numeric(18,2),
OccUnitDsrgrdngCpcty  numeric(18,2),
UnitRent numeric(18,2),
ResPrimaryServiceAmtMonthly numeric(18,2),
ResOtherMonthlyChargesAmt numeric(18,2),
ResSecAmt numeric(18,2),
RateType Varchar(10),
ResDeposit numeric(18,2),
SecResName Varchar(100),
SecResBDt datetime,
SecResAge numeric(18,2),
SecOccupantRateMonthly numeric(18,2),
SecRateType Varchar(10),
exclude Varchar(3),
waitlist Varchar(3),
bEliminate bit,
Currencysymbol VARCHAR(2),
ProrationValue numeric(18,2),
/*TR #480225*/
ResAdditionUnitRent numeric(18,2), 
ResAdditionUnitRentMonthly numeric(18,2), 
ResAdditionalUnitOtherCharge numeric(18,2),
AdditionalUnit INT,
SecResId numeric(18, 0),
ResPrimaryServiceAmtMonthly_Prorate numeric(18,2)
)

CREATE TABLE #TmpMedicaid    
(    
 PropertyID NUMERIC(18,0),    
 MedicaidTemplateID NUMERIC(18,0),    
 MedicaidTemplateName VARCHAR(200),    
 ResidentID NUMERIC(18,0),    
 ProrationRuleCode VARCHAR(5),    
 FactorType VARCHAR(20),    
 FactorCode VARCHAR(20),    
 FactorDescription VARCHAR(50),    
 FactorFromDate DATETIME,    
 FactorToDate DATETIME NULL,    
 RateType VARCHAR(20),    
 DeductFactor INT,    
 TemplateRate NUMERIC(18,2),    
 ResidentRate NUMERIC(18,2),    
 PayableDays NUMERIC(18,0),     
 FactorAmount NUMERIC(18,2),   
 ActualAmount NUMERIC(18,2),    
 UseIncomeFlag INT,    
 EFTFlag INT,  
 CCFlag INT,
 ResidentRateNew NUMERIC(18,2)  
)    

Create TAble #tmpOccupancyDetail (
   Propertyid               NUMERIC
  ,Propertyname            VARCHAR( 100 )
  ,Propcode                VARCHAR( 10 )
  ,Unitid                  NUMERIC
  ,Unitcode                VARCHAR( 15 )
  ,Unittypeid              NUMERIC
  ,Unittype                VARCHAR( 20 )
  ,Carelevelcode           VARCHAR( 10 )
  ,Privacylvlcode          VARCHAR( 10 )
  ,Unitcapacity            NUMERIC
  ,Unitbudgetcapacity      NUMERIC
  ,Unitsqft                NUMERIC( 18, 2 )
  ,Unitrentmonthly         NUMERIC( 18, 2 )
  ,Unitrentdaily           NUMERIC( 18, 2 )
  ,Unitwaitlistflag        BIT
  ,Unitexcludeflag         BIT
  ,Residentid              NUMERIC
  ,Residentname            VARCHAR( 100 )
  ,Dtmovein                DATETIME
  ,Dtmoveout               DATETIME
  ,SecResName              VARCHAR(100)
  ,SecResBDt               DATETIME
  ,SecResAge               NUMERIC(18,2)
  ,Pubocc                  NUMERIC( 18, 2 )
  ,Plbocc                  NUMERIC( 18, 2 )
  ,Pubdcocc                NUMERIC( 18, 2 )
  ,Fubocc                  NUMERIC( 18, 2 )
  ,Flbocc                  NUMERIC( 18, 2 )
  ,Fubdcocc                NUMERIC( 18, 2 )
  ,Serviceinstancefromdate DATETIME
  ,Serviceinstancetodate   DATETIME
  ,Rescarelevelcode        VARCHAR( 10 )
  ,Beliminate              BIT 
  ,AdditionalUnit          BIT
  ,ResDeposit              NUMERIC(18,2) 
  ,ResOtherMonthlyChargesAmt NUMERIC(18,2) 
  ,ResAdditionUnitRent     NUMERIC(18,2) 
  ,ResAdditionUnitRentMonthly NUMERIC(18,2) 
  ,ResAdditionalUnitOtherCharge NUMERIC(18,2) 
  ,SecOccupantRateMonthly  NUMERIC(18,2) 
  ,SecResId                NUMERIC(18,0) 
  ,ResBDt                  DATETIME 
  ,ResAge                  NUMERIC(18,2) 
  ,ResSecAmt               NUMERIC(18,2) 
  ,ResPrimaryServiceAmtMonthly NUMERIC(18,2) 
  ,RateType                VARCHAR(10)
  ,ResPrimaryServiceAmtMonthly_Prorate numeric(18,2)
 )  
  
create Table #sec
(
serviceid numeric
)

insert into  #sec 
 select s.serviceid from service s where 1=1  #condition3#
and  ( (select count(s1.serviceid) from service s1 ) <> (select count(s.serviceid) from service s where 1=1 #condition3# ) )
union all 
select 0


Insert Into #tmpOccupancyDetail
exec Seniorconditionaloccupancydetails_UnitRosterAndRentRollNew       @propCode,@AsOfDate,@AsOfDate,@flag,'Yes','Report'

/*execute the procedure SeniorMedicaidFactorDetails if Include Medicaid Factor? is Yes */

if '#MedicaidFactor#'='Yes' 
	begin 	
		INSERT INTO #TmpMedicaid
                  (PropertyID,
                   MedicaidTemplateID,
                   MedicaidTemplateName,
                   ResidentID,
                   ProrationRuleCode,
                   FactorType,
                   FactorCode,
                   FactorDescription,
                   FactorFromDate,
                   FactorToDate,
                   RateType,
                   DeductFactor,
                   TemplateRate,
                   ResidentRate,
                   PayableDays,
                   FactorAmount,
                   ActualAmount,
                   UseIncomeFlag,
                   EFTFlag,
                   CCFlag) 
		exec SeniorMedicaidFactorDetails_RentRoll @propCode,@startDate,@AsOfDate,0,0
		
		UPDATE #TmpMedicaid
		SET ResidentRateNew=ResidentRate
	end 
	
	
insert into #RentRoll (
 PropId
,PropName
,UnitId 
,UnitCode
,UnitType
,UnitSqft
,UnitCareLevelCode
,Capacity
,PriLC
,ResId
,ResName
,ResMoveInDt
,SecResName
,SecResBDt
,SecResAge 
,ResPriLC 
,OccPerc
,OccUnit
,OccResident   
,OccUnitDsrgrdngCpcty
,UnitRent
,exclude
,waitlist
,bEliminate
,Currencysymbol
,ProrationValue 
,additionalunit
,ResDeposit
,ResOtherMonthlyChargesAmt  
,ResAdditionUnitRent  
,ResAdditionUnitRentMonthly  
,ResAdditionalUnitOtherCharge  
,SecOccupantRateMonthly  
,SecResId  
,ResBDt   
,ResAge  
,ResSecAmt  
,ResPrimaryServiceAmtMonthly  
,RateType  
,ResCLC 
) 
 select 	
 	  occ.Propertyid,
 		occ.propertyName,    
		UnitId ,
		UnitCode ,
		UnitType,   
		UnitSqft,                       
		CareLevelCode,   
		UnitCapacity , 
		PrivacyLvlcode, 
		occ.ResidentId ,
		ResidentName,	 
		occ.dtMoveIn,
        occ.SecResName, 
        occ.SecResBDt, 
        occ.SecResAge,		
		PrivacyLvlcode, 
	  isnull(case @flag when 1 then PUBOcc		when 2 then PLBOcc when 3 then PUBDCOcc 
				when 4 then FUBOcc when 5 then  FLBOcc else FUBDCOcc end,0),
		isnull(case when @flag in(1,2,3) then PUBOcc else FUBOcc end,0),
		isnull(case when @flag in(1,2,3) then PLBOcc else FLBOcc end,0),
		isnull(case when @flag in(1,2,3) then PUBDCOcc else FUBDCOcc end,0),
		0 ,
		case when unitExcludeFlag =0 then 'No' else 'Yes' end    ,
		case when unitWaitlistFlag =0 then 'No' else 'Yes' end  ,				
		Beliminate , 
		Currencysymbol,
		case isnull(po.svalue,'304') when 'ANN' then 30.41666667  
										when '30d' then 30
										when '304' then 30.4
                    when 'act' then (datediff(day, @BOM, @EOM)+1)
    else 30.4
    end,
    additionalunit, 
	Occ.ResDeposit, 
	Occ.ResOtherMonthlyChargesAmt, 
    Occ.ResAdditionUnitRent,  
    Occ.ResAdditionUnitRentMonthly ,
    Occ.ResAdditionalUnitOtherCharge, 
    Occ.SecOccupantRateMonthly, 
    Occ.SecResId, 
    Occ.ResBDt, 
    Occ.ResAge, 
    Occ.ResSecAmt, 
    Occ.ResPrimaryServiceAmtMonthly, 
    Occ.RateType, 
    Occ.Rescarelevelcode
from  Property p	
Inner Join #tmpOccupancyDetail occ on occ.propertyid = p.hmy
inner JOIN SeniorIntlAddress( @Propcode, '', 1 )sia on (sia.Propertyid = occ.Propertyid)
left Join Tenant t on (t.hMyPerson = occ.ResidentId)
left Join SeniorResidentStatus srs on (srs.iStatus = t.iStatus)
Left join propoptions po on po.hprop = occ.Propertyid and po.stype like 'SeniorProrationRule'
INNER JOIN listoption CareList ON CareList.ListOptionCode = Carelevelcode AND CareList.listName = 'CareLevel' 
INNER JOIN UnitType ut ON LTRIM(RTRIM(ut.sCode)) = LTRIM(RTRIM(occ.Unittype))
WHERE ISNULL(t.iStatus,99) <> 6

UPDATE rr1 
 SET    rr1.resclc = rr2.resclc, 
        rr1.ResBDt = rr2.ResBDt , 
 	     rr1.ResAge = rr2.ResAge , 
 	     rr1.RateType = rr2.RateType, 
 	     rr1.ResDeposit = rr2.ResDeposit, 
         rr1.ResName = rr2.ResName 
 FROM   #rentroll rr1 
        INNER JOIN #rentroll rr2 
                ON rr1.resid = rr2.resid 
         WHERE rr1.additionalunit = 1 
        AND rr2.additionalunit = 0

		SELECT 'Other Rec. Charge' Title,
			 Src.RecurringChargeID, 
       SRC.RateTYpeCode, 
       resid,
       rr.unitid,
	   rr.ResPriLC,	   
       CASE 
         WHEN @BOM <= src.RecurringChargeFromDate THEN 
         src.RecurringChargeFromDate 
         ELSE @BOM 
       END AS dtFrom, 
       CASE 
         WHEN @EOM > Isnull(src.RecurringChargeToDate, @AsofDate) THEN 
         Isnull(src.RecurringChargeToDate, @AsofDate) 
         ELSE @EOM 
       END AS dtTo, 
       src.RecurringChargeAmount 
INTO   #temp_prorate 
FROM   #rentroll rr 
       INNER JOIN seniorrecurringcharge src 
               ON ( rr.resId = src.residentid 
                    AND src.RecurringChargeActiveFlag <> 0 AND rr.UnitID=src.UnitID AND rr.ResPriLC=src.PrivacyLevelCode) 
       LEFT JOIN ServiceInstance si 
              ON si.ServiceInstanceID = src.ServiceInstanceID 
       LEFT JOIN Service s 
              ON s.serviceID = si.serviceID and isnull(s.serviceid,0) not in (select serviceid from #sec)
WHERE  src.RecurringChargeFromDate <= @EOM 
       AND Isnull(src.RecurringChargeToDate, @EOM) >= @BOM 
       AND src.RecurringChargeFromDate <= Isnull(src.RecurringChargeToDate, 
                                          @AsofDate) 
       AND Isnull(s.ServiceClassID, 0) <> 1 
UNION ALL
SELECT 'Accommodation' Title,
			 Src.RecurringChargeID, 
       SRC.RateTYpeCode, 
       resid,
       rr.unitid,
	   rr.ResPriLC,	   
       CASE 
         WHEN @BOM <= src.RecurringChargeFromDate THEN 
         src.RecurringChargeFromDate 
         ELSE @BOM 
       END AS dtFrom, 
       CASE 
         WHEN @EOM > Isnull(src.RecurringChargeToDate, @AsofDate) THEN 
         Isnull(src.RecurringChargeToDate, @AsofDate) 
         ELSE @EOM 
       END AS dtTo, 
       src.RecurringChargeAmount 
FROM   #rentroll rr 
       INNER JOIN seniorrecurringcharge src 
               ON ( rr.resId = src.residentid 
                    AND src.RecurringChargeActiveFlag <> 0 AND rr.UnitID=src.UnitID AND rr.ResPriLC=src.PrivacyLevelCode) 
       INNER JOIN ServiceInstance si 
              ON si.ServiceInstanceID = src.ServiceInstanceID 
       INNER JOIN Service s 
              ON s.serviceID = si.serviceID 
WHERE  src.RecurringChargeFromDate <= @EOM 
       AND Isnull(src.RecurringChargeToDate, @EOM) >= @BOM 
       AND src.RecurringChargeFromDate <= Isnull(src.RecurringChargeToDate, 
                                          @AsofDate) 
       AND Isnull(s.ServiceClassID, 0) = 1        
      
UPDATE #rentroll 
SET    ResOtherMonthlyChargesAmt = Round(tmp.Prorated_Amount ,2),
ResAdditionalUnitOtherCharge = Round(tmp.Prorated_Amount ,2)
FROM   #rentroll rr 
       INNER JOIN (SELECT rr.Resid,  rr.Unitid, rr.ResPriLC,                         
	   Round(SUM(CASE WHEN tp.RateTypeCode = 'DLY' THEN tp.RecurringChargeAmount * ( DATEDIFF(dd,dtFrom ,Isnull(dtTo,@AsOFdate) )+1 )
			ELSE
				CASE WHEN ( DATEDIFF(dd,dtFrom ,Isnull(dtTo,@AsOFdate) )+1 ) = DAY(DATEADD(dd, - 1, DATEADD(mm, 1, @BOM))) 
					THEN  tp.RecurringChargeAmount
					ELSE ROUND((( tp.RecurringChargeAmount/rr.ProrationValue) *  ( DATEDIFF(dd,dtFrom ,Isnull(dtTo,@AsOFdate) ) +1)),2)
				END 
			END),2) Prorated_Amount
From #RentRoll rr
Inner join #Temp_Prorate tp on tp.resid = rr.resid and tp.unitid = rr.unitid and tp.ResPriLC = rr.ResPriLC
Where Title = 'Other Rec. Charge' 
Group by rr.resid, rr.UnitId, rr.ResPriLC
) tmp on tmp.resid = rr.resid and tmp.unitid = rr.unitid and tmp.ResPriLC = rr.ResPriLC

UPDATE #rentroll 
SET    ResPrimaryServiceAmtMonthly_Prorate = Round(tmp.Prorated_Amount ,2)
FROM   #rentroll rr 
       INNER JOIN (SELECT rr.Resid,                        
	   Round(SUM(CASE WHEN tp.RateTypeCode = 'DLY' THEN tp.RecurringChargeAmount * ( DATEDIFF(dd,dtFrom ,Isnull(dtTo,@AsOFdate) )+1 )
			ELSE
				CASE WHEN ( DATEDIFF(dd,dtFrom ,Isnull(dtTo,@AsOFdate) ) +1) = DAY(DATEADD(dd, - 1, DATEADD(mm, 1, @BOM))) 
					THEN  tp.RecurringChargeAmount
					ELSE ROUND((( tp.RecurringChargeAmount/rr.ProrationValue) *  ( DATEDIFF(dd,dtFrom ,Isnull(dtTo,@AsOFdate) ) +1)),2)
				END 
			END),2) Prorated_Amount
From #RentRoll rr
Inner join #Temp_Prorate tp on tp.resid = rr.resid
Where Title = 'Accommodation' 
Group by rr.resid, rr.UnitId, rr.ResPriLC
) tmp on tmp.resid = rr.resid

UPDATE rr 
SET    UnitRent = CASE 
					WHEN Isnull(td.ratetype, '') = '' THEN CASE WHEN Isnull(td.UnitRentMonthly, 0) = 0 THEN td.unitRentDaily ELSE td.UnitRentMonthly END 
					WHEN td.ratetype = 'DLY' THEN td.unitRentDaily 
					ELSE td.UnitRentMonthly 
        End 
from #RentRoll rr 
inner join #tmpOccupancyDetail td on rr.ResId = td.residentid and isnull(rr.ResPriLC,PriLC)=td.privacyLvlCode and rr.UnitId = td.Unitid 

IF '#MedicaidFactor#'='Yes' 
BEGIN
	UPDATE t
	SET ResidentRateNew=case when isnull( t.ratetype ,'')='Daily' 
					then isnull(t.ResidentRateNew,0) * ( CASE 
                      Isnull(t.ProrationRuleCode, 'NON') 
                      WHEN 'AN8' THEN 30.41666667 
                      WHEN 'ANN' THEN 30.42 
                      WHEN 'D30' THEN 30 
                      WHEN 'D34' THEN 30.4 
                      WHEN 'ACT' THEN 
                      Datediff(day, @AsOfDate, Dateadd(month, 1, @AsOfDate)) 
                                                     END )
						else isnull(t.ResidentRateNew,0) end
	FROM #TmpMedicaid t
	INNER JOIN #RentRoll rr ON t.residentid=rr.resId AND rr.additionalunit=0
	
Delete from #TmpMedicaid where @asofDate not between FactorFromDate and FactorTodate 
	
	select Row_Number() over (Partition by t.ResidentID,t.MedicaidTemplateID order by t.factorcode)ID, t.ResidentID,t.MedicaidTemplateID,t.Factorcode 
	into #tmpDeductFactor
	from #tmpMedicaid t
	Inner join 
	(select PropertyID,MedicaidTemplateID,ResidentID,hChargeType 
	from #TmpMedicaid t
	inner join SeniorMedicaidTemplatedetail mtd on mtd.hMedicaidTemplate = t.MedicaidTemplateID and t.factorcode = mtd.sFactorcode
	where t.deductfactor =1 and factorType = 'MedicaidFactor' 
	and @AsOfDate between mtd.dtfrom and isnull(mtd.dtend,'01/01/2100')
	Group by PropertyID,MedicaidTemplateID,ResidentID,hChargeType
	having count(distinct hChargeType) = 1 and count (Factorcode) >1
	) tmp on tmp.PropertyID = t.PropertyID and t.ResidentID = tmp.residentID and t.MedicaidTemplateID = tmp.MedicaidTemplateID
	where t.factorType = 'MedicaidFactor' and t.deductfactor =1
	
	UPDATE t1
	SET t1.ResidentRateNew=t1.ResidentRateNew-t2.ResidentRateNew
	FROM #TmpMedicaid t1
	INNER JOIN (SELECT SUM(ResidentRateNew) ResidentRateNew,ResidentID,MedicaidTemplateID FROM #TmpMedicaid WHERE DeductFactor=1 AND FactorType = 'ResidentFactor' GROUP BY ResidentID,MedicaidTemplateID)t2
	ON t1.ResidentID=t2.ResidentID and t1.MedicaidTemplateID=t2.MedicaidTemplateID
	Left Join #tmpDeductFactor tmp on t1.ResidentID = tmp.residentID and t1.MedicaidTemplateID = tmp.MedicaidTemplateID and t1.FactorCode = tmp.FactorCode
	WHERE t1.FactorType='MedicaidFactor'
	AND t1.DeductFactor=1
	and isnull(tmp.ResidentID,0) = 0

	UPDATE t1
	SET t1.ResidentRateNew=t1.ResidentRateNew-t2.ResidentRateNew
	FROM #TmpMedicaid t1
	INNER JOIN (SELECT SUM(ResidentRateNew) ResidentRateNew,ResidentID,MedicaidTemplateID FROM #TmpMedicaid WHERE DeductFactor=1 AND FactorType = 'ResidentFactor' GROUP BY ResidentID,MedicaidTemplateID)t2
	ON t1.ResidentID=t2.ResidentID and t1.MedicaidTemplateID=t2.MedicaidTemplateID
	INNER Join #tmpDeductFactor tmp on t1.ResidentID = tmp.residentID and t1.MedicaidTemplateID = tmp.MedicaidTemplateID and t1.FactorCode = tmp.FactorCode
	and tmp.ID = 1
	WHERE t1.FactorType='MedicaidFactor'
	AND t1.DeductFactor=1

Drop table #tmpDeductFactor
	
END

UPDATE rr 
SET    resname  = resname + case when '#bStatus#' = 'Yes' then  case t.istatus when 0 then '(C)'
					when 1 then '(M)'
					when 2 then '(F)'
					when 4 then '(N)'
					when 8 then '(W)'
					when 11 then '(L)'
					else '(X)' end 
	else '' end 
from #RentRoll rr 
inner join tenant t on t.hmyperson = rr.resid
--//end 

--//Select
declare @AsOfDate datetime
set @AsOfDate  ='#begmonth#'

DECLARE @BOM DATETIME, 
        @EOM DATETIME 
SET @BOM = CONVERT(VARCHAR, Datepart(mm, @AsOfDate)) 
           + '/01/' 
           + CONVERT(VARCHAR, Datepart(yyyy, @AsOfDate)) 
SET @EOM = Dateadd(dd, -1, Dateadd(mm, 1, @BOM)) 

Select PropName 					s_prop,
	UnitCode 					s_ucode,
	lp2.ListoptionCode 				s_PLC,
	UnitSqft s_UnitSqft,
	UnitType 					s_utype,
	Capacity 	S_Capacity,
	isnull(ResName,'') 				s_Resname,
	ResBDt  					s_ResBDt,
	ResAge 						s_ResAge,
	ResMoveInDt 					s_ResMoveInDt,
	lp1.ListoptionCode 				s_CLC,
	isnull(UnitRent,0.00) 				s_UnitRent ,
	rr.RateType 					s_RateType,
	case additionalunit when 1 then isnull(ResAdditionUnitRent,0.00) else isnull(ResPrimaryServiceAmtMonthly,0.00) end	s_ActualMonthly,
    case additionalunit when 1 then isnull(rr.ResAdditionUnitRentMonthly,0.00) else isnull(rr.ResPrimaryServiceAmtMonthly_Prorate,0) END s_MonthlyAmount,
	case additionalunit when 1 then 0 else isnull(ResDeposit,0.00) end 			s_Deposit,
	case additionalunit when 1 then isnull(ResAdditionalUnitOtherCharge,0.00) else (isnull(ResOtherMonthlyChargesAmt,0.00) 	+   isnull(tmd.ActualAmount,0)) end s_OtherMonthlyCharges, 
	isnull(SecResName,'') 				s_SecRes,
	isnull(SecOccupantRateMonthly,0.00)  		s_secmon ,
	
	SecResAge 					s_SecResAge ,
	waitlist 					s_waitlist ,
	exclude 					s_exclude ,
 isnull(SecResBDt,'') 				s_SecResBDt,
	ResId 						s_resid, 
	Currencysymbol                                  Currencysymbol ,
  isnull(ResAdditionUnitRent,0.00) 	s_ActualMonthlyAdditionUnit,
	isnull(rr.ResAdditionUnitRentMonthly,0.00) s_MonthlyAmountAdditionUnit,
	isnull(ResAdditionalUnitOtherCharge,0.00) s_OtherMonthlyChargesAdditionalUnit,
	additionalunit
from #RentRoll rr
	left outer join listoption lp1 on (lp1.listname = 'CareLevel' and lp1.ListoptionCode = case when rr.ResName = '*Vacant' then rr.UnitCareLevelCode else rr.ResCLC end )
	left outer join listoption lp2 on (lp2.listname = 'PrivacyLevel' and lp2.ListoptionCode = Case when rr.ResName = '*Vacant' then rr.PriLC else rr.ResPriLC end)
	left join tenant t on t.hmyperson= rr.resid 
 	left join (select tm.residentid,sum(tm.ResidentRateNew) ActualAmount
 						  from #TmpMedicaid tm 
 						  	Inner join  #RentRoll rr on tm.residentid=rr.resId  
 						  	where '#MedicaidFactor#'= 	'Yes' AND rr.additionalunit=0
 						  	group by tm.residentid 
 						)tmd on tmd.residentid=rr.resId  
where 1=1 and 'Crystal'='Crystal'  
	and case when '#bExclude#' = 'No' then exclude else 'No' end <> 'Yes' 
	and case when '#bExclude#' = 'No' then waitlist else 'No' end <> 'Yes' 
	and left(rr.PriLC,2) = case when rr.resname = '*Vacant' then (case when rr.Capacity = 1 then 'PR'
								when rr.Capacity = 2 then 'SP'
								when rr.Capacity = 3 then 'TO'
								when rr.Capacity = 4 then 'QD' end) else left(rr.PriLC,2)  end 
	and isnull(rr.ResName,'')<>''
	and  rr.ResName not like (case  when '#bVacant#' like 'no' then '*Vacant' else ''  end )
order by 1, UnitCode,additionalunit, left(lp2.listoptioncode,1) + substring(lp2.listoptioncode,3,3)
--//End Select
	
	
--//Select Sub
Select PropName 					s_prop,
	UnitCode 					s_ucode,
	Capacity	  				S_Capacity,
	isnull(ResName,'') 				s_Resname,
	ResAge 						s_ResAge,
	ResId,
  case 	when isnull(rr.resname,'*Vacant') <> '*Vacant' then isnull(OccPerc,0) else 0 end  CapacityFilledcount,
  case 	when isnull(rr.resname,'*Vacant') <> '*Vacant' then isnull(OccUnit,0) else 0 end OccupancyPerc,
  case 	when isnull(rr.resname,'*Vacant') <> '*Vacant' then isnull(OccUnitDsrgrdngCpcty,0) else 0 end  occUnitDsrgrdngCpcty,
  case 	when isnull(rr.resname,'*Vacant') <> '*Vacant' then isnull(OccResident,0) else 0 end  occResident,
 	isnull(UnitRent,0.00) 				s_UnitRent ,
	isnull(SecResName,'') 				s_SecRes,
	isnull(SecOccupantRateMonthly,0.00)  		s_secmon,
	SecResAge 					s_SecResAge,
	CASE WHEN RTRIM(lp2.ListoptionCode) IN ('PRI','SPA','TOA','QDA' ) THEN 
	case when rr.waitlist = 'Yes' then 'Yes'  
    ELSE 'No' END End  s_waitlist,
	CASE WHEN RTRIM(lp2.ListoptionCode) IN ('PRI','SPA','TOA','QDA' ) THEN 
	case when rr.exclude = 'Yes' then 'Yes'  
    ELSE 'No' END End  s_exclude,
	(Select count(distinct rr1.UnitId) unitcount 
	from 	#RentRoll rr1 
	where 	1=1 
		and case when '#bExclude#' = 'No' then rr1.exclude else 'No' end <> 'Yes'
		and case when '#bExclude#' = 'No' then rr1.waitlist else 'No' end <> 'Yes' 
		and rr1.PropName = rr.PropName 
		and rr1.ResName not like (case  when '#bVacant#' like 'no' then '*Vacant' else ''  end )  
	) 						totalunits,
	(Select sum(vu.unitcount) 
	from 	(Select distinct unitid unitid,
			rr2.Capacity unitcount 
		from 	#RentRoll rr2
		where 	1=1
			and case when '#bExclude#' = 'No' then rr2.exclude else 'No' end <> 'Yes' 
			and case when '#bExclude#' = 'No' then rr2.waitlist else 'No' end <> 'Yes' 
			and rr2.PropName = rr.PropName
			and rr2.ResName not like (case  when '#bVacant#' like 'no' then '*Vacant' else ''  end )  
		) vu 
	where 1=1   
	) 						totalcapacity,
	(Select sum(UnitSqft.UnitSqft) 
	from 	(Select distinct unitid unitid,
			rr3.UnitSqft UnitSqft
		from 	#RentRoll rr3
		where 	1=1
			and case when '#bExclude#' = 'No' then rr3.exclude else 'No' end <> 'Yes' 
			and case when '#bExclude#' = 'No' then rr3.waitlist else 'No' end <> 'Yes'
			and rr3.PropName = rr.PropName        
			and  rr3.ResName not like (case  when '#bVacant#' like 'no' then '*Vacant' else ''  end )   			
		) UnitSqft 
	where 1=1   
	) 						UnitSqft,
	rr.ResPriLC as s_PriLC,
	additionalunit
INTO #temp
from #RentRoll rr
	left outer join listoption lp1 on (lp1.listname = 'CareLevel' and lp1.ListoptionCode = case when rr.ResName = '*Vacant' then rr.UnitCareLevelCode else rr.ResCLC end )
	left outer join listoption lp2 on (lp2.listname = 'PrivacyLevel' and lp2.ListoptionCode = Case when rr.ResName = '*Vacant' then rr.PriLC else rr.ResPriLC end)
	/*left join tenant t on t.hmyperson= rr.resid */
where 1=1
	and case when '#bExclude#' = 'No' then exclude else 'No' end <> 'Yes' 
	and case when '#bExclude#' = 'No' then waitlist else 'No' end <> 'Yes' 
	/*and case when '#bVacant#' = 'No' then ltrim(rtrim(isnull(ResName,''))) else 'a' end <> '*Vacant'*/
	and  left(rr.PriLC,2) = case when rr.resname = '*Vacant' then (case when rr.Capacity = 1 then 'PR'
								when rr.Capacity = 2 then 'SP'
								when rr.Capacity = 3 then 'TO'
								when rr.Capacity = 4 then 'QD' end) else left(rr.PriLC,2)  end 
	and  rr.ResName is not null
	and  rr.ResName not like (case  when '#bVacant#' like 'no' then '*Vacant' else ''  end )
	and '#Output#' <> 'Html'
order by 1, 2

/*TR #480225 - Added occupancy counts for additional unit residents.
AddUnitResidents - Distinct count of residents with respect to unit for additional units.
AddUnitSecResidents - Distinct count of second residents with respect to unit for additional units.
AddUnitOccResidents - Distinct count of residents with respect to unit for additional units (Lease Based Occupancy).
*/
SELECT t.s_prop, 
       t.s_ucode, 
       s_capacity, 
       s_resname, 
       s_resage, 
       t.resid, 
       capacityfilledcount, 
       occupancyperc, 
       occunitdsrgrdngcpcty, 
       t.occresident, 
       s_unitrent, 
       s_secres, 
       s_secmon, 
       s_secresage, 
       s_waitlist, 
       s_exclude, 
       totalunits, 
       totalcapacity, 
       unitsqft, 
       t.s_prilc, 
       additionalunit, 
       addunitresidents, 
       addunitsecresidents, 
       addunitoccresidents 
FROM   #temp t 
       LEFT JOIN (SELECT s_prop, 
                         CONVERT(NUMERIC(18, 2), Count(resid)) 
                         AddUnitResidents, 
                         CONVERT(NUMERIC(18, 2), Count( 
                         CASE 
                           WHEN s_prilc NOT IN ( 
                                'PRI', 'SPA', 
                                'SPB', 
                                'TOA' 
                                , 
                                'TOB', 'TOC', 
                                'QDA', 
                                'QDB' 
                                , 
                                'QDC', 'QDD' ) THEN resid 
                         END))       AddUnitSecResidents, 
                         CONVERT(NUMERIC(18, 2), Sum(occresident)) 
                         AddUnitOccResidents 
                  FROM   (SELECT DISTINCT s_prop, 
                                          s_ucode, 
                                          resid, 
                                          s_prilc, 
                                          occresident 
                          FROM   #temp t 
                          WHERE  additionalunit = 1 
                                 AND resid <> 0 
                          GROUP  BY s_prop, 
                                    s_ucode, 
                                    resid, 
                                    s_prilc, 
                                    occresident) myview 
                  GROUP  BY s_prop) myview1 
              ON myview1.s_prop = t.s_prop 

--//End Select
	
--//Select Detail
/*Detail*/
declare @AsOfDate datetime
set @AsOfDate  ='#begmonth#'

DECLARE @BOM DATETIME, 
        @EOM DATETIME 
SET @BOM = CONVERT(VARCHAR, Datepart(mm, @AsOfDate)) 
           + '/01/' 
           + CONVERT(VARCHAR, Datepart(yyyy, @AsOfDate)) 
SET @EOM = Dateadd(dd, -1, Dateadd(mm, 1, @BOM))

select 
distinct src.residentid resid,
rr.unitcode unitcode,
	src.ratetypecode ratecode, 
	isnull(s.servicename,'Other - ' + ltrim(rtrim(ct.sname))) servicename,
	isnull( src.ratetypecode,'')  ratetype,
	isnull(src.recurringchargeamount,0)  ActualAmount,
	(CASE WHEN tp.RateTypeCode = 'DLY' THEN tp.RecurringChargeAmount * ( DATEDIFF(dd,dtFrom ,Isnull(dtTo,@AsOFdate) )+1 )
			ELSE
				CASE WHEN ( DATEDIFF(dd,dtFrom ,Isnull(dtTo,@AsOFdate) ) +1) = DAY(DATEADD(dd, - 1, DATEADD(mm, 1, @BOM))) 
					THEN  tp.RecurringChargeAmount
					ELSE ROUND((( tp.RecurringChargeAmount/rr.ProrationValue) *  ( DATEDIFF(dd,dtFrom ,Isnull(dtTo,@AsOFdate) ) +1)),2)
				END 
	END)MonthlyAmount,
	ltrim(rtrim(sp.PayorLastNAme)) +', '+ ltrim(rtrim(sp.PayorfirstName))+ '('+ltrim(rtrim(PayorCode))+') ' Payer, 
	src.RecurringChargefromdate SIFromDT, 
	src.RecurringChargeToDate SIToDT,
	rr.propId p_pId,
	rr.resname ResName,
	case when (s.serviceid  in (select serviceid from #sec)) then '2nd Resident Service' else 'Ancillary Services / Other Recurring Charges' end servicetype,
	ltrim(rtrim(ct.sname)) ChargeCode,
		Currencysymbol Currencysymbol
from #RentRoll rr
inner join seniorrecurringcharge src on (rr.resId = src.residentid and src.RecurringChargeActiveFlag <> 0) 
inner join seniorpayor sp on sp.payorid = src.payorid
inner join chargtyp ct on ct.hmy = src.chargetypeid
Inner Join #Temp_Prorate tp on tp.RecurringChargeID = src.RecurringChargeID
left join  serviceinstance si on si.serviceinstanceid = src.serviceinstanceid 
left join service s on s.serviceid = si.serviceid  
Left Join SeniorProspect pros ON pros.hTenant = rr.resid AND pros.sStatus in ('Prospect', 'Inactive')
Left join seniorcontact scon on (scon.residentid = IsNull(pros.hMy, rr.resid) and scon.relationshipcode <> 'SLF' AND scon.ContactRoommateFlag <> 0 and ContactActiveFlag <> 0)
left join  #sec se on (se.serviceid=isnull(s.serviceid,0)) 
where 1=1
and isnull(s.serviceid,-1) <> ( case when isnull(scon.contactid,0) <>0 then  isnull(se.serviceid,0) else 0 end)
		and isnull(s.serviceclassid,0) <>1
/*and @AsOfDate between src.RecurringChargeFromDate and isnull(src.RecurringChargeToDate,@AsOfDate)
and src.RecurringChargeFromDate <=  isnull(src.RecurringChargeToDate,src.RecurringChargeFromDate)*/
AND		src.RecurringChargeFromDate <= @EOM
AND		ISNULL(src.RecurringChargeToDate,@EOM)	>= @BOM
AND		src.RecurringChargeFromDate			<= ISNULL(src.RecurringChargeToDate, @AsOFdate)

union all  
select   tm.residentid resid,
rr.unitcode unitcode,
	 tm.rateType, 
	 FactorDescription servicename,
	isnull( tm.ratetype ,'')  ratetype,
	isnull(tm.ResidentRate,0)  ActualAmount,
	tm.ResidentRateNew MonthlyAmount,
	'' Payer, 
	tm.Factorfromdate SIFromDT, 
	tm.FactorToDate SIToDT,
	rr.propId p_pId,
	rr.resname ResName,
	Case when FactorType like 'MedicaidFactor' then 'Medicaid Factor' ELSE 'Resident Factor' end  servicetype,
	'' ChargeCode,
		Currencysymbol Currencysymbol
from #RentRoll rr
Inner join #tmpMedicaid tm on tm.residentid=rr.resid AND rr.additionalunit=0
order by 1,4
--//End Select

--//Select  CLC_Key
select ListoptionCode code
	, ListOptionName name 
	, CAse when ListOptionActiveFlag = 1 then 'Yes' else 'No' end  active
from ListOption where listname = 'CareLevel' 
and '#Output#' <> 'Html'
--//end select 

--//Select  PLC_Key
select ListoptionCode code
	, ListOptionName name 
	, CAse when ListOptionActiveFlag = 1 then 'Yes' else 'No' end  active
from ListOption where listname = 'PrivacyLevel' 
and '#Output#' <> 'Html'
//end select 

--//Select RSC_Key
select '' code
	, '' name 
	, ''  active
--//end select 
--//Select No Crystal after 
drop table #RentRoll
drop table #sec
drop table #tmpOccupancyDetail
drop table #TmpMedicaid
--//End Select

--//Columns
--//Type  Name    Head1     Head2                   Head3        		  Head4,   Show,  Color,     Formula,  Drill,     Key,  Width,
--B,        ,        ,         ,         								,   	     Property,      N,       ,            ,      	,        ,    700,
--T,        ,        ,         ,         								,              Unit,      Y,       ,            ,       ,        ,   1000,
--I,        ,        ,         ,         								,         Unit Sqft,      Y,       ,            ,       ,        ,   1000,
--T,        ,        ,         ,         								,         Unit Type,      Y,       ,            ,       ,        ,   1000,
--I,	  		,	   		 ,	     	 ,	       								,          Capacity,      Y,       ,       			,       ,        ,   	700,
--T,        ,        ,         ,         				 Privacy,             Level,      Y,       ,            ,       ,        ,   1400,
--T,        ,        ,         ,         								,          Resident,      Y,       ,            ,       ,        ,   1400,
--A,        ,        ,         ,         								,        Birth Date,      Y,       ,            ,       ,        ,    700,
--T,        ,        ,         ,         								,               Age,      Y,       ,            ,       ,        ,    500, 
--A,        ,        ,         ,  							 Move In,              Date,      Y,       ,            ,       ,        ,   1000,
--T,        ,        ,         ,         								,        Care Level,      Y,       ,            ,       ,        ,   1400,
--T,        ,        ,         ,     								 2nd,          Resident,      Y,       ,            ,       ,        ,   1400,
--D,        ,        ,      	 ,						2nd Resident,               Age,      Y,       ,            ,       ,        ,   1000,
--D,        ,        ,       	 ,						 Unit Market,              Rate,      Y,       ,            ,       ,        ,   1000,
--T,        ,        ,         ,     								Rate,              Type,      Y,       ,            ,       ,        ,   1400,
--D,        ,        ,      	 ,		Accomodation Service,        Per Period,      Y,       ,            ,       ,        ,   2000,
--D,        ,        ,      	 ,		Accomodation Service,           Monthly,      Y,       ,            ,       ,        ,   2000,
--D,        ,        ,         , 								Resident,           Deposit,      Y,       ,            ,       ,        ,   1000,
--D,        ,        ,     		 ,		  		 2nd Resident,         Rate (Monthly),      Y,       ,            ,       ,        ,   1000,
--D,        ,        ,     		 ,		  		 Other Charges,         (Monthly),      Y,       ,            ,       ,        ,   1000,
--T,        ,        ,         ,         								,                 X,      Y,       ,            ,       ,        ,   10,
--T,        ,        ,         ,         								,                 W,      Y,       ,            ,       ,        ,   10,
--//landscape
--//End columns

--//Filter    
--//Type,yp,              Name,                             Caption,    Key,                                                                                                         List,                          Val1,	Val2, 	Man, Multi, Title  Title
--C,      T,             phmy,                           Community,       ,                                                                                                           61,                 p.hmy=#phmy#,     ,     Y,     Y,    Y,
--0,      A,          begmonth,                          As of Date,       ,                                                                                                             ,                              ,     ,     Y,     N,    Y,
--0,      T,       ServiceName,                2nd Occupant Service,       ,                               "select  s.ServiceId,ltrim(rtrim(s.ServiceName)) from service s where s.serviceclassid not in (1)", s.ServiceId in (#ServiceName#),     ,     N,     N,    Y,
--L,      T,          bExclude,	Show Excluded / Waitlisted Units?,       ,                                                                                                       No^Yes,                              ,     ,     N,     N,     ,  
--L,      T,           bVacant,	               Show Vacant Units?,       ,                                                                                                       No^Yes,                              ,     ,     N,     N,     ,  
--L,      T,           bStatus,	    Show Current Resident Status?,       ,                                                                                                       No^Yes,                              ,     ,     N,     N,     ,  
--L,      T,   MedicaidFactor,	   Include Medicaid Factor?,   ,   "No^Yes",                              ,     ,     N,     N,     ,  
--L,      T,   OccType,	      Occupancy Type,   ,     					"SELECT DISTINCT CASE WHEN sObjName='SHOccupancyPhysicalUnitBased' THEN 'Physical Unit Based' WHEN sObjName='SHOccupancyPhysicalLeaseBased' THEN 'Physical Lease Based' WHEN sObjName='SHOccupancyPhysicalUnitBaseddisregardingcapacity' THEN 'Physical Unit Based (disregarding capacity)' WHEN sObjName='SHOccupancyFinancialUnitBased' THEN 'Financial Unit Based' WHEN sObjName='SHOccupancyFinancialLeaseBased' THEN 'Financial Lease Based' WHEN sObjName='SHOccupancyFinancialUnitBaseddisregardingcapacity' THEN 'Financial Unit Based (disregarding capacity)' END, CASE WHEN sObjName='SHOccupancyPhysicalUnitBased' THEN 1 WHEN sObjName='SHOccupancyPhysicalLeaseBased' THEN 2 WHEN sObjName='SHOccupancyPhysicalUnitBaseddisregardingcapacity' THEN 3 WHEN sObjName='SHOccupancyFinancialUnitBased' THEN 4 WHEN sObjName='SHOccupancyFinancialLeaseBased' THEN 5 WHEN sObjName='SHOccupancyFinancialUnitBaseddisregardingcapacity' THEN 6 END  FROM isecurity2 i INNER JOIN pmgroup g ON i.hGroup = g.hmy INNER JOIN pmuser u ON u.hGroup = g.hmy WHERE iAccess= 2 and sObjName in ('SHOccupancyPhysicalUnitBased','SHOccupancyPhysicalLeaseBased','SHOccupancyPhysicalUnitBaseddisregardingcapacity','SHOccupancyFinancialUnitBased','SHOccupancyFinancialLeaseBased','SHOccupancyFinancialUnitBaseddisregardingcapacity') and u.uName = '#@@USERNAME#' and '#@@USERNAME#' <> '' UNION SELECT DISTINCT 'Physical Unit Based', 1 WHERE ('#@@USERNAME#' = '' OR CHARINDEX('@@USERNAME#', '#@@USERNAME#') > 0) UNION SELECT 'Physical Lease Based',2 WHERE ('#@@USERNAME#' = '' OR CHARINDEX('@@USERNAME#', '#@@USERNAME#') > 0) UNION SELECT 'Physical Unit Based (disregarding capacity)',3 WHERE ('#@@USERNAME#' = '' OR CHARINDEX('@@USERNAME#', '#@@USERNAME#') > 0) UNION SELECT 'Financial Unit Based',4 WHERE ('#@@USERNAME#' = '' OR CHARINDEX('@@USERNAME#', '#@@USERNAME#') > 0) UNION SELECT 'Financial Lease Based',5 WHERE ('#@@USERNAME#' = '' OR CHARINDEX('@@USERNAME#', '#@@USERNAME#') > 0) UNION SELECT 'Financial Unit Based (disregarding capacity)',6 WHERE ('#@@USERNAME#' = '' OR CHARINDEX('@@USERNAME#', '#@@USERNAME#') > 0) ORDER BY 2",                              ,     ,     Y,     N,     ,  
--//end filter