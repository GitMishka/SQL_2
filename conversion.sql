

IF EXISTS ( SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id(N'[dbo].[IHPCommunityAnalytics_ConversionReport]') 
                   and OBJECTPROPERTY(id, N'IsProcedure') = 1 )
BEGIN
    DROP PROCEDURE [dbo].[IHPCommunityAnalytics_ConversionReport]
END

GO

CREATE PROCEDURE IHPCommunityAnalytics_ConversionReport @propcode varchar(max) , @startd DATETIME, @endd DATETIME
AS
DECLARE @propertyid INTEGER
, @sDateStart DATETIME
, @sDateEnd   DATETIME

set @propertyid = (select hmy from property where scode=@propcode)
SET @sDateStart = CONVERT(DATETIME,@startd , 101)
set @sDateEnd = CONVERT(DATETIME, @endd, 101)


DECLARE @DepositDefination INTEGER
	,@DepositActivity VARCHAR(300)
	,@xml AS XML
	,@delimiter AS VARCHAR(10);

SELECT @DepositDefination = SVALUE
FROM PARAMOPT2
WHERE stype = 'DepositColumnDefinition'

IF @DepositDefination = 1
BEGIN
	SELECT @DepositActivity = SVALUE
	FROM PARAMOPT2
	WHERE stype = 'DepositActivities'

	SET @delimiter = ',';
	SET @xml = CAST('<X>' + REPLACE(@DepositActivity, @delimiter, '</X><X>') + '</X>' AS XML);
END

SELECT isnull(tmp1.Attribute, '*None') Attribute
	,isnull(tmp1.Summary, '*None') Summary
	,SUM(tmp1.Inquiries) Inquiries
	,SUM(tmp1.RefInquiries) RefInquiries
	,SUM(tmp1.FirstTour) FirstTour
	,SUM(tmp1.AdditionalTours) AdditionalTours
	,SUM(tmp1.MoveIns) MoveIns
	,SUM(tmp1.NewDeposits) NewDeposits
	,SUM(tmp1.ProspectActivityCompleted) ProspectActivityCompleted
	,SUM(tmp1.ReferralActivityCompleted) ReferralActivityCompleted
	,CASE 
		WHEN SUM(tmp1.RefInquiries) = 0
			THEN 0
		ELSE (convert(NUMERIC(8, 2), SUM(tmp1.MoveIns)) / convert(NUMERIC(8, 2), SUM(tmp1.RefInquiries)) * 100)
		END ReferraltoMoveins
	,CASE 
		WHEN SUM(tmp1.Inquiries) = 0
			THEN 0
		ELSE (convert(NUMERIC(8, 2), SUM(tmp1.FirstTour)) / convert(NUMERIC(8, 2), SUM(tmp1.Inquiries)) * 100)
		END InquiriesToFirstTours
	,CASE 
		WHEN SUM(tmp1.Inquiries) = 0
			THEN 0
		ELSE (convert(NUMERIC(8, 2), SUM(tmp1.AdditionalTours)) / convert(NUMERIC(8, 2), SUM(tmp1.Inquiries)) * 100)
		END InquiriesToAdditionalTours
	,CASE 
		WHEN SUM(tmp1.FirstTour) = 0
			THEN 0
		ELSE (convert(NUMERIC(8, 2), SUM(tmp1.MoveIns)) / convert(NUMERIC(8, 2), SUM(tmp1.FirstTour)) * 100)
		END FirstTourToMoveIns
	,CASE 
		WHEN SUM(tmp1.AdditionalTours) = 0
			THEN 0
		ELSE (convert(NUMERIC(8, 2), SUM(tmp1.MoveIns)) / convert(NUMERIC(8, 2), SUM(tmp1.AdditionalTours)) * 100)
		END AdditionalToursToMoveIns
	,CASE 
		WHEN SUM(tmp1.Inquiries) = 0
			THEN 0
		ELSE (convert(NUMERIC(8, 2), SUM(tmp1.MoveIns)) / convert(NUMERIC(8, 2), SUM(tmp1.Inquiries)) * 100)
		END InquiriesToMoveIns
	,CASE 
		WHEN SUM(tmp1.NewDeposits) = 0
			THEN 0
		ELSE (convert(NUMERIC(8, 2), SUM(tmp1.MoveIns)) / convert(NUMERIC(8, 2), SUM(tmp1.NewDeposits)) * 100)
		END NewDepositsToMoveIns
	,CASE 
		WHEN SUM(tmp1.Inquiries) = 0
			THEN 0
		ELSE (convert(NUMERIC(8, 2), SUM(tmp1.NewDeposits)) / convert(NUMERIC(8, 2), SUM(tmp1.Inquiries)) * 100)
		END NewDepositsToInquiries
	,CASE 
		WHEN SUM(tmp1.FirstTour) = 0
			THEN 0
		ELSE (convert(NUMERIC(8, 2), SUM(tmp1.NewDeposits)) / convert(NUMERIC(8, 2), SUM(tmp1.FirstTour)) * 100)
		END FirstTourToNewDeposits
	,CASE 
		WHEN SUM(tmp1.AdditionalTours) = 0
			THEN 0
		ELSE (convert(NUMERIC(8, 2), SUM(tmp1.NewDeposits)) / convert(NUMERIC(8, 2), SUM(tmp1.AdditionalTours)) * 100)
		END AdditionalToursToNewDeposits
	,isnull(tmp1.Summaryhmy, 0) Summaryhmy
	,isnull(tmp1.Attributehmy, 0) Attributehmy
