
SELECT 	'Property',
	'SectionType',
	'Description',
	LEFT(DateName(Month,Dateadd (m,-12, '7/1/2021' )), 3) +'-' + RIGHT(DateName(yyyy,Dateadd (m,-12, '7/1/2021' )), 2) + '.',
	LEFT(DateName(Month,Dateadd (m,-11, '7/1/2021' )), 3) +'-' + RIGHT(DateName(yyyy,Dateadd (m,-11, '7/1/2021' )), 2) + '.',
	LEFT(DateName(Month,Dateadd (m,-10, '7/1/2021' )), 3) +'-' + RIGHT(DateName(yyyy,Dateadd (m,-10, '7/1/2021' )), 2) + '.',
	LEFT(DateName(Month,Dateadd (m,-9,  '7/1/2021' )), 3) +'-' + RIGHT(DateName(yyyy,Dateadd (m,-9,  '7/1/2021' )), 2) + '.',
	LEFT(DateName(Month,Dateadd (m,-8,  '7/1/2021' )), 3) +'-' + RIGHT(DateName(yyyy,Dateadd (m,-8,  '7/1/2021' )), 2) + '.',
	LEFT(DateName(Month,Dateadd (m,-7,  '7/1/2021' )), 3) +'-' + RIGHT(DateName(yyyy,Dateadd (m,-7,  '7/1/2021' )), 2) + '.',
	LEFT(DateName(Month,Dateadd (m,-6,  '7/1/2021' )), 3) +'-' + RIGHT(DateName(yyyy,Dateadd (m,-6,  '7/1/2021' )), 2) + '.',
	LEFT(DateName(Month,Dateadd (m,-5,  '7/1/2021' )), 3) +'-' + RIGHT(DateName(yyyy,Dateadd (m,-5,  '7/1/2021' )), 2) + '.',
	LEFT(DateName(Month,Dateadd (m,-4,  '7/1/2021' )), 3) +'-' + RIGHT(DateName(yyyy,Dateadd (m,-4,  '7/1/2021' )), 2) + '.',
	LEFT(DateName(Month,Dateadd (m,-3,  '7/1/2021' )), 3) +'-' + RIGHT(DateName(yyyy,Dateadd (m,-3,  '7/1/2021' )), 2) + '.',
	LEFT(DateName(Month,Dateadd (m,-2,  '7/1/2021' )), 3) +'-' + RIGHT(DateName(yyyy,Dateadd (m,-2,  '7/1/2021' )), 2) + '.',
	LEFT(DateName(Month,Dateadd (m,-1,  '7/1/2021' )), 3) +'-' + RIGHT(DateName(yyyy,Dateadd (m,-1,  '7/1/2021' )), 2) + '.',
	'PropCode',
	LEFT(DateName(Month,Dateadd (m,0, '7/1/2021' )), 3) +'-' + RIGHT(DateName(yyyy,Dateadd (m,0, '7/1/2021' )), 2) + '.',
	'12-Month Total';

DECLARE @sStatus    VARCHAR(20),
        @sDate      DATETIME,
        @sDateStart DATETIME,
        @sDateEnd   DATETIME,


	@iCounter    INT

SET @sDate = '7/1/2021'
SET @sDateStart = Dateadd(mm, -11, @sDate)
SET @sDateEnd = Dateadd(dd, -1, Dateadd(mm, 1, @sDate))
SET @iCounter = 1


CREATE TABLE #Counts
(
    Pcode		VARCHAR(25),
    PropName		VARCHAR(150),
    Description		VARCHAR(250),
    MonthName		VARCHAR(6),
    SectionType		VARCHAR(25),
    Month1		NUMERIC,
    Month2		NUMERIC,
    Month3		NUMERIC,
    Month4		NUMERIC,
    Month5		NUMERIC,
    Month6		NUMERIC,
    Month7		NUMERIC,
    Month8		NUMERIC,
    Month9		NUMERIC,
    Month10		NUMERIC,
    Month11		NUMERIC,
    Month12		NUMERIC,
    Month13		NUMERIC
)


