CREATE TABLE #ConsolidatedAssessmentResult
(
  residentid NUMERIC,
  Class VARCHAR(100),
  Code VARCHAR(50),
  s_Recommend VARCHAR(50),
  s_service VARCHAR(100),
  s_sid NUMERIC,
  Classid NUMERIC,
  s_score NUMERIC,
  InHouse NUMERIC(10, 2),
  OutSide NUMERIC(10, 2),
  RecommScore NUMERIC(10, 2),
  ChargeTypeCode varchar(8)
)

CREATE TABLE #ResidentRecurringCharge
(
  UnitCode          varchar(250), 
  RecurringChargeID numeric(18, 0),
  ChargeTypeCode varchar(8),
  ChargeTypeDescription varchar(32),
  RecurringChargeFromDate datetime,
  RecurringChargeToDate datetime,
  RecurringChargeAmount money,
  Billing varchar(7),
  PayorID numeric(18, 0),
  PayorName varchar(164),
  PrivacyLevelCode varchar(3),
  ContractTypeCode varchar(3),
  RecurringChargeLowIncomeFlag bit,
  RateTypeCode varchar(3),
  EFTChecked varchar(7),
  RecurringChargeEFTFlag bit,
  CCChecked varchar(7),
  RecurringChargeCCFlag bit,
  ccDisabled varchar(8),
  ResidentID numeric(18, 0)
)

CREATE TABLE #Service
(
  UnitCode          varchar(250),
  ServiceInstanceID numeric(18, 0),
  ServiceID numeric(18, 0),
  PayorID numeric(18, 0),
  ServiceInstanceFromDate datetime,
  ServiceInstanceToDate datetime,
  ServiceInstanceAmount money,
  StartBatchID numeric(18, 0),
  EndBatchID numeric(18, 0),
  ServiceName varchar(100),
  ServiceBillingType varchar(7),
  ServiceClassID numeric(18, 0),
  ServiceClassName varchar(50),
  PayorName varchar(164),
  EFTChecked varchar(7),
  CCChecked varchar(7),
  ServiceInstanceEFTFlag bit,
  ServiceInstanceCCFlag bit,
  ResidentID numeric(18, 0)
)

create table #ResidentAssessment
(
  ResidentID numeric(18, 0),
  AssessmentID numeric(18, 0),
  AssessmentTypeID numeric(18, 0),
  PropertyID NUMERIC(18, 0)
)

DECLARE @ResidentID NUMERIC(18, 0)

SELECT @ResidentID = t.HMYPERSON
FROM TENANT t
WHERE t.SCODE = CASE WHEN '#ResidentCode#' = '' THEN '' ELSE '#ResidentCode#' END

select distinct
  t.hMyPerson as ResidentID
, t.hProperty AS PropertyID
into #Residents
from Tenant t
join
(
  select
    p.*
  from Property p
  left join ListProp lp on lp.hPropList = p.hMy
  where
    lp.hMy is null
    --#condition1#
  union
  select
    p1.*
  from ListProp lp
  --join Property p on p.hMy = lp.hPropList #condition1#
  join Property p1 on p1.hMy = lp.hProperty
) p on p.hMy = t.hProperty
JOIN SeniorResident sr ON sr.residentId = t.hmyperson
JOIN SeniorResidentStatus resStatus on resStatus.istatus = t.iStatus
JOIN ListOption l2 ON l2.ListOptionCode = sr.CareLevelCode AND l2.listname = 'CareLevel'
JOIN Unit u ON u.hmy = t.hunit
JOIN SHCrGiverZone CGZ ON CGZ.hProperty = p.HMY
JOIN SHCrGiverZoneunit CGZU ON CGZU.hSHCrGiverZone = cgz.hmy AND u.HMY = cgzu.hUnit
JOIN SeniorUserZoneXref xref ON xref.hshcrgiverzone = CGZ.hmy AND CGZU.hSHCrGiverZone = xref.hshcrgiverzone
JOIN Pmuser Pm ON Pm.hmy = xref.huser /* AND Pm.UNAME = '#@@username#'*/
where
  (NOT EXISTS (SELECT 1 FROM SeniorGlobalContactuser WHERE UserID = Pm.hmy) OR EXISTS (SELECT 1 FROM Seniorresidentuser WHERE UserID = Pm.hmy AND ResidentID = t.hMyPerson))
  --#condition2#
  --#condition3#
  --#condition4#
  --#condition5#