FROM (
	SELECT ltrim(rtrim(p.saddr1)) + ' (' + ltrim(rtrim(p.scode)) + ')' Attribute
		,ltrim(rtrim(p.saddr1)) + ' (' + ltrim(rtrim(p.scode)) + ')' Summary
		,count(DISTINCT CASE 
				WHEN isnull(h1.hprospect, 0) <> 0
					AND h1.dtdate BETWEEN convert(DATETIME, @sDateStart, 101)
						AND convert(DATETIME, @sDateEnd, 101)
					THEN sp.hmy
				END) Inquiries
		,count(DISTINCT CASE 
				WHEN sps.sourceTypecode = 'ref'
					AND isnull(h1.hprospect, 0) <> 0
					AND h1.dtdate BETWEEN convert(DATETIME, @sDateStart, 101)
						AND convert(DATETIME, @sDateEnd, 101)
					THEN sp.hmy
				END) RefInquiries
		,0 FirstTour
		,0 AdditionalTours
		,0 MoveIns
		,0 NewDeposits
		,0 ProspectActivityCompleted
		,0 ReferralActivityCompleted
		,p.hmy SummaryHmy
		,p.hmy AttributeHmy
	FROM seniorprospect sp
	LEFT JOIN tenant t ON t.hmyperson = sp.htenant
	LEFT JOIN seniorprospecthistory h ON sp.hmy = h.hprospect
	LEFT JOIN seniorprospectactivity spa3 ON spa3.activityid = h.activityid
	LEFT JOIN seniorprospecthistory h1 ON h.hmy = h1.hmy
		AND spa3.ActivityCategory = 'INI'
		AND h1.dtdate BETWEEN convert(DATETIME, @sDateStart, 101)
			AND convert(DATETIME, @sDateEnd, 101)
		AND sp.sstatus NOT IN (
			'referral'
			,'advocate'
			)
	LEFT JOIN property p ON h.hproperty = p.hmy
	LEFT JOIN AgentNames a ON (
			h1.hAgent = a.hmy
			AND p.hmy = a.hProp
			)
	LEFT JOIN attributes att ON att.hprop = p.hmy
	LEFT JOIN listoption l ON l.listoptioncode = sp.hcarelevel
		AND l.listname = 'CareLevel'
	LEFT JOIN Listoption leadstatus ON leadstatus.Listoptioncode = sp.hLeadType
		AND leadstatus.ListName = 'LeadStatus'
	LEFT JOIN seniorprospectmarketarea spma ON spma.marketareaid = sp.hmarketarea
	LEFT JOIN seniorprospectsource sps ON sps.sourceid = sp.hsource
	LEFT JOIN (
		SELECT p.hmy
			,an.sname sname
			,AV.sValue
			,AV.Hmy AHMY
		FROM property p
		INNER JOIN AttributeXref ax ON ax.hFileRecord = p.hmy
		INNER JOIN attributeValue AV ON av.hmy = ax.hattributeValue
		INNER JOIN attributename AN ON av.hAttributename = an.hmy
			AND an.iFileType = 3
			AND an.sSubgroup = CASE 
				WHEN isnull('byComm', '') = ''
					THEN an.sSubgroup
				ELSE 'byComm'
				END
			AND isnull('byComm', '') <> ''
		) CF ON CF.hmy = p.hmy
	WHERE 1 = 1
		AND p.hmy IN (@propertyID)
	GROUP BY ltrim(rtrim(p.saddr1)) + ' (' + ltrim(rtrim(p.scode)) + ')'
		,ltrim(rtrim(p.saddr1)) + ' (' + ltrim(rtrim(p.scode)) + ')'
		,p.hmy
		,p.hmy
	
	UNION
	
	SELECT ltrim(rtrim(p.saddr1)) + ' (' + ltrim(rtrim(p.scode)) + ')' Attribute
		,ltrim(rtrim(p.saddr1)) + ' (' + ltrim(rtrim(p.scode)) + ')' Summary
		,0 Inquiries
		,0 RefInquiries
		,count(CASE 
				WHEN isnull(spa.activityid, 0) <> 0
					AND isnull(rt.ActivityID, 0) = 0
					THEN h.hmy
				END) FirstTour
		,count(CASE 
				WHEN isnull(spa1.activityid, 0) <> 0
					AND isnull(rt.ActivityID, 0) = 0
					THEN h.hmy
				END) AdditionalTours
		,0 MoveIns
		,0 NewDeposits
		,COUNT(CASE 
				WHEN Isnull(spa2.activityid, 0) <> 0
					AND isnull(rt.ActivityID, 0) = 0
					THEN h.hmy
				END) ProspectActivityCompleted
		,COUNT(CASE 
				WHEN Isnull(spa4.activityid, 0) <> 0
					AND isnull(rt.ActivityID, 0) = 0
					THEN h.hmy
				END) ReferralActivityCompleted
		,p.hmy SummaryHmy
		,p.hmy AttributeHmy
	FROM seniorprospect sp
	LEFT JOIN tenant t ON t.hmyperson = sp.htenant
	LEFT JOIN seniorprospecthistory h ON sp.hmy = h.hprospect
	LEFT JOIN seniorprospectactivity spa3 ON spa3.activityid = h.activityid
	LEFT JOIN seniorprospectactivity spa ON (
			spa.activityid = h.activityid
			AND (
				spa.oldtypecode = 'AT1'
				AND spa.activitycategory IN (
					'TOU'
					,'INI'
					)
				AND spa.bUseForReporting = 1
				)
			)
		AND convert(DATETIME, convert(CHAR(10), h.dtcompleted, 121), 101) BETWEEN convert(DATETIME, @sDateStart, 101)
			AND convert(DATETIME,@sDateEnd, 101)
	LEFT JOIN seniorprospectactivity spa1 ON spa1.activityid = h.activityid
		AND (
			ISNULL(spa1.oldtypecode, '') <> 'AT1'
			AND spa1.bUseForReporting = 1
			)
		AND convert(DATETIME, convert(CHAR(10), h.dtcompleted, 121), 101) BETWEEN convert(DATETIME, @sDateStart, 101)
			AND convert(DATETIME, @sDateEnd, 101)
	LEFT JOIN seniorprospectactivity spa2 ON (spa2.activityid = h.activityid)
		AND sp.sstatus NOT IN ('Referral')
		AND spa2.ActivityCategory <> 'STT'
		AND ISNULL(spa2.CancelledFlag, 0) = 0
		AND CONVERT(DATETIME, CONVERT(CHAR(10), h.dtcompleted, 121), 101) BETWEEN convert(DATETIME, @sDateStart, 101)
			AND convert(DATETIME, @sDateEnd, 101)
	LEFT JOIN seniorprospectactivity spa4 ON (spa4.activityid = h.activityid)
		AND sp.sstatus IN ('Referral')
		AND spa4.ActivityCategory <> 'STT'
		AND ISNULL(spa4.CancelledFlag, 0) = 0
		AND CONVERT(DATETIME, CONVERT(CHAR(10), h.dtcompleted, 121), 101) BETWEEN convert(DATETIME, @sDateStart, 101)
			AND convert(DATETIME, @sDateEnd, 101)
	LEFT JOIN seniorprospectactivity rt ON rt.ActivityID = h.ActivityResultID
		AND Isnull(rt.cancelledflag, 0) = 1
	LEFT JOIN property p ON h.hproperty = p.hmy
	LEFT JOIN AgentNames a ON (
			h.hAgent = a.hmy
			AND p.hmy = a.hProp
			)
	LEFT JOIN attributes att ON att.hprop = p.hmy
	LEFT JOIN listoption l ON l.listoptioncode = sp.hcarelevel
		AND l.listname = 'CareLevel'
	LEFT JOIN Listoption leadstatus ON leadstatus.Listoptioncode = sp.hLeadType
		AND leadstatus.ListName = 'LeadStatus'
	LEFT JOIN seniorprospectmarketarea spma ON spma.marketareaid = sp.hmarketarea
	LEFT JOIN seniorprospectsource sps ON sps.sourceid = sp.hsource
	LEFT JOIN (
		SELECT p.hmy
			,an.sname sname
			,AV.sValue
			,AV.Hmy AHMY
		FROM property p
		INNER JOIN AttributeXref ax ON ax.hFileRecord = p.hmy
		INNER JOIN attributeValue AV ON av.hmy = ax.hattributeValue
		INNER JOIN attributename AN ON av.hAttributename = an.hmy
			AND an.iFileType = 3
			AND an.sSubgroup = CASE 
				WHEN isnull('byComm', '') = ''
					THEN an.sSubgroup
				ELSE 'byComm'
				END
			AND isnull('byComm', '') <> ''
		) CF ON CF.hmy = p.hmy
	WHERE 1 = 1
		AND ISNULL(h.snotes, '') <> 'Auto Status Change'
		AND p.hmy IN (@propertyID)
	GROUP BY ltrim(rtrim(p.saddr1)) + ' (' + ltrim(rtrim(p.scode)) + ')'
		,ltrim(rtrim(p.saddr1)) + ' (' + ltrim(rtrim(p.scode)) + ')'
		,p.hmy
		,p.hmy
	
	UNION
	
	SELECT tmp2.attribute
		,isnull(tmp2.Summary, '*None') Summary
		,SUM(tmp2.inquiries) inquiries
		,SUM(tmp2.refinquiries) refinquiries
		,SUM(tmp2.firsttour) firsttour
		,SUM(tmp2.additionaltours) additionaltours
		,SUM(tmp2.moveins) moveins
		,SUM(tmp2.newdeposits) newdeposits
		,SUM(tmp2.ProspectActivityCompleted) ProspectActivityCompleted
		,SUM(tmp2.ReferralActivityCompleted) ReferralActivityCompleted
		,isnull(tmp2.Summaryhmy, 0) Summaryhmy
		,isnull(tmp2.Attributehmy, 0) Attributehmy
	FROM (
		SELECT ltrim(rtrim(p.saddr1)) + ' (' + ltrim(rtrim(p.scode)) + ')' Attribute
			,ltrim(rtrim(p.saddr1)) + ' (' + ltrim(rtrim(p.scode)) + ')' Summary
			,0 Inquiries
			,0 RefInquiries
			,0 FirstTour
			,0 AdditionalTours
			,0 ProspectActivityCompleted
			,0 ReferralActivityCompleted
			,count(DISTINCT CASE 
					WHEN t.istatus NOT IN (
							2
							,7
							)
						AND srh.residentstatuscode IN (
							0
							,1
							,4
							,11
							)
						AND convert(DATETIME, convert(CHAR(10), t.dtmovein, 121), 101) BETWEEN convert(DATETIME, @sDateStart, 101)
							AND convert(DATETIME, @sDateEnd, 101)
						THEN t.hmyperson
					END) MoveIns
			,CASE @DepositDefination
				WHEN 0
					THEN count(DISTINCT CASE 
								WHEN isnull(dpsts.ProspectID, 0) <> 0
									THEN dpsts.ProspectID
								END)
				WHEN 1
					THEN count(DISTINCT CASE 
								WHEN isnull(dpsts1.ProspectID, 0) <> 0
									THEN dpsts1.ProspectID
								END)
				WHEN 2
					THEN count(DISTINCT CASE 
								WHEN isnull(dpsts2.ProspectID, 0) <> 0
									THEN dpsts2.ProspectID
								END)
				END NewDeposits
			,p.hmy SummaryHmy
			,p.hmy AttributeHmy
		FROM property p
		INNER JOIN tenant t ON t.hproperty = p.hmy
		INNER JOIN seniorresident sr ON sr.residentid = t.hmyperson
		LEFT JOIN seniorresidenthistory srh ON srh.residentID = t.hmyperson
			AND residenthistoryid IN (
				SELECT MAX(residenthistoryid) residenthistoryid
				FROM seniorresidenthistory(NOLOCK)
				WHERE convert(DATETIME, convert(VARCHAR(20), residenthistorydate, 101), 101) <= CONVERT(DATETIME, convert(DATETIME, @sDateEnd, 101), 101)
					AND residentid = srh.residentid
				GROUP BY residentid
				)
			AND sr.carelevelcode <> ''
		LEFT JOIN SeniorProspect SP ON SP.htenant = T.hmyperson
		LEFT JOIN seniorprospecthistory h ON sp.hmy = h.hprospect
		LEFT JOIN seniorprospectactivity spa3 ON spa3.activityid = h.activityid
		INNER JOIN seniorprospecthistory h1 ON h.hmy = h1.hmy
			AND spa3.ActivityCategory = 'INI'
		LEFT JOIN AgentNames a ON (
				sp.hAgent = a.hmy
				AND p.hmy = a.hProp
				)
		LEFT JOIN listoption l ON l.listoptioncode = sp.hcarelevel
			AND l.listname = 'CareLevel'
		LEFT JOIN Listoption leadstatus ON leadstatus.Listoptioncode = sp.hLeadType
			AND leadstatus.ListName = 'LeadStatus'
		LEFT JOIN seniorprospectmarketarea spma ON spma.marketareaid = sp.hmarketarea
		LEFT JOIN seniorprospectsource sps ON sps.sourceid = sp.hsource
		LEFT JOIN (
			SELECT p.hmy
				,an.sname sname
				,AV.sValue
				,AV.Hmy AHMY
			FROM property p
			INNER JOIN AttributeXref ax ON ax.hFileRecord = p.hmy
			INNER JOIN attributeValue AV ON av.hmy = ax.hattributeValue
			INNER JOIN attributename AN ON av.hAttributename = an.hmy
				AND an.iFileType = 3
				AND an.sSubgroup = CASE 
					WHEN isnull('byComm', '') = ''
						THEN an.sSubgroup
					ELSE 'byComm'
					END
				AND isnull('byComm', '') <> ''
			) CF ON CF.hmy = p.hmy
		LEFT JOIN (
			SELECT DISTINCT t.hmy
				,p.hmy PropertyID
				,TN.hmyperson ProspectID
				,convert(DATETIME,@sDateStart, 101) FromDate
				,convert(DATETIME, @sDateEnd, 101) Todate
				,0 DepositType
			FROM Tenant TN
			INNER JOIN Property P ON P.Hmy = TN.HProperty
			INNER JOIN Trans T ON T.Hperson = TN.HMYPERSON
			INNER JOIN Detail D ON D.Hinvorrec = T.HMY
			INNER JOIN Acct Act ON Act.HMY = D.Hacct
			INNER JOIN param pm ON pm.hchart = act.hchart
				AND act.hmy IN (
					pm.hdeposit
					,pm.hdeposit1
					,pm.hdeposit2
					,pm.hdeposit2
					,pm.hdeposit3
					,pm.hdeposit4
					,pm.hdeposit5
					,pm.hdeposit6
					,pm.hdeposit7
					,pm.hdeposit8
					,pm.hdeposit9
					)
			WHERE T.ITYpe = 6
				AND d.samount > 0
				AND ISNULL(t.sNotes, '') NOT LIKE '%Reverses receipt Ctrl%'
				AND ISNULL(t.sNotes, '') NOT LIKE '%Reversed by ctrl%'
				AND p.hmy IN (@propertyID)
				AND CONVERT(DATETIME, CONVERT(CHAR(10), T.SDateOccurred, 121), 101) BETWEEN convert(DATETIME, @sDateStart, 101)
					AND convert(DATETIME, @sDateEnd, 101)
			) dpsts ON dpsts.PropertyID = p.hmy
			AND t.hmyperson = dpsts.ProspectID
			AND convert(DATETIME, @sDateStart, 101) = dpsts.FromDate
			AND convert(DATETIME, @sDateEnd, 101) = dpsts.ToDate
			AND dpsts.DepositType = @DepositDefination
		LEFT JOIN (
			SELECT DISTINCT sp.hmy
				,p.hmy PropertyID
				,sp.hTenant ProspectID
				,convert(DATETIME, @sDateStart, 101) FromDate
				,convert(DATETIME, @sDateEnd, 101) Todate
				,1 DepositType
			FROM seniorprospect sp
			INNER JOIN property p ON p.hmy = sp.hproperty
				AND sp.htenant > 0
			INNER JOIN seniorprospecthistory sph ON sph.hprospect = sp.hmy
			INNER JOIN seniorprospectactivity spa ON spa.activityid = sph.activityid
				AND sph.dtCompleted IS NOT NULL
				AND isnull(sph.ActivityResultID, 0) > 0
			LEFT JOIN listoption o ON sp.hcarelevel = o.listoptioncode
				AND o.ListOptionActiveFlag = 1
				AND o.ListName = 'CareLevel'
			WHERE spa.activityid IN (
					SELECT [N].value('.', 'varchar(50)')
					FROM @xml.nodes('X') AS [T]([N])
					)
				AND CONVERT(DATETIME, CONVERT(CHAR(10), (sph.dtdate), 121), 101) BETWEEN convert(DATETIME, @sDateStart, 101)
					AND convert(DATETIME, @sDateEnd, 101)
				AND p.hmy IN (@propertyID)
			) dpsts1 ON dpsts1.PropertyID = p.hmy
			AND t.hmyperson = dpsts1.ProspectID
			AND convert(DATETIME, @sDateStart, 101) = dpsts1.FromDate
			AND convert(DATETIME, @sDateEnd, 101) = dpsts1.ToDate
			AND Dpsts1.DepositType = @DepositDefination
		LEFT JOIN (
			SELECT DISTINCT sp.hmy
				,p.hmy PropertyID
				,sp.hTenant ProspectID
				,convert(DATETIME, @sDateStart, 101) FromDate
				,convert(DATETIME, @sDateEnd, 101) Todate
				,2 DepositType
			FROM seniorprospect sp
			INNER JOIN Property p ON p.hmy = sp.hproperty
			INNER JOIN tenant t ON sp.hTenant = t.HMYPERSON
			INNER JOIN SeniorResidentHistoryStatus rhs ON (rhs.hResident = t.hmyperson)
			WHERE rhs.iStatusCode IN (
					2
					,8
					)
				AND rhs.sprivacylevelcode <> 'SEC'
				AND convert(DATETIME, convert(CHAR(10), rhs.dtFrom, 121)) BETWEEN convert(DATETIME, @sDateStart, 101)
					AND convert(DATETIME, @sDateEnd, 101)
				AND rhs.hmy IN (
					SELECT max(hmy)
					FROM SeniorResidentHistoryStatus
					WHERE Convert(DATETIME, Convert(CHAR(10), dtFrom, 121)) BETWEEN convert(DATETIME, convert(DATETIME, @sDateStart, 101), 101)
							AND convert(DATETIME, convert(DATETIME,@sDateEnd, 101), 101)
						AND hResident = rhs.hResident
					GROUP BY hResident
					)
				AND p.hmy IN (@propertyID)
			) dpsts2 ON dpsts2.PropertyID = p.hmy
			AND t.hmyperson = dpsts2.ProspectID
			AND convert(DATETIME, @sDateStart, 101) = dpsts2.FromDate
			AND convert(DATETIME, @sDateEnd, 101) = dpsts2.ToDate
			AND Dpsts2.DepositType = @DepositDefination
		WHERE 1 = 1
			AND sr.PrivacyLevelcode NOT IN (
				SELECT SecondaryPrivacyLevel
				FROM SeniorPrivacyLevelMapping
				)
			AND p.hmy IN (@propertyID)
		GROUP BY ltrim(rtrim(p.saddr1)) + ' (' + ltrim(rtrim(p.scode)) + ')'
			,ltrim(rtrim(p.saddr1)) + ' (' + ltrim(rtrim(p.scode)) + ')'
			,p.hmy
			,p.hmy
		
		UNION ALL
		
		SELECT ltrim(rtrim(p.saddr1)) + ' (' + ltrim(rtrim(p.scode)) + ')' Attribute
			,ltrim(rtrim(p.saddr1)) + ' (' + ltrim(rtrim(p.scode)) + ')' Summary
			,0 Inquiries
			,0 RefInquiries
			,0 FirstTour
			,0 AdditionalTours
			,0 ProspectActivityCompleted
			,0 ReferralActivityCompleted
			,count(DISTINCT CASE 
					WHEN t.istatus NOT IN (
							2
							,7
							)
						AND srh.residentstatuscode IN (
							0
							,1
							,4
							,11
							)
						AND convert(DATETIME, convert(CHAR(10), t.dtmovein, 121), 101) BETWEEN convert(DATETIME, @sDateStart, 101)
							AND convert(DATETIME, @sDateEnd, 101)
						THEN t.hmyperson
					END) MoveIns
			,CASE @DepositDefination
				WHEN 0
					THEN count(DISTINCT CASE 
								WHEN isnull(dpsts.ProspectID, 0) <> 0
									THEN dpsts.ProspectID
								END)
				WHEN 1
					THEN count(DISTINCT CASE 
								WHEN isnull(dpsts1.ProspectID, 0) <> 0
									THEN dpsts1.ProspectID
								END)
				WHEN 2
					THEN count(DISTINCT CASE 
								WHEN isnull(dpsts2.ProspectID, 0) <> 0
									THEN dpsts2.ProspectID
								END)
				END NewDeposits
			,p.hmy SummaryHmy
			,p.hmy AttributeHmy
		FROM property p
		INNER JOIN tenant t ON t.hproperty = p.hmy
		INNER JOIN seniorresident sr ON sr.residentid = t.hmyperson
		LEFT JOIN listoption l ON l.listoptioncode = sr.carelevelcode
			AND l.listname = 'CareLevel'
		LEFT JOIN seniorresidenthistory srh ON srh.residentID = t.hmyperson
			AND residenthistoryid IN (
				SELECT MAX(residenthistoryid) residenthistoryid
				FROM seniorresidenthistory(NOLOCK)
				WHERE convert(DATETIME, convert(VARCHAR(20), residenthistorydate, 101), 101) <= CONVERT(DATETIME, convert(DATETIME, @sDateEnd, 101), 101)
					AND residentid = srh.residentid
				GROUP BY residentid
				)
			AND sr.carelevelcode <> ''
		LEFT JOIN (
			SELECT p.hmy
				,an.sname sname
				,AV.sValue
				,AV.Hmy AHMY
			FROM property p
			INNER JOIN AttributeXref ax ON ax.hFileRecord = p.hmy
			INNER JOIN attributeValue AV ON av.hmy = ax.hattributeValue
			INNER JOIN attributename AN ON av.hAttributename = an.hmy
				AND an.iFileType = 3
				AND an.sSubgroup = CASE 
					WHEN isnull('byComm', '') = ''
						THEN an.sSubgroup
					ELSE 'byComm'
					END
				AND isnull('byComm', '') <> ''
			) CF ON CF.hmy = p.hmy
		LEFT JOIN (
			SELECT DISTINCT t.hmy
				,p.hmy PropertyID
				,TN.hmyperson ProspectID
				,convert(DATETIME, @sDateStart, 101) FromDate
				,convert(DATETIME, @sDateEnd, 101) Todate
				,0 DepositType
			FROM Tenant TN
			INNER JOIN Property P ON P.Hmy = TN.HProperty
			INNER JOIN Trans T ON T.Hperson = TN.HMYPERSON
			INNER JOIN Detail D ON D.Hinvorrec = T.HMY
			INNER JOIN Acct Act ON Act.HMY = D.Hacct
			INNER JOIN param pm ON pm.hchart = act.hchart
				AND act.hmy IN (
					pm.hdeposit
					,pm.hdeposit1
					,pm.hdeposit2
					,pm.hdeposit2
					,pm.hdeposit3
					,pm.hdeposit4
					,pm.hdeposit5
					,pm.hdeposit6
					,pm.hdeposit7
					,pm.hdeposit8
					,pm.hdeposit9
					)
			WHERE T.ITYpe = 6
				AND d.samount > 0
				AND ISNULL(t.sNotes, '') NOT LIKE '%Reverses receipt Ctrl%'
				AND ISNULL(t.sNotes, '') NOT LIKE '%Reversed by ctrl%'
				AND p.hmy IN (@propertyID)
				AND CONVERT(DATETIME, CONVERT(CHAR(10), T.SDateOccurred, 121), 101) BETWEEN convert(DATETIME, @sDateStart, 101)
					AND convert(DATETIME, @sDateEnd, 101)
			) dpsts ON dpsts.PropertyID = p.hmy
			AND t.hmyperson = dpsts.ProspectID
			AND convert(DATETIME, @sDateStart, 101) = dpsts.FromDate
			AND convert(DATETIME, @sDateEnd, 101) = dpsts.ToDate
			AND dpsts.DepositType = @DepositDefination
		LEFT JOIN (
			SELECT DISTINCT sp.hmy
				,p.hmy PropertyID
				,sp.hTenant ProspectID
				,convert(DATETIME, @sDateStart, 101) FromDate
				,convert(DATETIME, @sDateEnd, 101) Todate
				,1 DepositType
			FROM seniorprospect sp
			INNER JOIN property p ON p.hmy = sp.hproperty
				AND sp.htenant > 0
			INNER JOIN seniorprospecthistory sph ON sph.hprospect = sp.hmy
			INNER JOIN seniorprospectactivity spa ON spa.activityid = sph.activityid
				AND sph.dtCompleted IS NOT NULL
				AND isnull(sph.ActivityResultID, 0) > 0
			LEFT JOIN listoption o ON sp.hcarelevel = o.listoptioncode
				AND o.ListOptionActiveFlag = 1
				AND o.ListName = 'CareLevel'
			WHERE spa.activityid IN (
					SELECT [N].value('.', 'varchar(50)')
					FROM @xml.nodes('X') AS [T]([N])
					)
				AND p.hmy IN (@propertyID)
			) dpsts1 ON dpsts1.PropertyID = p.hmy
			AND t.hmyperson = dpsts1.ProspectID
			AND convert(DATETIME, @sDateStart, 101) = dpsts1.FromDate
			AND convert(DATETIME, @sDateEnd, 101) = dpsts1.ToDate
			AND Dpsts1.DepositType = @DepositDefination
		LEFT JOIN (
			SELECT DISTINCT sp.hmy
				,p.hmy PropertyID
				,sp.hTenant ProspectID
				,convert(DATETIME, @sDateStart, 101) FromDate
				,convert(DATETIME, @sDateEnd, 101) Todate
				,2 DepositType
			FROM seniorprospect sp
			INNER JOIN property p ON p.hmy = sp.hproperty
			INNER JOIN tenant t ON sp.hTenant = t.HMYPERSON
			INNER JOIN SeniorResidentHistoryStatus rhs ON (rhs.hResident = t.hmyperson)
			WHERE rhs.ISTATUSCODE IN (
					2
					,8
					)
				AND rhs.sprivacylevelcode <> 'SEC'
				AND convert(DATETIME, convert(CHAR(10), rhs.dtFrom, 121)) BETWEEN convert(DATETIME, @sDateStart, 101)
					AND convert(DATETIME, @sDateEnd, 101)
				AND rhs.hmy IN (
					SELECT max(hmy)
					FROM SeniorResidentHistoryStatus
					WHERE Convert(DATETIME, Convert(CHAR(10), dtFrom, 121)) BETWEEN convert(DATETIME, convert(DATETIME, @sDateStart, 101), 101)
							AND convert(DATETIME, convert(DATETIME, @sDateEnd, 101), 101)
						AND hResident = rhs.hResident
					GROUP BY hResident
					)
				AND p.hmy IN (@propertyID)
			) dpsts2 ON dpsts2.PropertyID = p.hmy
			AND t.hmyperson = dpsts2.ProspectID
			AND convert(DATETIME, @sDateStart, 101) = dpsts2.FromDate
			AND convert(DATETIME, @sDateEnd, 101) = dpsts2.ToDate
			AND Dpsts2.DepositType = @DepositDefination
		WHERE 1 = 1
			AND sr.PrivacyLevelcode NOT IN (
				SELECT SecondaryPrivacyLevel
				FROM SeniorPrivacyLevelMapping
				)
			AND t.hmyperson NOT IN (
				SELECT sp.htenant
				FROM SeniorProspect sp
				INNER JOIN property p ON p.hmy = sp.hproperty
				INNER JOIN seniorprospecthistory sph ON sph.hprospect = sp.hmy
				INNER JOIN SeniorProspectActivity spa ON (
						spa.ActivityCategory = 'INI'
						AND spa.ActivityId = sph.ActivityId
						)
				WHERE isnull(sp.htenant, 0) <> 0
					AND p.hmy IN (@propertyID)
					AND convert(DATETIME, convert(VARCHAR(10), sph.dtdate, 101), 101) BETWEEN '01/01/1900'
						AND '01/01/2100'
				)
			AND p.hmy IN (@propertyID)
		GROUP BY ltrim(rtrim(p.saddr1)) + ' (' + ltrim(rtrim(p.scode)) + ')'
			,p.hmy
			,ltrim(rtrim(p.saddr1)) + ' (' + ltrim(rtrim(p.scode)) + ')'
			,p.hmy
		) tmp2
	GROUP BY tmp2.Attribute
		,isnull(tmp2.Summary, '*None')
		,isnull(tmp2.Summaryhmy, 0)
		,isnull(tmp2.Attributehmy, 0)
	) tmp1
GROUP BY tmp1.Attribute
	,isnull(tmp1.Summary, '*None')
	,isnull(tmp1.Summaryhmy, 0)
	,isnull(tmp1.Attributehmy, 0)
ORDER BY 1
	,2

GO
;

exec [dbo].[IHPCommunityAnalytics_ConversionReport]
@propcode = 'colm',
@startd = '7/06/2021', 
@endd = '7/6/2021'

----select * from tempdb.sys.objects

----select * from tmp1