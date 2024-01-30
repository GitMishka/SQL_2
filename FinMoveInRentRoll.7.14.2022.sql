--//Vista

--//Notes
--Senior Housing: Independent HealthCare Rent Roll
--Modifications
--        07/02/2015 - CPR#23961 - VC - Created.
--                                      07/09/2015 - Modified again for custom changes.
--                                      08/17/2015 - Modified for issues.
--                                      08/21/2015 - Modified to work like Income Statement from Financial Analytics
--                                      09/09/2015 - Modified to include more account codes
--                                      10/06/2015 - Modified to remove account 570600 from Other Monthly Charges
--                                      	           Modified to exclude Move Out residents from the report.
--       03/29/2016 - VCH - Case#3230048 - Modified to include the account mentioned in the case for respective columns.
--       																	 Created SQL report to preview/add/delete account details from the table referred in this report.
--			 11/21/2016 -	VB 	- Case#3790557 - Added Sort By filter to the report.   
--			 12/09/2016 - VCH - Case#3817070 - Modified report to include unit details for a tenant Based on Resident history   			
--			 12/21/2016 - VCH - Case#3850147 - Modified report to display a resident with prorated amount if a unit transfer is performed in the same period.														 
--//End Notes

--//Database
--SSRS rs_SeniorIHPRentRoll.rdlc
--//End Database

--//Crystal
--CryActive Y
--Crytree y
--param rptVersion = 50.12.20 23.08
--param rptMonth = #begmonth#
--param Community = #p.hmy#
--param Exclude = #bExclude#
--param Vacant = #bVacant#
--param sort= #SortBy#
--param idrill =PageASPX/YSIEntry.aspx?e=ResidentCensus&ResidentID=
--param repDrill=SSRSReportViewer.aspx?select=reports\\rs_SeniorIHPRentRoll_Drill.SSRS.txt
--//End Crystal

--//Title
--IHP Rent Roll
--//end title

--//Select No Crystal
DECLARE @Month DATETIME
DECLARE @MonthEnd DATETIME
DECLARE @PropertyCode VARCHAR(4000)

SET @Month = '07-01-22' --'#begmonth#'
SET @MonthEnd = DATEADD(MI, 1400,DATEADD(dd, -1, DATEADD(mm, 1, @Month)))
--SET @MonthEnd = DATEADD(dd, -1, DATEADD(mm, 1, @Month))
SET @PropertyCode = 'brwd'
SELECT @PropertyCode = @PropertyCode + CASE WHEN @PropertyCode = '' THEN '' ELSE ',' END + LTRIM(RTRIM(p.sCode))
FROM Property p
WHERE 1=1
--#CONDITION1#

IF OBJECT_ID('TempDb..#Property') IS NOT NULL
DROP TABLE #Property
CREATE TABLE #Property
(
        PropertyID      NUMERIC,
        PropCode        VARCHAR(8),
        PropName        VARCHAR(50),
        Address2        VARCHAR(50),
        Address3        VARCHAR(50),
        CityStateZip    VARCHAR(50)
)

IF OBJECT_ID('TempDb..#Units') IS NOT NULL
DROP TABLE #Units
CREATE TABLE #Units
(
        PropertyID              NUMERIC,
        x                       INTEGER,
        w                       INTEGER,
        UnitId                  NUMERIC,
        Unit                    VARCHAR(20),
        UnitType                VARCHAR(60),
        PrivacyLevel            VARCHAR(60),
        UnitRent                NUMERIC(18, 2)
)

