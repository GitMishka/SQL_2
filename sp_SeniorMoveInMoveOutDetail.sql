--sp_helptext SeniorMoveInMoveOutDetail
 --CREATE PROCEDURE SeniorMoveInMoveOutDetail(  
  declare
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
 -- )    
 --AS    
 -- BEGIN  
 -- IF ISNULL(@carelev,'') = ''   
 --  SELECT @carelev =  ISNULL(@carelev,'') + COALESCE(LTRIM(RTRIM(listoptioncode)), '') + ',' FROM listoption WHERE ListName='CareLevel'  
 -- ELSE SET @carelev= LEFT(@carelev,len(@carelev)-1)  
 -- IF ISNULL(@ResStatus,'') = ''   
 --  SELECT @ResStatus = ISNULL(@ResStatus,'') + COALESCE(LTRIM(RTRIM(iStatus)), '') + ',' FROM SeniorResidentStatus WHERE status NOT IN ('Applicant','Prospect')  
 -- ELSE SET @ResStatus= LEFT(@ResStatus,len(@ResStatus)-1)  
 -- IF ISNULL(@ContTyp,'') = ''   
 --  SELECT @ContTyp = ISNULL(@ContTyp,'') + COALESCE(l1.listoptioncode, '') + ',' FROM listoption l1 WHERE l1.listname='ContractType'  
 -- ELSE SET @ContTyp= LEFT(@ContTyp,len(@ContTyp)-1)   
    
    
    
  /*Common code for Move in attributes */  
  IF(@type ='MoveIn')  
  BEGIN    
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
    FROM dbo.Senior_ListHandler(@PropertyCode, 'sCode') x      
      INNER JOIN Property p ON LTRIM(RTRIM(x.sCode)) = LTRIM(RTRIM(p.sCode))   
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
   CREATE TABLE #ActMInoutRes  
    (  
     hResident NUMERIC(18, 0),  
     srhhmy NUMERIC(18, 0)  
    )  
     
   /* Code will list all MIN & MAX hmy for ResidentHistoryStatus for MoveIn & MoveOut,  
    Code optimizes reads as selective Hmy are passed to detail query*/  
   INSERT INTO #ActMInoutRes  
   SELECT Srh1.hResident,Case when @type ='Movein' then MIN(srh1.hmy)  
        when @type ='MoveOut' then MAX(srh1.hmy) end srhhmy     
   FROM dbo.Senior_ListHandler(@PropertyCode, 'sCode') x      
    INNER JOIN Property p ON LTRIM(RTRIM(x.sCode)) = LTRIM(RTRIM(p.sCode))   
    INNER JOIN ListProp2 l  ON l.hProplist = p.hmy AND l.iType <> 11  
    INNER join SeniorResidentHistoryStatus srh1 ON p.hmy = srh1.hProperty  
   WHERE srh1.dtFROM <= ISNULL(srh1.dtto, srh1.dtfrom)     
    AND srh1.dtFROM <= CONVERT(DATETIME, @sDat2, 101)  
    AND 1= Case when @type ='Movein' AND srh1.iStatuscode NOT IN (2,8,7) then 1  
       when @type ='MoveOut' AND (srh1.istatuscode =1 OR srh1.bOnNotice = 1 ) then 1  
       ELSE 0 END  
    AND Case when @type ='Movein' then dtMoveIn  
      when @type ='MoveOut' then dtMoveOut end   
     between CONVERT(DATETIME, @sDat1, 101) and CONVERT(DATETIME, @sDat2, 101)       
   GROUP BY hResident,Case when @type ='Movein' then dtMoveIn  
          when @type ='MoveOut' then dtMoveOut end   
              
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
   /*Code to gather detail data for actual MoveIn MoveOut*/  
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
     INNER JOIN Senior_ListHandler(@carelev,'') CrHnd ON CrHnd.scode = ISNULL(srh.sCareLevelCode,sr.CareLevelcode)  
     INNER JOIN Senior_ListHandler(@ContTyp,'') ConHnd ON ConHnd.scode = srh.sContractTypeCode  
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
     
   /*Code for Move In Actual*/   
   IF(@type ='MoveIn')  
   BEGIN  
    CREATE TABLE #TempResidentHistoryStatus  
    (  
      ID NUMERIC,  
      hResident NUMERIC(18, 0),  
      dtMoveIn DATETIME,  
      dtMoveOut DATETIME,  
      ServiceInstanceID NUMERIC(18, 0)  
    )  
    /*Moveout is null to include current residents also, if dtMoveOut selected in same query then logic needs to be added   
      to remove NULL moveout enties for NON-Current residents in respective multiple In-Out combinations */  
    INSERT INTO #TempResidentHistoryStatus  
    SELECT Distinct 1, hResident, dtMovein, NULL dtMoveOut, NULL ServiceInstanceID  
    FROM dbo.Senior_ListHandler(@PropertyCode, 'sCode') x      
     INNER JOIN Property p ON LTRIM(RTRIM(x.sCode)) = LTRIM(RTRIM(p.sCode))   
     INNER JOIN ListProp2 l ON l.hProplist = p.hmy AND l.iType <> 11  
     INNER join SeniorResidentHistoryStatus srh2  on p.hmy = srh2.hProperty  
    WHERE srh2.dtFROM <= ISNULL(srh2.dtto, srh2.dtfrom)    
     AND srh2.dtFROM <= CONVERT(DATETIME, @sDat2, 101)  
      
    /* This will update ID in sequence of movein's*/  
    UPDATE  #TempResidentHistoryStatus SET ID = Rownum  
    FROM #TempResidentHistoryStatus tmp  
     Inner join (SELECT Row_Number() Over (partition by hResident ORDER BY dtMovein) rownum,* FROM #TempResidentHistoryStatus) a on a.hResident = tmp.hResident   
     AND a.dtMovein = tmp.dtMovein  
    /* Update correct Move-out date for respective movein*/  
    UPDATE  #TempResidentHistoryStatus SET dtMoveOut = srh2.dtMoveOut  
    FROM SeniorResidentHistoryStatus srh2   
     INNER JOIN #TempResidentHistoryStatus tmp on tmp.hResident = srh2.hResident  
    WHERE Srh2.dtMovein  = tmp.dtMovein  
     AND srh2.dtFROM <= ISNULL(srh2.dtto, srh2.dtfrom)    
     AND srh2.dtFROM <= CONVERT(DATETIME, @sDat2, 101)  
     AND srh2.istatuscode =1   
    CREATE TABLE #mintemp1  
    (  
      ID NUMERIC,  
      hResident NUMERIC(18, 0),  
      dtMoveIn DATETIME,  
      ServiceInstanceID NUMERIC(18, 0)  
    )  
    /*In multiple Move in scenario, each movein will get respective Minimum serviceinstanceid*/  
    INSERT INTO #mintemp1    
    SELECT tmp1.ID,tmp1.hResident,tmp1.dtMovein,MIN (si.ServiceInstanceID) ServiceInstanceID  
     FROM ServiceInstance si  
     INNER JOIN #TempResidentHistoryStatus tmp on tmp.hResident = si.ResidentID  
     LEFT JOIN #TempResidentHistoryStatus tmp1 on tmp1.hResident = si.ResidentID  
     INNER JOIN service s1 ON si.serviceid = s1.serviceid AND s1.serviceclassid = 1  
    WHERE 1=1  
     AND si.ServiceInstanceFromDate >= tmp.dtMoveOut  
     AND si.ServiceInstanceFromDate BETWEEN @srDat1 AND @srDat2  
     AND si.ServiceInstanceActiveFlag <> 0  
     AND tmp.ID = tmp1.ID-1  
     AND ISNULL(si.serviceinstancetodate,si.serviceinstancefromdate) >= si.serviceinstancefromdate  
    GROUP BY tmp1.ID,tmp1.hResident,tmp1.dtMovein  
    /* Each instance of move in will get respective Minimum serviceinstanceid, InstanceID of 1st Move-in if only 1 exists in range*/  
    UPDATE  #TempResidentHistoryStatus SET ServiceInstanceID = ISNULL(a.ServiceInstanceID,B.ServiceInstanceID)  
    FROM #TempResidentHistoryStatus tmp  
    LEFT JOIN #mintemp1 a ON a.ID = tmp.ID AND a.hResident = tmp.hResident  
    LEFT JOIN ( SELECT ResidentID,MIN(si3.serviceinstanceid) serviceinstanceid  
       FROM serviceinstance si3   
        INNER JOIN service s1 ON si3.serviceid = s1.serviceid AND s1.serviceclassid = 1  
        INNER JOIN #TempResidentHistoryStatus tmp ON tmp.hResident = si3.residentid  
       WHERE si3.ServiceInstanceActiveFlag <> 0  
        AND si3.ServiceInstanceFromDate BETWEEN @srDat1 AND @srDat2  
        AND ISNULL(si3.serviceinstancetodate,si3.serviceinstancefromdate) >= si3.serviceinstancefromdate  
       GROUP BY ResidentID ) b ON b.ResidentID = tmp.hResident  
      
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
     INNER JOIN #TempResidentHistoryStatus tmp ON tmp.hResident = d.thMy AND tmp.dtmovein = d.dMin  
     INNER JOIN serviceinstance si ON si.Residentid = d.thMy AND si.ServiceInstanceID = tmp.ServiceInstanceID  
     LEFT JOIN #Attribute av ON av.hprop = d.phmy    
       /*In multiple Move in scenario, each movein will get respective deposit amount*/  
     LEFT JOIN (SELECT DISTINCT actde.phmy phmy, actde.ThMy hmyperson,tmp1.dtMovein,SUM(ISNULL(D.SAMOUNT,0)) AS Deposit  
           FROM #ActResDet actde  
         INNER JOIN Trans T    ON T.Hperson = actde.ThMy AND T.ITYpe = 6 AND CONVERT(DATETIME,CONVERT(CHAR(10),T.SDateOccurred ,121),101) <= @DpDate          
         INNER JOIN Detail D   ON D.Hinvorrec = T.HMY            
         INNER JOIN Acct Act   ON Act.HMY = D.Hacct              
         INNER JOIN param pm ON pm.hchart=act.hchart AND act.hmy IN (pm.hdeposit,pm.hdeposit1,pm.hdeposit2,pm.hdeposit2,pm.hdeposit3,pm.hdeposit4,pm.hdeposit5,pm.hdeposit6,pm.hdeposit7,pm.hdeposit8,pm.hdeposit9)  
         Inner JOIN #TempResidentHistoryStatus tmp1 ON tmp1.hResident = actde.ThMy  
         LEFT JOIN #TempResidentHistoryStatus tmp ON tmp.hResident = actde.ThMy AND tmp.ID = tmp1.ID-1  
        WHERE @DispRate='Yes' AND actde.dMin = tmp1.dtMovein  
         AND CONVERT(DATETIME,CONVERT(CHAR(10),T.SDateOccurred ,121),101) >= ISNULL(tmp.dtMoveout,'01/01/1900')   
         AND CONVERT(DATETIME,CONVERT(CHAR(10),T.SDateOccurred ,121),101) <= ISNULL(tmp1.dtMoveout,'01/01/2100')  
        GROUP BY actde.phmy,actde.ThMy,tmp1.dtMovein  
        ) Dpsts ON Dpsts.phmy=d.phmy AND Dpsts.hmyperson=si.ResidentID AND Dpsts.dtMovein = tmp.dtmovein  
     OUTER APPLY ( SELECT cast(SUM(ISNULL(srt.ChargeTypeAmount,0)) +   
          CASE WHEN si.RateTypeCode = 'MLY' THEN ISNULL(sur.UnitRentMonthlyAmount,0)   
           ELSE ISNULL(sur.UnitRentDailyAmount,0) END  as NUMERIC(18,2) ) MarketRate  
         From seniorUnitRent sur   
          LEFT JOIN servicerate srt ON srt.ServiceID = si.ServiceID AND srt.PropertyID = d.phmy    
          WHERE @DispRate='Yes' AND sur.unitid = si.UnitID AND sur.PrivacyLevelCode = si.PrivacyLevelCode  
         Group BY sur.UnitRentMonthlyAmount, sur.UnitRentDailyAmount  
        )a  
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
   FROM dbo.Senior_ListHandler(@PropertyCode, 'sCode') x      
    INNER JOIN Property p ON LTRIM(RTRIM(x.sCode)) = LTRIM(RTRIM(p.sCode))   
    INNER JOIN ListProp2 l ON l.hProplist = p.hmy AND l.iType <> 11  
    INNER JOIN tenant t ON t.hproperty = p.hmy   
    INNER JOIN SeniorReserveUnit SRU ON SRU.hTenant = t.hmyperson   
    INNER JOIN SeniorResidentStatus srs ON (srs.iStatus = t.iStatus)  
    INNER JOIN seniorresident sr ON t.hmyperson = sr.residentid   
    INNER JOIN unit u ON u.hmy = SRU.hUnit  
    INNER JOIN unittype ut ON ut.hmy = u.hunittype  
    INNER JOIN Senior_ListHandler(@carelev,'') CrHnd ON CrHnd.scode = SRU.sCarelevelCode  
    INNER JOIN Senior_ListHandler(@ContTyp,'') ConHnd ON ConHnd.scode = sr.ContractTypeCode  
    LEFT JOIN Senior_ListHandler(@ResStatus,'') StaHnd ON StaHnd.scode = cast(t.iStatus as varchar(20))  
   WHERE SRU.dtEFfective BETWEEN @sDat1 AND @sDat2  
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
   CREATE TABLE #SchedTenant(  
      hmy NUMERIC,  
      hmyperson NUMERIC  
     )  
   /* Code will list residents for MoveIn OR MoveOut,  
    Code optimizes reads as selective residents are passed to detail query*/  
   INSERT INTO #SchedTenant  
    SELECT p.hmy ,T.hmyperson  
    FROM dbo.Senior_ListHandler(@PropertyCode, 'sCode') x      
     INNER JOIN Property p ON LTRIM(RTRIM(x.sCode)) = LTRIM(RTRIM(p.sCode))   
     INNER JOIN ListProp2 l ON l.hProplist = p.hmy AND l.iType <> 11   
     INNER JOIN tenant t ON t.hproperty = p.hmy  
    WHERE CASE WHEN @type ='MoveOut' THEN t.dtmoveout   
          WHEN @type ='MoveIn' THEN t.dtmovein END   
      BETWEEN  @sDat1 AND  @sDat2  
    AND 1 = CASE WHEN @type ='MoveOut' AND t.iStatus NOT IN (2,8,6,7,9,1) THEN 1  
        WHEN @type ='MoveIn' AND t.istatus IN (8,2) THEN 1  
      ELSE 0 END  
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
     INNER JOIN Senior_ListHandler(@carelev,'') CrHnd ON CrHnd.scode=sr.CareLevelcode  
     INNER JOIN Senior_ListHandler(@ContTyp,'') ConHnd ON ConHnd.scode = sr.ContractTypeCode  
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
 -- END   
 END  

 --select * from #DetSchedul