/* Below code calculates Move In counts when @iCounter is 1 and Move Out counts when @iCounter is 2 */
WHILE @iCounter <= 2
BEGIN
INSERT INTO #Counts
	SELECT  Ltrim(Rtrim(p.scode))													AS Pcode,
		Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')'								AS PropName,
		CASE 	WHEN @iCounter = 1 THEN Isnull(ls.listoptionname, '*None') ELSE Isnull(l3.ListOptionName, '*None') END		AS Description,
		Convert(VARCHAR(3), CASE WHEN @iCounter = 1 THEN t.dtmovein ELSE t.dtMoveOut END, 100) + '-' 
		+ Right(Convert(VARCHAR(4), Year(CASE WHEN @iCounter = 1 THEN t.dtmovein ELSE t.dtMoveOut END)), 2)			AS MonthName,
		CASE 	WHEN @iCounter = 1 THEN 'Move Ins by Lead Category' ELSE 'Move Outs by Reason Code' END				AS SectionType,
		CASE	WHEN Convert(VARCHAR(3), CASE WHEN @iCounter = 1 THEN t.dtmovein ELSE t.dtMoveOut END, 100) + '-' + Right(Convert(VARCHAR(4), Year(CASE WHEN @iCounter = 1 THEN t.dtmovein ELSE t.dtMoveOut END)), 2) = Convert(VARCHAR(3), DATEADD(mm, -12, @sDateEnd), 100) + '-' + Right(Convert(VARCHAR(4), Year(DATEADD(mm, -12, @sDateEnd))), 2) THEN Count(DISTINCT t.hmyperson) ELSE 0 END 	AS Month1,   /* Jan 09 */
		CASE	WHEN Convert(VARCHAR(3), CASE WHEN @iCounter = 1 THEN t.dtmovein ELSE t.dtMoveOut END, 100) + '-' + Right(Convert(VARCHAR(4), Year(CASE WHEN @iCounter = 1 THEN t.dtmovein ELSE t.dtMoveOut END)), 2) = Convert(VARCHAR(3), DATEADD(mm, -11, @sDateEnd), 100) + '-' + Right(Convert(VARCHAR(4), Year(DATEADD(mm, -11, @sDateEnd))), 2) THEN Count(DISTINCT t.hmyperson) ELSE 0 END 	AS Month2,   /* Feb 09 */
		CASE	WHEN Convert(VARCHAR(3), CASE WHEN @iCounter = 1 THEN t.dtmovein ELSE t.dtMoveOut END, 100) + '-' + Right(Convert(VARCHAR(4), Year(CASE WHEN @iCounter = 1 THEN t.dtmovein ELSE t.dtMoveOut END)), 2) = Convert(VARCHAR(3), DATEADD(mm, -10, @sDateEnd), 100) + '-' + Right(Convert(VARCHAR(4), Year(DATEADD(mm, -10, @sDateEnd))), 2) THEN Count(DISTINCT t.hmyperson) ELSE 0 END 	AS Month3,   /* Mar 09 */
		CASE	WHEN Convert(VARCHAR(3), CASE WHEN @iCounter = 1 THEN t.dtmovein ELSE t.dtMoveOut END, 100) + '-' + Right(Convert(VARCHAR(4), Year(CASE WHEN @iCounter = 1 THEN t.dtmovein ELSE t.dtMoveOut END)), 2) = Convert(VARCHAR(3), DATEADD(mm, -9,  @sDateEnd), 100) + '-' + Right(Convert(VARCHAR(4), Year(DATEADD(mm, -9,  @sDateEnd))), 2) THEN Count(DISTINCT t.hmyperson) ELSE 0 END 	AS Month4,   /* Apr 09 */
		CASE	WHEN Convert(VARCHAR(3), CASE WHEN @iCounter = 1 THEN t.dtmovein ELSE t.dtMoveOut END, 100) + '-' + Right(Convert(VARCHAR(4), Year(CASE WHEN @iCounter = 1 THEN t.dtmovein ELSE t.dtMoveOut END)), 2) = Convert(VARCHAR(3), DATEADD(mm, -8,  @sDateEnd), 100) + '-' + Right(Convert(VARCHAR(4), Year(DATEADD(mm, -8,  @sDateEnd))), 2) THEN Count(DISTINCT t.hmyperson) ELSE 0 END 	AS Month5,   /* May 09 */
		CASE	WHEN Convert(VARCHAR(3), CASE WHEN @iCounter = 1 THEN t.dtmovein ELSE t.dtMoveOut END, 100) + '-' + Right(Convert(VARCHAR(4), Year(CASE WHEN @iCounter = 1 THEN t.dtmovein ELSE t.dtMoveOut END)), 2) = Convert(VARCHAR(3), DATEADD(mm, -7,  @sDateEnd), 100) + '-' + Right(Convert(VARCHAR(4), Year(DATEADD(mm, -7,  @sDateEnd))), 2) THEN Count(DISTINCT t.hmyperson) ELSE 0 END 	AS Month6,   /* Jun 09 */
		CASE	WHEN Convert(VARCHAR(3), CASE WHEN @iCounter = 1 THEN t.dtmovein ELSE t.dtMoveOut END, 100) + '-' + Right(Convert(VARCHAR(4), Year(CASE WHEN @iCounter = 1 THEN t.dtmovein ELSE t.dtMoveOut END)), 2) = Convert(VARCHAR(3), DATEADD(mm, -6,  @sDateEnd), 100) + '-' + Right(Convert(VARCHAR(4), Year(DATEADD(mm, -6,  @sDateEnd))), 2) THEN Count(DISTINCT t.hmyperson) ELSE 0 END 	AS Month7,   /* Jul 09 */
		CASE	WHEN Convert(VARCHAR(3), CASE WHEN @iCounter = 1 THEN t.dtmovein ELSE t.dtMoveOut END, 100) + '-' + Right(Convert(VARCHAR(4), Year(CASE WHEN @iCounter = 1 THEN t.dtmovein ELSE t.dtMoveOut END)), 2) = Convert(VARCHAR(3), DATEADD(mm, -5,  @sDateEnd), 100) + '-' + Right(Convert(VARCHAR(4), Year(DATEADD(mm, -5,  @sDateEnd))), 2) THEN Count(DISTINCT t.hmyperson) ELSE 0 END 	AS Month8,   /* Aug 09 */
		CASE	WHEN Convert(VARCHAR(3), CASE WHEN @iCounter = 1 THEN t.dtmovein ELSE t.dtMoveOut END, 100) + '-' + Right(Convert(VARCHAR(4), Year(CASE WHEN @iCounter = 1 THEN t.dtmovein ELSE t.dtMoveOut END)), 2) = Convert(VARCHAR(3), DATEADD(mm, -4,  @sDateEnd), 100) + '-' + Right(Convert(VARCHAR(4), Year(DATEADD(mm, -4,  @sDateEnd))), 2) THEN Count(DISTINCT t.hmyperson) ELSE 0 END 	AS Month9,   /* Sep 09 */
		CASE	WHEN Convert(VARCHAR(3), CASE WHEN @iCounter = 1 THEN t.dtmovein ELSE t.dtMoveOut END, 100) + '-' + Right(Convert(VARCHAR(4), Year(CASE WHEN @iCounter = 1 THEN t.dtmovein ELSE t.dtMoveOut END)), 2) = Convert(VARCHAR(3), DATEADD(mm, -3,  @sDateEnd), 100) + '-' + Right(Convert(VARCHAR(4), Year(DATEADD(mm, -3,  @sDateEnd))), 2) THEN Count(DISTINCT t.hmyperson) ELSE 0 END 	AS Month10,  /* Oct 09 */
		CASE	WHEN Convert(VARCHAR(3), CASE WHEN @iCounter = 1 THEN t.dtmovein ELSE t.dtMoveOut END, 100) + '-' + Right(Convert(VARCHAR(4), Year(CASE WHEN @iCounter = 1 THEN t.dtmovein ELSE t.dtMoveOut END)), 2) = Convert(VARCHAR(3), DATEADD(mm, -2,  @sDateEnd), 100) + '-' + Right(Convert(VARCHAR(4), Year(DATEADD(mm, -2,  @sDateEnd))), 2) THEN Count(DISTINCT t.hmyperson) ELSE 0 END 	AS Month11,  /* Nov 09 */
		CASE	WHEN Convert(VARCHAR(3), CASE WHEN @iCounter = 1 THEN t.dtmovein ELSE t.dtMoveOut END, 100) + '-' + Right(Convert(VARCHAR(4), Year(CASE WHEN @iCounter = 1 THEN t.dtmovein ELSE t.dtMoveOut END)), 2) = Convert(VARCHAR(3), DATEADD(mm, -1,  @sDateEnd), 100) + '-' + Right(Convert(VARCHAR(4), Year(DATEADD(mm, -1,  @sDateEnd))), 2) THEN Count(DISTINCT t.hmyperson) ELSE 0 END 	AS Month12,  /* Dec 09 */
		CASE	WHEN Convert(VARCHAR(3), CASE WHEN @iCounter = 1 THEN t.dtmovein ELSE t.dtMoveOut END, 100) + '-' + Right(Convert(VARCHAR(4), Year(CASE WHEN @iCounter = 1 THEN t.dtmovein ELSE t.dtMoveOut END)), 2) = Convert(VARCHAR(3), DATEADD(mm,  0,  @sDateEnd), 100) + '-' + Right(Convert(VARCHAR(4), Year(DATEADD(mm,  0,  @sDateEnd))), 2) THEN Count(DISTINCT t.hmyperson) ELSE 0 END 	AS Month13   /* Jan 10 */
	FROM   property p
               INNER JOIN listprop2 l 			ON l.hproplist 			= p.hmy
               INNER JOIN listprop2 lp2 		ON lp2.hproperty 		= l.hproperty
               INNER JOIN tenant t 			ON t.hproperty 			= lp2.hproperty
	       INNER JOIN seniorresident sr		ON t.hmyperson 			= sr.residentid
	       LEFT JOIN seniorprospect sp		ON Isnull(sp.htenant, -1) 	= t.hmyperson
	       LEFT JOIN seniorprospectsource sps	ON sps.sourceid 		= sp.hsource
	       LEFT JOIN listoption ls			ON ls.listoptioncode 		= sps.sourcetypecode 	AND ls.listname = 'SourceType'
	       LEFT JOIN listoption l3			ON (convert(varchar(10),t.ireason) = l3.listoptioncode 	AND l3.listname = 'MoveOutReason')
	       INNER JOIN seniorresidenthistory srh	ON srh.residentid 		= t.hmyperson 		AND srh.residentstatuscode = CASE @iCounter WHEN 1 THEN srh.residentstatuscode ELSE 1 END
							AND residenthistoryid IN (SELECT Max(residenthistoryid) residenthistoryid
										 FROM   seniorresidenthistory (nolock)
										 WHERE  Convert(DATETIME, Convert(VARCHAR(20), residenthistorydate, 101), 101) <= Convert(DATETIME, @sDateEnd, 101)
											AND residentid = srh.residentid
										 GROUP  BY residentid)
							AND sr.carelevelcode <> ''
	       LEFT OUTER JOIN seniorresidentstatus ts	ON ( ts.istatus = srh.residentstatuscode )
	WHERE  1 = 1
	        
	       AND '#ReportFor#' IN ( 'Unconsolidated','Consolidated')
	       AND 1 = 	CASE @iCounter	
	       			WHEN 1 THEN CASE srh.residentstatuscode	
						WHEN 0 THEN 1 
						WHEN 1 THEN 1 
						WHEN 4 THEN 1 
						WHEN 11 THEN 1 
						ELSE 0 END
			ELSE 1 END
	       AND 1 = 	CASE @iCounter 
			    	WHEN 1 THEN CASE t.istatus 
					    	WHEN 2 THEN 0 
					    	WHEN 7 THEN 0
						ELSE 1 END
			ELSE 1 END
	       AND CASE WHEN @iCounter = 1 THEN t.dtmovein ELSE t.dtMoveOut END BETWEEN @sDateStart AND @sDateEnd
	GROUP  BY 
		Ltrim(Rtrim(p.scode)),
		Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')',
		Convert(VARCHAR(3), CASE WHEN @iCounter = 1 THEN t.dtmovein ELSE t.dtMoveOut END, 100) + '-' + Right(Convert(VARCHAR(4), Year(CASE WHEN @iCounter = 1 THEN t.dtmovein ELSE t.dtMoveOut END)), 2),
		CASE WHEN @iCounter = 1 THEN Isnull(ls.listoptionname, '*None') ELSE Isnull(l3.ListOptionName, '*None') END 