insert INTO #ResidentAssessment (ResidentID, AssessmentID, AssessmentTypeID, PropertyID)
select
  r.ResidentID,
  a.AssessmentID,
  at.AssessmentTypeID,
  r.PropertyID
from Assessment a
join AssessmentType at on at.AssessmentTypeID = a.AssessmentTypeID
join #Residents r on r.ResidentID = a.ResidentID
where
  a.AssessmentID in
    (
      select
        max(a.AssessmentID)
      from Assessment a
      join AssessmentType at on at.AssessmentTypeID = a.AssessmentTypeID
      join
      (
        select
          max(a.AssessmentDate) as MaxDate,
          at.AssessmentClass
        from Assessment a
        join AssessmentType at on at.AssessmentTypeID = a.AssessmentTypeID
        where
          a.ResidentID = r.ResidentID and
          a.AssessmentActiveFlag = 1 and
          a.AssessmentCompleteFlag = 1
        group by
          at.AssessmentClass
      ) m on m.MaxDate = a.AssessmentDate and m.AssessmentClass = at.AssessmentClass
      where
        a.ResidentID = r.ResidentID and
        a.AssessmentActiveFlag = 1 and
        a.AssessmentCompleteFlag = 1
      group by
        at.AssessmentClass
    )
    AND a.AssessmentDate >= DATEADD(MONTH, -3, GETDATE()) -- Filter for last 3 months
    
DECLARE @ServiceClassName VARCHAR(MAX)

SELECT @ServiceClassName = STUFF((
			SELECT DISTINCT ',' + CONVERT(VARCHAR(50), t4.ServiceClassName)
			FROM ServiceClass t4
			--WHERE t4.ServiceClassActiveFlag = 1 #Condition6#
			FOR XML PATH('')
				, TYPE
			).value('.', 'VARCHAR(MAX)'), 1, 1, SPACE(0))
				
DECLARE @PropertyID NUMERIC(18, 0)

IF ISNULL(@ResidentID, 0) = 0
BEGIN
	DECLARE RecommenCursor CURSOR
	FOR
	SELECT DISTINCT PropertyID
	FROM #ResidentAssessment

	OPEN RecommenCursor

	FETCH NEXT
	FROM RecommenCursor
	INTO @PropertyID

	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT INTO #ConsolidatedAssessmentResult (
			residentid
			, Class
			, Code
			, s_Recommend
			, s_service
			, s_sid
			, Classid
			, s_score
			, InHouse
			, OutSide
			, RecommScore
			)
		EXEC SeniorConsolidatedAssessmentResult_Custom '1'
			, @PropertyID
			, @ServiceClassName
			
		FETCH NEXT
		FROM RecommenCursor
		INTO @PropertyID
	END

	CLOSE RecommenCursor

	DEALLOCATE RecommenCursor
END

IF ISNULL(@ResidentID, 0) <> 0
BEGIN
	SELECT DISTINCT @PropertyID = PropertyID
	FROM #ResidentAssessment

	INSERT INTO #ConsolidatedAssessmentResult (
		residentid
		, Class
		, Code
		, s_Recommend
		, s_service
		, s_sid
		, Classid
		, s_score
		, InHouse
		, OutSide
		, RecommScore
		)
	EXEC SeniorConsolidatedAssessmentResult_3198964 '1'
		, @ResidentID
END

Declare @Count int = 0


--Select @Count = Count(t4.ServiceClassID) from ServiceClass t4 where t4.ServiceClassActiveFlag = 1 #Condition6#


