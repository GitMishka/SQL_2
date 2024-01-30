
--Raw data underneath the "Raw Data" field


Declare @propcode varchar(max)
Declare @startd DATETIME
Declare @endd DATETIME

DECLARE @propertyid INTEGER
Declare @sDateStart DATETIME
Declare @sDateEnd   DATETIME

set @propcode = 'colm'
Set @startd = '6/30/2021'
set @endd = '7/06/2021'

set @propertyid = (select hmy from property where scode=@propcode)
SET @sDateStart = CONVERT(DATETIME,@startd , 101)
set @sDateEnd = CONVERT(DATETIME, @endd, 101)

--SELECT ltrim(rtrim(p.saddr1)) + ' (' + ltrim(rtrim(p.scode)) + ')' Attribute
--            ,ltrim(rtrim(p.saddr1)) + ' (' + ltrim(rtrim(p.scode)) + ')' Summary
--            ,0 Inquiries
--            ,0 RefInquiries
--            ,count(CASE 
--                           WHEN isnull(spa.activityid, 0) <> 0
--                                  AND isnull(rt.ActivityID, 0) = 0
--                                  THEN h.hmy
--                           END) FirstTour
--            ,count(CASE 
--                           WHEN isnull(spa1.activityid, 0) <> 0
--                                  AND isnull(rt.ActivityID, 0) = 0
--                                  THEN h.hmy
--                           END) AdditionalTours
--            ,0 MoveIns
--            ,0 NewDeposits
--            ,COUNT(CASE 
--                           WHEN Isnull(spa2.activityid, 0) <> 0
--                                  AND isnull(rt.ActivityID, 0) = 0
--                                  THEN h.hmy
--                           END) ProspectActivityCompleted
--            ,COUNT(CASE 
--                           WHEN Isnull(spa4.activityid, 0) <> 0
--                                  AND isnull(rt.ActivityID, 0) = 0
--                                  THEN h.hmy
--                           END) ReferralActivityCompleted
--            ,p.hmy SummaryHmy
--            ,p.hmy AttributeHmy
select p.scode, spa.activityid, rt.activityid,spa1.activityid, spa.*, rt.*
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
              --AND p.hmy IN (25)
              and p.hmy in (@propertyid)
              and (spa.activityid IS NOT NULL);-- OR rt.activityID IS NOT NULL)

       --GROUP BY ltrim(rtrim(p.saddr1)) + ' (' + ltrim(rtrim(p.scode)) + ')'
       --     ,ltrim(rtrim(p.saddr1)) + ' (' + ltrim(rtrim(p.scode)) + ')'
       --     ,p.hmy
       --     ,p.hmy





 
  
