/*  Output for 44120d34-53b4-4a96-8e4d-c3996c20dc80  */
/* file=ss_Case_10129551_StoredProcedure.pkg */
/*

select * from #temp2
select * from #RegionCount
select * from #TmpOccupancy
select * from #Attrib

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[SeniorIHPCensusSummarySFTP]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].SeniorIHPCensusSummarySFTP

 */
 
 --CREATE PROCEDURE SeniorIHPCensusSummarySFTP (@PropList VARCHAR(100))
 --AS
 --BEGIN




 DECLARE @asEnddate DATETIME
 	,@startdate DATETIME
 	,@i INT
 DECLARE @tmpDate TABLE (
 	[Week] INT
 	,StartDate DATE
 	,EndDate DATE
 	)
IF OBJECT_ID('TempDb..#tmppre') IS NOT NULL
drop table #tmppre
IF OBJECT_ID('TempDb..#Final') IS NOT NULL
drop table #Final
 IF OBJECT_ID('TempDb..#temp2') IS NOT NULL
 	DROP TABLE #temp2
 IF OBJECT_ID('TempDb..#main_tab') IS NOT NULL
 	DROP TABLE #main_tab
 IF OBJECT_ID('TempDb..#TmpOccupancy') IS NOT NULL
 	DROP TABLE #TmpOccupancy
 CREATE TABLE #temp2 (
 	Description1 VARCHAR(30)
 	,propid INT
 	,PropCode VARCHAR(100)
 	,OccupancyCount NUMERIC(10, 2)
 	,WeekNum INT
 	)

 IF OBJECT_ID('TempDb..#Attrib') IS NOT NULL
 	DROP TABLE #Attrib
 CREATE TABLE #Attrib (
 	hprop INT
 	,Region VARCHAR(100)
 	,SUBGROUP3 VARCHAR(100)
 	,iSequence INT
 	)
 INSERT INTO #Attrib
 SELECT P.Hmy hprop
 	,/*Code to find system attribute for the property*/ ltrim(rtrim(ax.SUBGROUP2)) Region
 	,SUBGROUP3
 	,isnull(iSequence, 99) iSequence
 FROM property p
 INNER JOIN SeniorpropertyfunctiON('', '') p1 ON p1.propertyid = p.hmy
 	AND P.hMy IN (
 		SELECT hproperty
 		FROM listprop2
 		WHERE iType = 3
 			AND hproplist IN (3)
 		)
 LEFT JOIN Attributes ax ON ax.HPROP = p.hmy
 LEFT JOIN attributeValue AV ON av.sValue = Rtrim(Ltrim(ax.SUBGROUP2))
 LEFT JOIN attributename AN ON av.hAttributename = an.hmy
 	AND an.iFileType = 3
 WHERE ax.subgroup3 = 'Pre-Open Deposits'
 SET @asEnddate = convert(DATETIME, GETDATE(), 106)
 SET @startdate = DATEADD(wk, - 8, @asEnddate)
 SET @i = 1
 WHILE (@i <= 8)
 BEGIN
 	INSERT INTO @tmpDate
 	SELECT @i
 		,DATEADD(dd, 1, DATEADD(wk, - @i, @asEnddate))
 		,DATEADD(wk, 1 - @i, @asEnddate)
 	SET @i = @i + 1
 END
 SELECT P.hmy PropertyID
 	,COUNT(CASE 
 			WHEN si.carelevelcode IN ('ALZ')
 				AND si.ContractTypeCode <> 'RES'
 				THEN isnull(t.hmyperson, 0)
 			END) ALZresidentcount
 	,COUNT(CASE 
 			WHEN si.carelevelcode IN (
 					'AL'
 					,'PC'
 					)
 				AND si.ContractTypeCode <> 'RES'
 				THEN isnull(t.hmyperson, 0)
 			END) ALPCresidentcount
 	,sum(isnull(CASE 
 				WHEN si.CareLevelCode IN ('ALZ')
 					THEN cast(lv.listoptionValue AS NUMERIC(10, 2))
 				ELSE 0
 				END, 0)) ALZOccupancyCount
 	,sum(isnull(CASE 
 				WHEN si.CareLevelCode IN (
 						'AL'
 						,'PC'
 						)
 					THEN cast(lv.listoptionValue AS NUMERIC(10, 2))
 				ELSE 0
 				END, 0)) AL_PCOccupancyCount
 	,COUNT(CASE 
 			WHEN si.ContractTypeCode = 'RES'
 				THEN isnull(t.hmyperson, 0)
 			END) Respite_count
 	,sum(isnull(CASE 
 				WHEN ct.SCODE = 'PT'
 					THEN cast(lv.listoptionValue AS NUMERIC(10, 2))
 				ELSE 0
 				END, 0)) LeasedTherapyCount
 	,tmp.[Week]
 INTO #TmpOccupancy
 FROM @tmpDate tmp
 INNER JOIN property P ON 1 = 1
 INNER JOIN Attributes a ON a.HPROP = p.hmy
 	AND a.subgroup3 = 'Pre-Open Deposits'
 INNER JOIN Tenant T ON T.Hproperty = P.hmy
 INNER JOIN unit u ON u.hmy = t.hunit
 	AND isnull(u.exclude, 0) = 0
 INNER JOIN Serviceinstance Si ON (T.Hmyperson = Si.Residentid)
 INNER JOIN Service S ON (
 		Si.Serviceid = S.Serviceid
 		AND S.Serviceclassid = 1
 		)
 LEFT JOIN servicechargetype sct ON s.serviceid = sct.serviceid
 LEFT JOIN Chargtyp ct ON ct.hmy = sct.ChargeTypeID
 INNER JOIN Listoption L2 ON (
 		Si.Privacylevelcode = L2.Listoptioncode
 		AND L2.Listname = 'PrivacyLevel'
 		)
 INNER JOIN Listoptionvalue Lv ON Lv.Listname = 'PrivacyLevel'
 	AND Lv.Listoptioncode = L2.Listoptioncode
 WHERE Si.Serviceinstanceid = (
 		SELECT Max(Si3.Serviceinstanceid)
 		FROM Serviceinstance Si3
 		INNER JOIN Service S1 ON Si3.Serviceid = S1.Serviceid
 			AND S1.Serviceclassid = 1
 		WHERE Si3.Residentid = Si.Residentid
 			AND Si3.Serviceinstanceactiveflag <> 0
 			AND Isnull(CONVERT(DATETIME, CONVERT(VARCHAR(11), si3.ServiceInstanceTODate), 101), tmp.EndDate) > = CONVERT(DATETIME, CONVERT(VARCHAR(11), si3.ServiceInstanceFromDate), 101)
 			AND Si3.Serviceinstancefromdate = (
 				SELECT Max(Si2.Serviceinstancefromdate)
 				FROM Serviceinstance Si2
 				INNER JOIN Service S ON Si2.Serviceid = S.Serviceid
 					AND S.Serviceclassid = 1
 				WHERE Si2.Residentid = Si.Residentid
 					AND Si2.Serviceinstanceactiveflag <> 0
 					AND Isnull(CONVERT(DATETIME, CONVERT(VARCHAR(11), si2.ServiceInstanceTODate), 101), tmp.EndDate) > = CONVERT(DATETIME, CONVERT(VARCHAR(11), si2.ServiceInstanceFromDate), 101)
 					AND CONVERT(DATETIME, CONVERT(VARCHAR(11), si2.ServiceInstanceFromDate), 101) <= tmp.EndDate
 					AND tmp.ENDDate <= Isnull(CONVERT(DATETIME, CONVERT(VARCHAR(11), si2.ServiceInstanceTODate), 101), tmp.EndDate)
 				)
 		)
 	AND P.hMy IN (
 		SELECT hproperty
 		FROM listprop2
 		WHERE iType = 3
 			AND hproplist IN (3)
 		)
 GROUP BY p.saddr1
 	,p.hmy
 	,P.scode
 	,tmp.week
 INSERT INTO #temp2
 SELECT '# of New Deposits' AS Description1
 	,p.hmy
 	,ltrim(rtrim(isnull(p.sAddr1, ''))) + ' (' + RTRIM(p.scode) + ')' AS propertycode
 	,count(DISTINCT sp.hmy)
 	,tmp.Week
 FROM @tmpDate tmp
 INNER JOIN Property P ON 1 = 1
 INNER JOIN SeniorProspect sp ON p.hmy = sp.hproperty
 INNER JOIN Tenant TN ON tn.hmyperson = isnull(sp.htenant, 0)
 INNER JOIN seniorresidenthistory srh ON tn.hmyperson = srh.residentid
 	AND CONVERT(DATETIME, CONVERT(CHAR(10), srh.ResidentHistoryDate, 121), 101) BETWEEN tmp.startdate
 		AND tmp.enddate
 	AND srh.ResidentHistoryCode IN (
 		'CRE'
 		,'PWL'
 		) /*   INNER JOIN Trans T    ON T.Hperson   = TN.HMYPERSON AND CONVERT(DATETIME, CONVERT(CHAR(10), T.SDateOccurred, 121), 101) BETWEEN  tmp.startdate and tmp.enddate INNER JOIN Detail D   ON D.Hinvorrec = T.HMY INNER JOIN Acct Act   ON Act.HMY     = D.Hacct WHERE    T.ITYpe   = 6   AND d.samount > 0 AND t.sNotes NOT LIKE '%Reverses receipt Ctrl%' AND t.sNotes NOT LIKE '%Reversed by ctrl%' */
 	AND tn.ISTATUS IN (
 		2
 		,8
 		)
 	AND P.hMy IN (
 		SELECT hproperty
 		FROM listprop2
 		WHERE iType = 3
 			AND hproplist IN (3)
 		)
 GROUP BY p.saddr1
 	,p.hmy
 	,P.scode
 	,tmp.week
 UNION ALL
 SELECT '# of existing Deposits' AS Description1
 	,p.hmy
 	,ltrim(rtrim(isnull(p.sAddr1, ''))) + ' (' + RTRIM(p.scode) + ')' AS propertycode
 	,count(DISTINCT sp.hmy)
 	,tmp.Week
 FROM @tmpDate tmp
 INNER JOIN Property P ON 1 = 1
 INNER JOIN SeniorProspect sp ON p.hmy = sp.hproperty
 INNER JOIN Tenant TN ON tn.hmyperson = isnull(sp.htenant, 0)
 LEFT JOIN seniorresidenthistory srh ON tn.hmyperson = srh.residentid
 WHERE srh.ResidentHistoryID IN (
 		SELECT max(srh1.ResidentHistoryID)
 		FROM SeniorResidentHistory srh1
 		WHERE srh1.ResidentId = srh.residentid
 			AND srh1.ResidentHistoryDate = (
 				SELECT max(srh2.ResidentHistoryDate)
 				FROM SeniorResidentHistory srh2
 				WHERE srh2.residentid = Srh1.residentid
 					AND srh2.ResidentHistoryDate <= tmp.startdate
 					AND srh2.ResidentHistoryCode IN (
 						'CRE'
 						,'PWL'
 						)
 				GROUP BY srh2.residentID
 				)
 		GROUP BY srh1.ResidentID
 		) /* INNER JOIN Trans T    ON T.Hperson   = TN.HMYPERSON AND CONVERT(DATETIME, CONVERT(CHAR(10), T.SDateOccurred, 121), 101)<=  
 tmp.enddate INNER JOIN Detail D   ON D.Hinvorrec = T.HMY INNER JOIN Acct Act   ON Act.HMY     = D.Hacct WHERE    T.ITYpe   = 6   AND d.samount > 0 AND t.sNotes NOT LIKE 
 '%Reverses receipt Ctrl%' AND t.sNotes NOT LIKE '%Reversed by ctrl%' */
 	AND tn.ISTATUS IN (
 		2
 		,8
 		)
 	AND P.hMy IN (
 		SELECT hproperty
 		FROM listprop2
 		WHERE iType = 3
 			AND hproplist IN (3)
 		)
 GROUP BY p.saddr1
 	,p.hmy
 	,P.scode
 	,tmp.week /* Main Table */
 CREATE TABLE #Main_tab (
 	phmy INT
 	,scode VARCHAR(20)
 	,Activityname VARCHAR(100)
 	,section VARCHAR(100)
 	,Budget NUMERIC(10, 2)
 	,week1 NUMERIC(10, 2)
 	,week2 NUMERIC(10, 2)
 	,week3 NUMERIC(10, 2)
 	,week4 NUMERIC(10, 2)
 	,week5 NUMERIC(10, 2)
 	,week6 NUMERIC(10, 2)
 	,week7 NUMERIC(10, 2)
 	,week8 NUMERIC(10, 2)
 	,orderby INT
 	,ascapFlag INT
 	)
 INSERT INTO #Main_Tab
 SELECT DISTINCT p.hmy
 	,p.scode
 	,des.Activity
 	,des.section
 	,0 Bugdet
 	,isnull([1], 0) week1
 	,isnull([2], 0) week2
 	,isnull([3], 0) week3
 	,isnull([4], 0) week4
 	,isnull([5], 0) week5
 	,isnull([6], 0) week6
 	,isnull([7], 0) week7
 	,isnull([8], 0) week8
 	,des.orderby
 	,NULL ascapFlag
 FROM Property p
 INNER JOIN Attributes a ON a.HPROP = p.hmy
 	AND a.subgroup3 = 'Pre-Open Deposits'
 INNER JOIN Unit u ON u.HPROPERTY = p.HMY
 	AND isnull(u.exclude, 0) = 0
 INNER JOIN (
 	SELECT '# of New 
 Deposits' Activity
 		,16 OrderBy
 		,'Deposits' Section
 	
 	UNION ALL
 	
 	SELECT '# of Existing Deposits' Activity
 		,17 OrderBy
 		,'Deposits' Section
 	) Des ON 1 = 1
 	AND p.iType = 3 /*and p.HMY in (select distinct hProperty from Unit)*/
 LEFT JOIN (
 	SELECT Description1
 		,propid
 		,propcode
 		,isnull(OccupancyCount, 0) AS OccupancyCount
 		,WeekNum
 	FROM #temp2
 	) AS t
 PIVOT(max(OccupancyCount) FOR weeknum IN (
 			[1]
 			,[2]
 			,[3]
 			,[4]
 			,[5]
 			,[6]
 			,[7]
 			,[8]
 			)) AS pvt ON pvt.Description1 = des.Activity
 	AND p.hmy = pvt.propid
 WHERE 1 = 1
 	AND P.hMy IN (
 		SELECT hproperty
 		FROM listprop2
 		WHERE iType = 3
 			AND hproplist IN (3)
 		)
 ORDER BY orderby
 IF NOT EXISTS (
 		SELECT *
 		FROM dbo.sysobjects
 		WHERE id = OBJECT_ID(N'[dbo].[ASCAP30]')
 			AND type IN (N'U')
 		)
 BEGIN
 	UPDATE MT
 	SET MT.Budget = 0
 		,ascapFlag = 0
 	FROM #main_tab MT
 END /* Main Table */
 INSERT INTO #Main_tab (
 	phmy
 	,scode
 	,Activityname
 	,section
 	,Budget
 	,week1
 	,week2
 	,week3
 	,week4
 	,week5
 	,week6
 	,week7
 	,week8
 	,orderby
 	,ascapFlag
 	)
 SELECT phmy
 	,scode
 	,'Total # of Deposits'
 	,section
 	,sum(budget)
 	,SUM(week1) week1
 	,SUM(week2) week2
 	,SUM(week3) week3
 	,SUM(week4) week4
 	,SUM(week5) week5
 	,SUM(week6) week6
 	,SUM(week7) week7
 	,SUM(week8) week8
 	,18 orderby
 	,ascapFlag
 FROM #Main_tab
 WHERE orderby IN (
 		16
 		,17
 		)
 GROUP BY phmy
 	,scode
 	,section
 	,ascapFlag
 SELECT phmy
 	,scode
 	,Dense_Rank() OVER ( 
 		ORDER BY mt.scode
 		) DenseRank
 	,mt.section
 	,mt.Activityname
 	,CASE 
 		WHEN mt.orderby BETWEEN 5
 				AND 18
 			THEN 0
 		ELSE CAST(mt.Budget AS NUMERIC(18, 2))
 		END Budget
 	,cast(week1 AS NUMERIC(18, 2)) week1
 	,cast(week2 AS NUMERIC(18, 2)) week2
 	,cast(week3 AS NUMERIC(18, 2)) week3
 	,cast(week4 AS NUMERIC(18, 2)) week4
 	,cast(week5 AS NUMERIC(18, 2)) week5
 	,cast(week6 AS NUMERIC(18, 2)) week6
 	,cast(week7 AS NUMERIC(18, 2)) week7
 	,cast(week8 AS NUMERIC(18, 2)) week8
 	,ltrim(rtrim(a.Region)) Region
 	,SUBGROUP3
 	,orderby AS ssequence
 	,iSequence
 	,ascapFlag
 INTO #tmppre
 FROM #Main_tab mt
 INNER JOIN #Attrib a ON mt.phmy = a.hProp
 WHERE activityname = 'Total # of Deposits'
 DECLARE @asRangeEnddate DATETIME
 DELETE FROM @tmpDate
 IF OBJECT_ID('TempDb..#temptotunitcount') IS NOT NULL
 	DROP TABLE #temptotunitcount
 IF OBJECT_ID('TempDb..#temp') IS NOT NULL
 	DROP TABLE #temp
 CREATE TABLE #temp (
 	propid INT
 	,PropCode VARCHAR(100)
 	,OccupancyCount NUMERIC(10, 2)
 	,WeekNum INT
 	)
 IF OBJECT_ID('TempDb..#PropCount') IS NOT NULL
 	DROP TABLE #PropCount
 CREATE TABLE #PropCount (
 	propid NUMERIC(10, 2)
 	,PropCode VARCHAR(500) 
 	,[Total units] INT
 	,Bugdet NUMERIC(10, 2)
 	,week1 NUMERIC(10, 2)
 	,week2 NUMERIC(10, 2)
 	,week3 NUMERIC(10, 2)
 	,week4 NUMERIC(10, 2)
 	,week5 NUMERIC(10, 2)
 	,week6 NUMERIC(10, 2)
 	,week7 NUMERIC(10, 2)
 	,week8 NUMERIC(10, 2)
 	,ascapflag INT
 	,code VARCHAR(20)
 	)
 IF OBJECT_ID('TempDb..#RegionCount') IS NOT NULL
 	DROP TABLE #RegionCount
 CREATE TABLE #RegionCount (
 	iSequence NUMERIC(10, 2)
 	,Region VARCHAR(500)
 	,[Total units] INT
 	,Bugdet NUMERIC(10, 2)
 	,week1 NUMERIC(10, 2) 
 	,week2 NUMERIC(10, 2)
 	,week3 NUMERIC(10, 2)
 	,week4 NUMERIC(10, 2)
 	,week5 NUMERIC(10, 2)
 	,week6 NUMERIC(10, 2)
 	,week7 NUMERIC(10, 2)
 	,week8 NUMERIC(10, 2)
 	,ascapflag INT
 	)
 SET @asEnddate = convert(DATETIME, GETDATE(), 106)
 SET @startdate = DATEADD(wk, - 8, @asEnddate)
 SET @i = 1
 WHILE (@i <= 8)
 BEGIN
 	INSERT INTO @tmpDate
 	SELECT @i
 		,DATEADD(dd, 1, DATEADD(wk, - @i, @asEnddate))
 		,DATEADD(wk, 1 - @i, @asEnddate)
 	SET @i = @i + 1
 END
 SET @asRangeEnddate = DATEADD(dd, 1, DATEADD(wk, - 8, @asEnddate))
 IF OBJECT_ID('TempDb..#temp1') IS NOT NULL
 	DROP TABLE #temp1
 CREATE TABLE #temp1 (
 	minmovin DATETIME
 	,scode VARCHAR(30)
 	,unitcount INT
 	,totalunitdiff INT
 	)
 INSERT INTO #temp1 /*values ('2015-08-15 00:00:00.000','lvlm',73,null) --,('2015-08-01 00:00:00.000','powl',73,null) --,('2015-08-23 00:00:00.000','chtt',77,null)*/
 SELECT min(t.dtmovein)
 	,ltrim(rtrim(p.scode))
 	,uv.unitcount
 	,NULL
 FROM PROPERTY p
 INNER JOIN tenant t ON p.HMY = t.HPROPERTY
 INNER JOIN (
 	SELECT COUNT(u.hmy) unitcount
 		,p.scode
 	FROM Unit u
 	INNER JOIN PROPERTY p ON u.hProperty = p.HMY
 		AND isnull(u.exclude, 0) = 0
 	GROUP BY p.scode
 	) uv ON uv.scode = p.scode
 LEFT JOIN attributes a ON p.hmy = a.hprop
 	AND a.subgroup3 IN (
 		'Under Development'
 		,'Pre-Open Deposits'
 		)
 WHERE t.istatus = 0
 	AND ISNULL(a.hprop, 0) = 0
 GROUP BY p.scode
 	,uv.unitcount
 HAVING min(t.dtmovein) BETWEEN @asRangeEnddate
 		AND @asEnddate
 ORDER BY 1 DESC
 INSERT INTO #temp
 SELECT P.hmy PropertyID
 	,ltrim(rtrim(isnull(p.sAddr1, ''))) AS PropertyCode
 	,sum(cast(lv.listoptionValue AS NUMERIC(10, 2))) OccupancyCount
 	,tmp.Week
 FROM @tmpDate tmp
 INNER JOIN property P ON 1 = 1
 INNER JOIN Tenant T ON T.Hproperty = P.hmy
 INNER JOIN unit u ON u.hmy = t.hunit
 	AND isnull(u.exclude, 0) = 0
 INNER JOIN Serviceinstance Si ON (T.Hmyperson = Si.Residentid)
 	AND si.carelevelcode IN (
 		'AL'
 		,'ALZ'
 		,'PC'
 		,'LL'
 		,'BUN'
 		)
 INNER JOIN Service S ON (
 		Si.Serviceid = S.Serviceid
 		AND S.Serviceclassid = 1
 		)
 INNER JOIN Seniorresident Rs ON (T.Hmyperson = Rs.Residentid)
 INNER JOIN Listoption L1 ON (
 		Si.Carelevelcode = L1.Listoptioncode
 		AND L1.Listname = 'CareLevel'
 		)
 INNER JOIN Listoption L2 ON (
 		Si.Privacylevelcode = L2.Listoptioncode
 		AND L2.Listname = 'PrivacyLevel'
 		)
 INNER JOIN Listoptionvalue Lv ON Lv.Listname = 'PrivacyLevel'
 	AND Lv.Listoptioncode = L2.Listoptioncode
 WHERE Si.Serviceinstanceid = (
 		SELECT Max(Si3.Serviceinstanceid)
 		FROM Serviceinstance Si3
 		INNER JOIN Service S1 ON Si3.Serviceid = S1.Serviceid
 			AND S1.Serviceclassid = 1
 		WHERE Si3.Residentid = Si.Residentid
 			AND Si3.Serviceinstanceactiveflag <> 0
 			AND Isnull(CONVERT(DATETIME, CONVERT(VARCHAR(11), si3.ServiceInstanceTODate), 101), tmp.EndDate) > = CONVERT(DATETIME, CONVERT(VARCHAR(11), si3.ServiceInstanceFromDate), 101)
 			AND Si3.Serviceinstancefromdate = (
 				SELECT Max(Si2.Serviceinstancefromdate)
 				FROM Serviceinstance Si2
 				INNER JOIN Service S ON Si2.Serviceid = S.Serviceid
 					AND S.Serviceclassid = 1
 				WHERE Si2.Residentid = Si.Residentid
 					AND Si2.Serviceinstanceactiveflag <> 0
 					AND Isnull(CONVERT(DATETIME, CONVERT(VARCHAR(11), si2.ServiceInstanceTODate), 101), tmp.EndDate) > = CONVERT(DATETIME, CONVERT(VARCHAR(11), si2.ServiceInstanceFromDate), 101)
 					AND CONVERT(DATETIME, CONVERT(VARCHAR(11), si2.ServiceInstanceFromDate), 101) <= tmp.EndDate
 					AND tmp.ENDDate <= Isnull(CONVERT(DATETIME, CONVERT(VARCHAR(11), si2.ServiceInstanceTODate), 101), tmp.EndDate)
 				)
 		)
 	AND P.hMy IN (
 		SELECT hproperty
 		FROM listprop2
 		WHERE iType = 3
 			AND hproplist IN (3)
 		)
 GROUP BY p.HMY
 	,P.sCode
 	,tmp.week
 	,p.saddr1
 UNION ALL
 SELECT p.hmy propid
 	,ltrim(rtrim(isnull(p.sAddr1, ''))) AS PropCode
 	,sum(cast(lv.listoptionValue AS NUMERIC(10, 2))) OccupancyCount
 	,tmp.Week
 FROM @tmpDate tmp
 LEFT JOIN Property P ON 1 = 1
 INNER JOIN Tenant T ON T.Hproperty = P.hmy
 INNER JOIN unit u ON u.hmy = t.hunit
 	AND isnull(u.exclude, 0) = 0
 INNER JOIN Serviceinstance Si ON (T.Hmyperson = Si.Residentid)
 INNER JOIN Service S ON (
 		Si.Serviceid = S.Serviceid
 		AND S.Serviceclassid = 1
 		)
 INNER JOIN servicechargetype sct ON s.serviceid = sct.serviceid
 INNER JOIN Chargtyp ct ON ct.hmy = sct.ChargeTypeID
 	AND ct.SCODE = 'PT'
 INNER JOIN Seniorresident Rs ON (T.Hmyperson = Rs.Residentid)
 INNER JOIN Listoption L2 ON (
 		Si.Privacylevelcode = L2.Listoptioncode
 		AND L2.Listname = 'PrivacyLevel'
 		)
 INNER JOIN Listoptionvalue Lv ON Lv.Listname = 'PrivacyLevel'
 	AND Lv.Listoptioncode = L2.Listoptioncode
 WHERE Si.Serviceinstanceid = (
 		SELECT Max(Si3.Serviceinstanceid)
 		FROM Serviceinstance Si3
 		INNER JOIN Service S1 ON Si3.Serviceid = S1.Serviceid
 			AND S1.Serviceclassid = 1
 		WHERE Si3.Residentid = Si.Residentid
 			AND Si3.Serviceinstanceactiveflag <> 0
 			AND Isnull(Si3.Serviceinstancetodate, tmp.EndDate) > = Si3.Serviceinstancefromdate
 			AND Si3.Serviceinstancefromdate = (
 				SELECT Max(Si2.Serviceinstancefromdate)
 				FROM Serviceinstance Si2
 				INNER JOIN Service S ON Si2.Serviceid = S.Serviceid
 					AND S.Serviceclassid = 1
 				WHERE Si2.Residentid = Si.Residentid
 					AND Si2.Serviceinstanceactiveflag <> 0
 					AND Isnull(Si2.Serviceinstancetodate, tmp.EndDate) > = Si2.Serviceinstancefromdate
 					AND Si2.Serviceinstancefromdate <= tmp.EndDate
 					AND tmp.EndDate <= Isnull(Si2.Serviceinstancetodate, tmp.EndDate)
 				)
 		)
 	AND P.hMy IN (
 		SELECT hproperty
 		FROM listprop2
 		WHERE iType = 3
 			AND hproplist IN (3)
 		)
 GROUP BY p.HMY
 	,P.sCode
 	,tmp.Week
 	,p.saddr1
 UNION ALL
 SELECT p.hmy propid
 	,ltrim(rtrim(isnull(p.sAddr1, ''))) AS PropCode
 	,COUNT(DISTINCT SAU.HUNIT) OccupancyCount
 	,tmp.Week
 FROM @tmpDate tmp
 LEFT JOIN Property P ON 1 = 1
 INNER JOIN Tenant T ON T.Hproperty = P.hmy
 INNER JOIN unit u ON u.hmy = t.hunit
 	AND isnull(u.exclude, 0) = 0
 INNER JOIN SeniorAdditionalUnit sau ON sau.htenant = t.hmyperson
 	AND sau.bActive = 1
 WHERE 1 = 1
 	AND (
 		(
 			SAU.DTSTART <= TMP.STARTDATE
 			AND ISNULL(SAU.DTEND, TMP.STARTDATE) BETWEEN TMP.STARTDATE
 				AND TMP.ENDDATE
 			)
 		OR (
 			SAU.DTSTART BETWEEN TMP.STARTDATE
 				AND TMP.ENDDATE
 			AND ISNULL(SAU.DTEND, TMP.STARTDATE) BETWEEN TMP.STARTDATE
 				AND TMP.ENDDATE
 			)
 		OR (
 			SAU.DTSTART BETWEEN TMP.STARTDATE
 				AND TMP.ENDDATE
 			AND ISNULL(SAU.DTEND, TMP.ENDDATE) >= TMP.ENDDATE
 			)
 		)
 	AND T.ISTATUS NOT IN (7)
 	AND P.hMy IN (
 		SELECT hproperty
 		FROM listprop2
 		WHERE iType = 3
 			AND hproplist IN (3)
 		)
 GROUP BY p.HMY
 	,P.sCode
 	,tmp.Week
 	,p.saddr1 /*  Property Count 
 */
 INSERT INTO #PropCount
 SELECT DISTINCT p.hmy
 	,ltrim(rtrim(isnull(p.sAddr1, '')))
 	,(
 		SELECT COUNT(u.hmy)
 		FROM Unit u
 		WHERE u.hProperty = p.HMY
 			AND isnull(u.exclude, 0) = 0
 		) [Total units]
 	,(
 		/* VCH - Case# 5024067 */ SELECT abs(sum(t.sBudget))
 		FROM Total t
 		INNER JOIN acct a ON a.hmy = t.hAcct
 		WHERE t.hppty = p.hmy
 			AND a.scode IN (
 				'001005'
 				,'001006'
 				,'001007'
 				)
 			AND t.iBook = 1
 			AND (CAST(MONTH(@asEnddate) AS VARCHAR(2)) + '/' + CAST(YEAR(@asEnddate) AS VARCHAR(4))) = (CAST(MONTH(t.uMonth) AS VARCHAR(2)) + '/' + CAST(YEAR(t.uMonth) AS VARCHAR(4)))
 		) Bugdet
 	,isnull([1], 0) week1
 	,isnull([2], 0) week2
 	,isnull([3], 0) week3
 	,isnull([4], 0) week4
 	,isnull([5], 0) week5
 	,isnull([6], 0) week6
 	,isnull([7], 0) week7
 	,isnull([8], 0) week8
 	,1
 	,p.SCODE
 FROM Property p
 INNER JOIN Unit u ON u.HPROPERTY = p.HMY
 	AND isnull(u.exclude, 0) = 0
 LEFT JOIN (
 	SELECT propid
 		,propcode
 		,OccupancyCount
 		,WeekNum
 	FROM #temp
 	) t
 PIVOT(sum(OccupancyCount) FOR weeknum IN (
 			[1]
 			,[2]
 			,[3]
 			,[4]
 			,[5]
 			,[6]
 			,[7]
 			,[8]
 			)) AS pvt ON p.hmy = pvt.propid
 WHERE p.iType = 3
 	AND P.hMy IN (
 		SELECT hproperty
 		FROM listprop2
 		WHERE iType = 3
 			AND hproplist IN (3)
 		) /* and p.HMY in (Select distinct HPROPERTY from unit) */ /*  Region Count */
 INSERT INTO #RegionCount
 SELECT av.iSequence + 1000 iSequence
 	,Rtrim(Ltrim(SUBGROUP2)) + ' Region' Region
 	,SUM([Total units]) [Total units]
 	,SUM(isnull(Bugdet, 0)) Bugdet
 	,SUM(week1) week1
 	,SUM(week2) week2
 	,SUM(week3) week3
 	,SUM(week4) week4
 	,SUM(week5) week5
 	,SUM(week6) week6
 	,SUM(week7) week7
 	,SUM(week8) week8
 	,ascapflag
 FROM Attributes a
 INNER JOIN AttributeValue av ON av.sValue = Rtrim(Ltrim(SUBGROUP2))
 INNER JOIN #PropCount PC ON pc.propid = a.HPROP
 WHERE a.subgroup3 <> 'Under Development'
 	AND a.subgroup3 <> 'Pre-Open Deposits'
 GROUP BY SUBGROUP2
 	,av.iSequence
 	,ascapflag
 UNION
 SELECT 1011
 	,'% Occupied Stabilized' Attribute
 	,sum(CASE 
 			WHEN SUBGROUP3 IN (
 					'Focus'
 					,'Stabilized'
 					)
 				THEN [Total units]
 			ELSE '0'
 			END) [Total units]
 	,sum(CASE 
 			WHEN SUBGROUP3 IN (
 					'Focus'
 					,'Stabilized'
 					)
 				THEN isnull(Bugdet, 0)
 			ELSE '0'
 			END) Bugdet
 	,sum(CASE 
 			WHEN SUBGROUP3 IN (
 					'Focus'
 					,'Stabilized'
 					)
 				THEN week1
 			ELSE '0'
 			END) week1
 	,sum(CASE 
 			WHEN SUBGROUP3 IN (
 					'Focus'
 					,'Stabilized'
 					)
 				THEN week2
 			ELSE '0'
 			END) week2
 	,sum(CASE 
 			WHEN SUBGROUP3 IN (
 					'Focus'
 					,'Stabilized'
 					)
 				THEN week3
 			ELSE '0'
 			END) week3
 	,sum(CASE 
 			WHEN SUBGROUP3 IN (
 					'Focus'
 					,'Stabilized'
 					)
 				THEN week4
 			ELSE '0'
 			END) week4
 	,sum(CASE 
 			WHEN SUBGROUP3 IN (
 					'Focus'
 					,'Stabilized'
 					)
 				THEN week5
 			ELSE '0'
 			END) week5
 	,sum(CASE 
 			WHEN SUBGROUP3 IN (
 					'Focus'
 					,'Stabilized'
 					)
 				THEN week6
 			ELSE '0'
 			END) week6
 	,sum(CASE 
 			WHEN SUBGROUP3 IN (
 					'Focus'
 					,'Stabilized'
 					)
 				THEN week7
 			ELSE '0'
 			END) week7
 	,sum(CASE 
 			WHEN SUBGROUP3 IN (
 					'Focus'
 					,'Stabilized'
 					)
 				THEN week8
 			ELSE '0'
 			END) week8
 	,ascapflag
 FROM Attributes a
 INNER JOIN #PropCount PC ON pc.propid = a.HPROP
 WHERE a.subgroup3 <> 'Under Development'
 	AND a.subgroup3 <> 'Pre-Open Deposits'
 GROUP BY ascapflag
 UNION
 SELECT 1010
 	,'% Occupied Start Up' Attribute
 	,sum(CASE 
 			WHEN SUBGROUP3 = 'Start Up'
 				THEN [Total units]
 			ELSE '0'
 			END) [Total units]
 	,sum(CASE 
 			WHEN SUBGROUP3 = 'Start Up'
 				THEN isnull(Bugdet, 0)
 			ELSE '0'
 			END) Bugdet
 	,sum(CASE 
 			WHEN SUBGROUP3 = 'Start Up'
 				THEN week1
 			ELSE '0'
 			END) week1
 	,sum(CASE 
 			WHEN SUBGROUP3 = 'Start Up'
 				THEN week2
 			ELSE '0'
 			END) week2
 	,sum(CASE 
 			WHEN SUBGROUP3 = 'Start Up'
 				THEN week3
 			ELSE '0'
 			END) week3
 	,sum(CASE 
 			WHEN SUBGROUP3 = 'Start Up'
 				THEN week4
 			ELSE '0'
 			END) week4
 	,sum(CASE 
 			WHEN SUBGROUP3 = 'Start Up'
 				THEN week5
 			ELSE '0'
 			END) week5
 	,sum(CASE 
 			WHEN SUBGROUP3 = 'Start Up'
 				THEN week6
 			ELSE '0'
 			END) week6
 	,sum(CASE 
 			WHEN SUBGROUP3 = 'Start Up'
 				THEN week7
 			ELSE '0'
 			END) week7
 	,sum(CASE 
 			WHEN SUBGROUP3 = 'Start Up'
 				THEN week8
 			ELSE '0'
 			END) week8
 	,ascapflag
 FROM Attributes a
 INNER JOIN #PropCount PC ON pc.propid = a.HPROP
 WHERE a.subgroup3 <> 'Under Development'
 	AND a.subgroup3 <> 'Pre-Open Deposits'
 GROUP BY ascapflag
 UNION
 SELECT 2000
 	,'% Occupied Total'
 	,SUM([Total units]) [Total units]
 	,SUM(isnull(Bugdet, 0)) Bugdet
 	,SUM(week1) week1
 	,SUM(week2) week2
 	,SUM(week3) week3
 	,SUM(week4) week4
 	,SUM(week5) week5
 	,SUM(week6) week6
 	,SUM(week7) week7
 	,SUM(week8) week8
 	,ascapflag
 FROM #PropCount
 LEFT JOIN Attributes a ON propid = a.HPROP
 WHERE a.subgroup3 <> 'Under Development'
 	AND a.subgroup3 <> 'Pre-Open Deposits'
 GROUP BY ascapflag
 SELECT TOP 1 [TOTAL Units]
 	,[TOTAL Units] - t1.unitcount unitdiff
 	,t1.MinMovin
 	,sum([TOTAL Units] - CASE 
 			WHEN t1.MinMovin >= DATEADD(wk, 1 - 1, @asEnddate)
 				THEN t1.unitcount
 			ELSE 0
 			END) w1
 	,sum([TOTAL Units] - CASE 
 			WHEN t1.MinMovin >= DATEADD(wk, 1 - 2, @asEnddate)
 				THEN t1.unitcount
 			ELSE 0
 			END) w2
 	,sum([TOTAL Units] - CASE 
 			WHEN t1.MinMovin >= DATEADD(wk, 1 - 3, @asEnddate)
 				THEN t1.unitcount
 			ELSE 0
 			END) w3
 	,sum([TOTAL Units] - CASE 
 			WHEN t1.MinMovin >= DATEADD(wk, 1 - 4, @asEnddate)
 				THEN t1.unitcount
 			ELSE 0
 			END) w4
 	,sum([TOTAL Units] - CASE 
 			WHEN t1.MinMovin >= DATEADD(wk, 1 - 5, @asEnddate)
 				THEN t1.unitcount
 			ELSE 0
 			END) w5
 	,sum([TOTAL Units] - CASE 
 			WHEN t1.MinMovin >= DATEADD(wk, 1 - 6, @asEnddate)
 				THEN t1.unitcount
 			ELSE 0
 			END) w6
 	,sum([TOTAL Units] - CASE 
 			WHEN t1.MinMovin >= DATEADD(wk, 1 - 7, @asEnddate)
 				THEN t1.unitcount
 			ELSE 0
 			END) w7
 	,sum([TOTAL Units] - CASE 
 			WHEN t1.MinMovin >= DATEADD(wk, 1 - 8, @asEnddate)
 				THEN t1.unitcount
 			ELSE 0
 			END) w8
 INTO #temptotunitcount
 FROM #regioncount
 LEFT JOIN #temp1 t1 ON 1 = 1
 WHERE region = '% Occupied Total'
 GROUP BY region
 	,t1.unitcount
 	,[TOTAL Units]
 	,t1.MinMovin
 ORDER BY t1.MinMovin DESC
 UPDATE t
 SET t.totalunitdiff = tuc.unitdiff
 FROM #temp1 t
 INNER JOIN #temptotunitcount tuc ON 1 = 1
 WHERE t.MinMovin = tuc.minmovin
 DECLARE @num INT
 SELECT @num = Count(*)
 FROM #temp1
 WHILE (@num > 1)
 BEGIN
 	UPDATE tuc
 	SET tuc.unitdiff = tuc.unitdiff - t1.unitcount
 		,tuc.MinMovin = t1.MinMovin
 		,w1 = w1 - CASE 
 			WHEN t1.MinMovin >= DATEADD(wk, 1 - 1, @asEnddate)
 				THEN t1.unitcount
 			ELSE 0
 			END
 		,w2 = w2 - CASE 
 			WHEN t1.MinMovin >= DATEADD(wk, 1 - 2, @asEnddate)
 				THEN t1.unitcount
 			ELSE 0
 			END
 		,w3 = w3 - CASE 
 			WHEN t1.MinMovin >= DATEADD(wk, 1 - 3, @asEnddate)
 				THEN t1.unitcount
 			ELSE 0
 			END
 		,w4 = w4 - CASE 
 			WHEN t1.MinMovin >= DATEADD(wk, 1 - 4, @asEnddate)
 				THEN t1.unitcount
 			ELSE 0
 			END
 		,w5 = w5 - CASE 
 			WHEN t1.MinMovin >= DATEADD(wk, 1 - 5, @asEnddate)
 				THEN t1.unitcount
 			ELSE 0
 			END
 		,w6 = w6 - CASE 
 			WHEN t1.MinMovin >= DATEADD(wk, 1 - 6, @asEnddate)
 				THEN t1.unitcount
 			ELSE 0
 			END
 		,w7 = w7 - CASE 
 			WHEN t1.MinMovin >= DATEADD(wk, 1 - 7, @asEnddate)
 				THEN t1.unitcount
 			ELSE 0
 			END
 		,w8 = w8 - CASE 
 			WHEN t1.MinMovin >= DATEADD(wk, 1 - 8, @asEnddate)
 				THEN t1.unitcount
 			ELSE 0
 			END
 	FROM #temptotunitcount tuc
 	LEFT JOIN #temp1 t1 ON 1 = 1
 	WHERE t1.MinMovin < tuc.minmovin
 	UPDATE t
 	SET t.totalunitdiff = tuc.unitdiff
 	FROM #temp1 t
 	INNER JOIN #temptotunitcount tuc ON 1 = 1
 	WHERE t.MinMovin = tuc.minmovin
 	SET @num = @num - 1
 END
 SELECT @num = Count(*)
 FROM #temp1
 SELECT Dense_Rank() OVER (
 		ORDER BY Code
 		) isequence
 	,cast([TOTAL Units] AS VARCHAR) [Total units]
 	,CASE 
 		WHEN Propcode LIKE '%Lantern%'
 			THEN replace(Propcode, 'The Lantern at Morning Pointe of', '') + ' ' + 'Lantern' + ' ' + ' (' + RTRIM(code) + ')'
 		ELSE replace(Propcode, 'Morning Pointe of', '') + ' (' + RTRIM(code) + ')'
 		END AS propcode
 	,cast(isnull(cast(Bugdet AS NUMERIC(18, 2)), 0) AS VARCHAR) Bugdet
 	,cast(week1 AS NUMERIC(18, 2)) week1
 	,cast(week2 AS NUMERIC(18, 2)) week2
 	,cast(week3 AS NUMERIC(18, 2)) week3
 	,cast(week4 AS NUMERIC(18, 2)) week4
 	,cast(week5 AS NUMERIC(18, 2)) week5
 	,cast(week6 AS NUMERIC(18, 2)) week6
 	,cast(week7 AS NUMERIC(18, 2)) week7
 	,cast(week8 AS NUMERIC(18, 2)) week8
 INTO #Final
 FROM #PropCount
 LEFT JOIN Attributes a ON propid = a.HPROP
 WHERE a.subgroup3 <> 'Under Development'
 	AND a.subgroup3 <> 'Pre-Open Deposits'

 UNION
 SELECT 9999
 	,cast([TOTAL Units] AS VARCHAR) [Total units]
 	,CASE 
 		WHEN Propcode LIKE '%Lantern%'
 			THEN replace(Propcode, 'The Lantern at Morning Pointe of', '') + ' ' + 'Lantern' + ' ' + ' (' + RTRIM(code) + ')'
 		ELSE replace(Propcode, 'Morning Pointe of', '') + ' (' + RTRIM(code) + ')'
 		END AS propcode
 	
 	,cast(isnull(cast(Bugdet AS NUMERIC(18, 2)), 0) AS VARCHAR) Bugdet
 	,cast(week1 AS NUMERIC(18, 2)) week1
 	,cast(week2 AS NUMERIC(18, 2)) week2
 	,cast(week3 AS NUMERIC(18, 2)) week3
 	,cast(week4 AS NUMERIC(18, 2)) week4
 	,cast(week5 AS NUMERIC(18, 2)) week5
 	,cast(week6 AS NUMERIC(18, 2)) week6
 	,cast(week7 AS NUMERIC(18, 2)) week7
 	,cast(week8 AS NUMERIC(18, 2)) week8
 FROM #PropCount
 LEFT JOIN Attributes a ON propid = a.HPROP
 WHERE a.subgroup3 = 'Under Development'
 UNION ALL
 SELECT 9999
 	,cast([TOTAL Units] AS VARCHAR) [Total units]
 	,CASE 
 		WHEN Propcode LIKE '%Lantern%'
 			THEN replace(Propcode, 'The Lantern at Morning Pointe of', '') + ' ' + 'Lantern' + ' ' + ' (' + RTRIM(code) + ')'
		WHEN code = 'fktl'
			THEN replace(Propcode,'The Lantern at Morning Pointe of', '') + replace(Propcode,'TN', '') + ' ' + 'Lantern' + ' ' + ' (' + RTRIM(code) + ')'
		WHEN code = 'fktn'
			THEN replace(Propcode, 'Morning Pointe of', '') + ' (' + RTRIM(code) + ')' + replace(Propcode,'TN', '') 			
 		ELSE replace(Propcode, 'Morning Pointe of', '') + ' (' + RTRIM(code) + ')'
 		END AS propcode /*VCH - Case#4307965*/
 	,cast(isnull(cast(Bugdet AS NUMERIC(18, 2)), 0) AS VARCHAR) Bugdet
 	,cast(t.week1 AS NUMERIC(18, 2)) week1
 	,cast(t.week2 AS NUMERIC(18, 2)) week2
 	,cast(t.week3 AS NUMERIC(18, 2)) week3
 	,cast(t.week4 AS NUMERIC(18, 2)) week4
 	,cast(t.week5 AS NUMERIC(18, 2)) week5
 	,cast(t.week6 AS NUMERIC(18, 2)) week6
 	,cast(t.week7 AS NUMERIC(18, 2)) week7 
 	,cast(t.week8 AS NUMERIC(18, 2)) week8
 FROM #PropCount p
 INNER JOIN #tmppre t ON t.phmy = p.propid /*where  a.subgroup3 ='Pre-Open Deposits'*/
 ORDER BY isequence
 SELECT isequence,CONVERT(VARCHAR,propcode)'Community',CONVERT(VARCHAR,[Total units])'Total Units',
 CONVERT(VARCHAR,Bugdet)'Budget',CONVERT(VARCHAR,week1),CONVERT(VARCHAR,week2),CONVERT(VARCHAR,week3),
 CONVERT(VARCHAR,week4),CONVERT(VARCHAR,week5),CONVERT(VARCHAR,week6),CONVERT(VARCHAR,week7),CONVERT(VARCHAR,week8) FROM #Final
 UNION
 SELECT 0,'Community','Total Units','Budget',CONVERT(VARCHAR(10),@asEnddate,101),CONVERT(VARCHAR(10),DATEADD(DD,-7,@asEnddate),101),CONVERT(VARCHAR(10),DATEADD(DD,-14,@asEnddate),101),
 CONVERT(VARCHAR(10),DATEADD(DD,-21,@asEnddate),101),CONVERT(VARCHAR(10),DATEADD(DD,-28,@asEnddate),101),CONVERT(VARCHAR(10),DATEADD(DD,-35,@asEnddate),101),
 CONVERT(VARCHAR(10),DATEADD(DD,-42,@asEnddate),101),CONVERT(VARCHAR(10),DATEADD(DD,-49,@asEnddate),101)
 --select * from #Final
 --END

/*  Output for 64bf890d-408f-4ca5-b35f-c0d5a05bf68a.sql  */
--drop table #tmppre
--drop table #Final