--if len(@Count) > 0
--begin
--  delete from #ConsolidatedAssessmentResult where Class not in (#t4.ServiceClassName#) and (ClassID <> 1 or s_sid is not null)
--end

update car
set
  car.ChargeTypeCode = ct.sCode
from #ConsolidatedAssessmentResult car
join ChargTyp ct on ct.hMy = car.s_sID and car.ClassID = 99

/* Update column 'Code' where classid <> 1 with the carelevel code of classid = 1 for each resident */
UPDATE t1
SET
  t1.code = t2.code
FROM #ConsolidatedAssessmentResult t1
JOIN #ConsolidatedAssessmentResult t2 ON t1.residentId = t2.residentId
WHERE
  t1.classid <> 1 AND
  t2.classid = 1

DECLARE ResidentCursor CURSOR FOR select ResidentID from #Residents
OPEN ResidentCursor
FETCH NEXT FROM ResidentCursor INTO @ResidentID
WHILE @@FETCH_STATUS = 0
BEGIN
  INSERT INTO #ResidentRecurringCharge (UnitCode,RecurringChargeID, ChargeTypeCode, ChargeTypeDescription, RecurringChargeFromDate, RecurringChargeToDate, RecurringChargeAmount, Billing, PayorID, PayorName, PrivacyLevelCode, ContractTypeCode, RecurringChargeLowIncomeFlag, RateTypeCode, EFTChecked, RecurringChargeEFTFlag, CCChecked, RecurringChargeCCFlag, ccDisabled) EXEC SeniorRecurringChargeSelect @ResidentID, 'Current' 
  INSERT INTO #Service (UnitCode,ServiceInstanceID, ServiceID, PayorID, ServiceInstanceFromDate, ServiceInstanceToDate, ServiceInstanceAmount, StartBatchID, EndBatchID, ServiceName, ServiceBillingType, ServiceClassID, ServiceClassName, PayorName, EFTChecked, CCChecked, ServiceInstanceEFTFlag, ServiceInstanceCCFlag) exec SeniorServiceInstanceSelect @ResidentID, 'Current'
  FETCH NEXT FROM ResidentCursor INTO @ResidentID
END
CLOSE ResidentCursor
DEALLOCATE ResidentCursor

update s
set
  ResidentID = s.ResidentID
from #Service s
join ServiceInstance si on si.ServiceInstanceID = s.ServiceInstanceID

update rc
set
  ResidentID = src.ResidentID
from #ResidentRecurringCharge rc
join SeniorRecurringCharge src on src.RecurringChargeID = rc.RecurringChargeID

/* Update Payorid to residentid */
UPDATE s
SET
  s.payorid = si.residentid
FROM #service s
Join Serviceinstance si on si.Serviceinstanceid = s.Serviceinstanceid and si.payorid = s.payorid
--//end Select

--//select no crystal
DECLARE @propCode VARCHAR(4000)
SET @propCode = ''
SELECT
  @propCode = @propCode + Ltrim(Rtrim(P.Scode)) + ','
FROM Property P
WHERE
  1 = 1
  --#condition1#

SELECT
  ra.residentid,
  ra.AssessmentTypeID,
  'Other Recurring Charges' AS classname,
  99 AS ServiceClassID,
  ISNULL(car.S_Service, '*None Recommended') AS Reccom,
  LTRIM(RTRIM
  (
    CASE
      WHEN Isnull(recchr.RecurRingChargeAmount, -99) = -99 THEN ''
      ELSE sia.Currencysymbol + CONVERT(VARCHAR(10), recchr.RecurRingChargeAmount)
    END +
    '  ' +
    Isnull(recchr.ChargeTypeDescription, '*None') +
    CASE
      WHEN recchr.ChargeTypeCode IS NULL THEN ''
      ELSE ' (' + LTRIM(RTRIM(Isnull(recchr.ChargeTypeCode, ''))) + ')'
    END
  )) AS Actual