IF OBJECT_ID('TempDb..#RentRoll') IS NOT NULL
DROP TABLE #RentRoll
CREATE TABLE #RentRoll
(
        PropCode                VARCHAR(8),
        PropName                VARCHAR(100),
        x                       INTEGER,
        w                       INTEGER,
        UnitId                  NUMERIC,
        Unit                    VARCHAR(20),
        UnitType                VARCHAR(60),
        PrivacyLevel            VARCHAR(60),
        ResidentID              NUMERIC,
        Resident                VARCHAR(150),
        CareLevel               VARCHAR(50),
        MoveInDate              DATETIME,
        LengthOfStay            NUMERIC(18, 2),
        Accommodation           VARCHAR(60),
        BillingCareLevel        VARCHAR(60),
        UnitMarketRate          NUMERIC(18, 2),
        StreetRate              NUMERIC(18, 2),
        Discounts               NUMERIC(18, 2),
        BillingCareLvlRate      NUMERIC(18, 2),
        MedicationMgmt          NUMERIC(18, 2),
        OtherMonthlyCharges     NUMERIC(18, 2),
        TotalMonthlyCharges     NUMERIC(18, 2)
)

/* Collect unit Information */
INSERT INTO #Units
SELECT  p.hmy,
        isnull(myView.UnitExcludeFlag,u.exclude),
        myView.UnitWaitlistFlag,
        u.hmy,
        ltrim(rtrim(u.scode)),
        ltrim(rtrim(ut.scode)),
        isnull(myview.PrivacyLevelCode, (case when su.UnitCapacityCount =1 then 'PR'
                                        when su.UnitCapacityCount =2 then 'SP'
                                        when su.UnitCapacityCount =3 then 'TO'
                                        when su.UnitCapacityCount =3 then 'QD' end )),
        myview.UnitrentMonthlyAmount
FROM Unit u
INNER JOIN Property p on u.hproperty = p.hmy
INNER JOIN SeniorPropertyFunctionAll ('brwd', @PropertyCode) x on x.PropertyID = p.hmy
INNER JOIN Unittype ut on (u.hunittype = ut.hmy)
INNER JOIN Seniorunit su on u.hmy = su.unitid
INNER JOIN
(
        SELECT  UnitId,
                UnitWaitlistFlag,
                UnitExcludeFlag,
                surh.UnitrentMonthlyAmount,
                surh.UnitrentDailyAmount,
                surh.PrivacyLevelCode
        FROM SeniorUnitHistory suh
        INNER JOIN  SeniorUnitRentHistory surh on surh.UnitHistoryId = suh.UnitHistoryId AND surh.PrivacyLevelCode = 'PRI'
        WHERE 1=1
        and suh.UnitHistoryId =
        (
                SELECT  Max(UnitHistoryId)
                FROM SeniorUnitHistory suh1
                WHERE suh1.UnitId = suh.UnitId
                AND suh1.UnitHistoryActiveFlag <> 0
                AND suh1.UnitHistoryFromdate =
                (
                        SELECT max(suh2.UnitHistoryFromDate)
                        FROM SeniorUnitHistory suh2
                        WHERE suh2.UnitId = suh.UnitId
                        AND suh2.UnitHistoryActiveFlag <> 0
                        AND DATEADD(dd, 0, DATEDIFF(dd, 0, suh2.UnitHistoryFromDate)) <= @MonthEnd
                        AND @Month <= ISNULL(DATEADD(dd, 0, DATEDIFF(dd, 0,  ISNULL(suh2.UnitHistorytoDate,@MonthEnd))), @MonthEnd)
                )
        )
        AND LEFT(surh.privacylevelcode,2) in
        (
                SELECT 'PR' WHERE suh.unitcapacitycount in (1,2,3,4)
                UNION
                SELECT 'SP' WHERE suh.unitcapacitycount in (2,3,4)
                UNION
                SELECT 'TO' WHERE suh.unitcapacitycount in (3,4)
                UNION
                SELECT 'QD' WHERE suh.unitcapacitycount in (4)
        )
) myview on (myview.UnitId = u.hmy)
WHERE 1=1
--select * from #Units
/* Collect property Information */
INSERT  INTO #Property
SELECT DISTINCT
        p.hMy,
        LTRIM(RTRIM(p.sCode)),
        LTRIM(RTRIM(p.sAddr1)),
        LTRIM(RTRIM(p.sAddr2)),
        LTRIM(RTRIM(p.sAddr3)),
        LTRIM(RTRIM(p.sCity)) + ' ' + LTRIM(RTRIM(p.sState))
        + ' ' + LTRIM(RTRIM(p.sZipCode))