SET @iCounter = @iCounter + 1
END

/* Calculates property wise Move-In counts */
SELECT  p.hmy					AS phmy,
	Isnull(ls.listoptionname, '*None')	AS Description,
	Count(DISTINCT t.hmyperson)		AS MoveInCount
INTO	#Min
FROM   property p
       INNER JOIN ListProp2 l 			ON l.hProplist = p.hmy AND l.iType <> 11
       INNER JOIN ListProp2 lp2 		ON lp2.hProperty = l.hProperty
       INNER JOIN tenant t			ON t.hproperty = lp2.hProperty  
						AND t.istatus NOT IN ( 2, 7 )
						AND t.dtmovein BETWEEN @sDateStart AND @sDateEnd
       INNER JOIN seniorresident sr		ON t.hmyperson = sr.residentid
       INNER JOIN seniorresidenthistory srh	ON srh.residentid = t.hmyperson 
						AND srh.residentstatuscode IN ( 0, 1, 4, 11 )
						AND residenthistoryid IN (SELECT Max(residenthistoryid) residenthistoryid
									 FROM   seniorresidenthistory (nolock)
									 WHERE  residentid = srh.residentid
										AND Convert(DATETIME, Convert(VARCHAR(20), residenthistorydate, 101), 101) <= Convert(DATETIME, @sDateEnd, 101)
									 GROUP  BY residentid)
						AND sr.carelevelcode <> ''
       LEFT JOIN seniorprospect sp		ON Isnull(sp.htenant, -1) = t.hmyperson
       LEFT JOIN seniorprospectsource sps	ON sps.sourceid = sp.hsource
       LEFT JOIN listoption ls			ON ls.listoptioncode = sps.sourcetypecode AND ls.listname = 'SourceType'
       LEFT JOIN listoption l3			ON (convert(varchar(10),t.ireason) = l3.listoptioncode and l3.listname = 'MoveOutReason')
       LEFT OUTER JOIN seniorresidentstatus ts	ON ( ts.istatus = srh.residentstatuscode )