INTO #OtherRec
from #ConsolidatedAssessmentResult car
JOIN #ResidentRecurringCharge RecChr ON RecChr.chargetypecode = car.ChargeTypeCode and RecChr.ResidentID = car.ResidentID
join #ResidentAssessment ra on ra.ResidentID = car.ResidentID
JOIN AssessmentTypeSection ats ON ats.AssessmentTypeID = ra.AssessmentTypeID
JOIN AssessmentSection aSect ON aSect.AssessmentSectionID = ats.AssessmentSectionID
join SeniorPCSchedAssessmentXref pointchargeXref on pointchargeXref.hAssessmentSection = aSect.AssessmentSectionID and pointchargeXref.bActive in (-1, 1)
JOIN Tenant ten ON ten.hmyperson = ra.ResidentID
LEFT JOIN SeniorIntlAddress(@Propcode, NULL, 1) sia ON sia.PropertyId = ten.hProperty

CREATE TABLE #temp4
(
  ResidentId numeric,
  AssessmentTypeID numeric(18, 0),
  ServiceClassName varchar(40),
  ServiceClassID integer,
  Reccom varchar(80),
  Actual varchar(80)
)

INSERT INTO #temp4 (ResidentId, AssessmentTypeID, ServiceClassName, ServiceClassID, Actual, Reccom)
  SELECT DISTINCT
    t.residentid,
    t.assessmenttypeID,
    scl.serviceclassname,
    scl.serviceclassid,
    Isnull(actsrv2.servicename, '*None')
      +
      CASE
        WHEN Isnull(actsrv2.servicename, '*None') <> '*None' THEN ' -' + actsrv2.servicebillingtype
        ELSE ''
      END,
    ISNULL(rs.s_service, '*None Recommended')
  FROM #ResidentAssessment t
  Join Tenant ten on ten.hMyPerson = t.ResidentID
  JOIN AssessmentTypeSection ats ON ats.AssessmentTypeID = t.AssessmentTypeID
  JOIN AssessmentSection aSect ON aSect.AssessmentSectionID = ats.AssessmentSectionID
  JOIN SeniorAssessmentSectionServiceClass aSectServ ON aSectServ.AssessmentSectionID = aSect.AssessmentSectionID
  JOIN SeniorAssessmentServiceScoreSchedule aServScoreSched ON aServScoreSched.AssessmentServiceScoreScheduleID = aSectServ.AssessmentServiceScoreScheduleID
  JOIN ServiceClass scl ON scl.ServiceClassID = aServScoreSched.ServiceClassID AND scl.ServiceClassActiveFlag = 1
  JOIN SERVICE s ON s.ServiceClassID = scl.ServiceClassID
  JOIN serviceinstance sc ON sc.residentid = t.residentid
  LEFT JOIN #service actsrv ON actsrv.serviceinstanceid = sc.serviceinstanceid AND scl.serviceclassid = actsrv.serviceclassid
  LEFT JOIN #ConsolidatedAssessmentResult rs ON rs.residentid = t.residentid AND rs.classid = scl.serviceclassid
  LEFT JOIN SERVICE s1 ON actsrv.serviceid = s1.serviceid
  LEFT JOIN #Service actsrv2 on actsrv2.payorid = t.residentid and actsrv2.serviceclassid = scl.serviceclassid
  WHERE
    (ISNULL(rs.code, '') <> '' OR ISNULL(s1.ServiceId, 0) <> 0)

/* Now add Recurring Charges */
INSERT INTO #temp4 (ResidentId, AssessmentTypeID, ServiceClassName, ServiceClassID, Reccom, Actual)
  SELECT
    residentid,
    assessmenttypeID,
    ClassName,
    ServiceClassID,
    reccom,
    actual
  FROM #otherrec t
  UNION ALL
  SELECT DISTINCT
    car.ResidentId,
    ra.AssessmentTypeID,
    'Other Recurring Charges',
    99,
    isnull(car.S_Service, '*None Recommended'),
    '*None'
  from #ConsolidatedAssessmentResult car
  left JOIN #ResidentRecurringCharge rc ON rc.chargetypecode = car.ChargeTypeCode and rc.ResidentID = car.ResidentID
  join ChargTyp ct on ct.sCode = car.ChargeTypeCode
  join SeniorPointCharge pc on pc.ChargeTypeID = ct.hMy
  join SeniorPointChargeSchedule pcs on pcs.PointChargeScheduleID = pc.PointChargeScheduleID
  join SeniorPCSchedAssessmentXref pcsx on pcsx.hPointChargeSchedule = pcs.PointChargeScheduleID
  JOIN AssessmentTypeSection ats ON ats.AssessmentSectionID = pcsx.hAssessmentSection
  join #ResidentAssessment ra on ra.ResidentID = car.ResidentID and ra.AssessmentTypeID = ats.AssessmentTypeID
  WHERE
    rc.RecurringChargeID is null