FROM    dbo.SeniorPropertyFunctionAll('', @PropertyCode) x
        INNER JOIN Property p on x.PropertyID = p.hmy

/* Collect unit, resident, and one time charges information into #RentRoll table */
INSERT INTO #RentRoll
SELECT  p.PropCode                                                                                                             PropCode,
        p.PropName                                                                                                             PropName,
        us.x                                                                                                                   x,
        us.w                                                                                                                   w,
        us.UnitId                                                                                                              UnitId,
        LTRIM(RTRIM(us.Unit))                                                                                                  Unit,
        us.UnitType                                                                                                            UnitType,
        us.PrivacyLevel                                                                                                        PrivacyLevel,
        t.hmyPerson                                                                                                            ResidentID,
        LTRIM(RTRIM(t.sLastName)) + ', ' + LTRIM(RTRIM(t.sFirstName)) + ' (' + LTRIM(RTRIM(t.sCode)) + ')'                     Resident,
        LTRIM(RTRIM(sr.CareLevelCode))                                                                                         CareLevel,
        CONVERT(CHAR(10), SR1.dtMoveInFinancial, 101)                                                                          MoveInDate, /* CHANGED: FIN MOVE IN 7/14/2022 */
        0.00                                                                                                                   MonthStay,
        ''                                                                                                                     Accommodation,
        ''                                                                                                                     BillingCareLevel,
        us.UnitRent                                                                                                            UnitRent,
        SUM(CASE WHEN Custom.Description = 'Accommodation' THEN tr.sTotalAmount ELSE 0 END)                                    AccommodationRate,
        SUM(CASE WHEN Custom.Description = 'Discounts' THEN tr.sTotalAmount ELSE 0 END)                                 			 Discounts,
        SUM(CASE WHEN Custom.Description = 'Billing Level of Care' THEN tr.sTotalAmount ELSE 0 END) 													 BillingCareLvlRate,
        SUM(CASE WHEN Custom.Description = 'Medication Mgmt' THEN tr.sTotalAmount ELSE 0 END)               									 MedicationMgmt,
        SUM(CASE WHEN Custom.Description = 'Other Monthly Charges' THEN tr.sTotalAmount ELSE 0 END)                            OtherMonthlyCharges,
        0.00                                                                                                                   TotalMonthlyCharges
FROM #Property p
        INNER JOIN PropOptions po ON po.hProp = p.PropertyID AND po.sType LIKE 'SeniorProrationRule'
        INNER JOIN #Units us ON us.PropertyID = p.propertyid
        INNER JOIN Trans tr ON us.UnitID = tr.hUnit and tr.hprop = p.propertyid AND tr.iType = 7 
		AND tr.upostdate = @Month
		--AND tr.SDATECREATED = @Month---tr.uPostDate = @Month /* VCH - Case#3850147 */
		--and tr.SDATECREATED between @month and @MonthEnd
        INNER JOIN Tenant t ON t.hProperty = p.PropertyID and tr.hPerson = t.hmyPerson
        INNER JOIN SeniorResident sr ON sr.ResidentID = t.hmyPerson
        INNER JOIN SeniorResidentHistory srh ON srh.ResidentID = t.hmyPerson		/*VCH*/
        INNER JOIN SeniorResidentStatus srs ON srs.iStatus = t.iStatus
        LEFT  JOIN UnitType ut ON ut.sCode = us.UnitType
        INNER JOIN SeniorCharge sc ON sc.ChargeID = tr.hmy
        LEFT  JOIN acct a ON a.hmy = tr.hOffsetAcct
		LEFT  JOIN SeniorIHPCustomRentRollAccounts Custom on Custom.Account_scode = a.scode    
		INNER JOIN SeniorResident SR1 on SR1.ResidentID = t.HMYPERSON /* CHANGED: FIN MOVE IN 7/14/2022 */
       
       /* AND a.sCode IN ( '510100','510200','510300','510400','510500','510600','510700','510800','510900','520000','520100','520200','520300','520500','520600','520700','520800','520900',
                         '570600','580150','580170',
                         '540100', '540200', '540300', '540400', '540450', '540500', '540550','540410','540420',
                         '541550','541552','541553','541554','541555',
                         '541000','541010','541020','541100','541200','541300','541400','541500','541560','541700','542000','570200','570300','570500','580050','580100','580300','580400','589920','589930'
                        ) */ 																													/*VCH*/
        LEFT  JOIN ChargTyp ct ON ct.hmy = tr.hRetentionAcct
        LEFT  JOIN SeniorRecurringCharge src ON src.RecurringChargeID = sc.RecurringChargeID
        LEFT  JOIN ServiceInstance si ON si.ServiceInstanceID = src.ServiceInstanceID
        LEFT  JOIN Service s ON s.ServiceID = si.ServiceID
        LEFT  JOIN ServiceClass scl ON scl.ServiceClassID = s.ServiceClassID