WHERE  1 = 1
	AND '#ReportFor#' = 'None'
	AND p.hmy IN ( SELECT  hmy FROM Property p WHERE 1=1   )
GROUP  BY p.hmy,
	  Ltrim(Rtrim(p.scode)),
	  Isnull(ls.listoptionname, '*None')
	  
/* Calculates property wise Move-Out counts */
SELECT  p.hmy					AS phmy,
	l3.ListOptionName			AS Description,
	Count(DISTINCT t.hmyperson)		AS MoveOutCount
INTO	#Mout
FROM   property p
       INNER JOIN ListProp2 l 			ON l.hProplist = p.hmy
       INNER JOIN ListProp2 lp2 		ON lp2.hProperty = l.hProperty 
       INNER JOIN tenant t			ON t.hproperty = lp2.hProperty
						AND t.dtMoveOut BETWEEN @sDateStart AND @sDateEnd
       INNER JOIN seniorresident sr		ON t.hmyperson = sr.residentid
       INNER JOIN seniorresidenthistory srh	ON srh.residentid = t.hmyperson AND srh.residentstatuscode = 1
						AND residenthistoryid IN (SELECT Max(residenthistoryid) residenthistoryid
									 FROM   seniorresidenthistory (nolock)
									 WHERE  Convert(DATETIME, Convert(VARCHAR(20), residenthistorydate, 101), 101) <= Convert(DATETIME, @sDateEnd, 101)
										AND residentid = srh.residentid
									 GROUP  BY residentid)
						AND sr.carelevelcode <> '' 
       LEFT JOIN seniorprospect sp		ON Isnull(sp.htenant, -1) = t.hmyperson
       LEFT JOIN seniorprospectsource sps	ON sps.sourceid = sp.hsource
       LEFT JOIN listoption ls			ON ls.listoptioncode = sps.sourcetypecode AND ls.listname = 'SourceType'
       LEFT JOIN listoption l3			ON (convert(varchar(10),t.ireason) = l3.listoptioncode and l3.listname = 'MoveOutReason')
       LEFT OUTER JOIN seniorresidentstatus ts	ON ( ts.istatus = srh.residentstatuscode )