DELETE
FROM #temp4
WHERE
  Actual = Reccom AND
  (Actual <> '*None' or Reccom <> '*None Recommended') and
  '#Show#' = 'Discrepancies Only'

DELETE
FROM #OtherRec
WHERE
  Actual = Reccom AND
  (Actual <> '*None' or Reccom <> '*None Recommended') and
  '#Show#' = 'Discrepancies Only'
--//End Select

--//Select
SELECT
  LTRIM(RTRIM(ISNULL(p.saddr1, ''))) AS PropName,
  LTRIM(RTRIM(t.sLastName)) + ', ' + LTRIM(RTRIM(t.sFirstName)) AS resident,
  LTRIM(RTRIM(t.sunitCode)) AS unit,
  t4.residentid,
  l1.ListOptionName AS privacylevel,
  ast.AssessmentTypeName AS assessmenttype,
  a.assessmentdate,
  t4.ServiceClassName  ClassName ,
  t4.ServiceClassID AS classid,
  t4.Reccom,
  t4.actual,
  lpr.ListOptionName AS ActualCarelevel,
  t.istatus,
  CASE
    WHEN 'Last Name' = 'Last Name' THEN LTRIM(RTRIM(t.sLastName)) + ', ' + LTRIM(RTRIM(t.sFirstName))
    ELSE LTRIM(RTRIM(t.sunitcode))
  END AS orderby,
  case
    when t4.Actual <> t4.Reccom and (t4.Actual <> '*None' or t4.Reccom <> '*None Recommended') then 1
    else 0
  end AS Discrepancy,
  t1.AssessmentID,
  RecommScore =
    (
      SELECT
        convert(numeric(18, 2), SUM(ISNULL(ail.AssessmentItemListScore, 0))) Score
      FROM Assessment a
      join Tenant t on t.hMyPerson = a.ResidentID
      join SeniorResident sr on sr.ResidentID = t.hMyPerson
      JOIN AssessmentTypeSection ats ON ats.AssessmentTypeID = a.AssessmentTypeID
      JOIN AssessmentItem ai ON ai.AssessmentSectionID = ats.AssessmentSectionID AND ai.AssessmentItemActiveFlag <> 0
      join AssessmentResultXref ar ON ar.AssessmentID = a.AssessmentID AND ar.AssessmentItemID = ai.AssessmentItemID
      JOIN AssessmentItemList ail ON ail.AssessmentItemID = ai.AssessmentItemID AND LTRIM(RTRIM(ail.AssessmentItemListValue)) = LTRIM(RTRIM(ar.AssessmentResultValue))
      left JOIN SeniorAssessmentSectionServiceClass aSectServ ON aSectServ.AssessmentSectionID = ats.AssessmentSectionID and t2.ClassID <> 99
      left JOIN SeniorAssessmentServiceScoreSchedule aServScoreSched ON aServScoreSched.AssessmentServiceScoreScheduleID = aSectServ.AssessmentServiceScoreScheduleID and aServScoreSched.PropertyID = t.hProperty and aServScoreSched.CareLevelCode = sr.CareLevelCode
      left JOIN ServiceClass sc ON sc.ServiceClassID = aServScoreSched.ServiceClassID AND sc.ServiceClassActiveFlag = 1 and sc.ServiceClassID = case when t2.ClassID = 99 then 0 else t2.ClassID end
      left join SeniorPCSchedAssessmentXref pointchargeXref on pointchargeXref.hAssessmentSection = ats.AssessmentSectionID and pointchargeXref.bActive in (-1, 1) and len(t2.ChargeTypeCode) > 0 and t2.ClassID = 99
      left join SeniorPointChargeSchedule pcs on pcs.PointChargeScheduleID = pointchargeXref.hPointChargeSchedule
      left join SeniorPointCharge pc on pc.PointChargeScheduleID = pcs.PointChargeScheduleID
      left join ChargTyp ct on ct.hMy = pc.ChargeTypeID and ct.sCode = t2.ChargeTypeCode
      WHERE
        a.AssessmentID = t1.AssessmentID and
        ((t2.ClassID <> 99 and sc.ServiceClassID is not null) or (t2.ClassID = 99 and ct.hMy is not null))
    )
    ,p.hmy
