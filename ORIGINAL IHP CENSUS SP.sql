  CREATE PROCEDURE [dbo].[SeniorIHPPortfolioCensusReport ]                                                             
  (      
       @hprop               AS VARCHAR(6000)        
      ,@BOM                 AS DATETIME        
      ,@EOM                 AS DATETIME        
      ,@flag                AS INTEGER        
      ,@ShowSeccondResident CHAR(3)      
   ,@IncludeMoveOutDate  CHAR(3)    
      ,@CareLevel           VARCHAR(1000)    
   ,@AdditionalUnit CHAR(3)  
  )    
  AS BEGIN    
  DECLARE @BegDefault DATETIME,    
          @EndDefault DATETIME,    
    @BOMActual  DATETIME;    
  SET @BegDefault = '01/01/1900';    
  SET @EndDefault = '12/31/2200';    
  SET @BOMActual  = @BOM    
  SET @BOM        = DATEADD(dd, -1, @BOMActual)    
  SET @IncludeMoveOutDate = 'Yes'    
    IF OBJECT_ID('tempdb..#tmpProperty') IS NOT NULL DROP TABLE #tmpProperty    
   IF OBJECT_ID('tempdb..#tmpCareLevel') IS NOT NULL DROP TABLE #tmpCareLevel    
    IF OBJECT_ID('tempdb..#ResidentHistoryStatusAdditionalUnit') IS NOT NULL DROP TABLE #residenthistorystatusadditionalunit    
    IF OBJECT_ID('tempdb..#ServiceInstanceAdditionalUnit') IS NOT NULL DROP TABLE #ServiceInstanceadditionalunit    
    IF OBJECT_ID('tempdb..#tmpOccupancyDetail') IS NOT NULL DROP TABLE #tmpOccupancyDetail    
    IF OBJECT_ID('tempdb..#tmpOccupancy') IS NOT NULL DROP TABLE #tmpOccupancy    
    IF OBJECT_ID('tempdb..#TempTbl') IS NOT NULL DROP TABLE #TempTbl    
    IF OBJECT_ID('tempdb..#tempRowNum') IS NOT NULL DROP TABLE #tempRowNum     
    IF OBJECT_ID('tempdb..#tmpPrivacyListOptionValue') IS NOT NULL DROP TABLE #tmpPrivacyListOptionValue    
  CREATE TABLE #tmpPrivacyListOptionValue(    
      ListName varchar(50),    
      ListOptionCode varchar(50),    
      ListColumnID numeric(18,0),    
      ListOptionValue varchar(200)    
  )    
  INSERT INTO #tmpPrivacyListOptionValue    
  SELECT lv.ListName, lv.ListOptionCode, lv.ListColumnID,     
      CASE WHEN lv.ListOptionCode in ('SEC') THEN 1    
      WHEN lv.ListOptionCode in ('DAS','DBS') THEN 0.5    
      WHEN lv.ListOptionCode in ('TAS','TBS','TCS') THEN 0.333    
      WHEN lv.ListOptionCode in ('QAS','QBS','QCS','QDS') THEN 0.25      
     ELSE lv.ListOptionValue    
         END    
  FROM ListOptionValue Lv WHERE Lv.listname = 'PrivacyLevel'    
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
  FROM   dbo.Senior_listhandler(@hprop , 'hmy') pr     
  INNER JOIN Property p  ON (p.HMY = pr.hmy)     
  CREATE TABLE #tmpCareLevel    
  (     
       hmy     NUMERIC,     
       ListOptionCode   VARCHAR(8),     
       ListOptionName  VARCHAR(300)    
  )    
  IF LTRIM(RTRIM(@CareLevel)) <> ''    
  BEGIN    
  INSERT INTO #tmpCareLevel     
  SELECT DISTINCT lp.hmy                  hmy,     
                  lp.ListOptionCode       ListOptionCode,     
                  lp.ListOptionName  ListOptionName    
  FROM   dbo.Senior_listhandler(@CareLevel, 'hmy') lr     
  INNER JOIN ListOption lp ON lr.hmy = lp.hmy    
  WHERE lp.listname = 'CareLevel'     
  --AND ISNULL(lp.listoptionActiveFlag,1) <> 0     
  END    
  ELSE    
  BEGIN    
  INSERT INTO #tmpCareLevel    
  SELECT DISTINCT lp.hmy                  hmy,     
                  lp.ListOptionCode       sCode,     
                  lp.ListOptionName  sName    
  FROM listoption lp     
  WHERE lp.listname = 'CareLevel'     
  --AND ISNULL(lp.listoptionActiveFlag,1) <> 0     
  END    
  IF OBJECT_ID ('TempDb..#tmpTenant') IS NOT NULL    
      DROP TABLE #tmpTenant    
  CREATE TABLE #tmpTenant    
  (    
          hProperty NUMERIC,    
    hUnit     NUMERIC,    
    hmyPerson NUMERIC,    
          dtMoveIn DATETIME,    
          dtMoveOut DATETIME,    
    CareLevelCodeMin VARCHAR(3),        CareLevelCodeOut VARCHAR(3),    
    PrivacyLevelCode VARCHAR(3),    
          MoveInStatus INTEGER,    
          MoutStatus INTEGER,    
          MoveInResidentHistoryID INTEGER,    
          MoveOutResidentHistoryID INTEGER    
  )    
  IF OBJECT_ID('TempDb..#ResidentHistory') IS NOT NULL    
      DROP TABLE #ResidentHistory   CREATE TABLE #ResidentHistory (    
      ResidentHistoryID NUMERIC(18,0) NOT NULL,    
     hProperty           NUMERIC(18, 0)  NOT NULL,    
      ResidentId   NUMERIC(18, 0)  NOT NULL,    
     ResidentHistoryCode VARCHAR(3),    
     PrivacyLevelCode    VARCHAR(3),    
     UnitId              NUMERIC(18,0),    
     CareLevelCode       VARCHAR(3),    
     ContractTypeCode    VARCHAR(3),    
     ResidentStatusCode  SMALLINT,    
     ResidentHistoryDate DATETIME    
  )    
  IF OBJECT_ID('TempDb..#ResidentHistoryStatus') IS NOT NULL    
      DROP TABLE #ResidentHistoryStatus    
  CREATE TABLE #ResidentHistoryStatus (    
      historyID   NUMERIC(18,0) NOT NULL,    
     hProperty           NUMERIC(18, 0)  NOT NULL,    
      hResident   NUMERIC(18, 0)  NOT NULL,    
     PrivacyLevelCode    VARCHAR(3),    
     UnitId              NUMERIC(18,0),    
     CareLevelCode       VARCHAR(3),    
     ContractTypeCode    VARCHAR(3),    
     iStatusCode         SMALLINT,    
     dtFrom              DATETIME,    
     dtTo                DATETIME,    
     dtMoveIn            DATETIME,    
     dtMoveOut           DATETIME,    
     RemoveFlag          SMALLINT,    
     bMoveIn             SMALLINT,    
     bMoveOut            SMALLINT,    
     CoOccupantId        NUMERIC(18, 0)    
  )    
  INSERT INTO #ResidentHistory (    
      ResidentHistoryID,       
     hProperty  ,    
      ResidentId ,    
     ResidentHistoryCode,    
     PrivacyLevelCode ,    
     UnitId        ,    
     CareLevelCode   ,    
     ContractTypeCode ,    
     ResidentStatusCode  ,    
     ResidentHistoryDate)    
      SELECT  srh1.ResidentHistoryID,    
           p.PropertyID,    
     t.HMYPERSON,    
     srh1.ResidentHistoryCode,    
     RTRIM(srh1.PrivacyLevelCode),    
     srh1.UnitID,    
     RTRIM(srh1.CareLevelCode),    
     RTRIM(srh1.ContractTypeCode),    
     srh1.ResidentStatusCode,    
     CONVERT( DATETIME, CONVERT(VARCHAR(11), srh1.ResidentHistoryDate), 101 )     
   FROM #tmpProperty P      
   JOIN    Tenant t ON (p.PropertyID = t.HPROPERTY)    
   INNER JOIN SeniorResidentHistory srh1 ON (t.HMYPERSON = srh1.ResidentId)     
      INNER JOIN #tmpCareLevel lc ON (RTRIM(srh1.CareLevelCode) = lc.ListOptionCode)    
   WHERE  srh1.ResidentStatusCode IN (0,1,4,11)     
   AND srh1.ResidentHistoryCode in ('AUN', 'MIN', 'QIK','CMO','OUT','CVT')    
   AND ISNULL(srh1.ResidentHistoryCancelFlag, 0) = 0     
  INSERT INTO #ResidentHistoryStatus    
   SELECT srh1.hmy,    
           srh1.hProperty,    
     srh1.hResident,     
     RTRIM(srh1.sPrivacyLevelCode),     
     srh1.hunit,    
     RTRIM(srh1.sCarelevelcode),    
     RTRIM(srh1.sContractTypeCode),    
     srh1.iStatusCode,    
     CONVERT( DATETIME, CONVERT(VARCHAR(11), srh1.dtFrom), 101 ) ,    
     CONVERT( DATETIME, CONVERT(VARCHAR(11), srh1.dtTo), 101 ),    
     CONVERT( DATETIME, CONVERT(VARCHAR(11), srh1.dtMoveIn), 101 ),    
     CONVERT( DATETIME, CONVERT(VARCHAR(11), srh1.dtMoveOut), 101 ),    
     0,    
     0,    
     0,    
     NULL    
   FROM #tmpProperty P        
   INNER JOIN SeniorResidentHistoryStatus srh1 ON ( p.PropertyID = srh1.hProperty)     
      INNER JOIN #tmpCareLevel lc ON (RTRIM(srh1.sCareLevelCode) = lc.ListOptionCode)     
   WHERE  srh1.iStatusCode IN (0, 4, 11)    
   AND CONVERT( DATETIME, CONVERT(VARCHAR(11), srh1.dtFrom), 101 ) <= ISNULL(CONVERT( DATETIME, CONVERT(VARCHAR(11), srh1.dtTo), 101 ) , CONVERT( DATETIME, CONVERT(VARCHAR(11), srh1.dtFrom), 101 ) )      
   AND CONVERT( DATETIME, CONVERT(VARCHAR(11), srh1.dtFrom), 101 ) <= @EOM    
   AND ISNULL(CONVERT( DATETIME, CONVERT(VARCHAR(11), srh1.dtTo), 101 ) , @EndDefault) >= @BOM    
  --03/16/2021 try to get CoOccupantId    
   UPDATE s SET s.CoOccupantId = sr.hCoOccupant    
   FROM #ResidentHistoryStatus s    
   JOIN SeniorResident sr ON (s.hResident = sr.ResidentId)    
   WHERE 1 = 1    
   UPDATE ss SET ss.hResident = ss.CoOccupantId    
   FROM #ResidentHistoryStatus s    
   JOIN #ResidentHistoryStatus ss ON (s.hResident = ss.CoOccupantId AND s.UnitId = ss.UnitId    
                                 AND ss.PrivacyLevelCode IN (SELECT SecondaryPrivacyLevel FROM SeniorPrivacyLevelMapping))    
   WHERE 1 = 1    
   UPDATE s SET s.hResident = ss.CoOccupantId    
   FROM #ResidentHistoryStatus s    
   JOIN #ResidentHistoryStatus ss ON ( s.UnitId = ss.UnitId AND s.CoOccupantId = ss.CoOccupantId                         
                                 AND ss.PrivacyLevelCode IN (SELECT SecondaryPrivacyLevel FROM SeniorPrivacyLevelMapping)    
            AND s.PrivacyLevelCode NOT IN (SELECT SecondaryPrivacyLevel FROM SeniorPrivacyLevelMapping))    
   WHERE 1 = 1    
   DELETE ss     
   FROM #ResidentHistoryStatus s    
   JOIN #ResidentHistoryStatus ss ON (s.hresident = ss.hResident AND s.UnitId = ss.UnitId AND ss.CoOccupantId = s.hResident    
                                 AND s.dtTo IS NOT NULL    
            AND ss.dtto IS NOT NULL    
                                 AND s.dtto = ss.dtTo    
                                 AND ss.PrivacyLevelCode IN (SELECT SecondaryPrivacyLevel FROM SeniorPrivacyLevelMapping)    
            AND s.PrivacyLevelCode NOT IN (SELECT SecondaryPrivacyLevel FROM SeniorPrivacyLevelMapping))    
   WHERE 1 = 1    
   --Delete secondary privacy levels if the @ShowSeccondResident parameter is not set to 'yes' --???03/03/2021    
   IF @ShowSeccondResident <> 'yes'    
   BEGIN    
    DELETE FROM #ResidentHistoryStatus    
    WHERE PrivacyLevelCode IN (    
     SELECT SecondaryPrivacyLevel    
     FROM SeniorPrivacyLevelMapping    
    )    
   END    
   --Correct multi rows    
   UPDATE sd    
   SET sd.RemoveFlag=1, sd.bMoveOut = 1    
   FROM #ResidentHistoryStatus sd    
   INNER JOIN #ResidentHistoryStatus sd1 ON sd.hresident=sd1.hresident    
                                     AND sd.unitid=sd1.unitid     
             AND sd.PrivacyLevelCode=sd1.PrivacyLevelCode     
                                    --AND sd.CareLevelCode = sd1.CareLevelCode AND sd.ServiceID = sd1.ServiceID    
                                     AND sd.dtFrom = DATEADD(dd,1,sd1.dtTo)    
  UPDATE sd    
  SET    sd.RemoveFlag = 2, sd.bMoveOut = 1    
  FROM   #ResidentHistoryStatus sd    
         INNER JOIN #ResidentHistoryStatus sd1    
                 ON sd.hResident = sd1.hResident    
                    AND sd.unitid = sd1.unitid    
                    AND sd.PrivacyLevelCode = sd1.PrivacyLevelCode    
                    --AND sd.CareLevelCode = sd1.CareLevelCode    
                    AND sd.dtFrom = DATEADD(dd, 1, sd1.dtTo)     
  WHERE ISNULL(sd.RemoveFlag,0) in (1, 0) AND ISNULL(sd1.RemoveFlag,0) = 1     
  UPDATE sd    
    SET  sd.bMoveIn = 1    
   FROM #ResidentHistoryStatus sd    
   WHERE ISNULL(sd.RemoveFlag,0) = 0    
   AND  sd.dtFrom BETWEEN @BOMActual AND @EOM    
  UPDATE sd    
    SET  sd.bMoveOut = 1    
   FROM #ResidentHistoryStatus sd    
   LEFT JOIN #ResidentHistoryStatus sd1 ON sd.hResident = sd1.hresident    
                    AND sd.unitid = sd1.unitid    
                    AND sd.PrivacyLevelCode = sd1.PrivacyLevelCode    
        AND ISNULL(sd1.RemoveFlag, 0) = 1    
    WHERE ISNULL(sd.RemoveFlag,0) = 0    
    AND sd1.hResident IS NULL    
  UPDATE sd    
    SET  sd.bMoveOut = 0    
   FROM #ResidentHistoryStatus sd    
   LEFT JOIN #ResidentHistoryStatus sd1 ON sd.hResident = sd1.hresident    
                    AND sd.unitid = sd1.unitid    
                    AND sd.PrivacyLevelCode = sd1.PrivacyLevelCode    
        AND ISNULL(sd1.RemoveFlag, 0) = 2    
    WHERE ISNULL(sd.RemoveFlag,0) = 1    
    AND sd1.hResident IS NOT NULL    
  UPDATE sd    
    SET  sd.bMoveOut = 0    
  FROM #ResidentHistoryStatus sd    
  WHERE ISNULL(sd.dtTo, @EndDefault) > CASE @IncludeMoveOutDate WHEN 'No' THEN @EOM ELSE DATEADD(dd, 1,  @EOM) END    
  AND sd.bMoveOut = 1    
   /* table for  additional units*/    
  CREATE TABLE #ResidentHistoryStatusAdditionalUnit (     
        [historyId] [NUMERIC](18, 0) NOT NULL,     
        [hResident] [NUMERIC](18, 0) NOT NULL,     
        dtStartdate DATETIME,     
        dtEnddate   DATETIME,    
        UnitId      NUMERIC ,    
        PrivacyLevelCode  VARCHAR(3),    
     CareLevelCode  VARCHAR(3)    
  )     
   /* table for recurring charges of additional units*/         
  CREATE TABLE #ServiceInstanceAdditionalUnit (     
       ID Numeric Identity,    
      hAdditionalUnit         NUMERIC(18, 0),     
       Residentid              NUMERIC(18, 0),     
      UnitID         NUMERIC,    
       Recurringchargefromdate DATETIME,     
       Recurringchargetodate   DATETIME,    
     PrivacyLevelCode   VARCHAR(3),    
     ContractTypeCode   VARCHAR(3),    
     CareLevelCode     VARCHAR(3),    
     iStatus     INT,    
     bEliminate     INT,    
     RowNum      INT,    
     RowNum2                 INT    
  )   
  If @AdditionalUnit='Yes'  
  Begin  
   INSERT INTO #ResidentHistoryStatusAdditionalUnit    
   SELECT sau.hmy,     
          sau.hTenant,    
          CONVERT(DATETIME, CONVERT(VARCHAR(11), sau.dtstart), 101) ,    
          CONVERT(DATETIME, CONVERT(VARCHAR(11), sau.dtend), 101),    
          sau.hunit,    
          sau.sPrivacyLevelCode,    
    ''    
   FROM   #tmpProperty P    
   INNER JOIN TENANT t on t.hproperty = P.Propertyid      
   INNER JOIN senioradditionalunit sau ON t.HMYPERSON = sau.hTenant    
   WHERE  sau.dtstart <= Isnull(sau.dtend, sau.dtstart)     
          AND sau.bactive = 1     
           AND dtStart <= @EOM     
           AND Isnull(dtEnd, @EOM) >= @BOM     
           AND dtStart <= Isnull(dtEnd,dtStart)    
          AND @flag IN ( 1, 2, 3 )     
  INSERT INTO #ServiceInstanceAdditionalUnit     
      SELECT DISTINCT    
          sauc.hAdditionalUnit,    
           src.residentid,    
          src.UnitID,     
           CONVERT( DATETIME, CONVERT(VARCHAR(11), src.RecurringChargeFromDate), 101 ) ,     
           CONVERT( DATETIME, CONVERT(VARCHAR(11), src.RecurringChargeToDate), 101 ),    
         src.PrivacyLevelCode,    
         src.ContractTypeCode,    
         src.CareLevelCode,    
         99,    
         0,    
         0,    
         0    
    FROM   #tmpProperty P     
    INNER JOIN TENANT t ON p.propertyid = t.hproperty     
    INNER JOIN SeniorAdditionalUnit sau ON sau.hTenant = t.hmyperson     
    INNER JOIN SeniorAdditionalUnitCharge sauc ON sauc.hAdditionalUnit=sau.HMY    
    INNER JOIN SeniorRecurringCharge src on src.RecurringChargeID=sauc.hRecurringCharge    
    INNER JOIN UNIT u ON u.hmy = sau.hUnit AND isnull(u.exclude, 0) = 0    
    INNER JOIN SeniorUnitHistory suh ON suh.unitid = u.hmy                   
    WHERE sau.bActive=1     
          AND Isnull(src.RecurringChargeToDate, @EOM) > = src.RecurringChargeFromDate     
         AND src.RecurringchargeActiveFlag <> 0     
         AND sau.dtStart <= ISNULL(sau.dtEnd,'01/01/2100')    
          AND src.RecurringChargeFromDate <= @EOM     
          AND @BOM <= Isnull(src.RecurringChargeToDate, @EOM)     
          AND @flag IN ( 4, 5, 6 )     
         AND UnitHistoryID in ( SELECT MAX( suh1.Unithistoryid )        
           FROM   Seniorunithistory Suh1        
           WHERE  Suh1.Unitid = Suh.Unitid        
           AND Suh1.UnitHistoryActiveFlag <> 0        
           AND CONVERT( DATETIME, CONVERT(VARCHAR(11), Suh1.UnitHistoryFromDate), 101 )     
            = ( SELECT MAX( CONVERT( DATETIME, CONVERT(VARCHAR(11), Suh2.unitHistoryFromDate), 101 ) )        
                FROM   SeniorUnitHistory Suh2     
                WHERE  Suh2.Unitid = Suh1.Unitid        
                AND Suh2.Unithistoryactiveflag <> 0        
             AND Isnull(suh.unithistorytodate, @EOM) > = unithistoryfromdate     
             AND unithistoryfromdate <= @EOM     
             AND @BOM <= Isnull(unithistorytodate, @EOM)))        
            end  
        
   --Delete secondary privacy levels if the @ShowSeccondResident parameter is not set to 'yes' --???03/03/2021    
   IF @ShowSeccondResident <> 'yes'    
   BEGIN    
    DELETE FROM #ServiceInstanceAdditionalUnit    
    WHERE PrivacyLevelCode IN (    
     SELECT SecondaryPrivacyLevel    
     FROM SeniorPrivacyLevelMapping    
    )    
   END    
   /*1. Units that have Recurring charges starting before filter Start Date and ending after filter To Date*/    
    UPDATE #ServiceInstanceAdditionalUnit set bEliminate = 1    
    FROM #ServiceInstanceAdditionalUnit where RecurringChargeFromDate <= @BOM and Isnull(RecurringChargeToDate,@EOM) > = @EOM    
    /*Delete other recurring charge instance for above scenario*/ --???    
    DELETE a1    
    FROM #ServiceInstanceAdditionalUnit a1    
    INNER JOIN #ServiceInstanceAdditionalUnit a2 ON a1.ResidentID = a2.ResidentID and a1.UnitID = a2.UnitID and a1.PrivacyLevelCode = a2.PrivacyLevelCode    
    WHERE a1.bEliminate = 0 AND a2.bEliminate = 1    
    /*2. Select min Recurring charge start date for NULL recurringchargetodate and delete other recurring charge instance */    
    UPDATE a3 set bEliminate = 2    
    FROM #ServiceInstanceAdditionalUnit a3    
    WHERE a3.bEliminate = 1    
    AND Isnull(a3.RecurringChargeToDate,'01/01/2100') = '01/01/2100'    
    AND a3.ID IN    
    (SELECT MIN (a2.ID) FROM #ServiceInstanceAdditionalUnit a2    
     WHERE     
     a3.ResidentID = a2.ResidentID    
     and a3.UnitID = a2.UnitID    
     and a3.PrivacyLevelCode = a2.PrivacyLevelCode    
     and RecurringChargeFromDate in    
     (SELECT MIN(a1.RecurringChargeFromDate)     
        FROM #ServiceInstanceAdditionalUnit a1     
       WHERE bEliminate = 1 AND Isnull(RecurringChargeToDate,'01/01/2100') = '01/01/2100'    
         and a1.ResidentID = a2.ResidentID    
         and a1.UnitID = a2.UnitID    
         and a1.PrivacyLevelCode = a2.PrivacyLevelCode    
       GROUP BY ResidentId,UnitID,PrivacyLevelCode)    
    )    
    DELETE a1    
    FROM #ServiceInstanceAdditionalUnit a1    
    INNER JOIN #ServiceInstanceAdditionalUnit a2 on a1.ResidentID = a2.ResidentID and a1.UnitID = a2.UnitID and a1.PrivacyLevelCode = a2.PrivacyLevelCode    
    WHERE a1.bEliminate = 1 and a2.bEliminate = 2    
    /*3. select consecutive From/To Date instances and update max To date to the Min from date  */    
    UPDATE sd SET  sd.bEliminate = 3    
      FROM  #ServiceInstanceAdditionalUnit sd    
    INNER JOIN #ServiceInstanceAdditionalUnit sd1 on sd.residentid=sd1.residentid and sd.unitid=sd1.unitid and sd.PrivacyLevelCode=sd1.PrivacyLevelCode     
                                                     AND sd.RecurringChargeFromDate=dateadd(dd,1,sd1.RecurringChargeToDate)    
    UPDATE sd SET    sd.bEliminate = 4    
    FROM   #ServiceInstanceAdditionalUnit sd    
           INNER JOIN #ServiceInstanceAdditionalUnit sd1    
                   ON sd.residentid = sd1.residentid    
                      AND sd.unitid = sd1.unitid    
                      AND sd.PrivacyLevelCode = sd1.PrivacyLevelCode    
                      AND sd1.RecurringChargeFromDate = Dateadd(dd, 1, sd.RecurringChargeToDate)    
    WHERE isnull(sd.bEliminate,0) = 0 and isnull(sd1.bEliminate,0) = 3    
    UPDATE sd1    
    SET    sd1.RecurringChargeToDate = sd.RecurringChargeToDate, --???Isnull(sd.RecurringChargeToDate,@EOM) set this later???    
           sd1.CareLevelCode = sd.CareLevelCode,    
           sd1.ContractTypeCode = sd.ContractTypeCode,    
           sd1.iStatus = sd.iStatus    
    FROM   #ServiceInstanceAdditionalUnit sd1    
    INNER JOIN #ServiceInstanceAdditionalUnit sd    
                   ON sd.ID IN (SELECT ID    
                                 FROM  #ServiceInstanceAdditionalUnit tmp1    
                                 WHERE  Isnull(RecurringChargeToDate,@EOM) IN (SELECT Max(Isnull(RecurringChargeToDate,@EOM)) RecurringChargeToDate    
                                         FROM   #serviceinstanceadditionalunit tmp    
                                                                  WHERE  tmp.residentID = tmp1.residentID    
                                                                         AND tmp.unitID = tmp1.unitID    
                                                                         AND tmp.PrivacyLevelCode = tmp1.PrivacyLevelCode    
                                                                         AND Isnull(tmp.bEliminate, 0) = 3    
                                                                  GROUP  BY residentID,    
                                                                            unitID,    
                                                                            PrivacyLevelCode))    
                                 AND sd.residentid = sd1.residentid    
                                 AND sd.unitid = sd1.unitid    
                                 AND sd.PrivacyLevelCode = sd1.PrivacyLevelCode    
    WHERE  Isnull(sd1.bEliminate, 0) = 4     
    DELETE FROM #ServiceInstanceAdditionalUnit WHERE bEliminate=3     
    DELETE FROM #ServiceInstanceAdditionalUnit    
    WHERE ID IN    
    (SELECT MIN(a1.ID)    
       FROM #ServiceInstanceAdditionalUnit a1    
       INNER JOIN #ServiceInstanceAdditionalUnit a2 on a1.ResidentID = a2.ResidentID and a1.UnitID = a2.UnitID and a1.PrivacyLevelCode = a2.PrivacyLevelCode    
                                                    AND a1.RecurringChargeFromDate = a2.RecurringChargeFromDate and Isnull(a1.RecurringChargeToDate,@EOM) = Isnull(a2.RecurringChargeToDate,@EOM)    
     GROUP BY a1.ResidentID,a1.UnitID,a1.PrivacyLevelCode,a1.RecurringChargeFromDate,Isnull(a1.RecurringChargeToDate,@EOM)    
     HAVING COUNT(a1.id) > 1    
    )    
    /*4. Update greater To date if there are multiple instances with different start and end dates    
    eg. 05/01/18 - 05/15/18    
     05/08/18 - 05/25/18    
     05/10/18 - 05/31/18    
     05/01/18 - 05/06/18    
     05/08/18 - 05/15/18    
     05/10/18 - 05/25/18    
     */    
    UPDATE a1 SET RowNum = Rowcnt    
    FROM #ServiceInstanceAdditionalUnit a1    
    INNER JOIN (select *,    
    Row_Number() Over (Partition by ResidentID,UnitID,PrivacyLevelCode Order by ResidentID,UnitID,RecurringChargeFromDate,Isnull(RecurringChargeToDate,@EOM)) RowCnt    
    FROM #ServiceInstanceAdditionalUnit ) a2 on a1.ResidentID = a2.ResidentID and a1.UnitID = a2.UnitID and a1.PrivacyLevelCode = a2.PrivacyLevelCode    
                                                and a1.RecurringChargeFromDate = a2.RecurringChargeFromDate and Isnull(a1.RecurringChargeToDate,@EOM) = Isnull(a2.RecurringChargeToDate,@EOM)    
    UPDATE a2 SET a2.bEliminate = CASE when isnull(a1.RecurringChargeToDate, @EOM) <= isnull(a2.RecurringChargeToDate, @EOM) then 5    
                 when a2.RecurringChargeToDate BETWEEN a1.RecurringChargeFromDate and isnull(a1.RecurringChargeToDate,@EOM) then 5    
            END    
    FROM #ServiceInstanceAdditionalUnit a1    
    INNER JOIN #ServiceInstanceAdditionalUnit a2 on a1.ResidentID = a2.ResidentID and a1.UnitID = a2.UnitID and a1.PrivacyLevelCode = a2.PrivacyLevelCode    
    WHERE a1.Rownum = a2.Rownum - 1    
    and a2.RecurringChargeFromDate BETWEEN a1.RecurringChargeFromDate AND ISNULL(a1.RecurringChargeToDate, @EOM)    
    UPDATE a1 SET RowNum2 = Rowcnt    
    FROM #ServiceInstanceAdditionalUnit a1    
    INNER JOIN (select *,    
    Row_Number() Over (Partition by ResidentID,UnitID,PrivacyLevelCode,bEliminate  Order by ResidentID,UnitID,RecurringChargeFromDate,Isnull(RecurringChargeToDate,@EOM)) RowCnt    
    FROM #ServiceInstanceAdditionalUnit    
    WHERE 1=1 and bEliminate=0 ) a2 on a1.ID = a2.ID    
    SELECT a1.Residentid,a1.UnitID,a1.PrivacyLevelCode,a1.RowNum rownum1,a2.RowNum rownum2,a1.Rownum2 RowNum3    
    INTO #tempRowNum    
    FROM #ServiceInstanceAdditionalUnit a1    
    INNER JOIN #ServiceInstanceAdditionalUnit a2 ON a1.ResidentID = a2.ResidentID and a1.UnitID = a2.UnitID and a1.PrivacyLevelCode = a2.PrivacyLevelCode    
    AND a1.Rownum2+1 = a2.Rownum2     
    WHERE a1.bEliminate=0 and a2.bEliminate=0    
    INSERT INTO #tempRowNum    
    SELECT a1.ResidentID,a1.UnitID,a1.PrivacyLevelCode,a1.RowNum,a2.MaxRowNum+1,a1.RowNum2    
    FROM #ServiceInstanceAdditionalUnit a1     
    INNER JOIN (SELECT ResidentID,UnitID,PrivacyLevelCode,MAX(RowNum) MaxRowNum FROM #ServiceInstanceAdditionalUnit GROUP BY ResidentID,UnitID,PrivacyLevelCode ) a2    
               ON a2.ResidentID = a1.ResidentID and a2.UnitID = a1.UnitID and a2.PrivacyLevelCode = a1.PrivacyLevelCode     
    LEFT JOIN #tempRowNum tmp ON tmp.ResidentID = a1.ResidentID and tmp.UnitID = a1.UnitID and tmp.PrivacyLevelCode = a1.PrivacyLevelCode AND tmp.RowNum3=a1.RowNum2    
    WHERE a1.bEliminate=0 AND ISNULL(tmp.Residentid,0)=0    
    UPDATE a1    
    SET a1.RowNum2=tmp.RowNum3    
    FROM #ServiceInstanceAdditionalUnit a1    
    INNER JOIN #tempRowNum tmp on a1.ResidentID = tmp.ResidentID and a1.UnitID = tmp.UnitID and a1.PrivacyLevelCode = tmp.PrivacyLevelCode    
                                 AND a1.RowNum<tmp.rownum2 and a1.RowNum>tmp.rownum1    
    /*Update Min from date event with Max Todate from eliminate records*/           
    UPDATE a1     
    SET a1.Recurringchargetodate=a2.RecurringChargeToDate    
    FROM #ServiceInstanceAdditionalUnit a1    
    INNER JOIN (SELECT Residentid,UnitID,PrivacyLevelCode,RowNum2,MAX(Recurringchargetodate) Recurringchargetodate FROM #ServiceInstanceAdditionalUnit    
                WHERE bEliminate=5 GROUP BY Residentid,UnitID,PrivacyLevelCode,RowNum2) a2     
             ON a1.ResidentID = a2.ResidentID and a1.UnitID = a2.UnitID and a1.PrivacyLevelCode = a2.PrivacyLevelCode AND a1.RowNum2=a2.RowNum2    
    WHERE a1.bEliminate = 0     
    DELETE #ServiceInstanceAdditionalUnit WHERE bEliminate = 5    
  IF @IncludeMoveOutDate = 'No'    
  BEGIN    
      UPDATE #ResidentHistoryStatusAdditionalUnit SET dtEnddate = DATEADD(dd, -1, dtEndDate)    
   WHERE  dtEnddate IS NOT NULL    
   AND    @flag IN (1,2,3)    
   UPDATE #ServiceInstanceAdditionalUnit SET Recurringchargetodate = DATEADD(dd, -1, Recurringchargetodate)    
   FROM   #ServiceInstanceAdditionalUnit au    
   WHERE  au.Recurringchargetodate IS NOT NULL    
   AND     @flag IN (4,5,6)    
  END    
  /*Get movein/MoveOut counts*/    
  INSERT INTO #tmpTenant(hProperty,     
                         hUnit,     
          hmyPerson,     
          CareLevelCodeMin ,    
          CareLevelCodeOut,    
                   PrivacyLevelCode,    
          dtMoveIn,    
          dtMoveOut,    
          MoveInStatus,    
          MoutStatus,    
          MoveInResidentHistoryID,    
          MoveOutResidentHistoryID)    
  SELECT  DISTINCT    
           srh.hProperty,    
     srh.hUnit,    
           srh.hResident thmyperson ,    
     srh.sCareLevelCode,    
     srh.sCareLevelCode,    
     srh.sPrivacyLevelCode,    
     CONVERT( DATETIME, CONVERT(VARCHAR(11), srh.dtMoveIn), 101 )   dtMoveIn,     
           CONVERT( DATETIME, CONVERT(VARCHAR(11), srh.dtMoveOut), 101 )  dtMoveOut,    
           0  MoveInStatus,     
           1 MoveOutStatus,    
           0 MoveInResidentHistoryID,    
     0 MoveOutResidentHistoryID    
  FROM SeniorResidentHistoryStatus srh     
  INNER JOIN #tmpProperty p ON srh.hProperty = p.PropertyID    
  WHERE srh.dtMoveIn IS NOT NULL     
  AND   srh.dtFrom <= ISNULL(srh.dtTo, srh.dtFrom)    
  AND srh.istatuscode IN (1)    
  INSERT INTO #tmpTenant(hProperty,     
                         hUnit,     
          hmyPerson,    
          CareLevelCodeMin ,    
          CareLevelCodeOut ,    
                   PrivacyLevelCode,    
          dtMoveIn,    
          dtMoveOut,    
          MoveInStatus,    
          MoutStatus,    
          MoveInResidentHistoryID,    
          MoveOutResidentHistoryID)    
  SELECT  DISTINCT    
           srh.hProperty,    
     srh.hUnit,    
           srh.hResident thmyperson ,    
     srh.sCareLevelCode,    
     srh.sCareLevelCode,    
     srh.sPrivacyLevelCode,    
     CONVERT( DATETIME, CONVERT(VARCHAR(11), srh.dtMoveIn), 101 )   dtMoveIn,     
           CONVERT( DATETIME, CONVERT(VARCHAR(11), srh.dtMoveOut), 101 )  dtMoveOut,    
           0 MoveInStatus,    
           1 MoveOutStatus,    
           0 MoveInResidentHistoryID,    
     0 MoveInResidentHistoryID    
  FROM SeniorResidentHistoryStatus srh --Tenant t     
  INNER JOIN #tmpProperty p ON srh.hProperty = p.PropertyID    
  WHERE ISNULL(srh.dtTo, @BegDefault)  = @BegDefault    
  AND   srh.dtFrom <= ISNULL(srh.dtTo, srh.dtFrom)    
  AND srh.iStatusCode IN (0, 11,4)    
  --Delete secondary privacy levels if the @ShowSeccondResident parameter is not set to 'yes'     
   /*IF @ShowSeccondResident <> 'yes'    
   BEGIN    
    DELETE FROM #tmptenant    
    WHERE PrivacyLevelCode IN (    
     SELECT SecondaryPrivacyLevel    
     FROM SeniorPrivacyLevelMapping    
    )    
   END    
   */    
  UPDATE t     
  SET    t.MoveInResidentHistoryID = srh.Residenthistoryid ,    
         t.CareLevelCodeMin = srh.CareLevelCode,    
      t.PrivacyLevelCode = srh.PrivacyLevelCode    
  FROM   #tmptenant t     
  INNER JOIN #ResidentHistory srh ON srh.Residentid = t.Hmyperson     
                                     AND t.dtMoveIn = srh.Residenthistorydate     
                                     AND srh.ResidentHistoryCode = 'MIN'     
                                     --AND CONVERT(DATETIME, CONVERT(VARCHAR(20), srh.Residenthistorydate, 101), 101) <= @EOM    
  WHERE 1 = 1    
  UPDATE t     
  SET    t.MoveOutResidentHistoryID = srh.Residenthistoryid,    
         t.CareLevelCodeOut = srh.CareLevelCode    
  FROM   #tmptenant t     
  INNER JOIN #ResidentHistory srh ON srh.Residentid = t.Hmyperson     
                      AND t.dtMoveOut = srh.Residenthistorydate     
                                     AND srh.ResidentHistoryCode IN ( 'QIK','OUT')    
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
  CREATE TABLE #ServiceDateRange    
  (    
   ServiceInstanceId NUMERIC ,     
   PropertyId                NUMERIC,    
   ResidentId                NUMERIC,    
   ServiceID                 NUMERIC,    
   UnitId                    NUMERIC,    
   CareLevelCode             VARCHAR(50),    
   PrivacyLevelCode          VARCHAR(50),    
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
    ServiceInstanceFromDate  ,    
    ServiceInstanceToDate    ,    
    bMoveIn        ,    
    bMoveOut        ,    
    RemoveFlag,    
    CoOccupantId     
  )    
  /* Get information about service date ranges of the residnets */     
  SELECT DISTINCT i.ServiceInstanceID, tt.hProperty, i.residentid,     
         i.ServiceID,    
         i.unitid,    
      RTRIM(i.CareLevelCode),    
         RTRIM(i.PrivacyLevelCode),    
         CONVERT( DATETIME, CONVERT(VARCHAR(11), i.ServiceInstanceFromDate), 101 ) ,    
         CONVERT( DATETIME, CONVERT(VARCHAR(11), i.ServiceInstanceToDate), 101 ) ,    
         0,    
      0,    
      0,    
      NULL    
  FROM #tmpSERVICE cs    
  INNER JOIN ServiceInstance i ON i.ServiceID = cs.ServiceID    
  INNER JOIN #tmpTenant tt ON i.ResidentID = tt.hmyperson     
                        --AND ISNULL(tt.dtMoveOut, @EOM) >= @BOM     
  INNER JOIN #tmpCareLevel lc ON RTRIM(i.CareLevelCode) = lc.ListOptionCode    
  WHERE 1=1     
   AND i.ServiceInstanceFromDate <= @EOM    
   AND ISNULL(i.ServiceInstanceToDate, @EOM) >= @BOM    
   AND ISNULL(i.ServiceInstanceToDate, @EOM) >= i.ServiceInstanceFromDate    
   AND i.ServiceInstanceActiveFlag <> 0    
   --03/16/2021 try to get CoOccupantId    
   UPDATE s SET s.CoOccupantId = sr.hCoOccupant    
   FROM #ServiceDateRange s    
   JOIN SeniorResident sr ON (s.ResidentId = sr.ResidentId)    
   WHERE 1 = 1    
   UPDATE ss SET ss.ResidentId = ss.CoOccupantId    
   FROM #ServiceDateRange s    
   JOIN #ServiceDateRange ss ON (s.ResidentId = ss.CoOccupantId AND s.UnitId = ss.UnitId    
                                 AND ss.PrivacyLevelCode IN (SELECT SecondaryPrivacyLevel FROM SeniorPrivacyLevelMapping))    
   WHERE 1 = 1    
   UPDATE s SET s.ResidentId = ss.CoOccupantId    
   FROM #ServiceDateRange s    
   JOIN #ServiceDateRange ss ON ( s.UnitId = ss.UnitId AND s.CoOccupantId = ss.CoOccupantId                         
                                 AND ss.PrivacyLevelCode IN (SELECT SecondaryPrivacyLevel FROM SeniorPrivacyLevelMapping)    
            AND s.PrivacyLevelCode NOT IN (SELECT SecondaryPrivacyLevel FROM SeniorPrivacyLevelMapping))    
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
   --Delete secondary privacy levels if the @ShowSeccondResident parameter is not set to 'yes' --???03/03/2021    
   IF @ShowSeccondResident <> 'yes'    
   BEGIN    
    DELETE FROM #ServiceDateRange    
    WHERE PrivacyLevelCode IN (    
     SELECT SecondaryPrivacyLevel    
     FROM SeniorPrivacyLevelMapping    
    )    
   END    
  --SET statistics IO off    
  /*If there is unit transfer BETWEEN the month     
          e.g Unit 101 from 01/01/2011 to 02/09/2011    
              Unit 102 from 02/10/2011 to 02/11/2011    
              Unit 101 from 02/12/2011 to 02/16/2011    
              Unit 102 from 02/17/2011 to NULL */                             
   UPDATE sd    
   SET sd.RemoveFlag=1, sd.bMoveOut = 1    
   FROM #ServiceDateRange sd    
   INNER JOIN #ServiceDateRange sd1 ON sd.residentid=sd1.residentid     
                                     AND sd.unitid=sd1.unitid     
             AND sd.PrivacyLevelCode=sd1.PrivacyLevelCode     
                                    --AND sd.CareLevelCode = sd1.CareLevelCode AND sd.ServiceID = sd1.ServiceID    
                                     AND sd.serviceInstanceFromDate = DATEADD(dd,1,sd1.ServiceInstanceToDate)    
  UPDATE sd    
  SET    sd.RemoveFlag = 2, sd.bMoveOut = 1    
  FROM   #ServiceDateRange sd    
         INNER JOIN #ServiceDateRange sd1    
                 ON sd.ResidentId = sd1.residentid    
                    AND sd.unitid = sd1.unitid    
                    AND sd.PrivacyLevelCode = sd1.PrivacyLevelCode    
                    --AND sd.CareLevelCode = sd1.CareLevelCode    
                    AND sd1.ServiceInstanceFromDate = DATEADD(dd, 1, sd.ServiceInstanceToDate)    
  WHERE ISNULL(sd.RemoveFlag,0) IN (1, 0) AND ISNULL(sd1.RemoveFlag,0) = 1    
  UPDATE sd    
    SET  sd.bMoveIn = 1    
   FROM #ServiceDateRange sd    
   WHERE ISNULL(sd.RemoveFlag,0) = 0    
   AND  sd.ServiceInstanceFromDate BETWEEN @BOMActual AND @EOM    
  UPDATE sd    
    SET  sd.bMoveOut = 1    
   FROM #ServiceDateRange sd    
   LEFT JOIN #ServiceDateRange sd1 ON sd.ResidentId = sd1.residentid    
                    AND sd.unitid = sd1.unitid    
                    AND sd.PrivacyLevelCode = sd1.PrivacyLevelCode    
        AND ISNULL(sd1.RemoveFlag, 0) = 1    
    WHERE ISNULL(sd.RemoveFlag,0) = 0    
    AND sd1.ResidentId IS NULL    
  UPDATE sd    
    SET  sd.bMoveOut = 0    
   FROM #ServiceDateRange sd    
   LEFT JOIN #ServiceDateRange sd1 ON sd.ResidentId = sd1.residentid    
                    AND sd.unitid = sd1.unitid    
                    AND sd.PrivacyLevelCode = sd1.PrivacyLevelCode    
        AND ISNULL(sd1.RemoveFlag, 0) = 2    
    WHERE ISNULL(sd.RemoveFlag,0) = 1    
    AND sd1.ResidentId IS NOT NULL    
  UPDATE sd    
    SET  sd.bMoveOut = 0    
  FROM #ServiceDateRange sd    
  WHERE ISNULL(sd.ServiceInstanceToDate, @EndDefault) > CASE @IncludeMoveOutDate WHEN 'No' THEN @EOM ELSE DATEADD(dd, 1,  @EOM) END    
  AND sd.bMoveOut = 1    
   /*Gether Unit detail info*/    
   CREATE TABLE  #tmpOccupancyDetail (        
         PropertyId         NUMERIC        
        ,PropertyName       VARCHAR( 266 )        
        ,Property           VARCHAR( 266 )        
        ,PropCode           VARCHAR( 20 )        
        ,UnitId             NUMERIC        
        ,UnitCode           VARCHAR( 15 )        
        ,UnitTypeId         NUMERIC        
        ,UnitType           VARCHAR( 100 )        
        ,CareLevelCode      VARCHAR( 10 )        
        ,UnitCapacity       NUMERIC        
        ,Unitbudgetcapacity NUMERIC        
        ,UnitSqft           NUMERIC( 18, 2 )        
        ,UnitWaitlistFlag   BIT        
        ,UnitExcludeFlag    BIT UNIQUE(Propertyid,Unitid)     
        ,AdditionalUnit     BIT )     
    /* @flag ='1' then 'Physical Unit Based Occupancy'                                   
         @flag ='2' then 'Physical Lease Based Occupancy'                                  
         @flag ='3' then 'Physical Unit Based Occupancy (disregarding capacity)'                                  
         @flag ='4' then 'Financial Unit Based Occupancy'                                 
         @flag ='5' then 'Financial Lease Based Occupancy'                                  
         @flag ='6' then 'Financial Unit Based Occupancy (disregarding capacity)'                                
         and @flag =0  for both Physical and financial occupancies */        
   INSERT INTO #tmpOccupancyDetail        
   SELECT  P.Propertyid,        
            Ltrim( Rtrim( P.Propertyname ) ) + ' (' + Ltrim( Rtrim( P.Propertycode ) ) + ')',        
            P.Property,        
            Ltrim( Rtrim( P.Propertycode ) ),        
            U.Hmy,        
            U.Scode,        
            Ut.Hmy,        
            Isnull( Ut.Sdesc, Ut.Scode ),        
            Su.Carelevelcode,        
            Su.Unitcapacitycount,        
            Su.Unitbudgetcount,        
            U.Dsqft,        
            Su.Unitwaitlistflag,        
            U.Exclude      
            ,0      
    FROM #tmpProperty P        
    INNER JOIN Unit U ON U.Hproperty = P.Propertyid AND isnull(U.exclude, 0) = 0     
    INNER JOIN Seniorunit Su ON Su.Unitid = U.Hmy        
    INNER JOIN Unittype Ut ON Ut.Hmy = U.Hunittype        
    INNER JOIN #tmpCareLevel C ON Su.Carelevelcode = C.Listoptioncode     
    CREATE TABLE #tmpOccupancy (        
           Hmy                      NUMERIC( 18, 0 ) IDENTITY(1, 1)        
           ,Title                   VARCHAR( 100 )        
           ,Propertyid              NUMERIC        
           ,Unitid                  NUMERIC        
           ,Residentid              NUMERIC        
           ,Residentname            VARCHAR( 200 )        
           ,Dtmovein                DATETIME        
           ,Dtmoveout               DATETIME        
           ,Serviceinstancefromdate DATETIME        
           ,Serviceinstancetodate   DATETIME        
           ,Privacylevelcode        VARCHAR( 10 )        
           ,Rescarelvlcode          VARCHAR( 10 )        
           ,Contracttypecode    VARCHAR( 10 )        
           ,Residentstatus          NUMERIC( 18, 0 )        
           ,Occupancy               NUMERIC( 18, 2 )        
           ,Beliminate              BIT        
           ,Fromdate                DATETIME        
           ,Todate                  DATETIME        
           ,Residenthistorycode     VARCHAR( 10 )        
           ,Residenthistoryid       NUMERIC  UNIQUE (hmy)    
           ,MoveInExist             BIT    
           ,additionalunit          BIT )       
    INSERT INTO #tmpOccupancy (        
            Title        
            ,Propertyid        
            ,Unitid        
            ,Residentid        
            ,Residentname        
            ,Dtmovein        
            ,Dtmoveout        
            ,Serviceinstancefromdate        
            ,Serviceinstancetodate        
            ,Privacylevelcode        
            ,Rescarelvlcode        
            ,Contracttypecode        
            ,Residentstatus        
            ,Occupancy        
            ,Beliminate        
            ,Fromdate        
            ,Todate        
            ,Residenthistorycode        
            ,Residenthistoryid    
            ,MoveInExist     
            ,AdditionalUnit     )       
    SELECT        
           'Physical Occupancy',        
           P.Propertyid                                                                                                                                              Phmy,        
           Srh.UnitId,        
           T.Hmyperson                                                                                                                                               Residentid,        
           Rtrim( Ltrim( Isnull( T.Slastname, '' ) ) ) + ', ' + Rtrim( Ltrim( Isnull( T.Sfirstname, '' ) ) ) + ' (' + Rtrim( Ltrim( Isnull( T.Scode, '' ) ) ) + ') ' Residentname,        
           T.Dtmovein,        
           CASE        
              WHEN T.Istatus = 4 THEN NULL        
              ELSE T.Dtmoveout        
           END,        
           NULL,        
           NULL,        
           Srh.Privacylevelcode,        
           Srh.Carelevelcode,        
           Srh.Contracttypecode,        
           Srh.iStatusCode,        
           Cast( Lv.Listoptionvalue AS NUMERIC( 3, 2 ))                                                                                                              Occ,        
           1,       
     CASE WHEN CONVERT( DATETIME, CONVERT(VARCHAR(10), Srh.dtFrom,121), 101 ) <= CONVERT( DATETIME, CONVERT(VARCHAR(10), @BOM ,121), 101 ) THEN CONVERT( DATETIME, CONVERT(VARCHAR(10), @BOM ,121), 101 )    
     ELSE    
          CONVERT( DATETIME, CONVERT(VARCHAR(10), Srh.dtFrom,121), 101 )    
     END,    
     CASE WHEN srh.iStatusCode = 1 THEN srh.dtFrom    
     ELSE    
      /*CASE WHEN CONVERT( DATETIME, CONVERT(VARCHAR(10), Srh.dtTo,121), 101 ) >= CONVERT( DATETIME, CONVERT(VARCHAR(10), @EOM ,121), 101 ) THEN  @EOM    
      ELSE    
      CONVERT( DATETIME, CONVERT(VARCHAR(10), Srh.dtTo,121), 101 )    
      END*/ --???    
     CONVERT( DATETIME, CONVERT(VARCHAR(10), Srh.dtTo,121), 101 )    
     END,         
           '',    
           0,     
           0,    
           0     
    FROM  #tmpProperty P            
    INNER JOIN Tenant T ON (T.Hproperty = P.Propertyid AND @flag IN ( 0, 1, 2, 3 ) )             
    INNER JOIN #ResidentHistoryStatus Srh ON (Srh.hResident = T.Hmyperson)                
    INNER JOIN #tmpCareLevel L1 ON ( RTRIM(Srh.CareLevelCode ) = RTRIM(L1.ListOptionCode) )            
    INNER JOIN Listoption L2 ON ( RTRIM(Srh.Privacylevelcode) = RTRIM(L2.Listoptioncode) AND L2.Listname = 'PrivacyLevel' )            
    INNER JOIN #tmpPrivacyListOptionValue Lv ON (Lv.Listname = 'PrivacyLevel' AND Lv.Listoptioncode = L2.Listoptioncode   )         
    WHERE 1=1      
      AND (Srh.iStatusCode IN ( 0, 4, 11) OR (Srh.iStatusCode = 1 AND CONVERT(DATETIME, CONVERT(VARCHAR(10), Srh.dtFrom,121), 101) BETWEEN @BOM AND @EOM))      
    AND CONVERT( DATETIME, CONVERT(VARCHAR(10), Srh.dtFrom,121), 101 ) <= CONVERT( DATETIME, CONVERT(varchar(10),@EOM,121), 101)            
      AND CONVERT( DATETIME, CONVERT(VARCHAR(10), Srh.dtFrom,121), 101 ) <= ISNULL(Srh.dtTo, '12/01/2210')        
    UNION ALL    
    SELECT        
           'Financial Occupancy',        
           P.Propertyid                                                                                                                                              Phmy,        
           Si.Unitid,        
           T.Hmyperson                                                                                                                                               Residentid,        
           Rtrim( Ltrim( Isnull( T.Slastname, '' ) ) ) + ', ' + Rtrim( Ltrim( Isnull( T.Sfirstname, '' ) ) ) + ' (' + Rtrim( Ltrim( Isnull( T.Scode, '' ) ) ) + ') ' Residentname,        
           T.Dtmovein,        
           CASE        
              WHEN T.Istatus = 4 THEN NULL        
              ELSE T.Dtmoveout        
           END,        
           Si.Serviceinstancefromdate,        
           Si.Serviceinstancetodate,        
           Si.Privacylevelcode,        
           Si.Carelevelcode,        
           '',        
           T.Istatus,        
           Cast( Lv.Listoptionvalue AS NUMERIC( 3, 2 ))                                                                                                              Occ,        
           1,        
           Si.Serviceinstancefromdate,        
           Si.ServiceInstanceToDate, --Isnull(Si.ServiceInstanceToDate, @EOM ),  ??? Update it later     
           NULL,        
           0,    
           0,    
           0     
         FROM  #tmpProperty P        
         INNER JOIN Tenant T ON T.Hproperty = P.Propertyid AND @flag IN ( 0, 4, 5, 6 )        
         INNER JOIN #ServiceDateRange Si ON ( T.Hmyperson = Si.Residentid )        
         --INNER JOIN Service S ON ( Si.Serviceid = S.Serviceid AND S.Serviceclassid = 1 )        
         --INNER JOIN SeniorResident Rs ON ( T.Hmyperson = Rs.Residentid )        
         INNER JOIN #tmpCareLevel L1 ON ( Si.Carelevelcode = L1.Listoptioncode )        
         INNER JOIN Listoption L2 ON ( Si.Privacylevelcode = L2.Listoptioncode AND L2.Listname = 'PrivacyLevel' )        
         INNER JOIN #tmpPrivacyListOptionValue Lv ON Lv.Listname = 'PrivacyLevel' AND Lv.Listoptioncode = L2.Listoptioncode        
         WHERE 1 = 1       
           AND Isnull( Si.Serviceinstancetodate, @EOM ) >= Si.Serviceinstancefromdate        
           AND Si.ServiceInstanceFromDate <= @EOM        
           AND @BOM <= Isnull( Si.ServiceInstanceToDate, @EOM )        
         ORDER  BY        
           3,        
           4,        
           5,      
           19,        
           16     
   /* add additional unit residents*/    
   INSERT INTO #tmpOccupancy (          
             Title        
            ,Propertyid        
            ,Unitid        
            ,Residentid        
            ,Residentname        
            ,Dtmovein        
            ,Dtmoveout        
            ,Serviceinstancefromdate        
            ,Serviceinstancetodate        
            ,Privacylevelcode        
            ,Rescarelvlcode        
            ,Contracttypecode        
            ,Residentstatus        
            ,Occupancy        
            ,Beliminate        
            ,Fromdate        
            ,Todate        
            ,Residenthistorycode        
            ,Residenthistoryid    
            ,MoveInExist         
            ,additionalunit )            
   SELECT                
           'Physical Occupancy',        
           P.Propertyid                                                                                                                                              Phmy,        
           sau.Hunit,         
           T.Hmyperson                                          Residentid,        
           Rtrim( Ltrim( Isnull( T.Slastname, '' ) ) ) + ', ' + Rtrim( Ltrim( Isnull( T.Sfirstname, '' ) ) ) + ' (' + Rtrim( Ltrim( Isnull( T.Scode, '' ) ) ) + ') ' Residentname,        
           T.Dtmovein,        
           CASE        
              WHEN T.Istatus = 4 THEN NULL        
              ELSE T.Dtmoveout        
           END,        
           NULL,        
           NULL,        
           sau.sprivacylevelcode,        
           '',        
           '',        
           0,        
           Cast( Lv.Listoptionvalue AS NUMERIC( 3, 2 ))                                                                                                              Occ,        
           1,        
           CONVERT( DATETIME, CONVERT(VARCHAR(10), srh.dtStartdate,121), 101 ), --??? --CONVERT( DATETIME, CONVERT(VARCHAR(10), sau.dtStart,121), 101 ),        
           CONVERT( DATETIME, CONVERT(VARCHAR(10), srh.dtEnddate,121), 101 ),  --???srh.dtEnddate is already updated above based on includeMoveOutDate flag CONVERT( DATETIME, CONVERT(VARCHAR(10), sau.dtEnde,121), 101 )    
           '',        
           sau.HMY    ,    
           0    
     ,1        
          FROM  #tmpProperty P     
          INNER JOIN tenant T ON T.hproperty = P.propertyid AND @flag IN ( 0, 1, 2, 3 )     
          --INNER JOIN SeniorResident Sr ON T.hmyperson = Sr.residentid     
          INNER JOIN SeniorAdditionalUnit sau ON sau.hTenant = t.hmyPerson --sr.residentid     
        INNER JOIN (select distinct residentid FROM #tmpOccupancy) tocc ON sau.hTenant = tocc.residentid    
          INNER JOIN unit u ON u.hmy = t.hunit AND Isnull(u.exclude, 0) = 0     
          INNER JOIN #tmpPrivacyListOptionValue Lv ON Lv.listname = 'PrivacyLevel' AND Lv.listoptioncode = sau.sprivacylevelcode          
     INNER JOIN #ResidentHistoryStatusAdditionalUnit srh ON srh.HistoryID = sau.HMY    
   UNION ALL    
   SELECT        
           'Financial Occupancy',        
           P.Propertyid                                                                                                                                              Phmy,        
           si.UnitID,        
           T.Hmyperson                                                                                                                                               Residentid,        
           Rtrim( Ltrim( Isnull( T.Slastname, '' ) ) ) + ', ' + Rtrim( Ltrim( Isnull( T.Sfirstname, '' ) ) ) + ' (' + Rtrim( Ltrim( Isnull( T.Scode, '' ) ) ) + ') ' Residentname,        
           T.Dtmovein,        
           CASE        
              WHEN T.Istatus = 4 THEN NULL        
              ELSE T.Dtmoveout        
           END,        
           si.Recurringchargefromdate,     
           si.Recurringchargetodate,     
           si.PrivacyLevelCode,        
           '',        
           '',        
           0,        
           Cast( Lv.Listoptionvalue AS NUMERIC( 3, 2 ))                                                                                                  Occ,        
           1,        
           si.Recurringchargefromdate,     
           si.Recurringchargetodate,    
           NULL,        
           0    ,    
           0    
     ,1     
   FROM #tmpProperty P INNER JOIN tenant T ON T.hproperty = P.propertyid AND @flag IN ( 4, 5, 6 )     
   INNER JOIN unit u ON u.hmy = t.hunit AND Isnull(u.exclude, 0) = 0     
   --INNER JOIN SeniorResident Rs ON ( T.hmyperson = Rs.residentid )     
   INNER JOIN #serviceinstanceadditionalunit si  ON si.Residentid = T.HMYPERSON     
   INNER JOIN #tmpPrivacyListOptionValue Lv ON Lv.listname = 'PrivacyLevel' AND Lv.listoptioncode = si.PrivacyLevelCode     
   INNER JOIN (SELECT DISTINCT ResidentID FROM #tmpOccupancy) tocc ON tocc.ResidentID = t.HMYPERSON    
   ORDER  BY        
           3,        
           4,        
           5,        
           19,        
           16      
  UPDATE occ1         
  SET     occ1.Dtmovein = Occ2.Dtmovein ,        
          occ1.Dtmoveout = Occ2.Dtmoveout ,        
          occ1.Rescarelvlcode = Occ2.Rescarelvlcode ,        
          occ1.Contracttypecode = Occ2.Contracttypecode ,        
          occ1.Residentstatus = Occ2.Residentstatus ,        
          occ1.Residenthistorycode = Occ2.Residenthistorycode ,        
          occ1.MoveInExist = Occ2.MoveInExist         
  FROM #tmpOccupancy Occ1         
  INNER JOIN #tmpOccupancy Occ2 ON Occ1.residentId = Occ2.residentId         
  WHERE ISNULL(occ1.AdditionalUnit, 0) = 1 AND ISNULL(Occ2.AdditionalUnit, 0) = 0         
  UPDATE tmpo        
     SET tmpo.MoveInExist = 1        
    FROM #tmpOccupancy tmpo     
    Cross apply (SELECT h.ResidentId      
          FROM SeniorResidentHistory h       
         WHERE h.ResidentID =tmpo.Residentid and RTRIM(h.ResidentHistoryCode) = 'MIN'        
        AND h.ResidentHistoryCancelFlag <> 1        
        AND h.ResidentHistoryDate BETWEEN @BOM AND @EOM  )a    
   --Delete secondary privacy levels if the @ShowSeccondResident parameter is not set to 'yes'    
   IF @ShowSeccondResident <> 'yes'    
   BEGIN    
    DELETE FROM #tmpOccupancy    
    WHERE PrivacyLevelCode IN (    
     SELECT SecondaryPrivacyLevel    
     FROM SeniorPrivacyLevelMapping    
    )    
   END    
   IF @IncludeMoveOutDate = 'No'    
   BEGIN    
         UPDATE t SET t.Todate = DATEADD(dd, -1, t.toDate)    
      FROM #tmpOccupancy t    
      WHERE t.Todate IS NOT NULL    
      AND   ISNULL(t.additionalunit, 0) = 0    
   END    
  CREATE TABLE #TempTbl (        
     Unitid   NUMERIC    
     ,PrivacyLevelCode VARCHAR(10)       
      ,MinHmy Numeric        
      ,dcCount NUMERIC UNIQUE(UnitId, PrivacyLevelCode)     
  )    
  /*???*/          
  INSERT INTO #TempTbl         
  SELECT  T1.Unitid,        
     T1.privacyLevelCode,    
           Min(Hmy),        
    Max( CASE WHEN @BOM BETWEEN T1.Fromdate AND Isnull( T1.Todate, @eOM ) THEN 1    ELSE 0 END )     
    + Max( CASE WHEN Dateadd( Dd, 1, @BOM ) BETWEEN T1.Fromdate AND Isnull( T1.Todate, @eOM ) THEN 1 ELSE 0 END )     
    + Max( CASE WHEN Dateadd( Dd, 2, @BOM ) BETWEEN T1.Fromdate AND Isnull( T1.Todate, @eOM ) THEN 1 ELSE 0 END )     
    + Max( CASE WHEN Dateadd( Dd, 3, @BOM ) BETWEEN T1.Fromdate AND Isnull( T1.Todate, @eOM ) THEN 1 ELSE 0 END )     
    + Max( CASE WHEN Dateadd( Dd, 4, @BOM ) BETWEEN T1.Fromdate AND Isnull( T1.Todate, @eOM ) THEN 1 ELSE 0 END )     
    + Max( CASE WHEN Dateadd( Dd, 5, @BOM ) BETWEEN T1.Fromdate AND Isnull( T1.Todate, @eOM ) THEN 1 ELSE 0 END )     
    + Max( CASE WHEN Dateadd( Dd, 6, @BOM ) BETWEEN T1.Fromdate AND Isnull( T1.Todate, @eOM ) THEN 1 ELSE 0 END )     
    + Max( CASE WHEN Dateadd( Dd, 7, @BOM ) BETWEEN T1.Fromdate AND Isnull( T1.Todate, @eOM ) THEN 1 ELSE 0 END )     
    + Max( CASE WHEN Dateadd( Dd, 8, @BOM ) BETWEEN T1.Fromdate AND Isnull( T1.Todate, @eOM ) THEN 1 ELSE 0 END )     
    + Max( CASE WHEN Dateadd( Dd, 9, @BOM ) BETWEEN T1.Fromdate AND Isnull( T1.Todate, @eOM ) THEN 1 ELSE 0 END )     
    + Max( CASE WHEN Dateadd( Dd, 10, @BOM ) BETWEEN T1.Fromdate AND Isnull( T1.Todate, @eOM ) THEN 1 ELSE 0 END )     
    + Max( CASE WHEN Dateadd( Dd, 11, @BOM ) BETWEEN T1.Fromdate AND Isnull( T1.Todate, @eOM ) THEN 1 ELSE 0 END )     
    + Max( CASE WHEN Dateadd( Dd, 12, @BOM ) BETWEEN T1.Fromdate AND Isnull( T1.Todate, @eOM ) THEN 1 ELSE 0 END )     
    + Max( CASE WHEN Dateadd( Dd, 13, @BOM ) BETWEEN T1.Fromdate AND Isnull( T1.Todate, @eOM ) THEN 1 ELSE 0 END )     
    + Max( CASE WHEN Dateadd( Dd, 14, @BOM ) BETWEEN T1.Fromdate AND Isnull( T1.Todate, @eOM ) THEN 1 ELSE 0 END )     
    + Max( CASE WHEN Dateadd( Dd, 15, @BOM ) BETWEEN T1.Fromdate AND Isnull( T1.Todate, @eOM ) THEN 1 ELSE 0 END )     
    + Max( CASE WHEN Dateadd( Dd, 16, @BOM ) BETWEEN T1.Fromdate AND Isnull( T1.Todate, @eOM ) THEN 1 ELSE 0 END )     
    + Max( CASE WHEN Dateadd( Dd, 17, @BOM ) BETWEEN T1.Fromdate AND Isnull( T1.Todate, @eOM ) THEN 1 ELSE 0 END )     
    + Max( CASE WHEN Dateadd( Dd, 18, @BOM ) BETWEEN T1.Fromdate AND Isnull( T1.Todate, @eOM ) THEN 1 ELSE 0 END )     
    + Max( CASE WHEN Dateadd( Dd, 19, @BOM ) BETWEEN T1.Fromdate AND Isnull( T1.Todate, @eOM ) THEN 1 ELSE 0 END )     
    + Max( CASE WHEN Dateadd( Dd, 20, @BOM ) BETWEEN T1.Fromdate AND Isnull( T1.Todate, @eOM ) THEN 1 ELSE 0 END )     
    + Max( CASE WHEN Dateadd( Dd, 21, @BOM ) BETWEEN T1.Fromdate AND Isnull( T1.Todate, @eOM ) THEN 1 ELSE 0 END )     
    + Max( CASE WHEN Dateadd( Dd, 22, @BOM ) BETWEEN T1.Fromdate AND Isnull( T1.Todate, @eOM ) THEN 1 ELSE 0 END )     
    + Max( CASE WHEN Dateadd( Dd, 23, @BOM ) BETWEEN T1.Fromdate AND Isnull( T1.Todate, @eOM ) THEN 1 ELSE 0 END )     
    + Max( CASE WHEN Dateadd( Dd, 24, @BOM ) BETWEEN T1.Fromdate AND Isnull( T1.Todate, @eOM ) THEN 1 ELSE 0 END )     
    + Max( CASE WHEN Dateadd( Dd, 25, @BOM ) BETWEEN T1.Fromdate AND Isnull( T1.Todate, @eOM ) THEN 1 ELSE 0 END )     
    + Max( CASE WHEN Dateadd( Dd, 26, @BOM ) BETWEEN T1.Fromdate AND Isnull( T1.Todate, @eOM ) THEN 1 ELSE 0 END )     
    + Max( CASE WHEN Dateadd( Dd, 27, @BOM ) BETWEEN T1.Fromdate AND Isnull( T1.Todate, @eOM ) THEN 1 ELSE 0 END )     
    + Max( CASE WHEN (Dateadd( Dd, 28, @BOM ) BETWEEN T1.Fromdate AND Isnull( T1.Todate, @eOM ) ) AND Dateadd( Dd, 28, @BOM ) <= @EOM THEN 1 ELSE 0 END )     
    + Max( CASE WHEN Dateadd( Dd, 29, @BOM ) BETWEEN T1.Fromdate AND Isnull( T1.Todate, @eOM )    AND Dateadd( Dd, 29, @BOM ) <= @EOM THEN 1 ELSE 0 END )     
    + Max( CASE WHEN Dateadd( Dd, 30, @BOM ) BETWEEN T1.Fromdate AND Isnull( T1.Todate, @eOM )    AND Dateadd( Dd, 30, @BOM ) <= @EOM THEN 1 ELSE 0 END ) Dcdaycount        
   FROM #tmpOccupancy T1         
   WHERE ISNULL(todate,@EOM) BETWEEN  @BOM and @EOM        
   GROUP  BY T1.Unitid ,T1.privacyLevelCode      
   ORDER BY 1    
   IF OBJECT_ID ('TempDb..#tmpOccupancyDetailLocal') IS NOT NULL    
       DROP TABLE #tmpOccupancyDetailLocal    
  CREATE TAble #tmpOccupancyDetailLocal (    
      hmy                     NUMERIC,    
   monthstartdate          DATETIME,     
      monthenddate            DATETIME,     
      propertyid              NUMERIC,     
      propertyname            VARCHAR(255),     
      property                VARCHAR(266),     
      propcode                VARCHAR(10),     
      unitid                  NUMERIC,     
      unitcode                VARCHAR(30),     
      carelevelcode           VARCHAR(20),     
      unittypeid              NUMERIC,     
      unittype                VARCHAR(80),     
      unitcapacity            NUMERIC,     
      unitbudgetcapacity      NUMERIC,     
      residentid              NUMERIC,     
      residentname            VARCHAR(100),     
      dtmovein                DATETIME,     
      dtmoveout               DATETIME,     
      serviceinstancefromdate DATETIME,     
      serviceinstancetodate   DATETIME,     
      privacylevelcode        VARCHAR(10),     
      rescarelvlcode          VARCHAR(10),     
      residentstatus          NUMERIC (18, 0),     
      contracttypecode        VARCHAR(10),     
      unitbasedocc            NUMERIC(18, 2),     
      leasebasedocc           NUMERIC(18, 2),     
      unitbaseddcocc          NUMERIC(18, 2),     
      unitexcludeflag         BIT,     
      fromdate                DATETIME,     
      todate                  DATETIME,     
      dcdaycount              NUMERIC,    
   Additionalunit      BIT       
  )    
  INSERT INTO #tmpOccupancyDetailLocal    
   SELECT    
           T.Hmy,    
      @BOMActual MonthStartDate, --???    
      @EOM AsOfDate,    
           Td.Propertyid,    
           Td.Propertyname,    
           Td.Property,    
           Td.Propcode,    
           Td.Unitid,    
           Td.Unitcode,    
           Td.Carelevelcode,    
           Td.Unittypeid,    
           Td.Unittype,    
           Td.Unitcapacity,    
           Td.Unitbudgetcapacity,    
           Isnull( T.Residentid, 0 ) ResidentId,    
           Isnull( T.Residentname, '' ) ResidentName,    
           T.Dtmovein,    
           T.Dtmoveout,    
           T.Serviceinstancefromdate,    
           T.Serviceinstancetodate,    
           Isnull( T.Privacylevelcode, 'PRI' ) PrivaciLevelCode,    
           Isnull( T.Rescarelvlcode, Td.Carelevelcode ) ResCareLevelCode,    
           T.Residentstatus,    
           T.Contracttypecode,    
      CASE  WHEN Isnull( T.Residentid, 0 ) > 0 THEN     
                CASE WHEN T.Privacylevelcode in ( 'PRI') THEN 1     
          WHEN T.Privacylevelcode in ('SEC', 'DAS','DBS','TAS','TBS','TCS','QAS','QBS','QCS','QDS') THEN 0       
                           ELSE T.Occupancy     
       END    
        ELSE 0    
           END Unitbasedocc,             
           CASE WHEN Isnull( T.Residentid, 0 ) > 0 THEN     
               CASE WHEN T.Privacylevelcode in ('SEC', 'DAS','DBS','TAS','TBS','TCS','QAS','QBS','QCS','QDS') THEN 0     
              WHEN T.Privacylevelcode in ( 'PRI') THEN td.UnitCapacity    
              ELSE 1     
       END     
               ELSE 0                           
           END  Leasebasedocc,    
           CASE WHEN ISNULL(T.Residentid,0) > 0 THEN     
               CASE WHEN T.Privacylevelcode in ('SEC', 'DAS','DBS','TAS','TBS','TCS','QAS','QBS','QCS','QDS') THEN 0 ELSE 1 END     
               ELSE 0    
           END Unitbaseddcocc,    
           Td.UnitExcludeFlag,    
           T.Fromdate,    
           T.Todate,    
           Dc.Dccount,    
           ISNULL(T.additionalunit,0) additionalunit    
   FROM #tmpOccupancyDetail Td    
   LEFT JOIN #tmpOccupancy  T ON T.Propertyid = Td.Propertyid AND T.Unitid = Td.Unitid    
               AND 1 = CASE    
                           WHEN @flag IN ( 1, 2, 3 ) THEN    
                            CASE    
                               WHEN (ISNULL(T.Fromdate, @BegDefault) <= @EOM AND ISNULL( T.Todate, '01/01/2100' ) >= @BOM)    
               AND ISNULL(T.Fromdate, @BegDefault) <= ISNULL( T.Todate, '01/01/2100' ) THEN 1    
                                  ELSE 0    
                               END    
                           ELSE 1    
            END    
   LEFT JOIN #TempTbl Dc ON Dc.Unitid = Td.Unitid AND Dc.Privacylevelcode = T.Privacylevelcode AND @Flag IN ( 3, 6 )      
   IF OBJECT_ID ('TempDb..#tmpOccupancyResult') IS NOT NULL    
       DROP TABLE #tmpOccupancyResult    
  CREATE TAble #tmpOccupancyResult (    
      PropertyId              NUMERIC,     
      PropertyName            VARCHAR(255),     
      CareLevelCode           VARCHAR(20),     
   CareLevelName           VARCHAR(100),     
      UnitCount               NUMERIC,     
      UnitCapacity            NUMERIC,     
      MoveInCount             NUMERIC(18, 2),     
      MoveOutCount            NUMERIC(18, 2),     
      UnitOccupiedBeg         NUMERIC(18, 2),    
   UnitOccupiedEnd         NUMERIC(18, 2)      
  )    
  INSERT INTO #tmpOccupancyResult    
   SELECT t.propertyId,    
          t.propertyName,    
    t.carelevelcode,    
    cl.ListOptionName,    
    COUNT(DISTINCT t.unitId) UnitCount,    
    0,     
    0 MoveInCount,    
    0 MoveOutCount,    
    SUM(CASE WHEN (@BOM BETWEEN ISNULL(t.fromdate, @BegDefault) AND @EOM) OR (@BOM BETWEEN ISNULL(t.toDate, @EndDefault) AND @EOM) THEN     
              CASE WHEN @flag IN (1,4) THEN t.unitbasedocc     
                    WHEN @flag IN (2,5) THEN t.leasebasedocc    
                 ELSE t.unitbaseddcocc    
        END    
      ELSE 0    
       END) UnitOccupiedBeg,    
    SUM(CASE WHEN ISNULL(t.todate, @EOM) >= @EOM THEN     
              CASE WHEN @flag IN (1,4) THEN t.unitbasedocc     
                   WHEN @flag IN (2,5) THEN t.leasebasedocc    
          ELSE t.unitbaseddcocc    
        END    
      ELSE 0    
       END) UnitOccupiedEnd    
   FROM #tmpOccupancyDetailLocal t    
   JOIN #tmpCareLevel cl ON t.carelevelcode = cl.ListOptionCode    
   WHERE 1 = 1    
   GROUP BY t.propertyId, t.propertyName, t.carelevelcode, cl.ListOptionName    
  IF @flag IN (3,6)    
  BEGIN    
  UPDATE t SET t.UnitOccupiedBeg = tc.unitbaseddcocc     
  FROM   #tmpOccupancyResult t    
  JOIN (SELECT vu.propertyid, vu.carelevelcode, SUM(vu.unitbaseddcocc ) unitbaseddcocc     
      FROM (SELECT DISTINCT t2.propertyId, t2.CareLevelCode, t2.unitid unitid, MAX(t2.unitbaseddcocc) unitbaseddcocc     
           FROM #tmpOccupancyDetailLocal t2    
           WHERE 1=1    
        AND ISNULL(t2.fromdate, @BegDefault) <= @BOM    
        GROUP BY t2.propertyId, t2.CareLevelCode, t2.unitid    
      ) vu     
     WHERE 1=1      
     GROUP BY vu.propertyid, vu.carelevelcode) tc ON (t.PropertyId = tc.propertyid AND t.CareLevelCode = tc.carelevelcode)    
  WHERE 1 = 1    
  UPDATE t SET t.UnitOccupiedEnd = tc.unitbaseddcocc     
  FROM   #tmpOccupancyResult t    
  JOIN (SELECT vu.propertyid, vu.carelevelcode, SUM(vu.unitbaseddcocc ) unitbaseddcocc     
      FROM (SELECT DISTINCT t2.propertyId, t2.CareLevelCode, t2.unitid unitid, MAX(t2.unitbaseddcocc) unitbaseddcocc     
           FROM #tmpOccupancyDetailLocal t2    
           WHERE 1=1    
        AND ISNULL(t2.todate, @EOM) >= @EOM     
        GROUP BY t2.propertyId, t2.CareLevelCode, t2.unitid    
      ) vu     
     WHERE 1=1      
     GROUP BY vu.propertyid, vu.carelevelcode) tc ON (t.PropertyId = tc.propertyid AND t.CareLevelCode = tc.carelevelcode)    
  WHERE 1 = 1    
  END      
  IF @flag IN (1,3,4,6, 2,5)    
  BEGIN    
  UPDATE t SET t.UnitCapacity = tc.UnitCapacity    
  FROM   #tmpOccupancyResult t    
  JOIN (SELECT vu.propertyid, vu.carelevelcode, SUM(vu.UnitCapacity ) UnitCapacity    
      FROM (SELECT DISTINCT t2.propertyId, t2.CareLevelCode, t2.unitid unitid, t2.UnitCapacity UnitCapacity     
           FROM #tmpOccupancyDetailLocal t2    
          WHERE 1=1    
      ) vu     
     WHERE 1=1      
     GROUP BY vu.propertyid, vu.carelevelcode) tc ON (t.PropertyId = tc.propertyid AND t.CareLevelCode = tc.carelevelcode)    
  WHERE 1 = 1    
  END      
  IF OBJECT_ID ('TempDb..#ResidentMoveInOutCountTmp') IS NOT NULL    
      DROP TABLE #ResidentMoveInOutCountTmp    
  CREATE TABLE #ResidentMoveInOutCountTmp    
  (    
   PropertyId                NUMERIC ,     
   UnitId                    NUMERIC,    
   ResidentId                NUMERIC,    
   CareLevelCodeIn           VARCHAR(50),    
   CareLevelCodeOut          VARCHAR(50),    
   dtMoveIn                  DATETIME,    
   dtMoveOut                 DATETIME    
   )    
  IF OBJECT_ID ('TempDb..#ResidentMoveInOutCount') IS NOT NULL    
      DROP TABLE #ResidentMoveInOutCount    
  CREATE TABLE #ResidentMoveInOutCount    
  (    
   PropertyId                NUMERIC ,     
   UnitId                    NUMERIC,    
   CareLevelCodeIn           VARCHAR(50),    
   CareLevelCodeOut          VARCHAR(50),    
   MoveInCount         NUMERIC(18, 2),    
   MoveOutCount        NUMERIC(18, 2)    
   )    
  IF @flag IN (1,2,3)    
  BEGIN    
      UPDATE sd    
   SET sd.RemoveFlag=0, sd.bMoveOut = 0, sd.bMoveIn = 0    
   FROM #ResidentHistoryStatus sd    
   --Correct multi rows disregarding Privacy level, unit changes    
   UPDATE sd    
   SET sd.RemoveFlag=1, sd.bMoveOut = 1    
   FROM #ResidentHistoryStatus sd    
   INNER JOIN #ResidentHistoryStatus sd1 ON sd.hresident=sd1.hresident    
                                     --AND sd.unitid=sd1.unitid     
             --AND sd.PrivacyLevelCode=sd1.PrivacyLevelCode     
                                    --AND sd.CareLevelCode = sd1.CareLevelCode AND sd.ServiceID = sd1.ServiceID    
                                     AND sd.dtFrom = DATEADD(dd,1,sd1.dtTo)    
  UPDATE sd    
  SET    sd.RemoveFlag = 2, sd.bMoveOut = 1    
  FROM   #ResidentHistoryStatus sd    
         INNER JOIN #ResidentHistoryStatus sd1    
                 ON sd.hResident = sd1.hResident    
                    --AND sd.unitid = sd1.unitid    
                    --AND sd.PrivacyLevelCode = sd1.PrivacyLevelCode    
                    --AND sd.CareLevelCode = sd1.CareLevelCode    
                    AND sd.dtFrom = DATEADD(dd, 1, sd1.dtTo)     
  WHERE ISNULL(sd.RemoveFlag,0) in (1, 0) AND ISNULL(sd1.RemoveFlag,0) = 1     
  UPDATE sd    
  SET    sd.RemoveFlag = 3, sd.bMoveOut = 1    
  FROM   #ResidentHistoryStatus sd    
         INNER JOIN #ResidentHistoryStatus sd1    
                 ON sd.hResident = sd1.hResident    
                    --AND sd.unitid = sd1.unitid    
                    --AND sd.PrivacyLevelCode = sd1.PrivacyLevelCode    
                    --AND sd.CareLevelCode = sd1.CareLevelCode    
                    AND sd.dtFrom = DATEADD(dd, 1, sd1.dtTo)     
  WHERE ISNULL(sd.RemoveFlag,0) in (1, 2) AND ISNULL(sd1.RemoveFlag,0) = 2     
  UPDATE sd    
    SET  sd.bMoveIn = 1    
   FROM #ResidentHistoryStatus sd    
   WHERE ISNULL(sd.RemoveFlag,0) = 0    
   AND  sd.dtFrom BETWEEN @BOMActual AND @EOM    
  UPDATE sd    
    SET  sd.bMoveOut = 1    
   FROM #ResidentHistoryStatus sd    
   LEFT JOIN #ResidentHistoryStatus sd1 ON sd.hResident = sd1.hresident    
                    --AND sd.unitid = sd1.unitid    
                    --AND sd.PrivacyLevelCode = sd1.PrivacyLevelCode    
        AND ISNULL(sd1.RemoveFlag, 0) = 1    
    WHERE ISNULL(sd.RemoveFlag,0) = 0    
    AND sd1.hResident IS NULL    
  UPDATE sd    
    SET  sd.bMoveOut = 0    
   FROM #ResidentHistoryStatus sd    
   LEFT JOIN #ResidentHistoryStatus sd1 ON sd.hResident = sd1.hresident    
                    --AND sd.unitid = sd1.unitid    
                    --AND sd.PrivacyLevelCode = sd1.PrivacyLevelCode    
        AND ISNULL(sd1.RemoveFlag, 0) = 2    
    WHERE ISNULL(sd.RemoveFlag,0) = 1    
    AND sd1.hResident IS NOT NULL    
  UPDATE sd    
    SET  sd.bMoveOut = 0    
   FROM #ResidentHistoryStatus sd    
   LEFT JOIN #ResidentHistoryStatus sd1 ON sd.hResident = sd1.hresident    
                    --AND sd.unitid = sd1.unitid    
                    --AND sd.PrivacyLevelCode = sd1.PrivacyLevelCode    
        AND ISNULL(sd1.RemoveFlag, 0) = 3    
    WHERE ISNULL(sd.RemoveFlag,0) = 2    
    AND sd1.hResident IS NOT NULL    
  UPDATE sd    
    SET  sd.bMoveOut = 0    
  FROM #ResidentHistoryStatus sd    
  WHERE ISNULL(sd.dtTo, @EndDefault) > CASE @IncludeMoveOutDate WHEN 'No' THEN @EOM ELSE DATEADD(dd, 1,  @EOM) END    
  AND sd.bMoveOut = 1    
   INSERT INTO #ResidentMoveInOutCount (    
                            PropertyId   ,     
                            UnitId         ,    
                            CareLevelCodeIn  ,    
                            CareLevelCodeOut   ,    
                            MoveInCount        ,    
                            MoveOutCount)    
   SELECT sd.hProperty, 0, su.CareLevelCode, '', SUM(ISNULL(sd.bMoveIn, 0)) MoveInCount, 0    
   FROM   #ResidentHistoryStatus sd     
   JOIN SeniorUnit su ON (sd.UnitId = su.UnitID) -- Use unit Carelevel    
   WHERE 1 = 1    
   AND sd.dtFrom BETWEEN @BOMActual AND @EOM    
   AND ISNULL(sd.bMoveIn, 0) = 1  AND @flag in (2,3)  
   GROUP BY sd.hProperty, su.CareLevelCode    
   INSERT INTO #ResidentMoveInOutCount (    
                            PropertyId   ,     
                            UnitId         ,    
                            CareLevelCodeIn  ,    
                            CareLevelCodeOut   ,    
                            MoveInCount        ,    
                            MoveOutCount)    
   SELECT t.HPROPERTY, 0, su.CareLevelCode, '', COUNT(au.hResident) MoveInCount, 0    
   FROM #ResidentHistoryStatusAdditionalUnit au    
   JOIN Tenant t ON au.hResident = t.HMYPERSON    
   JOIN SeniorUnit su ON (au.UnitId = su.UnitID) -- Use unit Carelevel    
   WHERE 1 = 1    
   AND au.dtStartdate BETWEEN @BOMActual AND @EOM  AND @flag in (2,3)  
   GROUP BY t.hProperty, su.CareLevelCode    
   INSERT INTO #ResidentMoveInOutCount (    
                            PropertyId   ,     
                            UnitId         ,    
                            CareLevelCodeIn  ,    
                            CareLevelCodeOut   ,    
                            MoveInCount        ,    
                            MoveOutCount)    
   SELECT t.HPROPERTY, 0, '', su.CareLevelCode, 0, COUNT(au.hResident) MoveOutCount    
   FROM #ResidentHistoryStatusAdditionalUnit au    
   JOIN Tenant t ON au.hResident = t.HMYPERSON    
   JOIN SeniorUnit su ON (au.UnitId = su.UnitID) -- Use unit Carelevel    
   WHERE 1 = 1  AND @flag in (2,3)  
   AND ISNULL(au.dtEnddate, @EndDefault) BETWEEN CASE @IncludeMoveOutDate WHEN 'No' THEN @BOMActual ELSE @BOM END AND CASE @IncludeMoveOutDate WHEN 'No' THEN @EOM ELSE DATEADD(dd, -1, @EOM) END    
   GROUP BY t.hProperty, su.CareLevelCode    
   INSERT INTO #ResidentMoveInOutCount (    
                            PropertyId       ,     
                            UnitId           ,    
                            CareLevelCodeIn  ,    
                            CareLevelCodeOut ,    
                            MoveInCount      ,    
                            MoveOutCount)    
   SELECT sd.hProperty, 0, '', su.CareLevelCode, 0, SUM(ISNULL(sd.bMoveOut, 0))     
   FROM   #ResidentHistoryStatus sd     
   JOIN SeniorUnit su ON (sd.UnitId = su.UnitID) -- Use unit Carelevel    
   WHERE 1 = 1    
   AND ISNULL(sd.dtTo, @EndDefault) BETWEEN CASE @IncludeMoveOutDate WHEN 'No' THEN @BOMActual ELSE @BOM END AND CASE @IncludeMoveOutDate WHEN 'No' THEN @EOM ELSE DATEADD(dd, -1, @EOM) END    
   AND ISNULL(sd.bMoveOut, 0) = 1   AND @flag in (2,3)  
   GROUP BY sd.hProperty, su.CareLevelCode    
   --for Physical Unit based  
   INSERT INTO #ResidentMoveInOutCount (    
                            PropertyId   ,     
                            UnitId         ,    
                            CareLevelCodeIn  ,    
                            CareLevelCodeOut   ,    
                            MoveInCount        ,    
                            MoveOutCount)    
   SELECT sd.hProperty, 0, su.CareLevelCode, '', sum( CASE WHEN (sd.PrivacyLevelCode = 'PRI') then 1  
   WHEN (sd.PrivacyLevelCode IN ('SPA', 'SPB')) then 0.50  
   WHEN (sd.PrivacyLevelCode IN ('TOA', 'TOB', 'TOC')) then 0.33  
   WHEN (sd.PrivacyLevelCode IN ('QDA', 'QDB', 'QDC', 'QDD')) then 0.25  
  else 0  
  end) AS MoveInCount, 0    
   FROM   #ResidentHistoryStatus sd     
   JOIN SeniorUnit su ON (sd.UnitId = su.UnitID) -- Use unit Carelevel    
   WHERE 1 = 1    
   AND sd.dtFrom BETWEEN @BOMActual AND @EOM    
   AND ISNULL(sd.bMoveIn, 0) = 1  AND @flag = 1  
   GROUP BY sd.hProperty, su.CareLevelCode    
   INSERT INTO #ResidentMoveInOutCount (    
                            PropertyId   ,     
                            UnitId         ,    
                            CareLevelCodeIn  ,    
                            CareLevelCodeOut   ,    
                            MoveInCount        ,    
                            MoveOutCount)    
   SELECT t.HPROPERTY, 0, su.CareLevelCode, '', sum( CASE WHEN (au.PrivacyLevelCode = 'PRI') then 1  
   WHEN (au.PrivacyLevelCode IN ('SPA', 'SPB')) then 0.50  
   WHEN (au.PrivacyLevelCode IN ('TOA', 'TOB', 'TOC')) then 0.33  
   WHEN (au.PrivacyLevelCode IN ('QDA', 'QDB', 'QDC', 'QDD')) then 0.25  
  else 0  
  end) AS MoveInCount, 0    
   FROM #ResidentHistoryStatusAdditionalUnit au    
   JOIN Tenant t ON au.hResident = t.HMYPERSON    
   JOIN SeniorUnit su ON (au.UnitId = su.UnitID) -- Use unit Carelevel    
   WHERE 1 = 1    
   AND au.dtStartdate BETWEEN @BOMActual AND @EOM  AND @flag = 1  
   GROUP BY t.hProperty, su.CareLevelCode    
   INSERT INTO #ResidentMoveInOutCount (    
                            PropertyId   ,     
                            UnitId         ,    
                            CareLevelCodeIn  ,    
                            CareLevelCodeOut   ,    
                            MoveInCount        ,    
                            MoveOutCount)    
   SELECT t.HPROPERTY, 0, '', su.CareLevelCode, 0, sum( CASE WHEN (au.PrivacyLevelCode = 'PRI') then 1  
   WHEN (au.PrivacyLevelCode IN ('SPA', 'SPB')) then 0.50  
   WHEN (au.PrivacyLevelCode IN ('TOA', 'TOB', 'TOC')) then 0.33  
   WHEN (au.PrivacyLevelCode IN ('QDA', 'QDB', 'QDC', 'QDD')) then 0.25  
  else 0  
  end) AS MoveOutCount    
   FROM #ResidentHistoryStatusAdditionalUnit au    
   JOIN Tenant t ON au.hResident = t.HMYPERSON    
   JOIN SeniorUnit su ON (au.UnitId = su.UnitID) -- Use unit Carelevel    
   WHERE 1 = 1  AND @flag = 1  
   AND ISNULL(au.dtEnddate, @EndDefault) BETWEEN CASE @IncludeMoveOutDate WHEN 'No' THEN @BOMActual ELSE @BOM END AND CASE @IncludeMoveOutDate WHEN 'No' THEN @EOM ELSE DATEADD(dd, -1, @EOM) END    
   GROUP BY t.hProperty, su.CareLevelCode    
   INSERT INTO #ResidentMoveInOutCount (    
                            PropertyId       ,     
                            UnitId           ,    
                            CareLevelCodeIn  ,    
                            CareLevelCodeOut ,    
                            MoveInCount      ,    
                            MoveOutCount)    
   SELECT sd.hProperty, 0, '', su.CareLevelCode, 0, sum( CASE WHEN (sd.PrivacyLevelCode = 'PRI') then 1  
   WHEN (sd.PrivacyLevelCode IN ('SPA', 'SPB')) then 0.50  
   WHEN (sd.PrivacyLevelCode IN ('TOA', 'TOB', 'TOC')) then 0.33  
   WHEN (sd.PrivacyLevelCode IN ('QDA', 'QDB', 'QDC', 'QDD')) then 0.25  
  else 0  
  end)     
   FROM   #ResidentHistoryStatus sd     
   JOIN SeniorUnit su ON (sd.UnitId = su.UnitID) -- Use unit Carelevel    
   WHERE 1 = 1    
   AND ISNULL(sd.dtTo, @EndDefault) BETWEEN CASE @IncludeMoveOutDate WHEN 'No' THEN @BOMActual ELSE @BOM END AND CASE @IncludeMoveOutDate WHEN 'No' THEN @EOM ELSE DATEADD(dd, -1, @EOM) END    
   AND ISNULL(sd.bMoveOut, 0) = 1   AND @flag =1  
   GROUP BY sd.hProperty, su.CareLevelCode    
  END    
  IF @flag IN (4,5,6)    
  BEGIN    
      /*To set MoveIN/Out disregard privacylevel, carelevel, unit*/    
   UPDATE sd    
    SET sd.RemoveFlag=0, sd.bMoveOut = 0, sd.bMoveIn = 0    
    FROM #ServiceDateRange sd    
   UPDATE sd    
    SET sd.RemoveFlag=1, sd.bMoveOut = 1    
    FROM #ServiceDateRange sd    
    INNER JOIN #ServiceDateRange sd1 ON sd.residentid=sd1.residentid     
              AND sd.serviceInstanceFromDate = DATEADD(dd,1,sd1.ServiceInstanceToDate)    
   UPDATE sd    
   SET    sd.RemoveFlag = 2, sd.bMoveOut = 1    
   FROM   #ServiceDateRange sd    
       INNER JOIN #ServiceDateRange sd1    
         ON sd.ResidentId = sd1.residentid    
         AND sd.ServiceInstanceFromDate = DATEADD(dd, 1, sd1.ServiceInstanceToDate)     
   WHERE ISNULL(sd.RemoveFlag,0) IN (1, 0) AND ISNULL(sd1.RemoveFlag,0) = 1     
  UPDATE sd    
  SET    sd.RemoveFlag = 3, sd.bMoveOut = 1    
  FROM   #ServiceDateRange sd    
         INNER JOIN #ServiceDateRange sd1    
                 ON sd.ResidentId = sd1.residentid    
                    --AND sd.unitid = sd1.unitid --02/25/2021: Removed unit condition    
                    --AND sd.PrivacyLevelCode = sd1.PrivacyLevelCode    
                    --AND sd.CareLevelCode = sd1.CareLevelCode    
                    AND sd.ServiceInstanceFromDate = DATEADD(dd, 1, sd1.ServiceInstanceToDate)     
  WHERE ISNULL(sd.RemoveFlag,0) IN (1, 2) AND ISNULL(sd1.RemoveFlag,0) = 2     
   UPDATE sd    
     SET  sd.bMoveIn = 1    
    FROM #ServiceDateRange sd    
    WHERE ISNULL(sd.RemoveFlag,0) = 0    
    AND  sd.ServiceInstanceFromDate BETWEEN @BOMActual AND @EOM    
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
                    --AND sd.unitid = sd1.unitid --02/25/2021: Removed unit condition    
                    --AND sd.PrivacyLevelCode = sd1.PrivacyLevelCode    
 AND ISNULL(sd1.RemoveFlag, 0) = 3    
    WHERE ISNULL(sd.RemoveFlag,0) = 2    
    AND sd1.ResidentId IS NOT NULL    
   UPDATE sd    
     SET  sd.bMoveOut = 0    
   FROM #ServiceDateRange sd    
   WHERE ISNULL(sd.ServiceInstanceToDate, @EndDefault) > CASE @IncludeMoveOutDate WHEN 'No' THEN @EOM ELSE DATEADD(dd, 1,  @EOM) END    
   AND sd.bMoveOut = 1    
   INSERT INTO #ResidentMoveInOutCount (    
                            PropertyId   ,     
                            UnitId         ,    
                            --ResidentId    ,    
                            CareLevelCodeIn  ,    
                            CareLevelCodeOut   ,    
                            MoveInCount        ,    
                            MoveOutCount)    
   SELECT sd.PropertyId, 0, su.CareLevelCode, '', SUM(ISNULL(sd.bMoveIn, 0)) MoveInCount, 0    
   FROM   #ServiceDateRange sd     
   JOIN SeniorUnit su ON (sd.UnitId = su.UnitID) -- Use unit Carelevel    
   WHERE 1 = 1    
   AND sd.ServiceInstanceFromDate BETWEEN @BOMActual AND @EOM    
   AND ISNULL(sd.bMoveIn, 0) = 1  AND @flag in (5,6)  
   GROUP BY sd.PropertyId, su.CareLevelCode    
   INSERT INTO #ResidentMoveInOutCount (    
                            PropertyId   ,     
                            UnitId         ,    
                            CareLevelCodeIn  ,    
                            CareLevelCodeOut   ,    
                            MoveInCount        ,    
                            MoveOutCount)    
   SELECT t.HPROPERTY, 0, su.CareLevelCode, '', COUNT(au.ResidentId) MoveInCount, 0    
   FROM #ServiceInstanceAdditionalUnit au    
   JOIN Tenant t ON au.Residentid = t.HMYPERSON    
   JOIN SeniorUnit su ON (au.UnitId = su.UnitID) -- Use unit Carelevel    
   WHERE 1 = 1    
   AND au.Recurringchargefromdate BETWEEN @BOMActual AND @EOM   AND @flag in (5,6)  
   GROUP BY t.hProperty, su.CareLevelCode    
   INSERT INTO #ResidentMoveInOutCount (    
                            PropertyId   ,     
                            UnitId         ,    
                            CareLevelCodeIn  ,    
                            CareLevelCodeOut   ,    
                            MoveInCount        ,    
                            MoveOutCount)    
   SELECT t.HPROPERTY, 0, '', su.CareLevelCode, 0, COUNT(au.ResidentId) MoveOutCount    
   FROM #ServiceInstanceAdditionalUnit au    
   JOIN Tenant t ON au.Residentid = t.HMYPERSON    
   JOIN SeniorUnit su ON (au.UnitId = su.UnitID) -- Use unit Carelevel    
   WHERE 1 = 1   AND @flag in (5,6)  
   AND ISNULL(au.Recurringchargetodate, @EndDefault) BETWEEN CASE @IncludeMoveOutDate WHEN 'No' THEN @BOMActual ELSE @BOM END AND CASE @IncludeMoveOutDate WHEN 'No' THEN @EOM ELSE DATEADD(dd, -1, @EOM) END    
   GROUP BY t.hProperty, su.CareLevelCode    
   INSERT INTO #ResidentMoveInOutCount (    
                            PropertyId       ,     
                            UnitId           ,    
                            CareLevelCodeIn  ,    
                            CareLevelCodeOut ,    
                            MoveInCount      ,    
                            MoveOutCount)    
   SELECT sd.PropertyId, 0, '', su.CareLevelCode, 0, SUM(ISNULL(sd.bMoveOut, 0))     
   FROM   #ServiceDateRange sd     
   JOIN SeniorUnit su ON (sd.UnitId = su.UnitID) -- Use unit Carelevel    
   WHERE 1 = 1    
   AND ISNULL(sd.ServiceInstanceToDate, @EndDefault) BETWEEN CASE @IncludeMoveOutDate WHEN 'No' THEN @BOMActual ELSE @BOM END AND CASE @IncludeMoveOutDate WHEN 'No' THEN @EOM ELSE DATEADD(dd, -1, @EOM) END    
   AND ISNULL(sd.bMoveOut, 0) = 1   AND @flag in (5,6)  
   GROUP BY sd.PropertyId, su.CareLevelCode   
   --financiial unit based  
    INSERT INTO #ResidentMoveInOutCount (    
                            PropertyId   ,     
                            UnitId         ,    
                            --ResidentId    ,    
                            CareLevelCodeIn  ,    
                            CareLevelCodeOut   ,    
                            MoveInCount        ,    
                      MoveOutCount)    
   SELECT sd.PropertyId, 0, su.CareLevelCode, '', sum( CASE WHEN (sd.PrivacyLevelCode = 'PRI') then 1  
   WHEN (sd.PrivacyLevelCode IN ('SPA', 'SPB')) then 0.50  
   WHEN (sd.PrivacyLevelCode IN ('TOA', 'TOB', 'TOC')) then 0.33  
   WHEN (sd.PrivacyLevelCode IN ('QDA', 'QDB', 'QDC', 'QDD')) then 0.25  
  else 0  
  end) AS MoveInCount, 0    
   FROM   #ServiceDateRange sd     
   JOIN SeniorUnit su ON (sd.UnitId = su.UnitID) -- Use unit Carelevel    
   WHERE 1 = 1    
   AND sd.ServiceInstanceFromDate BETWEEN @BOMActual AND @EOM    
   AND ISNULL(sd.bMoveIn, 0) = 1  AND @flag = 4  
   GROUP BY sd.PropertyId, su.CareLevelCode    
   INSERT INTO #ResidentMoveInOutCount (    
                            PropertyId   ,     
                            UnitId         ,    
                            CareLevelCodeIn  ,    
                            CareLevelCodeOut   ,    
                            MoveInCount        ,    
                            MoveOutCount)    
   SELECT t.HPROPERTY, 0, su.CareLevelCode, '', sum( CASE WHEN (au.PrivacyLevelCode = 'PRI') then 1  
   WHEN (au.PrivacyLevelCode IN ('SPA', 'SPB')) then 0.50  
   WHEN (au.PrivacyLevelCode IN ('TOA', 'TOB', 'TOC')) then 0.33  
   WHEN (au.PrivacyLevelCode IN ('QDA', 'QDB', 'QDC', 'QDD')) then 0.25  
  else 0  
  end) AS MoveInCount, 0    
   FROM #ServiceInstanceAdditionalUnit au    
   JOIN Tenant t ON au.Residentid = t.HMYPERSON    
   JOIN SeniorUnit su ON (au.UnitId = su.UnitID) -- Use unit Carelevel    
   WHERE 1 = 1    
   AND au.Recurringchargefromdate BETWEEN @BOMActual AND @EOM   AND @flag = 4  
   GROUP BY t.hProperty, su.CareLevelCode    
   INSERT INTO #ResidentMoveInOutCount (    
                            PropertyId   ,     
                            UnitId         ,    
                            CareLevelCodeIn  ,    
                            CareLevelCodeOut   ,    
                            MoveInCount        ,    
                            MoveOutCount)    
   SELECT t.HPROPERTY, 0, '', su.CareLevelCode, 0, sum( CASE WHEN (au.PrivacyLevelCode = 'PRI') then 1  
   WHEN (au.PrivacyLevelCode IN ('SPA', 'SPB')) then 0.50  
   WHEN (au.PrivacyLevelCode IN ('TOA', 'TOB', 'TOC')) then 0.33  
   WHEN (au.PrivacyLevelCode IN ('QDA', 'QDB', 'QDC', 'QDD')) then 0.25  
  else 0  
  end) AS MoveOutCount    
   FROM #ServiceInstanceAdditionalUnit au    
   JOIN Tenant t ON au.Residentid = t.HMYPERSON    
   JOIN SeniorUnit su ON (au.UnitId = su.UnitID) -- Use unit Carelevel    
   WHERE 1 = 1    AND @flag = 4  
   AND ISNULL(au.Recurringchargetodate, @EndDefault) BETWEEN CASE @IncludeMoveOutDate WHEN 'No' THEN @BOMActual ELSE @BOM END AND CASE @IncludeMoveOutDate WHEN 'No' THEN @EOM ELSE DATEADD(dd, -1, @EOM) END    
   GROUP BY t.hProperty, su.CareLevelCode    
   INSERT INTO #ResidentMoveInOutCount (    
                            PropertyId       ,     
                            UnitId           ,    
                            CareLevelCodeIn  ,    
                            CareLevelCodeOut ,    
                            MoveInCount      ,    
                            MoveOutCount)    
   SELECT sd.PropertyId, 0, '', su.CareLevelCode, 0, sum( CASE WHEN (sd.PrivacyLevelCode = 'PRI') then 1  
   WHEN (sd.PrivacyLevelCode IN ('SPA', 'SPB')) then 0.50  
   WHEN (sd.PrivacyLevelCode IN ('TOA', 'TOB', 'TOC')) then 0.33  
   WHEN (sd.PrivacyLevelCode IN ('QDA', 'QDB', 'QDC', 'QDD')) then 0.25  
  else 0  
  end) AS  MoveOutCount  
   FROM   #ServiceDateRange sd     
   JOIN SeniorUnit su ON (sd.UnitId = su.UnitID) -- Use unit Carelevel    
   WHERE 1 = 1    
   AND ISNULL(sd.ServiceInstanceToDate, @EndDefault) BETWEEN CASE @IncludeMoveOutDate WHEN 'No' THEN @BOMActual ELSE @BOM END AND CASE @IncludeMoveOutDate WHEN 'No' THEN @EOM ELSE DATEADD(dd, -1, @EOM) END    
   AND ISNULL(sd.bMoveOut, 0) = 1   AND @flag = 4  
   GROUP BY sd.PropertyId, su.CareLevelCode    
  END    
  UPDATE t SET t.MoveInCount = tc.MoveInCount    
  FROM   #tmpOccupancyResult t    
  JOIN (SELECT ttc.PropertyId, ISNULL(ttc.CareLevelCodeIn, '') CareLevelCode, SUM(ttc.MoveInCount) MoveInCount    
          FROM #ResidentMoveInOutCount ttc    
         WHERE 1 = 1    
           AND ISNULL(ttc.CareLevelCodeIn, '') <> ''    
    GROUP BY ttc.PropertyId, ISNULL(ttc.CareLevelCodeIn, '')) tc    
         ON (t.PropertyId = tc.PropertyId AND t.CareLevelCode = tc.CareLevelCode)     
   WHERE 1 = 1    
   AND   ISNULL(tc.CareLevelCode, '') <> ''    
  UPDATE t SET t.MoveOutCount = tc.MoveOutCount    
  FROM   #tmpOccupancyResult t    
  JOIN (SELECT ttc.PropertyId, ISNULL(ttc.CareLevelCodeOut, '') CareLevelCode, SUM(ttc.MoveOutCount) MoveOutCount    
          FROM #ResidentMoveInOutCount ttc    
         WHERE 1 = 1    
           AND ISNULL(ttc.CareLevelCodeOut, '') <> ''    
    GROUP BY ttc.PropertyId, ISNULL(ttc.CareLevelCodeOut, '')) tc    
             ON (t.PropertyId = tc.PropertyId AND t.CareLevelCode = tc.CareLevelCode)     
   WHERE 1 = 1    
   AND ISNULL(tc.CareLevelCode, '') <> ''    
  SELECT t.PropertyId             ,                  
      t.PropertyName              ,     
      t.CareLevelCode             ,     
   t.CareLevelName             ,     
      ISNULL(t.UnitCount, 0)  UnitCount    ,     
      ISNULL(t.UnitCapacity, 0) UnitCapacity   ,     
      ISNULL(t.MoveInCount, 0) MoveInCount    ,        ISNULL(t.MoveOutCount, 0) MoveOutCount   ,     
      ISNULL(t.UnitOccupiedBeg, 0) UnitOccupiedBeg ,    
   ISNULL(t.UnitOccupiedEnd, 0) UnitOccupiedEnd    
  FROM #tmpOccupancyResult t    
  ORDER BY t.PropertyName, t.CareLevelCode    
  END    