WHERE 1=1  
  AND tr.uPostDate <= dateadd(dd,-(day(isnull(sr.ResidentbillingEndDate,'01/01/2100')))+1,isnull(sr.ResidentbillingEndDate,'01/01/2100')) 
  AND Srh.Residenthistoryid IN ( SELECT      
                                            Max( Residenthistoryid ) Residenthistoryid      
 																					 FROM   Seniorresidenthistory Srh1      
                                            WHERE  Srh1.Residentid = Srh.Residentid      
                                            AND Srh1.Residenthistorycode  IN ('MIN', 'NOT', 'CNT', 'OUT', 'QIK','SRV', 'LCM', 'LCN', 'LED', 'LST' )      
                                            AND CONVERT( DATETIME, CONVERT(VARCHAR(11), Srh1.Residenthistorydate), 101 ) = 
                                            							( SELECT      
                                                           Max( CONVERT( DATETIME, CONVERT(VARCHAR(11), Residenthistorydate), 101 ) )      
                                                           FROM   Seniorresidenthistory Srh2      
                                                           WHERE  CONVERT( DATETIME, CONVERT(VARCHAR(20), Srh2.Residenthistorydate, 101), 101 ) <= CONVERT( DATETIME, @MonthEnd, 101 )      
                                                           AND Srh2.Residentid = Srh1.Residentid      
                                                           AND Residenthistorycode  IN ( 'MIN', 'NOT', 'CNT', 'OUT', 'QIK','SRV', 'LCM', 'LCN', 'LED', 'LST' ) 
                                                          )      
                                            GROUP  BY Residentid 
                                           )		/*VCH*/
GROUP BY
        p.PropCode,
        p.PropName,
        us.x,
        us.w,
        us.UnitId,
        us.Unit,
        us.UnitType,
        us.PrivacyLevel,
        t.hmyPerson,
        LTRIM(RTRIM(t.sLastName)) + ', ' + LTRIM(RTRIM(t.sFirstName)) + ' (' + LTRIM(RTRIM(t.sCode)) + ')',
        LTRIM(RTRIM(sr.CareLevelCode)),
        sr1.dtMoveInFinancial, /* CHANGED: FIN MOVE IN 7/14/2022 */
        us.UnitRent

	select * from #RentRoll where unitid in (894,938,919)
	--where moveindate = '06-30-22'

