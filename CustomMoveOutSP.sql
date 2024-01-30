--sp_helptext  SeniorMoveInMoveOutDetailFinancial  
  --DROP PROCEDURE SeniorMoveInMoveOutDetailFinancial  
    CREATE PROCEDURE [dbo].[SeniorMoveInMoveOutDetailFinancial](      
    @Type VARCHAR(20)      
    ,@PropertyCode VARCHAR(MAX)      
    ,@grp VARCHAR(20)      
    ,@sStatus VARCHAR(30)      
    ,@carelev VARCHAR(MAX)      
    ,@ResStatus VARCHAR(MAX)      
    ,@ContTyp VARCHAR(MAX)      
    ,@sDat1 DATETIME      
    ,@sDat2 DATETIME      
    ,@srDat1 DATETIME      
    ,@srDat2 DATETIME      
    ,@DpDate DATETIME      
    ,@SecResident VARCHAR(3)      
    ,@DispRate VARCHAR(3)      
   ,@OccType VARCHAR(20)      
    )        
  AS        
  BEGIN      
  DECLARE @BegDefault DATETIME,      
          @EndDefault DATETIME,      
    @BegVirtual DATETIME,      
          @EndVirtual DATETIME,      
    @BOMActual  DATETIME;      
  SET @BegDefault = '01/01/1900';      
  SET @EndDefault = '12/31/2200';      
  --???No Need this concept???      
  SET @BOMActual  = @sDat1      
  IF @Type ='MoveOut'      
  BEGIN      
      SET @sDat1      = DATEADD(dd, -1, @BOMActual)      
      SET @srDat1 = @sDat1      
      SET @srDat2 = @sDat2      
  END      
  SET @BegVirtual = DATEADD(mm, -1, @srDat1);      
  SET @EndVirtual = DATEADD(mm, 1, @srDat2);      
  IF ISNULL(@ResStatus,'') = ''       
   SELECT @ResStatus = ISNULL(@ResStatus,'') + COALESCE(LTRIM(RTRIM(iStatus)), '') + ',' FROM SeniorResidentStatus WHERE status NOT IN ('Applicant','Prospect')      
  ELSE SET @ResStatus= LEFT(@ResStatus,len(@ResStatus)-1)      
  IF OBJECT_ID('tempdb..#tmpProperty') IS NOT NULL DROP TABLE #tmpProperty      
  IF OBJECT_ID('tempdb..#tmpCareLevel') IS NOT NULL DROP TABLE #tmpCareLevel      
  IF OBJECT_ID('tempdb..#tmpContractType') IS NOT NULL DROP TABLE #tmpContractType      
  CREATE TABLE #tmpProperty (      
        PropertyID  NUMERIC,        
        PropertyCode CHAR(8),        
        PropertyName VARCHAR(255),        
        Property  VARCHAR(266)        
  )      
  INSERT INTO #tmpProperty      
  SELECT DISTINCT p.hmy   PropertyID,       
                  p.scode PropertyCode,       
                  Ltrim(Rtrim(p.sAddr1)) PropertyName,      
      ''      
  FROM   dbo.Senior_listhandler(@PropertyCode , 'code') pr       
  INNER JOIN Property p  ON (RTRIM(p.scode) = RTRIM(pr.scode))       
  CREATE TABLE #tmpCareLevel      
  (       
       hmy     NUMERIC,       
       ListOptionCode   VARCHAR(8),       
       ListOptionName  VARCHAR(300)      
  )      
  IF LTRIM(RTRIM(@carelev)) <> ''      
  BEGIN      
  SET @carelev= LEFT(@carelev,len(@carelev)-1);      
  INSERT INTO #tmpCareLevel       
  SELECT DISTINCT lp.hmy                  hmy,       
                  lp.ListOptionCode       ListOptionCode,       
                  lp.ListOptionName  ListOptionName      
  FROM   dbo.Senior_listhandler(@carelev, 'Code') lr       
  INNER JOIN ListOption lp ON lr.scode = RTRIM(lp.ListOptionCode)      
  WHERE lp.listname = 'CareLevel'       
  END      
  ELSE      
  BEGIN      
  INSERT INTO #tmpCareLevel      
  SELECT DISTINCT lp.hmy                  hmy,       
                  lp.ListOptionCode       sCode,       
                  lp.ListOptionName  sName      
  FROM listoption lp       
  WHERE lp.listname = 'CareLevel'       
  END       
  CREATE TABLE #tmpContractType       
  (       
       hmy     NUMERIC,       
       ListOptionCode   VARCHAR(8),       
       ListOptionName  VARCHAR(300)      
  )      
  IF LTRIM(RTRIM(@ContTyp)) <> ''      
  BEGIN      
  SET @ContTyp= LEFT(@ContTyp,len(@ContTyp)-1)      
  INSERT INTO #tmpContractType        
  SELECT DISTINCT lp.hmy                  hmy,       
                  lp.ListOptionCode       ListOptionCode,       
                  lp.ListOptionName  ListOptionName      
  FROM   dbo.Senior_listhandler(@ContTyp, 'Code') lr       
  INNER JOIN ListOption lp ON lr.scode = RTRIM(lp.ListOptionCode)      
  WHERE lp.listname = 'ContractType'       
  END      
  ELSE      
  BEGIN      
  INSERT INTO #tmpContractType      
  SELECT DISTINCT lp.hmy                  hmy,       
                  lp.ListOptionCode       sCode,       
                  lp.ListOptionName  sName      
  FROM listoption lp       
  WHERE lp.listname = 'ContractType'       
  END      
   /*Common code for Move in attributes */      
   IF(@type ='MoveIn')      
   BEGIN        
    IF OBJECT_ID ('TempDb..#Attribute') IS NOT NULL      
               DROP TABLE #Attribute      
    CREATE TABLE #Attribute (hprop NUMERIC,       
         sSubgroup VARCHAR(20) ,      
         sname VARCHAR(80),      
         svalue VARCHAR(80))      
    IF(@grp <> '')      
     INSERT INTO #Attribute      
     SELECT  p.hmy hprop,      
     an.sSubgroup,      
     an.sname,      
     av.svalue       
     FROM #tmpProperty x          
       INNER JOIN Property p ON LTRIM(RTRIM(x.PropertyCode)) = LTRIM(RTRIM(p.sCode))       
       INNER JOIN ListProp2 l    ON l.hProplist = p.hmy AND l.iType <> 11       
       INNER JOIN AttributePropertyXref apx  ON apx.hProperty = P.hmy      
       INNER JOIN AttributeSET ats      ON ats.hMy   = apx.hAttributeSet      
       INNER JOIN AttributeSetXref asx    ON ats.hMy   = asx.hAttributeSet      
       INNER JOIN AttributeName an      ON an.hMy   = asx.hAttributeName      
       OUTER Apply(SELECT ax.hFileRecord phmy,      
                     av.hMy,      
            av.hAttributeName,      
            av.svalue      
           FROM AttributeValue av      
          INNER JOIN AttributeXref ax ON av.hMy = ax.hAttributeValue AND ax.iFileType = 3      
            WHERE av.hAttributeName = an.hMy AND p.HMY = ax.hFileRecord      
         ) av       
     WHERE ISNULL(an.ssubgroup,'') = @grp      
   END       
   /*Final code for Movein & MoveOut Actual */      
   IF(@sStatus ='Actual')      
   BEGIN      
       IF OBJECT_ID ('TempDb..#ActMInoutRes') IS NOT NULL      
               DROP TABLE #ActMInoutRes      
    CREATE TABLE #ActMInoutRes      
     (      
      hProperty NUMERIC(18, 0),      
      hResident NUMERIC(18, 0),      
      srhhmy NUMERIC(18, 0)      
     )      
    IF OBJECT_ID ('TempDb..#ActResDet') IS NOT NULL      
               DROP TABLE #ActResDet      
    CREATE TABLE #ActResDet (      
      phmy NUMERIC,      
      propname VARCHAR (300),      
      sResidentName VARCHAR (600),      
      istatus NUMERIC,      
      ThMy NUMERIC,      
      moveindate DATETIME,      
      uhmy NUMERIC,      
      uscode VARCHAR (8),      
      utscode VARCHAR (8),      
      utsdesc VARCHAR (40),      
      privacylevel VARCHAR (20),      
      carelevel VARCHAR (20),      
      ContTyp VARCHAR (20),      
      Noticedate DATETIME,      
      moveoutdate DATETIME,      
      Moveoutreason smallint,      
      BillingEndDate DATETIME,      
      dMin datetime      
      )      
    IF OBJECT_ID ('TempDb..#mintemp1') IS NOT NULL      
                   DROP TABLE #mintemp1      
     CREATE TABLE #mintemp1      
     (      
       ID NUMERIC,      
       hResident NUMERIC(18, 0),      
       dtMoveIn DATETIME,      
       ServiceInstanceID NUMERIC(18, 0)      
     )      
    IF OBJECT_ID ('TempDb..#TempResidentHistoryStatusOut') IS NOT NULL      
                   DROP TABLE #TempResidentHistoryStatusOut      
     CREATE TABLE #TempResidentHistoryStatusOut      
     (      
       ID NUMERIC,      
       hResident NUMERIC(18, 0),      
       dtMoveIn DATETIME,      
       dtMoveOut DATETIME,      
       ServiceInstanceID NUMERIC(18, 0),      
       ServiceInstanceIDOut NUMERIC(18, 0),      
       iMoveOutReason NUMERIC(2, 0),      
       dtBillingEnd DATETIME,      
       dtNotice DATETIME,      
       dtServiceFrom DATETIME      
     )      
     IF OBJECT_ID ('TempDb..#tmpService') IS NOT NULL      
       DROP TABLE #TmpService      
      CREATE TABLE #TmpService      
       (      
        ServiceID                 NUMERIC,           
        ServiceName VARCHAR(100)      
       )      
      INSERT INTO #TmpService      
       SELECT s.ServiceId, s.ServiceName      
       FROM Service s      
      WHERE s.ServiceClassID = 1      
      IF OBJECT_ID ('TempDb..#ServiceDateRange') IS NOT NULL      
        DROP TABLE #ServiceDateRange      
      CREATE TABLE #ServiceDateRange(      
        ServiceInstanceId NUMERIC ,       
        PropertyId                NUMERIC,      
        ResidentId                NUMERIC,      
        ServiceID                 NUMERIC,      
        UnitId                    NUMERIC,      
        CareLevelCode             VARCHAR(50),      
        PrivacyLevelCode          VARCHAR(50),      
        ContractTypeCode          VARCHAR(50), --???05/03/2021 Performance???      
        ServiceInstanceFromDate   DATETIME,      
        ServiceInstanceToDate     DATETIME,      
        bMoveIn         INT,      
        bMoveOut        INT,      
        RemoveFlag INT,      
        CoOccupantId NUMERIC      
        )      
      INSERT INTO #ServiceDateRange (       
         ServiceInstanceId,      
         PropertyId,      
         ResidentId               ,       
         ServiceID                ,      
         UnitId                   ,      
         CareLevelCode            ,      
         PrivacyLevelCode         ,      
         ContractTypeCode         , --???05/03/2021 Performance???      
         ServiceInstanceFromDate  ,      
         ServiceInstanceToDate    ,      
         bMoveIn        ,      
         bMoveOut        ,      
         RemoveFlag      
       )      
     /* Get information about service date ranges of the residnets */       
     SELECT DISTINCT i.ServiceInstanceID, tt.hProperty, i.residentid,       
         i.ServiceID,      
         i.unitid,      
         RTRIM(i.CareLevelCode),      
         RTRIM(i.PrivacyLevelCode),      
         RTRIM(i.ContractTypeCode),      
         CONVERT( DATETIME, CONVERT(VARCHAR(11), i.ServiceInstanceFromDate), 101 ) ,      
         CONVERT( DATETIME, CONVERT(VARCHAR(11), i.ServiceInstanceToDate), 101 )  ServiceInstanceToDate,      
         0,      
         0,      
         0      
     FROM #tmpSERVICE cs      
     INNER JOIN ServiceInstance i ON i.ServiceID = cs.ServiceID      
     INNER JOIN Tenant tt ON i.ResidentID = tt.HMYPERSON      
     INNER JOIN #tmpProperty p ON tt.HPROPERTY = p.PropertyID      
     WHERE 1=1       
      AND i.ServiceInstanceFromDate <= @srDat2      
      AND ISNULL(i.ServiceInstanceToDate, @srDat2) >= @BegVirtual      
      AND ISNULL(i.ServiceInstanceToDate, @srDat2) >= i.ServiceInstanceFromDate      
      AND i.ServiceInstanceActiveFlag <> 0      
    /* Code will list all MIN & MAX hmy for ResidentHistoryStatus for MoveIn & MoveOut,      
     Code optimizes reads as selective Hmy are passed to detail query*/      
    INSERT INTO #ActMInoutRes      
    SELECT p.PropertyID, Srh1.hResident,Case when @type ='Movein' then MIN(srh1.hmy)      
         when @type ='MoveOut' then MAX(srh1.hmy) end srhhmy         
    FROM #tmpProperty p       
     INNER JOIN ListProp2 l  ON l.hProplist = p.PropertyID AND l.iType <> 11      
     INNER JOIN SeniorResidentHistoryStatus srh1 ON p.PropertyID = srh1.hProperty      
    WHERE srh1.dtFROM <= ISNULL(srh1.dtto, srh1.dtfrom)         
     AND srh1.dtFROM <= CONVERT(DATETIME, @srDat2, 101)      
     AND 1= Case when @type ='Movein' AND srh1.iStatuscode NOT IN (2,8,7) then 1      
        when @type ='MoveOut' AND (srh1.istatuscode =1 OR srh1.bOnNotice = 1 ) then 1      
        ELSE 0 END      
     AND Case when @type ='Movein' then dtMoveIn      
       when @type ='MoveOut' then dtMoveOut end       
      between CONVERT(DATETIME, @srDat1, 101) and CONVERT(DATETIME, @srDat2, 101)           
    GROUP BY p.PropertyID, srh1.hResident,Case when @type ='Movein' then dtMoveIn      
           when @type ='MoveOut' then dtMoveOut end       
    IF @OccType = 'Financial'      
    BEGIN      
     /*Moveout is null to include current residents also, if dtMoveOut selected in same query then logic needs to be added       
       to remove NULL moveout enties for NON-Current residents in respective multiple In-Out combinations */      
     INSERT INTO #TempResidentHistoryStatusOut      
     SELECT ID,hResident,MAX(dtMoveIn),dtMoveOut,ServiceInstanceID,ServiceInstanceIDOut,iMoveOutReason,dtBillingEnd,dtNotice,dtServiceFrom FROM (    
    SELECT Distinct 1 ID, hResident, dtMovein, NULL dtMoveOut, NULL ServiceInstanceID, NULL ServiceInstanceIDOut, null iMoveOutReason, null dtBillingEnd, null dtNotice, null dtServiceFrom--srh2.iMoveOutReason, srh2.dtBillingEnd      
     FROM #tmpProperty p         
      INNER JOIN ListProp2 l ON l.hProplist = p.PropertyID AND l.iType <> 11      
      INNER JOIN SeniorResidentHistoryStatus srh2  on p.PropertyID = srh2.hProperty      
      AND srh2.iStatusCode IN (0, 4,11, 1) --???DEBUG      
     WHERE srh2.dtFROM <= ISNULL(srh2.dtto, srh2.dtfrom)        
      AND srh2.dtFROM <= CONVERT(DATETIME, @srDat2, 101)      
        ) A    
   GROUP BY ID,hResident,dtMoveOut,ServiceInstanceID,ServiceInstanceIDOut,iMoveOutReason,dtBillingEnd,dtNotice,dtServiceFrom    
     /* This will update ID in sequence of movein's*/      
     UPDATE  #TempResidentHistoryStatusOut SET ID = Rownum      
     FROM #TempResidentHistoryStatusOut tmp      
      Inner join (SELECT Row_Number() Over (partition by hResident ORDER BY dtMovein) rownum,* FROM #TempResidentHistoryStatusOut) a on a.hResident = tmp.hResident       
      AND a.dtMovein = tmp.dtMovein      
     /* Update correct Move-out date for respective movein*/      
     UPDATE  tmp SET tmp.dtMoveOut = srh2.dtMoveOut --???06/04/2021???      
     FROM SeniorResidentHistoryStatus srh2       
      INNER JOIN #TempResidentHistoryStatusOut tmp on tmp.hResident = srh2.hResident      
     WHERE Srh2.dtMovein  = tmp.dtMovein      
      AND srh2.dtFROM <= ISNULL(srh2.dtto, srh2.dtfrom)        
      AND srh2.dtFROM <= CONVERT(DATETIME, @srDat2, 101)      
      AND srh2.istatuscode =1       
     /*In multiple Move in scenario, each movein will get respective Minimum serviceinstanceid*/      
     INSERT INTO #mintemp1        
     SELECT tmp1.ID,tmp1.hResident,tmp1.dtMovein,MIN (si.ServiceInstanceID) ServiceInstanceID      
      FROM #ServiceDateRange si      
      INNER JOIN #TempResidentHistoryStatusOut tmp on tmp.hResident = si.ResidentID      
      LEFT JOIN #TempResidentHistoryStatusOut tmp1 on tmp1.hResident = si.ResidentID      
     WHERE 1=1      
      AND si.ServiceInstanceFromDate >= tmp.dtMoveOut      
      AND si.ServiceInstanceFromDate <= @srDat2      
      AND tmp.ID = tmp1.ID-1      
      AND ISNULL(si.serviceinstancetodate,si.serviceinstancefromdate) >= si.serviceinstancefromdate      
     GROUP BY tmp1.ID,tmp1.hResident,tmp1.dtMovein      
     /* Each instance of move in will get respective Minimum serviceinstanceid, InstanceID of 1st Move-in if only 1 exists in range*/      
     UPDATE  #TempResidentHistoryStatusOut SET ServiceInstanceID = ISNULL(a.ServiceInstanceID,B.ServiceInstanceID)      
     FROM #TempResidentHistoryStatusOut tmp      
     LEFT JOIN #mintemp1 a ON a.ID = tmp.ID AND a.hResident = tmp.hResident      
     LEFT JOIN ( SELECT ResidentID,MIN(si3.serviceinstanceid) serviceinstanceid      
        FROM #ServiceDateRange si3       
         INNER JOIN #TempResidentHistoryStatusOut tmp ON tmp.hResident = si3.residentid      
        WHERE 1 = 1      
         AND si3.ServiceInstanceFromDate <= @srDat2      
         AND ISNULL(si3.serviceinstancetodate,si3.serviceinstancefromdate) >= si3.serviceinstancefromdate      
        GROUP BY ResidentID ) b ON b.ResidentID = tmp.hResident      
     /*In multiple Move out scenario, each moveout will get respective Maximum serviceinstanceid*/      
     DELETE #mintemp1      
     INSERT INTO #mintemp1        
     SELECT tmp1.ID,tmp1.hResident,tmp1.dtMoveOut,MAX (si.ServiceInstanceID) ServiceInstanceID      
      FROM #ServiceDateRange si       
      INNER JOIN #TempResidentHistoryStatusOut tmp on tmp.hResident = si.ResidentID AND tmp.dtMoveOut IS NOT NULL      
      LEFT JOIN #TempResidentHistoryStatusOut tmp1 on tmp1.hResident = si.ResidentID AND tmp1.dtMoveOut IS NOT NULL      
     WHERE 1=1      
      AND si.ServiceInstanceToDate <= tmp.dtMoveIn      
      AND si.ServiceInstanceToDate BETWEEN @srDat1 AND @srDat2      
      AND tmp.ID = tmp1.ID+1      
      AND ISNULL(si.serviceinstancetodate,si.serviceinstancefromdate) >= si.serviceinstancefromdate      
     GROUP BY tmp1.ID,tmp1.hResident,tmp1.dtMoveOut      
     /* Each instance of move out will get respective Manimum serviceinstanceid, InstanceID of last Move-in if only 1 exists in range*/      
     UPDATE  #TempResidentHistoryStatusOut SET ServiceInstanceIDOut = ISNULL(a.ServiceInstanceID,B.ServiceInstanceID)      
     FROM #TempResidentHistoryStatusOut tmp      
     LEFT JOIN #mintemp1 a ON a.ID = tmp.ID AND a.hResident = tmp.hResident      
     LEFT JOIN ( SELECT ResidentID,MAX(si3.serviceinstanceid) serviceinstanceid      
        FROM #ServiceDateRange si3      
         INNER JOIN #TempResidentHistoryStatusOut tmp ON tmp.hResident = si3.residentid      
        WHERE 1 = 1       
         AND si3.ServiceInstanceToDate BETWEEN @srDat1 AND @srDat2      
         AND ISNULL(si3.serviceinstancetodate,si3.serviceinstancefromdate) >= si3.serviceinstancefromdate      
        GROUP BY ResidentID ) b ON b.ResidentID = tmp.hResident      
     WHERE tmp.dtMoveOut IS NOT NULL      
     --Update moveout reason and billing end date for financial       
     UPDATE tmp SET iMoveOutReason = h.iMoveOutReason, dtBillingEnd = h.dtBillingEnd, dtNotice = h.dtNotice       
     FROM #TempResidentHistoryStatusOut tmp      
     JOIN SeniorResidentHistoryStatus h ON (tmp.hResident = h.hResident AND tmp.dtMoveOut = h.dtMoveOut)      
     WHERE h.iStatusCode = 1      
     AND h.dtFrom <= ISNULL(h.dtTo, h.dtFrom)      
     --Update dates for financial       
     If @Type = 'MoveOut'      
     BEGIN      
      UPDATE tmp SET dtMovein = iIn.ServiceInstanceFromDate, dtMoveOut = DATEADD(dd, 1, iOut.ServiceInstanceToDate)      
      FROM #TempResidentHistoryStatusOut tmp      
      JOIN #ServiceDateRange iIn ON (tmp.ServiceInstanceID = iIn.ServiceInstanceID)       
      JOIN #ServiceDateRange iOut ON (tmp.ServiceInstanceIDOut = iOut.ServiceInstanceID)      
     END      
     ELSE      
     BEGIN      
      UPDATE tmp SET tmp.dtServiceFrom = iIn.ServiceInstanceFromDate, dtMoveOut = DATEADD(dd, 1, iOut.ServiceInstanceToDate)      
      FROM #TempResidentHistoryStatusOut tmp      
      JOIN #ServiceDateRange iIn ON (tmp.ServiceInstanceID = iIn.ServiceInstanceID)       
      LEFT OUTER JOIN #ServiceDateRange iOut ON (tmp.ServiceInstanceIDOut = iOut.ServiceInstanceID)      
      --Delete dupe records for invalid financial movein       
      DELETE tmp2      
      FROM #TempResidentHistoryStatusOut tmp1      
      JOIN #TempResidentHistoryStatusOut tmp2 ON (tmp1.Id = 1 AND tmp2.Id > 1       
                                                  AND ISNULL(tmp1.dtMoveOut, @EndDefault) = ISNULL(tmp2.dtMoveOut, @EndDefault)      
                 AND tmp1.ServiceInstanceID = tmp2.ServiceInstanceID)      
     END      
      --03/16/2021 try to get CoOccupantId      
      UPDATE s SET s.CoOccupantId = sr.hCoOccupant      
      FROM #ServiceDateRange s      
      JOIN SeniorResident sr ON (s.ResidentId = sr.ResidentId)      
      WHERE 1 = 1      
      UPDATE ss SET ss.ResidentId = ss.CoOccupantId      
      FROM #ServiceDateRange s      
      JOIN #ServiceDateRange ss ON (s.ResidentId = ss.CoOccupantId AND ss.ResidentId = s.CoOccupantId AND s.UnitId = ss.UnitId      
               AND ss.PrivacyLevelCode NOT IN (SELECT SecondaryPrivacyLevel FROM SeniorPrivacyLevelMapping)      
               AND s.PrivacyLevelCode NOT IN (SELECT SecondaryPrivacyLevel FROM SeniorPrivacyLevelMapping)      
               AND s.ServiceInstanceToDate IS NOT NULL       
               AND DATEADD(dd, 1, s.ServiceInstanceToDate) = ss.ServiceInstanceFromDate      
               )      
      JOIN #ServiceDateRange sss ON (s.ResidentId = sss.CoOccupantId AND sss.ResidentId = s.CoOccupantId AND sss.ResidentId = ss.ResidentId AND s.UnitId = sss.UnitId      
               AND ss.PrivacyLevelCode NOT IN (SELECT SecondaryPrivacyLevel FROM SeniorPrivacyLevelMapping)      
               AND s.PrivacyLevelCode NOT IN (SELECT SecondaryPrivacyLevel FROM SeniorPrivacyLevelMapping)      
               AND sss.PrivacyLevelCode IN (SELECT SecondaryPrivacyLevel FROM SeniorPrivacyLevelMapping)      
               AND s.ServiceInstanceToDate IS NOT NULL       
               AND sss.ServiceInstanceToDate IS NOT NULL      
               AND DATEADD(dd, 1, sss.ServiceInstanceToDate) = ss.ServiceInstanceFromDate      
               )      
      WHERE 1 = 1      
      UPDATE s SET s.ResidentId = ss.CoOccupantId      
      FROM #ServiceDateRange s      
      JOIN #ServiceDateRange ss ON ( s.UnitId = ss.UnitId AND s.CoOccupantId = ss.CoOccupantId                           
               AND ss.PrivacyLevelCode NOT IN (SELECT SecondaryPrivacyLevel FROM SeniorPrivacyLevelMapping)      
               AND s.PrivacyLevelCode IN (SELECT SecondaryPrivacyLevel FROM SeniorPrivacyLevelMapping)      
               AND s.ServiceInstanceToDate IS NOT NULL --??? Check for Portfolio report later???      
               AND DATEADD(dd, 1, s.ServiceInstanceToDate) = ss.ServiceInstanceFromDate      
               )      
      WHERE 1 = 1      
      DELETE ss       
      FROM #ServiceDateRange s      
      JOIN #ServiceDateRange ss ON (s.residentId = ss.ResidentId AND s.UnitId = ss.UnitId AND ss.CoOccupantId = s.ResidentId      
               AND s.ServiceInstanceToDate IS NOT NULL      
               AND ss.ServiceInstanceToDate IS NOT NULL      
               AND s.ServiceInstanceToDate = ss.ServiceInstanceToDate      
               AND ss.PrivacyLevelCode IN (SELECT SecondaryPrivacyLevel FROM SeniorPrivacyLevelMapping)      
               AND s.PrivacyLevelCode NOT IN (SELECT SecondaryPrivacyLevel FROM SeniorPrivacyLevelMapping))      
      WHERE 1 = 1      
     --Delete secondary privacy levels if the @ShowSeccondResident parameter is not set to 'yes' --04/16/2021      
      IF @SecResident <> 'yes'      
      BEGIN      
       DELETE FROM #ServiceDateRange      
       WHERE PrivacyLevelCode IN (      
        SELECT SecondaryPrivacyLevel      
        FROM SeniorPrivacyLevelMapping      
       )      
      END      
      UPDATE sd      
      SET sd.RemoveFlag = 1, sd.bMoveOut = 1      
      FROM #ServiceDateRange sd      
      INNER JOIN #ServiceDateRange sd1 ON sd.residentid=sd1.residentid                               
                AND sd.serviceInstanceFromDate = DATEADD(dd,1,sd1.ServiceInstanceToDate)      
     UPDATE sd      
     SET    sd.RemoveFlag = 2, sd.bMoveOut = 1      
     FROM   #ServiceDateRange sd      
         INNER JOIN #ServiceDateRange sd1      
           ON sd.ResidentId = sd1.residentid AND sd.ServiceInstanceFromDate = DATEADD(dd, 1, sd1.ServiceInstanceToDate)       
     WHERE ISNULL(sd.RemoveFlag,0) IN (1, 0) AND ISNULL(sd1.RemoveFlag,0) = 1       
      UPDATE sd      
     SET    sd.RemoveFlag = 3, sd.bMoveOut = 1      
     FROM   #ServiceDateRange sd      
         INNER JOIN #ServiceDateRange sd1      
           ON sd.ResidentId = sd1.residentid      
           AND sd.ServiceInstanceFromDate = DATEADD(dd, 1, sd1.ServiceInstanceToDate)       
     WHERE ISNULL(sd.RemoveFlag,0) IN (1, 2) AND ISNULL(sd1.RemoveFlag,0) = 2       
     UPDATE sd SET  sd.bMoveIn = 1      
      FROM #ServiceDateRange sd      
      WHERE ISNULL(sd.RemoveFlag,0) = 0      
      AND  sd.ServiceInstanceFromDate BETWEEN @srDat1 AND @srDat2 --??? @BOMActual???      
     UPDATE sd      
       SET  sd.bMoveOut = 1      
      FROM #ServiceDateRange sd      
      LEFT JOIN #ServiceDateRange sd1 ON sd.ResidentId = sd1.residentid      
           AND ISNULL(sd1.RemoveFlag, 0) = 1      
       WHERE ISNULL(sd.RemoveFlag,0) = 0      
       AND sd1.ResidentId IS NULL      
     UPDATE sd      
       SET  sd.bMoveOut = 0      
      FROM #ServiceDateRange sd      
      LEFT JOIN #ServiceDateRange sd1 ON sd.ResidentId = sd1.residentid      
           AND ISNULL(sd1.RemoveFlag, 0) = 2      
       WHERE ISNULL(sd.RemoveFlag,0) = 1      
       AND sd1.ResidentId IS NOT NULL      
     UPDATE sd      
       SET  sd.bMoveOut = 0      
      FROM #ServiceDateRange sd      
      LEFT JOIN #ServiceDateRange sd1 ON sd.ResidentId = sd1.residentid      
           AND ISNULL(sd1.RemoveFlag, 0) = 3      
       WHERE ISNULL(sd.RemoveFlag,0) = 2      
       AND sd1.ResidentId IS NOT NULL      
     UPDATE sd SET  sd.bMoveOut = 0      
     FROM #ServiceDateRange sd      
     WHERE ISNULL(sd.ServiceInstanceToDate, @EndDefault) >  DATEADD(dd, 1,  @srDat2)      
     AND sd.bMoveOut = 1      
     IF @Type = 'MoveOut'      
     BEGIN      
      --Update dates for financial for Secondary Privacy level change scenario      
      UPDATE tmp SET dtMoveOut = DATEADD(dd, 1, iOut.ServiceInstanceToDate), ServiceInstanceIDOut = iOut.ServiceInstanceID       
      FROM #TempResidentHistoryStatusOut tmp      
      JOIN #ServiceDateRange iOut ON (tmp.hResident = iOut.ResidentId       
               AND tmp.ServiceInstanceID <= iOut.ServiceInstanceID       
               AND tmp.dtMoveIn <= iOut.ServiceInstanceFromDate                                       
               AND ISNULL(tmp.dtMoveOut, @EndDefault) > DATEADD(dd, 1, iOut.ServiceInstanceToDate)               
               AND tmp.dtMoveIn <= iOut.ServiceInstanceToDate       
               AND iOut.bMoveOut = 1 )      
      JOIN ServiceInstance sis ON (iOut.ResidentId = sis.ResidentID AND DATEADD(dd, 1, iOut.ServiceInstanceToDate) = sis.ServiceInstanceFromDate)       
         JOIN Service s ON (sis.ServiceID = s.ServiceID AND s.ServiceClassID = 1)      
         WHERE sis.PrivacyLevelCode IN (SELECT RTRIM(Secondaryprivacylevel) FROM SeniorPrivacyLevelMapping)      
     END      
     IF @Type = 'MoveIn'      
     BEGIN      
      --Update dates for financial for Secondary Privacy level change scenario      
      UPDATE tmp SET dtServiceFrom =iIn.ServiceInstanceFromDate, ServiceInstanceID = iIn.ServiceInstanceID       
      FROM #TempResidentHistoryStatusOut tmp      
      JOIN #ServiceDateRange iIn ON (tmp.hResident = iIn.ResidentId       
               AND tmp.ServiceInstanceID < iIn.ServiceInstanceID       
               AND tmp.dtMoveIn < iIn.ServiceInstanceFromDate                                       
               AND ISNULL(tmp.dtMoveOut, @EndDefault) >= ISNULL( iIn.ServiceInstanceToDate, @EndDefault)               
               AND iIn.bMoveIn= 1 )      
     END      
      --Update dates for financial for Co-Occupants scenario      
     UPDATE tmp SET dtMoveOut = iOut.ServiceInstanceToDate, ServiceInstanceIDOut = iOut.ServiceInstanceID       
     FROM #TempResidentHistoryStatusOut tmp      
     JOIN #ServiceDateRange iOut ON (tmp.hResident = iOut.ResidentId       
                                      AND tmp.hResident = iOut.ResidentID       
              AND tmp.hResident = iOut.CoOccupantId      
              AND tmp.dtMoveIn <= iOut.ServiceInstanceFromDate                                       
              AND ISNULL(tmp.dtMoveOut, @EndDefault) = iOut.ServiceInstanceFromDate          
            )      
     INSERT INTO #ActMInoutRes (hProperty , hResident , srhhmy )      
     SELECT distinct s.PropertyId, s.ResidentId, 0      
     FROM #ServiceDateRange s      
     LEFT JOIN #ActMInoutRes a ON s.ResidentId = a.hResident --AND s.ServiceInstanceId = a.srhhmy      
     WHERE 1 = CASE @Type WHEN 'MoveOut' THEN s.bMoveOut WHEN 'MoveIn' THEN s.bMoveIn ELSE 0 END      
     AND a.hResident IS NULL      
     /*Code to gather detail data for actual MoveIn MoveOut Financial */      
     IF @Type = 'MoveOut'      
     BEGIN      
      INSERT INTO #ActResDet      
      SELECT DISTINCT      
       p.PropertyID phmy,      
       LTRIM(RTRIM(p.PropertyName))+ ' ('+LTRIM(RTRIM(p.PropertyCode))+')' propname ,      
       LTRIM(RTRIM(t.sLastName))+', '+LTRIM(RTRIM(t.sFirstName)) +' ('+ LTRIM(RTRIM(t.scode)) + ')' sResidentName ,      
       t.istatus,      
       t.hmyperson ThMy,      
       ISNULL(srh.dtmovein,t.dtMoveIn) moveindate,      
       u.hmy uhmy,      
       u.scode uscode,      
       ut.scode,      
       ut.sdesc,      
       iOut.PrivacyLevelCode privacylevel,       
       iOut.CareLevelCode carelevel,       
       iOut.ContractTypeCode ContTyp,      
       ISNULL(srh.dtNotice,t.dtnotice)  Noticedate,       
       ISNULL(srh.dtmoveout,t.dtmoveout) moveoutdate,       
       ISNULL(srh.iMoveOutReason,t.ireason) Moveoutreason,      
       ISNULL(srh.dtBillingEnd,'01/01/1900')BillingEndDate,      
       srh.dtMovein dMin      
       FROM tenant t      
       INNER JOIN #TempResidentHistoryStatusOut Srh ON Srh.hResident  = t.hmyperson      
       INNER JOIN #ActMInoutRes amr ON ( Srh.hResident =amr.hResident)      
       INNER JOIN #tmpProperty p ON (p.PropertyID = t.hproperty)      
       INNER JOIN #ServiceDateRange iOut ON (srh.ServiceInstanceIDOut = iOut.ServiceInstanceID AND iOut.bMoveOut = 1)       
       INNER JOIN Unit u ON u.hmy = ISNULL(iOut.UnitID,t.HUNIT)       
       INNER JOIN UnitType ut ON ut.hmy = u.hunittype      
       INNER JOIN #tmpCareLevel CrHnd ON CrHnd.ListOptionCode = iOut.CareLevelCode       
       INNER JOIN #tmpContractType ConHnd ON ConHnd.ListOptionCode = iOut.ContractTypeCode      
       INNER JOIN Senior_ListHandler(@ResStatus,'') StaHnd ON StaHnd.scode = cast(t.iStatus as varchar(20))      
      WHERE t.iStatus <> 6      
       AND ISNULL(srh.dtmoveout, @EndDefault) BETWEEN @BOMActual AND @srDat2      
       AND iOut.PrivacyLevelCode NOT IN ( SELECT CASE WHEN @SecResident = 'No' THEN secondaryprivacylevel ELSE '' END FROM SeniorPrivacyLevelMapping)      
              END      
     ELSE      
     BEGIN      
         --For Movein      
      INSERT INTO #ActResDet      
         SELECT DISTINCT      
      p.PropertyID phmy,      
      LTRIM(RTRIM(p.PropertyName))+ ' ('+LTRIM(RTRIM(p.PropertyCode))+')' propname ,      
      LTRIM(RTRIM(t.sLastName))+', '+LTRIM(RTRIM(t.sFirstName)) +' ('+ LTRIM(RTRIM(t.scode)) + ')' sResidentName ,      
      t.istatus,      
      t.hmyperson ThMy,      
      ISNULL(srh.dtmovein,t.dtMoveIn) moveindate,      
      u.hmy uhmy,      
      u.scode uscode,      
      ut.scode,      
      ut.sdesc,      
      iIn.PrivacyLevelCode privacylevel,       
      iIn.CareLevelCode carelevel,       
      iIn.ContractTypeCode ContTyp,      
      ISNULL(srh.dtNotice,t.dtnotice)  Noticedate,       
      ISNULL(srh.dtmoveout,t.dtmoveout) moveoutdate,       
      ISNULL(srh.iMoveOutReason,t.ireason) Moveoutreason,      
      ISNULL(srh.dtBillingEnd,'01/01/1900')BillingEndDate,      
      srh.dtMovein dMin      
      FROM tenant t      
      INNER JOIN #TempResidentHistoryStatusOut Srh ON Srh.hResident  = t.hmyperson      
      INNER JOIN #ActMInoutRes amr ON ( Srh.hResident =amr.hResident)      
      INNER JOIN #tmpProperty p ON (p.PropertyID = t.hproperty)      
      INNER JOIN #ServiceDateRange iIn ON (srh.ServiceInstanceId = iIn.ServiceInstanceID AND iIn.bMoveIn = 1)       
      INNER JOIN Unit u ON u.hmy = ISNULL(iIn.UnitID,t.HUNIT)       
      INNER JOIN UnitType ut ON ut.hmy = u.hunittype      
      INNER JOIN #tmpCareLevel CrHnd ON CrHnd.ListOptionCode = iIn.CareLevelCode       
      INNER JOIN #tmpContractType ConHnd ON ConHnd.ListOptionCode = iIn.ContractTypeCode      
      INNER JOIN Senior_ListHandler(@ResStatus,'') StaHnd ON StaHnd.scode = cast(t.iStatus as varchar(20))      
         WHERE t.iStatus <> 6      
      AND ISNULL(srh.dtServiceFrom, @EndDefault) BETWEEN @srDat1 AND @srDat2       
      AND iIn.PrivacyLevelCode NOT IN ( SELECT CASE WHEN @SecResident = 'No' THEN secondaryprivacylevel ELSE '' END FROM SeniorPrivacyLevelMapping)      
         AND 1 = CASE WHEN @sDat1 <> '01/01/1900' AND @sDat2 <> '01/01/2100' then       
          CASE WHEN srh.dtMoveIn BETWEEN  @sDat1 AND @sDat2 then 1      
               ELSE 0      
          END      
        ELSE 1 END      
     END      
    END      
       ELSE      
    BEGIN      
        /*Code to gather detail data for actual MoveIn MoveOut Physical */      
        INSERT INTO #ActResDet      
     SELECT DISTINCT      
      p.hmy phmy,      
      LTRIM(RTRIM(p.saddr1))+ ' ('+LTRIM(RTRIM(p.scode))+')' propname ,      
      LTRIM(RTRIM(t.sLastName))+', '+LTRIM(RTRIM(t.sFirstName)) +' ('+ LTRIM(RTRIM(t.scode)) + ')' sResidentName ,      
      t.istatus,      
      t.hmyperson ThMy,      
      ISNULL(srh.dtmovein,t.dtMoveIn) moveindate,      
      u.hmy uhmy,      
      u.scode uscode,      
      ut.scode,      
      ut.sdesc,      
      ISNULL(srh.sPrivacyLevelCode,sr.PrivacyLevelCode) privacylevel,       
      ISNULL(srh.sCareLevelCode,sr.CareLevelcode) carelevel,      
      srh.sContractTypeCode ContTyp,      
      ISNULL(srh.dtnotice,t.dtnotice)  Noticedate,       
      ISNULL(srh.dtmoveout,t.dtmoveout) moveoutdate,       
      ISNULL(srh.iMoveOutReason,t.ireason) Moveoutreason,      
      ISNULL(srh.dtBillingEnd,'01/01/1900')BillingEndDate,      
      srh.dtMovein dMin      
      FROM tenant t      
      INNER JOIN SeniorResidentHistoryStatus Srh ON Srh.hResident  = t.hmyperson      
         AND srh.hmy in (SELECT srhhmy FROM #ActMInoutRes amr WHERE Srh.hResident =amr.hResident)      
      INNER JOIN Property p on p.hmy =t.hproperty      
      INNER JOIN seniorresident sr ON t.hmyperson = sr.residentid       
      INNER JOIN unit u ON u.hmy = ISNULL(SRH.hunit,t.hunit)       
      INNER JOIN unittype ut ON ut.hmy = u.hunittype      
      INNER JOIN #tmpCareLevel CrHnd ON CrHnd.ListOptionCode = ISNULL(srh.sCareLevelCode,sr.CareLevelcode)      
      INNER JOIN #tmpContractType ConHnd ON ConHnd.ListOptionCode = srh.sContractTypeCode      
      LEFT JOIN Senior_ListHandler(@ResStatus,'') StaHnd ON StaHnd.scode = cast(t.iStatus as varchar(20))      
     WHERE t.iStatus <> 6      
      AND 1 = CASE WHEN @type ='MoveIn' and ISNULL(srh.iStatuscode,t.iStatus) IN (0,1,4,11) THEN 1      
          WHEN @type ='MoveOut' and ISNULL(srh.iStatuscode,t.iStatus) = 1 THEN 1      
          END      
      AND CASE WHEN @type ='MoveIn' THEN ISNULL(srh.dtmovein,t.dtMoveIn)      
         WHEN @type ='MoveOut' THEN ISNULL(srh.dtmoveout,t.dtmoveout)       
         END      
        BETWEEN @sDat1 AND @sDat2      
      AND 1 = CASE WHEN @type ='MoveIn'and StaHnd.scode is not null then 1      
          WHEN @type ='MoveOut' then 1      
        ELSE 0 END      
      AND ISNULL(srh.sPrivacyLevelCode,sr.PrivacyLevelCode) NOT IN ( SELECT CASE WHEN @SecResident = 'No' THEN secondaryprivacylevel ELSE '' END FROM SeniorPrivacyLevelMapping)      
    END      
    /*Code for Move In Actual*/       
    IF(@type ='MoveIn')      
    BEGIN      
     /*Final code for Move In Actual*/      
     SELECT DISTINCT ISNULL(LTRIM(RTRIM(av.sname)), '*None')  attribute,      
      ISNULL(LTRIM(RTRIM(av.svalue)), '*None') attrib,      
      d.phMy,      
      d.propname,      
      d.sResidentName,      
      d.istatus,      
      d.ThMy,      
      d.moveindate,       
      d.uhmy,      
      d.uscode,      
      d.utscode,      
      d.utsdesc,      
      d.privacylevel,       
      d.carelevel,      
      si.ServiceInstanceFromDate AS ServiceStartDate,      
      ISNULL(a.MarketRate,0) AS MarketRate,      
      ISNULL(si.ServiceInstanceAmount,0) AS AcutalRate,      
      ISNULL(Dpsts.Deposit ,0) AS Deposit      
      , d.ContTyp       
     FROM #ActResDet d      
      INNER JOIN #TempResidentHistoryStatusOut tmp ON tmp.hResident = d.thMy AND tmp.dtmovein = d.dMin      
      INNER JOIN #ServiceDateRange sii ON sii.Residentid = d.thMy AND sii.ServiceInstanceID = tmp.ServiceInstanceID AND sii.bMoveIn = 1 --???06/04/2021 performance???      
      INNER JOIN ServiceInstance si ON si.Residentid = d.thMy AND si.ServiceInstanceID = tmp.ServiceInstanceID  AND sii.Residentid = si.Residentid AND si.ServiceInstanceID = tmp.ServiceInstanceID --???06/04/2021 performance???      
      INNER JOIN SeniorRecurringCharge src ON src.ServiceInstanceID = si.ServiceInstanceID AND SRC.ResidentID = d.thMy       
      LEFT JOIN #Attribute av ON av.hprop = d.phmy        
        /*In multiple Move in scenario, each movein will get respective deposit amount*/      
      LEFT JOIN (SELECT DISTINCT actde.phmy phmy, actde.ThMy hmyperson,tmp1.dtMovein,SUM(ISNULL(D.SAMOUNT,0)) AS Deposit      
            FROM #ActResDet actde      
          INNER JOIN Trans T    ON T.Hperson = actde.ThMy AND T.ITYpe = 6 AND CONVERT(DATETIME,CONVERT(CHAR(10),T.SDateOccurred ,121),101) <= @DpDate              
          INNER JOIN Detail D   ON D.Hinvorrec = T.HMY                
          INNER JOIN Acct Act   ON Act.HMY = D.Hacct                  
          INNER JOIN param pm ON pm.hchart=act.hchart AND act.hmy IN (pm.hdeposit,pm.hdeposit1,pm.hdeposit2,pm.hdeposit2,pm.hdeposit3,pm.hdeposit4,pm.hdeposit5,pm.hdeposit6,pm.hdeposit7,pm.hdeposit8,pm.hdeposit9)      
          Inner JOIN #TempResidentHistoryStatusOut tmp1 ON tmp1.hResident = actde.ThMy      
          LEFT JOIN #TempResidentHistoryStatusOut tmp ON tmp.hResident = actde.ThMy AND tmp.ID = tmp1.ID-1      
         WHERE @DispRate='Yes' AND actde.dMin = tmp1.dtMovein      
          AND CONVERT(DATETIME,CONVERT(CHAR(10),T.SDateOccurred ,121),101) >= ISNULL(tmp.dtMoveout,'01/01/1900')       
          AND CONVERT(DATETIME,CONVERT(CHAR(10),T.SDateOccurred ,121),101) <= ISNULL(tmp1.dtMoveout,'01/01/2100')      
         GROUP BY actde.phmy,actde.ThMy,tmp1.dtMovein      
         ) Dpsts ON Dpsts.phmy=d.phmy AND Dpsts.hmyperson=si.ResidentID AND Dpsts.dtMovein = tmp.dtmovein      
      OUTER APPLY ( SELECT cast(SUM(ISNULL(srt.ChargeTypeAmount,0)) +       
           CASE WHEN si.RateTypeCode = 'MLY' THEN ISNULL(sur.UnitRentMonthlyAmount,0)       
            ELSE ISNULL(sur.UnitRentDailyAmount,0) END  as NUMERIC(18,2) ) MarketRate      
          From seniorUnitRent sur       
           LEFT JOIN servicerate srt ON srt.ServiceID = si.ServiceID AND Src.ChargeTypeID = srt.ChargeTypeID AND srt.PropertyID = d.phmy        
           WHERE @DispRate='Yes' AND sur.unitid = si.UnitID AND sur.PrivacyLevelCode = si.PrivacyLevelCode      
          Group BY sur.UnitRentMonthlyAmount, sur.UnitRentDailyAmount      
         ) a      
    END        
    /* Final Code for Move OUT Actual*/      
    IF(@type ='MoveOut')      
    BEGIN      
     SELECT DISTINCT      
      d.phMy,      
      d.propname ,      
      d.sResidentName ,      
      d.istatus,      
      d.ThMy,      
      d.moveindate,      
      d.Noticedate,       
      d.moveoutdate,       
      d.uhmy,      
      d.uscode,      
      d.utscode,      
      d.utsdesc,      
      d.privacylevel,       
      d.carelevel,      
      d.Moveoutreason,      
      d.BillingEndDate,      
      d.ContTyp      
     FROM #ActResDet d      
    END      
   END      
   /*Final code for Movein & MoveOut Scheduled Unit Transfer */       
   IF(@sStatus = 'Scheduled Unit Transfer')      
   BEGIN      
       IF OBJECT_ID ('TempDb..#DetSchedUntTransf') IS NOT NULL      
                DROP TABLE #DetSchedUntTransf      
    CREATE TABLE #DetSchedUntTransf (      
     phmy NUMERIC,      
     propname VARCHAR (300),      
     sResidentName VARCHAR (600),      
     istatus NUMERIC(18,0),      
     ThMy NUMERIC(18,0),      
     mdate DATETIME ,      
     uhmy NUMERIC,      
     uscode VARCHAR (8),      
     utscode VARCHAR (8),      
     utsdesc VARCHAR (40),      
     privacylevel VARCHAR (20),      
     carelevel VARCHAR (20),      
     ServiceStartDate DATETIME ,      
     ListOptionName VARCHAR (20),      
     pHcountry NUMERIC,      
     SRUhunit NUMERIC,      
     SRUPrivcode VARCHAR (3),      
     Moveoutreason VARCHAR (300),      
     BillingEndDate DATETIME,      
     dtmovein DATETIME)      
    /* Code common for Move in move Out Scheduled Unit Transfer*/      
    INSERT INTO #DetSchedUntTransf      
    SELECT DISTINCT p.hmy phmy,      
     LTRIM(RTRIM(p.saddr1))+ ' ('+LTRIM(RTRIM(p.scode))+')' propname ,      
     LTRIM(RTRIM(t.sLastName))+', '+LTRIM(RTRIM(t.sFirstName)) +' ('+ LTRIM(RTRIM(t.scode)) + ')' sResidentName ,      
     t.istatus,       
     t.hmyperson ThMy,      
     SRU.dtEFfective mdate,       
     u.hmy uhmy,      
     u.scode,      
     ut.scode,      
     ut.sdesc,      
     SRU.sPrivacyCode privacylevel,       
     SRU.sCarelevelCode carelevel,       
     SRU.dtEffective AS ServiceStartDate,      
     sr.ContractTypeCode ListOptionName,      
     P.Hcountry pHcountry,SRU.hUnit SRUhunit ,SRU.sPrivacyCode SRUPrivcode,      
     0 Moveoutreason,      
     ISNULL(sr.residentBillingEndDate,'01/01/1900')BillingEndDate,      
     t.dtmovein      
    FROM #tmpProperty x          
     INNER JOIN Property p ON LTRIM(RTRIM(x.PropertyCode)) = LTRIM(RTRIM(p.sCode))       
     INNER JOIN ListProp2 l ON l.hProplist = p.hmy AND l.iType <> 11      
     INNER JOIN tenant t ON t.hproperty = p.hmy       
     INNER JOIN SeniorReserveUnit SRU ON SRU.hTenant = t.hmyperson       
     INNER JOIN SeniorResidentStatus srs ON (srs.iStatus = t.iStatus)      
     INNER JOIN seniorresident sr ON t.hmyperson = sr.residentid       
     INNER JOIN unit u ON u.hmy = SRU.hUnit      
     INNER JOIN unittype ut ON ut.hmy = u.hunittype      
     INNER JOIN #tmpCareLevel CrHnd ON CrHnd.ListOptionCode = SRU.sCarelevelCode      
     INNER JOIN #tmpContractType ConHnd ON ConHnd.ListOptionCode = sr.ContractTypeCode      
     INNER JOIN Senior_ListHandler(@ResStatus,'') StaHnd ON StaHnd.scode = cast(t.iStatus as varchar(20))      
    WHERE SRU.dtEFfective BETWEEN @srDat1 AND @srDat2      
     AND t.iStatus <> 6      
     AND SRU.bActive = -1      
     AND ISNULL(SRU.bComplete,0)=0      
     AND 1 = CASE WHEN @type ='MoveIn' AND StaHnd.scode IS NULL THEN 0 ELSE 1 END      
     AND sr.PrivacyLevelCode NOT IN (SELECT CASE WHEN @SecResident = 'No' THEN secondaryprivacylevel ELSE '' END FROM SeniorPrivacyLevelMapping where @type ='MoveIn')      
    /* Code for Move In Scheduled Unit Transfer*/      
    IF(@type ='MoveIn')      
     SELECT DISTINCT ISNULL(LTRIM(RTRIM(av.sname)), '*None')  attribute,      
      ISNULL(LTRIM(RTRIM(av.svalue)), '*None') attrib,      
      stransf.phmy,      
      stransf.propname,      
      stransf.sResidentName,      
      stransf.istatus,       
      stransf.ThMy,       
      stransf.mdate,       
      stransf.uhmy,      
      stransf.uscode,      
      stransf.utscode,      
      stransf.utsdesc,      
      stransf.privacylevel,       
      stransf.carelevel,       
      stransf.ServiceStartDate,      
      cast(ISNULL(sur.UnitRentMonthlyAmount,0) as NUMERIC(18,2))  AS MarketRate,      
      0.00 AS AcutalRate,      
      ISNULL(a.depo,0) AS Deposit       
      , stransf.ListOptionName      
     FROM #DetSchedUntTransf stransf      
      LEFT JOIN seniorUnitRent sur ON sur.unitid = stransf.SRUhUnit AND sur.PrivacyLevelCode = stransf.SRUPrivCode      
      LEFT JOIN #Attribute av ON av.hprop = phmy      
      OUTER APPLY (SELECT SUM(ISNULL(D.SAMOUNT,0)) depo      
            FROM Trans T          
          INNER JOIN Detail D ON D.Hinvorrec = T.HMY                  
          INNER JOIN Acct Act ON Act.HMY     = D.Hacct                  
          INNER JOIN param pm ON pm.hchart=act.hchart AND act.hmy IN (pm.hdeposit,pm.hdeposit1,pm.hdeposit2,pm.hdeposit2,pm.hdeposit3,pm.hdeposit4,pm.hdeposit5,pm.hdeposit6,pm.hdeposit7,pm.hdeposit8,pm.hdeposit9)      
          INNER JOIN SeniorReserveUnit SRU ON T.Hperson =sru.hTenant AND SRU.bActive = -1 AND ISNULL(SRU.bComplete,0) = 0      
         WHERE @DispRate='Yes' AND SRU.dtEFfective BETWEEN @sDat1 AND @sDat2      
          AND T.Hperson = stransf.ThMy AND T.ITYpe = 6 AND CONVERT(DATETIME,CONVERT(CHAR(10),T.SDateOccurred ,121),101) <= @DpDate         
         GROUP BY T.Hperson)a      
    /* Code for Move Out Scheduled Unit Transfer*/      
    IF(@type ='MoveOut')      
     SELECT DISTINCT      
      stransf.phmy,      
      stransf.propname ,      
      stransf.sResidentName ,      
      stransf.istatus,      
      stransf.ThMy,      
      stransf.mdate,      
      '01/01/1900' Noticedate,       
      '01/01/1900' moveoutdate,       
      stransf.uhmy,       
      stransf.uscode,      
      stransf.utscode,      
      stransf.utsdesc,      
      stransf.privacylevel,       
      stransf.carelevel,       
      stransf.Moveoutreason,      
      stransf.BillingEndDate,      
      stransf.ListOptionName      
     FROM #DetSchedUntTransf stransf         
   END      
   /*Final code for Movein & MoveOut Scheduled */      
   IF(@sStatus = 'Scheduled')      
   BEGIN        
    /*Common code required for Movein & MoveOUT Scheduled*/       
    IF OBJECT_ID ('TempDb..#SchedTenant') IS NOT NULL      
                DROP TABLE #SchedTenant      
    CREATE TABLE #SchedTenant(      
       hmy NUMERIC,      
       hmyperson NUMERIC      
      )      
    /* Code will list residents for MoveIn OR MoveOut,      
     Code optimizes reads as selective residents are passed to detail query*/      
    INSERT INTO #SchedTenant      
     SELECT p.hmy ,T.hmyperson      
     FROM #tmpProperty x          
      INNER JOIN Property p ON LTRIM(RTRIM(x.PropertyCode)) = LTRIM(RTRIM(p.sCode))       
      INNER JOIN ListProp2 l ON l.hProplist = p.hmy AND l.iType <> 11       
      INNER JOIN tenant t ON t.hproperty = p.hmy      
     WHERE CASE WHEN @type ='MoveOut' THEN t.dtmoveout       
           WHEN @type ='MoveIn' THEN t.dtmovein END       
       BETWEEN  @sDat1 AND  @sDat2      
     AND 1 = CASE WHEN @type ='MoveOut' AND t.iStatus NOT IN (2,8,6,7,9,1) THEN 1      
         WHEN @type ='MoveIn' AND t.istatus IN (8,2) THEN 1      
       ELSE 0 END      
       IF OBJECT_ID ('TempDb..#DetSchedul') IS NOT NULL      
                DROP TABLE #DetSchedul      
    CREATE TABLE #DetSchedul(      
       pHMY NUMERIC,      
       propname VARCHAR (300),      
       sResidentName VARCHAR (600),      
        istatus  Numeric,      
        ThMy  int,      
        moveindate  datetime,      
        Noticedate  datetime,      
        moveoutdate  datetime,      
        uhmy  NUMERIC,      
       uscode VARCHAR (8),      
       utscode VARCHAR (8),      
       utsdesc VARCHAR (40),      
        privacylevel  Varchar(20),      
        carelevel  Varchar(20),      
        Moveoutreason  Varchar(250),      
        BillingEndDate  datetime,      
        ContTyp  Varchar(20)      
      )      
    /*Code to gather detail data for Scheduled MoveIn MoveOut*/      
    Insert into #DetSchedul      
     SELECT DISTINCT      
      p.hmy pHMY,          
      LTRIM(RTRIM(p.saddr1))+ ' ('+LTRIM(RTRIM(p.scode))+')' propname ,      
      LTRIM(RTRIM(t.sLastName))+', '+LTRIM(RTRIM(t.sFirstName)) +' ('+ LTRIM(RTRIM(t.scode)) + ')' sResidentName ,      
      t.istatus,      
      t.hmyperson ThMy,      
      t.dtmovein moveindate,      
      t.dtnotice Noticedate,       
      t.dtmoveout moveoutdate,       
      u.hmy uhmy,      
      u.scode,      
      ut.scode,      
      ut.SDESC,      
      sr.PrivacyLevelCode privacylevel,       
      sr.CareLevelcode carelevel,       
      t.ireason  Moveoutreason,      
      ISNULL(sr.residentBillingEndDate,'01/01/1900')BillingEndDate,      
      sr.ContractTypeCode ContTyp      
     FROM #SchedTenant ten      
      INNER JOIN tenant t ON t.hmyperson = ten.hmyperson      
      INNER JOIN Property p on p.hmy =t.HPROPERTY      
      INNER JOIN seniorresident sr ON t.hmyperson = sr.residentid       
      INNER JOIN unit u ON u.hmy = t.hunit      
      INNER JOIN unittype ut ON ut.hmy = u.hunittype      
      INNER JOIN #tmpCareLevel CrHnd ON CrHnd.ListOptionCode=sr.CareLevelcode      
      INNER JOIN #tmpContractType ConHnd ON ConHnd.ListOptionCode = sr.ContractTypeCode      
     WHERE sr.PrivacyLevelCode NOT IN ( SELECT CASE WHEN @SecResident = 'No' THEN secondaryprivacylevel ELSE '' END FROM SeniorPrivacyLevelMapping)      
    /*Final Code for Move In Scheduled*/      
    IF(@type ='MoveIn')      
    BEGIN      
     SELECT DISTINCT ISNULL(LTRIM(RTRIM(av.sname)), '*None')  attribute,      
      ISNULL(LTRIM(RTRIM(av.svalue)), '*None') attrib,      
      d.pHmy,      
      d.propname,      
      d.sResidentName,      
      istatus,      
      ThMy,      
      moveindate,          
      uhmy,       
      uscode,      
      utscode,      
      utsdesc,      
      privacylevel,       
      carelevel,      
      si.ServiceInstanceFromDate AS ServiceStartDate,       
      ISNULL(a.MarketRate,0) AS MarketRate,      
      ISNULL(si.ServiceInstanceAmount,0) AS AcutalRate,      
      ISNULL(b.depo,0)  AS Deposit      
      , ContTyp      
     FROM #DetSchedul d           
      INNER JOIN Senior_ListHandler(@ResStatus,'') StaHnd ON StaHnd.scode = cast(d.istatus as varchar(20))      
      LEFT JOIN #Attribute av ON av.hprop = d.phmy      
      LEFT JOIN serviceinstance si ON si.Residentid = d.ThMy       
              AND si.serviceinstanceID = (SELECT MIN(si3.serviceinstanceid)      
                     FROM serviceinstance si3      
                      INNER JOIN service s1 ON si3.serviceid = s1.serviceid AND s1.serviceclassid = 1      
                     WHERE si3.ServiceInstanceActiveFlag <> 0      
                      AND si3.ServiceInstanceFromDate BETWEEN @srDat1 AND @srDat2      
                      AND ISNULL(si3.serviceinstancetodate,si3.serviceinstancefromdate) >= si3.serviceinstancefromdate      
                      AND si3.residentid =d.ThMy      
                     GROUP BY si3.residentid)      
      OUTER APPLY( SELECT cast(SUM(ISNULL(srt.ChargeTypeAmount,0)) +       
          CASE WHEN si.RateTypeCode = 'MLY' THEN ISNULL(sur.UnitRentMonthlyAmount,0)       
           ELSE  ISNULL(sur.UnitRentDailyAmount,0) END as NUMERIC(18,2)) MarketRate      
          FROM seniorrecurringcharge src       
           LEFT JOIN seniorUnitRent sur ON sur.unitid = si.UnitID AND sur.PrivacyLevelCode = si.PrivacyLevelCode      
           LEFT JOIN servicerate srt ON srt.ServiceID = si.ServiceID AND Src.ChargeTypeID = srt.ChargeTypeID AND srt.PropertyID = d.pHmy      
          WHERE @DispRate='Yes' AND src.ServiceInstanceID = si.ServiceInstanceID AND SRC.ResidentID = d.ThMy      
          GROUP BY sur.UnitRentMonthlyAmount, sur.UnitRentDailyAmount      
          )a      
      OUTER APPLY( SELECT SUM(ISNULL(Det.SAMOUNT,0)) depo      
            FROM Trans T           
          INNER JOIN Detail Det ON Det.Hinvorrec = T.HMY                  
          INNER JOIN Acct Act ON Act.HMY = Det.Hacct                  
          INNER JOIN param pm ON pm.hchart=act.hchart AND act.hmy IN (pm.hdeposit,pm.hdeposit1,pm.hdeposit2,pm.hdeposit2,pm.hdeposit3,pm.hdeposit4,pm.hdeposit5,pm.hdeposit6,pm.hdeposit7,pm.hdeposit8,pm.hdeposit9)      
         WHERE @DispRate='Yes' AND T.Hperson = d.ThMy AND T.ITYpe = 6 AND CONVERT(DATETIME,CONVERT(CHAR(10),T.SDateOccurred ,121),101) <= @DpDate       
         GROUP BY T.Hperson)b      
    END      
    /*Final Code for Move OUT Scheduled*/      
    IF(@type ='MoveOut')      
    SELECT DISTINCT      
      phmy,      
      propname ,      
      sResidentName ,      
      istatus,      
      ThMy,      
      moveindate,      
      Noticedate,       
      moveoutdate,      
      uhmy,      
      uscode,      
      utscode,      
      utsdesc,      
      privacylevel,       
      carelevel,       
      Moveoutreason,      
      BillingEndDate,      
      ContTyp      
    FROM #DetSchedul d       
   END       
  END  
    
  --DROP PROCEDURE SeniorMoveInMoveOutDetailFinancial