WHERE  1 = 1
	AND '#ReportFor#' = 'None'
	AND p.hmy IN ( SELECT  hmy FROM Property p WHERE 1=1   )
GROUP  BY p.hmy,
	  Ltrim(Rtrim(p.scode)),
	  l3.ListOptionName

SELECT CASE WHEN '#ReportFor#' = 'Consolidated'then '1' ELSE Propname END	
							AS PropName,
       SectionType					AS SectionType,
       Description					AS Description,
       Sum(Month1) 					AS Month1,
       Sum(Month2)  					AS Month2,
       Sum(Month3)  					AS Month3,
       Sum(Month4)  					AS Month4,
       Sum(Month5)  					AS Month5,
       Sum(Month6)  					AS Month6,
       Sum(Month7)  					AS Month7,
       Sum(Month8)  					AS Month8,
       Sum(Month9)  					AS Month9,
       Sum(Month10) 					AS Month10,
       Sum(Month11) 					AS Month11,
       Sum(Month12) 					AS Month12,
       CASE WHEN '#ReportFor#' = 'Consolidated'then '1' ELSE Pcode END
         						AS Pcode,
       Sum(Month13)  			         	AS Month13,
       Sum(Month13)  + Sum(Month2)  + Sum(Month3) + 
       Sum(Month4)  + Sum(Month5)  + Sum(Month6) +
       Sum(Month7)  + Sum(Month8)  + Sum(Month9) + 
       Sum(Month10) + Sum(Month11) + Sum(Month12)	AS Total