/* Update Service name for service class 'Care Level' */
UPDATE rr
SET rr.BillingCareLevel = RIGHT(ISNULL(ser.serviceName, ''), 1)
FROM #RentRoll rr
INNER JOIN
(
        SELECT  p.PropCode,
                t.hmyPerson ResidentID,
                c.UnitID,
                LTRIM(RTRIM(sc.ServiceClassName)) ServiceClassName,
                LTRIM(RTRIM(s.ServiceName))       ServiceName
        FROM #Property p
        INNER JOIN Tenant t ON t.hProperty = p.PropertyID
        INNER JOIN ServiceInstance c ON c.ResidentID = t.hmyPerson
                AND c.ServiceInstanceActiveFlag <> 0
                AND c.ServiceInstanceFromDate <= @MonthEnd
                AND ISNULL(c.ServiceInstanceToDate,@MonthEnd) >= @Month
                AND isnull(c.ServiceInstanceToDate,@MonthEnd) >=  c.ServiceInstanceFromDate
        INNER JOIN Service s on s.ServiceId = c.ServiceId
        INNER JOIN ServiceClass sc on sc.ServiceClassId = s.ServiceClassId AND sc.ServiceClassName IN ('Care Level')
        GROUP BY p.PropCode, t.hmyPerson,c.UnitID, LTRIM(RTRIM(sc.ServiceClassName)), LTRIM(RTRIM(s.ServiceName))
) ser ON ser.PropCode = rr.PropCode AND ser.ResidentID = rr.ResidentID 
				AND ser.UnitID = rr.UnitID /* VCH - Case#3850147 */

/* Sum into Total Monthly Charges */
UPDATE r
SET r.TotalMonthlyCharges = StreetRate + Discounts + BillingCareLvlRate + MedicationMgmt + OtherMonthlyCharges
FROM #RentRoll r

/* Insert Vacant units */
INSERT INTO #RentRoll
SELECT  p.PropCode           PropCode,
        p.PropName           PropName,
        u.x                  x,
        u.w                  w,
        u.UnitId             UnitId,
        LTRIM(RTRIM(u.Unit)) Unit,
        u.UnitType           UnitType,
        u.PrivacyLevel       PrivacyLevel,
        0                    ResidentID,
        '*Vacant'            Resident,
        ''                   CareLevel,
        ''                   MoveInDate,
        0.00                 MonthStay,
        ''                   Accommodation,
        ''                   BillingCareLevel,
        u.UnitRent           UnitRent,
        0.00                 AccommodationRate,
        0.00                 Discounts,
        0.00                 BillingCareLvlRate,
        0.00                 MedicationMgmt,
        0.00                 OtherMonthlyCharges,
        0.00                 TotalMonthlyCharges
FROM #Units u
INNER JOIN #Property p ON p.PropertyID = u.PropertyID
LEFT JOIN #RentRoll r ON r.UnitId = u.UnitId
WHERE r.UnitID IS NULL
AND u.PrivacyLevel = 'PRI'

/* Calculate Average Legth of Stay */
SET @Month = '01/01/1900'
SET @MonthEnd = GetDate()

