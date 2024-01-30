

DECLARE @sStatus   VARCHAR(30), @sDat1 DATETIME, @sDat2 DATETIME, @LessThan VARCHAR(3)
SET @sStatus   = '#bActual#'; 
SET @sDat1     = #dat1#
SET @sDat2     = #dat2#
SET @LessThan  = '#LessThan#'

CREATE TABLE #Details
(phmy NUMERIC ,
propname VARCHAR (300),
sResidentName VARCHAR (600),
istatus NUMERIC(18,0) ,
ThMy NUMERIC(18,0) ,
moveindate DATETIME ,
Noticedate DATETIME ,
moveoutdate DATETIME ,
uhmy NUMERIC,
uscode VARCHAR (8),
utscode VARCHAR (8),
utsdesc VARCHAR (40),
privacylevel VARCHAR (20) ,
carelevel VARCHAR (20) ,
Moveoutreason SmallInt ,
ResStatus VARCHAR (60) ,
BillingEndDate DATETIME ,
ContTyp VARCHAR (20) )


DECLARE @SecResident VARCHAR(3)
DECLARE @flag VARCHAR(20)
		
SET @SecResident = '#SecResident#'
SET @flag = 'Financial'

DECLARE @carelev VARCHAR(MAX),@PropertyCode	VARCHAR(4000),@ContTyp VARCHAR(MAX)
	SET @ContTyp = ''
	SET @carelev = ''
	SET @PropertyCode = ''
	
	SELECT   @carelev = @carelev + LTRIM( RTRIM( listoptioncode ) ) + ','
	FROM   listoption P
	WHERE ListName='CareLevel' AND listoptionname IN ('#CareLvl#')
	
	SELECT @PropertyCode = @PropertyCode + COALESCE(LTRIM(RTRIM(P.sCode)), '') + ',' 
	FROM Property P 
	INNER JOIN ListProp2 l ON l.hProperty = p.hmy
	WHERE l.hProplist IN (SELECT DISTINCT hmy FROM Property WHERE SCODE  IN ('#pcode#'))

	IF @PropertyCode = '' 
		SELECT @PropertyCode = @PropertyCode + COALESCE(LTRIM(RTRIM(P.sCode)), '') + ',' FROM Property P
	
	SELECT @ContTyp = @ContTyp + LTRIM( RTRIM( l1.listoptioncode ) ) + ','
	FROM listoption l1 WHERE l1.listname='ContractType' AND LTRIM(RTRIM(l1.listoptionname)) IN ('#ContTyp#')

	SET @PropertyCode = LEFT(@PropertyCode,LEN(@PropertyCode)-1)

INSERT INTO #Details (phmy,propname,sResidentName,istatus,ThMy ,moveindate ,
                         Noticedate,moveoutdate ,uhmy ,uscode,utScode,utsdesc,privacylevel,carelevel,
			             Moveoutreason,BillingEndDate,ContTyp)
EXEC SeniorMoveInMoveOutDetailFinancial 'MoveOut',@PropertyCode,NULL,@sStatus,@carelev,NULL,@ContTyp,@sDat1,@sDat2,NULL,NULL,NULL,@SecResident,NULL,@flag
	
								
SELECT  propname ,d.istatus ,ThMy , t.scode hTcode , sResidentName ,moveindate ,Noticedate ,moveoutdate ,
DATEDIFF(dd,moveindate,CASE WHEN '#bActual#' = 'Scheduled Unit Transfer' THEN moveindate ELSE moveoutdate END ) NumOfMonths ,
d.uscode ucode ,
LTRIM(RTRIM(ISNULL(utsdesc,''))) + ' ('+ (LTRIM(RTRIM(ISNULL(utScode,''))))+')' utdesc ,
l2.listoptionname privacylevel ,l1.listoptionname carelevel ,
Case when '#bActual#' = 'Scheduled Unit Transfer' then 'TRANSFERING FROM '+ LTRIM(RTRIM(u2.scode)) + '-' + l3.listoptionname 
 when '#bActual#' In ('Scheduled','Actual') then l4.listoptionname