INTO #FinalResult
FROM #temp4 t4
LEFT JOIN #ResidentAssessment t1 ON t1.residentid = t4.residentid AND t1.AssessmentTypeID = t4.AssessmentTypeID
LEFT JOIN #ConsolidatedAssessmentResult t2 ON t2.residentid = t4.residentid AND t2.classid = t4.ServiceClassID
JOIN AssessmentType ast ON ast.AssessmentTypeID = t4.assessmenttypeID
JOIN Tenant t on t.hMyPerson = t4.residentid
JOIN Unit u ON u.hmy = t.hunit
join Property p on p.hMy = t.hProperty
join Assessment a on a.AssessmentID = t1.AssessmentID

join #ResidentAssessment ra on ra.ResidentID = t4.residentid and ra.AssessmentTypeID = a.AssessmentTypeID
JOIN SeniorResident sr ON sr.residentId = t.hmyperson
LEFT JOIN ListOption l1 ON sr.PrivacyLevelCode = l1.ListOptionCode AND L1.ListName = 'PrivacyLevel'
JOIN listoption lpr ON lpr.listoptioncode = sr.carelevelcode AND lpr.listname = 'Carelevel'
WHERE
  1 = 1
  AND a.assessmentdate >= DATEADD(MONTH, -3, GETDATE()) -- Filter for last 3 months
  --#condition6#

INSERT INTO #FinalResult (PropName, resident, unit, residentid, privacylevel, assessmenttype, assessmentdate, classname, classid, Reccom, actual, ActualCarelevel, istatus, orderby, Discrepancy, AssessmentID, RecommScore,hmy)
  SELECT
    LTRIM(RTRIM(ISNULL(p.sAddr1, ''))),
    LTRIM(RTRIM(t.sLastName)) + ', ' + LTRIM(RTRIM(t.sFirstName)),
    LTRIM(RTRIM(t.sunitCode)),
    r.ResidentID,
    l1.ListOptionName,
    '',
    0,
    '',
    0,
    '',
    '',
    lpr.ListOptionName,
    t.istatus,
    CASE WHEN '#OrderBy#' = 'Last Name' THEN LTRIM(RTRIM(t.sLastName)) + ', ' + LTRIM(RTRIM(t.sFirstName)) ELSE LTRIM(RTRIM(t.sunitcode)) END,
    0,
    0,
    null,
    p.hmy
  FROM #Residents r
  LEFT JOIN #FinalResult fr ON fr.ResidentID = r.ResidentID
  join Tenant t on t.hMyPerson = r.ResidentID
  join Property p on p.hMy = t.hProperty
  join SeniorResident sr on sr.ResidentID = r.ResidentID
  JOIN ListOption l1 ON sr.PrivacyLevelCode = l1.ListOptionCode AND l1.ListName = 'PrivacyLevel'
  JOIN listoption lpr ON lpr.listoptioncode = sr.carelevelcode AND lpr.listname = 'Carelevel'
  WHERE
    fr.ResidentID IS NULL and
    '#Show#' <> 'Discrepancies Only'