UPDATE rr
SET rr.LengthOfStay = a.Average
FROM #RentRoll rr
INNER JOIN
(
        SELECT  LTRIM(RTRIM(p.sCode)) pCode,
                t.hmyperson,
                /* srh.CareLevelCode,*/
                CASE WHEN count(t.hmyperson) = 0 THEN 0
                     ELSE ROUND(sum(DATEDIFF(dd, CASE WHEN sr.dtMoveInFinancial >=@Month THEN sr.dtMoveInFinancial ELSE @Month END /* CHANGED: FIN MOVE IN 7/14/2022 */
                                               , CASE WHEN @MonthEnd <= isnull(sr.ResidentBillingEndDate,@MonthEnd) THEN @MonthEnd
                                                      ELSE isnull(sr.ResidentBillingEndDate,@MonthEnd)
                                                 END +1) / 30.4166) / count(t.hmyperson),2)
                END Average
        FROM    Unit u
                INNER JOIN SeniorUnit su                ON (u.hmy = su.unitid)
                INNER JOIN Tenant t                     ON t.hunit = u.hmy
                INNER JOIN Property p                   ON p.hmy = t.hProperty
                INNER JOIN #RentRoll rr                 ON rr.PropCode = LTRIM(RTRIM(p.sCode)) and rr.ResidentID = t.hmyperson
                INNER JOIN SeniorResident sr            ON t.hmyperson = sr.residentid
                inner join SeniorResidentHistory srh    on srh.residentid =t.hmyperson
                and srh.ResidentHistoryId =
                (
                        select max(s.residenthistoryid)
                        from seniorresidenthistory s
                        where s.residentid=t.hmyperson
                        and s.residenthistorydate =
                        (
                                select max(s1.residenthistorydate)
                                from seniorresidenthistory s1
                                where s1.residentid=s.residentid
                                and convert(datetime,convert(char(10),ResidentHistoryDate,121),101) <= @MonthEnd
                                and s1.residentstatuscode not in (2,7,8,9)
                                and s1.residenthistorycode <>'CNT'
                        )
                        and s.residentstatuscode not in (2,7,8,9)
                )
                inner join SeniorResidentStatus srs ON srh.residentstatuscode = srs.iStatus
        WHERE   1 = 1
                AND sr.dtMoveInFinancial <= @MonthEnd /* CHANGED: FIN MOVE IN 7/14/2022 */
                AND su.UnitWaitListFlag NOT IN (1)
                AND srh.residentstatuscode NOT IN (2,7,8,9)
        GROUP BY LTRIM(RTRIM(p.sCode)),t.hmyperson
) a ON a.pCode = rr.PropCode AND a.hmyperson = rr.ResidentID
--//end

--//Select
SELECT  *
		--PropCode,
  --      PropName,
  --      x,
  --      w,
  --      UnitId,
  --      Unit,
  --      UnitType,
  --      PrivacyLevel,
  --      ResidentID,
  --      Resident,
  --      CareLevel,
  --      MoveInDate,
  --      LengthOfStay     MonthStay,
  --      Accommodation,
  --      BillingCareLevel,
  --      UnitMarketRate   UnitRent,
  --      StreetRate       AccommodationRate,
  --      Discounts,
  --      BillingCareLvlRate,
  --      MedicationMgmt,
  --      OtherMonthlyCharges,
  --      TotalMonthlyCharges
FROM #RentRoll
WHERE 1=1
        AND Resident <> CASE WHEN '#bVacant#'= 'No' THEN '*Vacant' ELSE '' END
        AND CASE WHEN '#bExclude#' = 'No' THEN x ELSE 0 END <> 1
        AND CASE WHEN '#bExclude#' = 'No' THEN w ELSE 0 END <> 1
		--and Residentid = 136431
		and moveindate = '2022-06-30'
ORDER BY CASE '#SortBy#' WHEN 'Unit Type' THEN UnitType 
												 WHEN 'Unit' 			THEN Unit	
												 WHEN 'Level of Care' THEN BillingCareLevel
												 WHEN 'Move In Date'	THEN CONVERT(VARCHAR(10),CONVERT(DATETIME, CONVERT(VARCHAR(20),LTRIM(RTRIM(MoveInDate)),101),101),121)									
												 ELSE  Resident END
				 
--//End Select

--//Filter
--//Type,yp,              Name,                             Caption,    Key,    List,       Val1, Val2,    Man,  Multi, Title Title
--C,      T,             p.hmy,                           Community,       ,    61,         p.hmy=#p.hmy#, ,     N,     Y,    Y,
--0,      M,          begmonth,                          Post Month,       ,    ,           ,              ,     Y,      ,    Y,
--L,      T,          bExclude,   Show Excluded / Waitlisted Units?,       ,    No^Yes,     ,              ,     Y,     N,     ,
--L,      T,           bVacant,                  Show Vacant Units?,       ,    No^Yes,     ,              ,     Y,     N,     ,
--L,			T,						SortBy,															Sort By,			 ,Unit^Unit Type^Resident^Move In Date^Level of Care,	,	,Y,	,
--//end filter