END Moveoutreason 
,ts.status ResStatus ,BillingEndDate ,
loct.ListOptionName ListOptionName ,
CASE '#sortKey#' WHEN 'Move-Out Date' THEN convert(varchar(10),moveoutdate,102)
	  	WHEN 'Resident Last Name' THEN sResidentName
		ELSE d.uscode 
		END  Sortby
FROM #Details d
	INNER JOIN tenant t on t.hmyperson =d.tHmy
	INNER JOIN unit u on u.hmy=d.uhmy
	INNER JOIN seniorresident sr ON t.hmyperson = sr.residentid 
	INNER JOIN listoption l1 ON d.carelevel = l1.listoptioncode AND l1.listname = 'CareLevel'
	INNER JOIN listoption l2 ON d.privacylevel = l2.listoptioncode AND l2.listname = 'PrivacyLevel'
	INNER JOIN ListOption loct ON d.ContTyp = loct.ListOptionCode AND loct.ListName = 'ContractType'
	LEFT JOIN listoption l4 ON d.Moveoutreason = l4.listoptioncode AND l4.listname = 'MoveOutReason'
	LEFT JOIN unit u2 ON u2.hmy = t.hunit 
	LEFT JOIN SeniorResidentStatus ts ON ts.istatus = t.istatus
	LEFT JOIN listoption l3 ON l3.listoptioncode = sr.PrivacyLevelcode AND l3.listname = 'PrivacyLevel'
WHERE 1 = 1
AND 1 = CASE WHEN '#LessThan#' = 'Yes' 
                  THEN CASE WHEN DATEDIFF(dd,moveindate,CASE WHEN '#bActual#' = 'Scheduled Unit Transfer' THEN moveindate ELSE moveoutdate END ) <= 30 
				                 THEN 1 
							ELSE 0 
						END
			 ELSE 1 
		END
Order by propname,SortBy,ucode ,privacylevel


SELECT 
	propname  AS hProperty, 
	ISNULL(l4.listoptionname,'*None') Moveoutreason,
	count(tHmy) NumOfMoveouts ,
	sum(DATEDIFF(dd,moveindate, moveoutdate)) AvgNumOfMonths
FROM #Details d
	LEFT JOIN listoption l4 ON d.Moveoutreason = l4.listoptioncode AND l4.listname = 'MoveOutReason'
WHERE '#bActual#' = 'Actual'
AND 1 = CASE WHEN '#LessThan#' = 'Yes' 
                  THEN CASE WHEN DATEDIFF(dd,moveindate,CASE WHEN '#bActual#' = 'Scheduled Unit Transfer' THEN moveindate ELSE moveoutdate END ) <= 30 
				                 THEN 1 
							ELSE 0 
						END
			 ELSE 1 
		END
GROUP BY propname , ISNULL(l4.listoptionname,'*None')
ORDER BY 1,2

SELECT 
	propname  AS hProperty, 
	ISNULL(listoptioncode,'*None') carelevelCode,
	l1.listoptionname Carelevel,
	count(tHmy) NumOfMoveouts,
	sum(DATEDIFF(dd,moveindate, moveoutdate)) AvgNumOfMonths
FROM #Details d
	LEFT OUTER JOIN listoption l1 ON d.CareLevel = l1.listoptioncode AND l1.listname = 'CareLevel'
WHERE '#bActual#' = 'Actual'
AND 1 = CASE WHEN '#LessThan#' = 'Yes' 
                  THEN CASE WHEN DATEDIFF(dd,moveindate,CASE WHEN '#bActual#' = 'Scheduled Unit Transfer' THEN moveindate ELSE moveoutdate END ) <= 30 
				                 THEN 1 
							ELSE 0 
						END
			 ELSE 1 
		END
GROUP BY propname ,l1.listoptionname, ISNULL(listoptioncode,'*None')
ORDER BY 1,2

DROP TABLE #Details