delete from #FinalResult where Actual = '*None' and Reccom = '*None Recommended' and ClassID = 99
update #FinalResult set RecommScore = 0 where RecommScore is null and isnull(AssessmentID, 0) <> 0




SELECT at.assessmenttypeName
	,a.assessmentdate
	,t4.ServiceClassName
	,a.AssessmentID
	,fr.residentid
	,at.assessmenttypeid
	,t4.ServiceClassID
	,sassc.AssessmentSectionID
INTO #temp1
FROM #FinalResult fr
JOIN assessment a ON a.residentid = fr.residentid
	/* AND a.AssessmentCompleteFlag = 1 */
JOIN assessmenttype at ON at.assessmenttypeid = a.assessmenttypeid
JOIN assessmenttypesection ats ON ats.assessmenttypeid = at.assessmenttypeid
JOIN SeniorAssessmentSectionServiceClass sassc ON sassc.AssessmentSectionID = ats.AssessmentSectionID
JOIN SeniorAssessmentServiceScoreSchedule sasss ON sasss.AssessmentServiceScoreScheduleID = sassc.AssessmentServiceScoreScheduleID
	AND sasss.PropertyID = fr.hmy
JOIN ServiceClass t4 ON t4.ServiceClassID = sasss.ServiceClassID
WHERE 1 = 1
	AND a.assessmentID = (
		SELECT max(assessmentID)
		FROM assessment am
		JOIN assessmenttype att ON att.assessmenttypeid = am.assessmenttypeid
		JOIN assessmenttypesection atss ON atss.assessmenttypeid = att.assessmenttypeid
		JOIN SeniorAssessmentSectionServiceClass sasscc ON sasscc.AssessmentSectionID = atss.AssessmentSectionID
		JOIN SeniorAssessmentServiceScoreSchedule sassss ON sassss.AssessmentServiceScoreScheduleID = sasscc.AssessmentServiceScoreScheduleID
			AND sassss.PropertyID = fr.hmy
		JOIN ServiceClass t44 ON t44.ServiceClassID = sassss.ServiceClassID
		WHERE am.residentid = a.residentid
		AND am.assessmentdate >= DATEADD(MONTH, -3, GETDATE()) -- Filter for last 3 months
		)
	/* AND t4.ServiceClassID = CASE 
		WHEN '#t4.ServiceClassID#' <> ''
			THEN t4.ServiceClassID
		ELSE '#t4.ServiceClassID#'
		END */ 
--#Condition6#

SELECT
  PropName,
  fr.resident,
  unit,
  fr.residentid,
  privacylevel,
  CASE 
    WHEN Reccom = '' AND actual = '' THEN t1.assessmenttypeName
    ELSE fr.assessmenttype
  END assessmenttype,
  CASE 
    WHEN Reccom = '' AND actual = '' THEN t1.assessmentdate
    ELSE fr.assessmentdate
  END assessmentdate,
  CASE 
    WHEN Reccom = '' AND actual = '' THEN t1.ServiceClassName
    ELSE classname
  END classname,
  CASE 
    WHEN Reccom = '' AND actual = '' THEN t1.ServiceClassID
    ELSE fr.classid
  END classid,
  CASE 
    WHEN Reccom = '' THEN '*None Recommended'
    ELSE Reccom
  END Reccom,
  CASE 
    WHEN actual = '' THEN '*None'
    ELSE actual
  END actual,
  ActualCarelevel,
  istatus,
  orderby,
  Discrepancy,
  CASE 
    WHEN Reccom = '' AND actual = '' THEN t1.AssessmentID
    ELSE fr.AssessmentID
  END AssessmentID,
  RecommScore,
  ai.AssessmentItemDescription -- 
FROM #FinalResult fr
LEFT JOIN #temp1 t1 ON t1.residentid = fr.residentid
LEFT JOIN AssessmentItem ai ON ai.AssessmentItemID = t1.AssessmentItemID --
ORDER BY 
  CASE WHEN '#OrderBy#' = 'Last Name' THEN fr.resident ELSE unit END, 
  residentid, 
  classid