FROM   #Counts
WHERE  1=1 AND '#ReportFor#' IN ( 'Unconsolidated','Consolidated') 
GROUP  BY CASE WHEN '#ReportFor#' = 'Consolidated'then '1' ELSE Pcode END,
	  CASE WHEN '#ReportFor#' = 'Consolidated'then '1' ELSE Propname END,
          Description,
          SectionType

UNION

SELECT ''						AS PropName,
       ''						AS SectionType,
       ''						AS Description,
       0 						AS Month1,
       0  						AS Month2,
       0 						AS Month3,
       0 						AS Month4,
       0 						AS Month5,
       0 						AS Month6,
       0 						AS Month7,
       0 						AS Month8,
       0 						AS Month9,
       0 						AS Month10,
       0 						AS Month11,
       0 						AS Month12,
       ''  						AS Pcode,
       0  						AS Month13,
       0						AS Total
WHERE  1=1 AND '#ReportFor#' = 'None'
ORDER  BY 1, 2, 3

--DECLARE @sStatus    VARCHAR(20),
--        @sDate      DATETIME,
--        @sDateStart DATETIME,
--        @sDateEnd   DATETIME

--SET @sDate = '7/1/2021'
--SET @sDateStart = Dateadd(mm, -11, @sDate)
--SET @sDateEnd = Dateadd(dd, -1, Dateadd(mm, 1, @sDate))


/* Below code calculates property wise counts */
SELECT	Ltrim(Rtrim(p.scode))			AS Pcode,
	Ltrim(Rtrim(p.scode))			AS PropName,
	ISNULL(MvIn.Description, '*None')	AS Description,
	0					AS AllPropTotal,
	ISNULL(MvIn.MoveInCount, 0)		AS MoveInCount,
	'Move Ins by Lead Category'		AS SectionType
FROM Property P
LEFT JOIN #Min MvIn ON MvIn.phmy = p.hmy
WHERE 1=1
		AND p.hmy IN ( 	SELECT	pr.hmy 
			FROM	Property pr
				INNER JOIN 
				(
					SELECT 	 p.sCode
					FROM   	property p
					WHERE  	1 = 1
						 
				) x ON x.sCode = pr.sCode 
			)
UNION
SELECT	Ltrim(Rtrim(p.scode))			AS Pcode,
	Ltrim(Rtrim(p.scode))			AS PropName,
	ISNULL(MvOut.Description, '*None')	AS Description,
	0					AS AllPropTotal,
	ISNULL(MvOut.MoveOutCount, 0)		AS MoveInCount,
	'Move Outs by Reason Code'		AS SectionType
FROM Property P
LEFT JOIN #Mout MvOut ON MvOut.phmy = p.hmy
WHERE 1=1
	AND p.hmy IN ( SELECT	pr.hmy 
			FROM	Property pr
				INNER JOIN 
				(
					SELECT 	 p.sCode
					FROM   	property p
					WHERE  	1 = 1
						 
				) x ON x.sCode = pr.sCode 
		     )
ORDER BY 5, 1, 2

DROP TABLE #Counts
DROP TABLE #Min
DROP TABLE #Mout
