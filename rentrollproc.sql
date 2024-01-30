 --CREATE PROCEDURE SeniorConditionalOccupancyDetails_UnitRosterAndRentRollNew  
     -- (    
	 declare
    @hprop               AS VARCHAR(6000)        
      ,@BOM                 AS DATETIME        
      ,@EOM                 AS DATETIME        
      ,@flag                AS INTEGER        
      ,@ShowSeccondResident CHAR(3)         
      ,@Type                VARCHAR(10) 
--	  ,@AsOfDate date
--	  ,@startDate date
--   -- )       
--    --AS    
--    --BEGIN 
	set @hprop = 'aths'
--set @AsOfDate  = '2022-05-01'
--set @startDate= cast(cast(month('2022-05-01') as varchar(2))+'/01'+ '/' +cast(Year('2022-05-01') as varchar(4)) as date)
declare @sql nvarchar(max)
select @sql = isnull(@sql+';', '') + 'drop table ' + quotename(name)
from tempdb..sysobjects
where name like '#%'
exec (@sql)

SET @BOM =  '2022-05-01'
--CONVERT(VARCHAR, Datepart(mm, @AsOfDate)) 
--           + '/01/' 
--           + CONVERT(VARCHAR, Datepart(yyyy, @AsOfDate)) 
SET @EOM = Dateadd(dd, -1, Dateadd(mm, 1, @BOM))  
     set @flag   = 1             
    set @ShowSeccondResident     = 1  
   set @Type = 4 

   IF OBJECT_ID('TempDb..#tmpConditionalOccDetail') IS NOT NULL
DROP TABLE #tmpConditionalOccDetail
    CREATE TABLE #tmpConditionalOccDetail (        
       Propertyid              NUMERIC        
      ,Propertyname            VARCHAR( 266 )        
      ,Propcode                VARCHAR( 10 )        
      ,Unitid                  NUMERIC        
      ,Unitcode                VARCHAR( 15 )        
      ,Unittypeid              NUMERIC        
      ,Unittype                VARCHAR( 20 )        
      ,Carelevelcode           VARCHAR( 10 )        
      ,Privacylvlcode          VARCHAR( 10 )        
      ,Unitcapacity            NUMERIC        
      ,Unitbudgetcapacity      NUMERIC        
      ,Unitsqft                NUMERIC( 18, 2 )        
      ,Unitrentmonthly         NUMERIC( 18, 2 )        
      ,Unitrentdaily           NUMERIC( 18, 2 )        
      ,Unitwaitlistflag        BIT        
      ,Unitexcludeflag         BIT        
      ,Residentid              NUMERIC        
      ,Residentname            VARCHAR( 100 )        
      ,Dtmovein                DATETIME        
      ,Dtmoveout               DATETIME   
   ,SecResName              Varchar(100)  
      ,SecResBDt               datetime  
      ,SecResAge               numeric(18,2)     
      ,Pubocc                  NUMERIC( 18, 2 )        
      ,Plbocc                  NUMERIC( 18, 2 )        
      ,Pubdcocc                NUMERIC( 18, 2 )        
      ,Fubocc                  NUMERIC( 18, 2 )        
      ,Flbocc                  NUMERIC( 18, 2 )        
      ,Fubdcocc                NUMERIC( 18, 2 )        
      ,Serviceinstancefromdate DATETIME        
      ,Serviceinstancetodate   DATETIME        
      ,Rescarelevelcode        VARCHAR( 10 )        
      ,Beliminate              BIT      
      ,RemoveRecord            BIT      
      ,DataIssue               BIT   
      ,AdditionalUnit          BIT /*TR #480225 - column added to identify additional unit record of resident.*/  
   ,ResDeposit              NUMERIC(18,2)  
   ,ResOtherMonthlyChargesAmt NUMERIC(18,2)  
   /*TR #480225*/  
      ,ResAdditionUnitRent     NUMERIC(18,2)   
      ,ResAdditionUnitRentMonthly NUMERIC(18,2)   
      ,ResAdditionalUnitOtherCharge NUMERIC(18,2)  
   ,SecOccupantRateMonthly  NUMERIC(18,2)  
   ,SecResId                NUMERIC(18,0)  
   ,ResBDt                  DateTime  
   ,ResAge            numeric(18,2)  
   ,ResSecAmt         numeric(18,2)  
   ,ResPrimaryServiceAmtMonthly numeric(18,2)  
   ,RateType        Varchar(10)  
   ,ResPrimaryServiceAmtMonthly_Prorate numeric(18,2)  
      )   
    IF OBJECT_ID('TempDb..#proptmp') IS NOT NULL
DROP TABLE #proptmp 
   CREATE TABLE #proptmp   
 (  
   PropertyID  NUMERIC,    
   PropertyCode CHAR(8),    
   PropertyName VARCHAR(255),    
   Property  VARCHAR(266)    
 )  
 INSERT INTO #proptmp  
 SELECT PropertyID, PropertyCode, PropertyName, Property  
 FROM DBO.Seniorpropertyfunction(NULL,@hprop)  
   DECLARE @AsofDate AS DATETIME  
   SET @AsofDate = @BOM  
   DECLARE @encryptionEnabled INTEGER  
   SET @encryptionEnabled=isnull( (SELECT svalue  
                                   FROM   paramopt2  
                                   WHERE  Upper(stype) = 'ENABLEDATAENCRYPTION'),0)      
   
  
   IF OBJECT_ID('TempDb..#ServiceInstancetmp') IS NOT NULL
DROP TABLE #ServiceInstancetmp
   CREATE TABLE #ServiceInstancetmp   
      (    
      Serviceinstanceid         NUMERIC(18,0),    
      Residentid                NUMERIC(18,0),    
   ServiceID                 NUMERIC(18, 0),   
   UnitID                    NUMERIC(18, 0),  
   CareLevelCode             VARCHAR(3),  
   PrivacyLevelCode          VARCHAR(3),  
   RateTypeCode              CHAR(3),  
      ServiceinstanceFromDate   DATETIME,    
      ServiceinstanceToDate     DATETIME,  
   ServiceinstanceAmount     MONEY,  
   ServiceinstanceActiveFlag BIT  
   )   
IF OBJECT_ID('TempDb.. #ServiceInstance') IS NOT NULL
DROP TABLE #ServiceInstance
CREATE TABLE #ServiceInstance
      (    
      Serviceinstanceid       NUMERIC(18,0),    
      Residentid              NUMERIC(18,0),    
      ServiceinstanceFromDate DATETIME,    
      ServiceinstanceToDate   DATETIME,  
   ServiceinstanceActiveFlag BIT,  
   ServiceID                 NUMERIC(18, 0)   
      )  
           
  /*TR #480225 - table for recurring charges of additional units*/ 
  

  IF OBJECT_ID('TempDb.. #serviceinstanceadditionalunit') IS NOT NULL
DROP TABLE #serviceinstanceadditionalunit
  CREATE TABLE #serviceinstanceadditionalunit   
    (   
       seniorrcurringchargeid  NUMERIC(18, 0),   
       residentid              NUMERIC(18, 0),   
       recurringchargefromdate DATETIME,   
       recurringchargetodate   DATETIME,   
       unitid                  NUMERIC ,  
       PrivacyLevelCode        VARCHAR(3)  
    )   
  CREATE TABLE #ResidentHistoryStatus(  
    [HistoryId] [numeric](18, 0)  NOT NULL,  
    [hResident] [numeric](18, 0)  NOT NULL,  
   PrivacyLevelCode     VARCHAR(3),  
   UnitId                NUMERIC(18,0),  
   CareLevelCode             VARCHAR(3)  
      
   )   
   /*TR #480225 - table of history for additional units*/  
  CREATE TABLE #residenthistorystatusadditionalunit   
    (   
       [historyid] [NUMERIC](18, 0) NOT NULL,   
       [hresident] [NUMERIC](18, 0) NOT NULL,   
       dtStartdate       DATETIME,   
       dtEnddate         DATETIME,  
       UnitId            NUMERIC ,  
       PrivacyLevelCode  VARCHAR(3)  
    )   
    CREATE TABLE #chargtyp  
    (  
       chargtypId NUMERIC,  
    itype  NUMERIC(18,0)  
      )  
    INSERT INTO  #chargtyp   
    SELECT c.HMY, c.itype FROM chargtyp c WHERE 1=1   
    CREATE TABLE #servicechargetype  
     (  
       ServiceId NUMERIC,  
    ChargeTypeId NUMERIC  
      )  
      
    INSERT INTO  #servicechargetype   
    SELECT c.ServiceId,c.ChargeTypeId  FROM servicechargetype c WHERE 1=1   
    CREATE TABLE #service  
      (  
       serviceid NUMERIC,  
    serviceclassid NUMERIC,  
    carelevelcode varchar(10),  
    servicename Varchar(100)   
      )  
    INSERT INTO  #service   
    SELECT s.serviceid, s.serviceclassid, s.carelevelcode, s.Servicename FROM service s WHERE 1=1   
    CREATE TABLE #sec  
      (  
       serviceid NUMERIC  
      )  
    INSERT INTO  #sec   
    SELECT s.serviceid FROM service s WHERE 1=1   
    AND  ( (SELECT count(s1.serviceid) FROM service s1 ) <> (SELECT count(s.serviceid) FROM service s WHERE 1=1) )  
    UNION all   
    SELECT 0  
    INSERT INTO #ServiceInstancetmp   
    SELECT si.ServiceInstanceId , si.ResidentID, si.ServiceID, si.UnitID, si.CareLevelCode, si.PrivacyLevelCode, si.RateTypeCode, si.ServiceInstanceFromDate , si.ServiceInstanceToDate, si.ServiceInstanceAmount, si.ServiceInstanceActiveFlag   
    FROM  ServiceInstance si     
    INNER JOIN Tenant t ON si.ResidentID = t.HMYPERSON   
    INNER JOIN #proptmp p ON p.propertyid = t.HPROPERTY   
    INSERT INTO #ServiceInstance    
    SELECT Si.ServiceInstanceId , Si.ResidentID,Si.ServiceInstanceFromDate , Si.ServiceInstanceToDate, Si.ServiceInstanceActiveFlag, Si.ServiceID    
    FROM  ServiceInstance Si  
    INNER JOIN #service s ON s.serviceid = si.serviceid      
    INNER JOIN Tenant t ON Si.ResidentID = t.HMYPERSON   
    INNER JOIN #proptmp p ON p.propertyid = t.HPROPERTY                
    WHERE      Si.Serviceinstanceid = ( SELECT max(si2.serviceinstanceid )   
                            FROM #ServiceInstancetmp si2   
                            INNER JOIN #service s2 ON s.serviceid = si2.serviceid    
                                              AND s2.servicename=s.servicename  
                            WHERE 1=1  
                            AND si2.residentid = si.residentid  
                            AND si2.ServiceInstanceActiveFlag <> 0  
                            AND isnull(si2.serviceinstancetodate,@AsOfDate)  > =  si2.serviceinstancefromdate  
                            AND si2.serviceinstancefromdate =  (SELECT max(si3.serviceinstancefromdate)   
                                                    FROM #ServiceInstancetmp si3  
                                                 INNER JOIN #service s3 ON si3.serviceid = s3.serviceid   
                         AND s3.servicename = s.servicename  
                                                 WHERE si3.residentid = si.residentid  
                                                 AND si3.ServiceInstanceActiveFlag <> 0  
                                                 AND @AsOfDate BETWEEN si3.serviceinstancefromdate AND isnull(si3.serviceinstancetodate,@AsOfDate)  
                                                 AND isnull(si3.serviceinstancetodate,@AsOfDate)  > =  si3.serviceinstancefromdate  
          )  
     )                               
              
  /*TR #480225 - Additional Unit will be considered here, if any active record of it's charge is present.*/   
    INSERT INTO #serviceinstanceadditionalunit   
    SELECT src.recurringchargeid,   
           src.residentid,   
           src.recurringchargefromdate,   
           src.recurringchargetodate,   
           src.unitid ,  
           src.PrivacyLevelCode  
    FROM   tenant t   
         INNER JOIN senioradditionalunit sau   
                 ON sau.htenant = t.hmyperson   
         INNER JOIN senioradditionalunitcharge sauc   
                 ON sauc.hadditionalunit = sau.hmy   
         INNER JOIN seniorrecurringcharge src   
                 ON src.recurringchargeid = sauc.hrecurringcharge   
         INNER JOIN unit u   
                 ON u.hmy = sau.hunit   
   INNER JOIN #proptmp p ON p.propertyid = t.hproperty  
    WHERE  sau.bactive = 1   
         AND sau.dtstart <= Isnull(sau.dtend, '01/01/2100')   
         AND src.recurringchargeactiveflag <> 0   
         AND Isnull(src.recurringchargetodate, @EOM) > =   
             src.recurringchargefromdate   
         AND src.recurringchargefromdate <= @EOM   
         AND @flag IN ( 0, 4, 5, 6 )   
     
    CREATE TABLE #UnitHistory  
  ( UnitHistoryId         NUMERIC(18,0),  
    UnitId                NUMERIC(18,0),  
    UnitHistoryFromDate   DATETIME,  
    UnitHistoryToDate     DATETIME,  
    CareLevelCode         VARCHAR(3),  
    UnitWaitlistFlag      BIT,  
    UnitExcludeFlag       BIT,  
    UnitHistoryActiveFlag BIT,  
    UnitCapacityCount     NUMERIC(18,2),  
    UnitBudgetCount       NUMERIC(18,2)  
  )  
    INSERT INTO #UnitHistory  
    SELECT suh.unithistoryid, suh.UnitID , suh.UnitHistoryFromDate ,suh.UnitHistoryToDate ,suh.CareLevelCode ,suh.UnitWaitlistFlag ,suh.UnitExcludeFlag ,suh.UnitHistoryActiveFlag  
   ,suh.UnitCapacityCount,suh.UnitBudgetCount  
    FROM #proptmp P        
       INNER JOIN Unit U ON U.Hproperty = P.Propertyid /*and isnull(u.exclude,0) = 0  */  
       INNER JOIN Seniorunit Su ON Su.Unitid = U.Hmy             
       INNER JOIN seniorunitHistory suh ON suh.unitid=su.UnitID       
         
    SELECT UnitId,CASE WHEN MIN(unitHistoryFromDate)<=@BOM THEN 1 ELSE 0 END flag        
    INTO #tmpunit        
    FROM #UnitHistory  
    GROUP BY UnitId    
    INSERT INTO #ResidentHistoryStatus  
    SELECT MAX(hmy),hResident, srh1.sPrivacyLevelCode, srh1.hunit,srh1.sCarelevelcode  
    FROM #proptmp P       
    INNER JOIN Tenant t ON T.Hproperty = P.Propertyid   
    INNER JOIN SeniorResidentHistoryStatus srh1 On srh1.hresident = t.hmyperson  
    WHERE  srh1.iStatusCode in ( 0,1,4,11)  
    AND srh1.dtfrom <= isnull(srh1.dtto, srh1.dtfrom)    
    AND CONVERT(DATETIME, @EOM, 101) BETWEEN srh1.dtfrom AND isnull(CASE WHEN srh1.istatuscode =1 THEN srh1.dtfrom ELSE srh1.dtto END , @EOM)     
    AND @flag IN ( 0, 1, 2, 3 )          
    AND @Type = 'Report'    
    GROUP BY hResident,srh1.sPrivacyLevelCode,srh1.hunit,srh1.sCarelevelcode  
  /*TR #480225*/  
    INSERT INTO #residenthistorystatusadditionalunit   
    SELECT sau.hmy,   
         hresident,  
         sau.dtstart,  
         sau.dtend,  
         sau.hunit,  
         sau.sPrivacyLevelCode  
    FROM   senioradditionalunit sau   
    INNER JOIN #residenthistorystatus srh1 ON sau.htenant = srh1.hresident   
    WHERE  sau.dtstart <= Isnull(sau.dtend, sau.dtstart)   
    AND sau.bactive = 1   
    AND CONVERT(DATETIME, @EOM, 101) BETWEEN sau.dtstart AND Isnull(sau.dtend , @EOM)   
    AND @flag IN ( 0, 1, 2, 3 )   
    AND @Type = 'Report'  
   /* If Report is for as of today, set the Report to run dashboard present occupancy query */        
          /* @flag ='1' then 'Physical Unit Based Occupancy'                               
          @flag ='2' then 'Physical Lease Based Occupancy'                              
          @flag ='3' then 'Physical Unit Based Occupancy (disregarding capacity)'                              
          @flag ='4' then 'Financial Unit Based Occupancy'                             
          @flag ='5' then 'Financial Lease Based Occupancy'                              
          @flag ='6' then  'Financial Unit Based Occupancy (disregarding capacity)'                            
          and @flag =0  for both Physical and financial occupancies */  
            
    INSERT INTO #tmpConditionalOccDetail      
         SELECT      
           P.Propertyid,      
           Ltrim( Rtrim( P.Propertyname ) ) + ' (' + Ltrim( Rtrim( P.Propertycode ) ) + ')',      
           Ltrim( Rtrim( P.Propertycode ) ),      
           U.Hmy,      
           U.Scode,      
           Ut.Hmy,      
           Ut.Scode,      
           Isnull( Suh.Carelevelcode, Su.Carelevelcode ),      
           Isnull( Suh.Privacylevelcode, ( CASE      
                                              WHEN Su.Unitcapacitycount = 1 THEN 'PRI'      
                                              WHEN Su.Unitcapacitycount = 2 THEN 'SPA'      
                                              WHEN Su.Unitcapacitycount = 3 THEN 'TOA'      
                                              WHEN Su.Unitcapacitycount = 4 THEN 'QDA'      
                                       END ) ),      
           Isnull( Suh.Unitcapacitycount, Su.Unitcapacitycount ),      
           Isnull( Suh.Unitbudgetcount, Su.Unitbudgetcount ),           U.Dsqft,      
           Isnull( Suh.Unitrentmonthlyamount, 0 ),      
           Isnull( Suh.Unitrentdailyamount, 0 ),      
           Isnull( Suh.Unitwaitlistflag, Su.Unitwaitlistflag ),      
           Isnull( Suh.Unitexcludeflag, U.Exclude ),      
           0 Residentid,      
           '',      
           NULL,      
           NULL,  
     '',  
     NULL,  
     0,      
           0,      
           0,      
           0,      
           0,      
           0,      
           0,      
           NULL,      
           NULL,      
           '',      
           0,  
     0,  
     0,  
     0,  
           0,  
     0,  
     0,  
     0,  
     0,  
     0,  
     0,  
     '',  
     0,  
     0,  
     0,  
     '',  
     0  
         FROM       #proptmp P      
         INNER JOIN Unit U ON U.Hproperty = P.Propertyid --and isnull(u.exclude,0) = 0   ---ram  
         INNER JOIN Seniorunit Su ON Su.Unitid = U.Hmy      
         INNER JOIN Unittype Ut ON Ut.Hmy = U.Hunittype      
         LEFT JOIN  ( SELECT      
                        U.Hmy Unitid,      
                        Suh.Carelevelcode,      
                        Surh.Privacylevelcode,      
                        Suh.Unitcapacitycount,      
                        Suh.Unitbudgetcount,      
                        Surh.Unitrentmonthlyamount,      
                        Surh.Unitrentdailyamount,      
                        Suh.Unitwaitlistflag,      
                        Suh.Unitexcludeflag      
                      FROM       #proptmp P      
                      INNER JOIN Unit U ON U.Hproperty = P.Propertyid      
                      INNER JOIN Seniorunit Su ON Su.Unitid = U.Hmy      
                      INNER JOIN #UnitHistory Suh ON Suh.Unitid = U.Hmy      
                      INNER JOIN Seniorunitrenthistory Surh ON Surh.Unithistoryid = Suh.Unithistoryid      
                      WHERE      Suh.Unithistoryid = ( SELECT      
                                                       MAX( Unithistoryid )      
                                                       FROM   #UnitHistory Suh1    
                                                       WHERE  Suh1.Unitid = Suh.Unitid      
                                                       AND Suh1.Unithistoryactiveflag <> 0      
                                                       AND CONVERT( DATETIME, CONVERT(VARCHAR(11), Suh1.unithistoryFromdate), 101 )  = ( SELECT      
                                                                                                                                         MAX( CONVERT( DATETIME, CONVERT(VARCHAR(11), Suh2.unithistoryFromdate), 101 )  )      
                                                                                                                                         FROM   #UnitHistory Suh2 inner join #tmpUnit tu ON tu.unitId=suh2.unitid      
                                                                                                                                         WHERE  Suh2.Unitid = Suh1.Unitid      
                                                                                                                                         AND Suh2.Unithistoryactiveflag <> 0      
                                                                                                                                         AND CONVERT( DATETIME, CONVERT(VARCHAR(11), Suh2.unithistoryFromdate), 101 )  <= CASE WHEN tu.flag=0 THEN CONVERT( DATETIME, CONVERT(VARCHAR(11), Suh2.unithistoryFromdate), 101 )  ELSE Isnull( CONVERT( DATETIME, CONVERT(VARCHAR(11), Suh2.unithistorytodate), 101 ) , @EOM ) END      
                                                                                                                                         AND @EOM BETWEEN  CASE WHEN tu.flag=0 THEN  @EOM ELSE  CONVERT( DATETIME, CONVERT(VARCHAR(11), Suh2.unithistoryFromdate), 101 )  END AND Isnull( CONVERT( DATETIME, CONVERT(VARCHAR(11), Suh2.unithistorytodate), 101 ) , @EOM ) ) )      
                                                       AND LEFT( Surh.Privacylevelcode, 2 ) IN ( SELECT      
                                                                                                   'PR'      
                                                                                                 WHERE  Suh.Unitcapacitycount IN ( 1, 2, 3, 4 )      
                                                                                                 UNION      
                                                                                                 SELECT      
                                                                                                   'SP'      
                                                                                                 WHERE  Suh.Unitcapacitycount IN ( 2, 3, 4 )      
                                                                                                 UNION      
                                                     SELECT      
                                                                                                   'TO'      
                                                                                                 WHERE  Suh.Unitcapacitycount IN ( 3, 4 )      
                                                                   UNION      
                                                                                                 SELECT      
                                                                                                   'QD'      
                                                                                                 WHERE  Suh.Unitcapacitycount IN ( 4 )      
                                                                                                 UNION      
                                                                                                 SELECT      
                                                                                                   'SE'      
                                            WHERE  @ShowSeccondResident = 'Yes'  
                                               UNION      
                                                                                                 SELECT      
                                                                                                     'DA'   
                                               WHERE  Suh.Unitcapacitycount IN ( 2, 3, 4 )  and @ShowSeccondResident = 'Yes'    
                                               UNION   
                                               SELECT      
                                                                                                     'DB'    
                                                                                                 WHERE  Suh.Unitcapacitycount IN ( 2, 3, 4 )  and @ShowSeccondResident = 'Yes'    
                                               UNION      
                                                                                                 SELECT      
                                                                                                  'TA'   
                                               WHERE  Suh.Unitcapacitycount IN ( 3, 4 )  and @ShowSeccondResident = 'Yes'  
                                               UNION      
                                                                                                 SELECT      
                                                                                                  'TB'   
                                               WHERE  Suh.Unitcapacitycount IN ( 3, 4 )  and @ShowSeccondResident = 'Yes'  
                                               UNION      
                                                                                                 SELECT      
                                                                                                  'TC'   
                                               WHERE  Suh.Unitcapacitycount IN ( 3, 4 )  and @ShowSeccondResident = 'Yes'  
                                               UNION      
                                                                                                 SELECT      
                                                                                                    'QA'   
                                               WHERE  Suh.Unitcapacitycount IN ( 4 )  and @ShowSeccondResident = 'Yes'  
                                               UNION      
                                                                                                 SELECT      
                                                                                                   'QB'   
                                               WHERE  Suh.Unitcapacitycount IN ( 4 )  and @ShowSeccondResident = 'Yes'  
                                               UNION      
                                                                                                 SELECT      
                                                                                                   'QC'   
                                               WHERE  Suh.Unitcapacitycount IN ( 4 )  and @ShowSeccondResident = 'Yes'  
                                               UNION      
                                                                                                 SELECT      
                                                                                                   'QD'   
                                               WHERE  Suh.Unitcapacitycount IN ( 4 )  and @ShowSeccondResident = 'Yes' ) )Suh ON Suh.Unitid = U.Hmy      
      CREATE TABLE #tmpOccupancy (        
            Title                    VARCHAR( 20 )        
            ,Propertyid              NUMERIC        
            ,Unitid                  NUMERIC        
            ,Residentid              NUMERIC        
            ,Residentname            VARCHAR( 100 )        
   ,Dtmovein                DATETIME        
            ,Dtmoveout               DATETIME        
            ,Serviceinstancefromdate DATETIME        
            ,Serviceinstancetodate   DATETIME        
            ,Privacylevelcode        VARCHAR( 10 )        
            ,Rescarelvlcode          VARCHAR( 10 )        
            ,Occupancy               NUMERIC( 18, 2 )        
            ,Beliminate              BIT   
          ,AdditionalUnit          BIT  
      ,ResDeposit              NUMERIC(18,2)  )      
       INSERT INTO #tmpOccupancy        
          (        
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
            ,Occupancy        
            ,Beliminate        
            ,AdditionalUnit  
      ,ResDeposit     
          )         
          SELECT        
            'Physical Occupancy',        
            P.Propertyid                                                                                                                                              Phmy,        
            rs.unitid,        
            T.Hmyperson                                                                                                                                               Residentid,        
            Rtrim( Ltrim( Isnull( T.Slastname, '' ) ) ) + ', ' + Rtrim( Ltrim( Isnull( T.Sfirstname, '' ) ) ) + ' (' + Rtrim( Ltrim( Isnull( T.Scode, '' ) ) ) + ') ' Residentname,        
            T.Dtmovein,        
            CASE        
               WHEN T.Istatus = 4 THEN NULL        
               ELSE T.Dtmoveout        
            END,        
            NULL,        
            NULL,        
            rs.Privacylevelcode,        
            rs.Carelevelcode,        
            Cast( Lv.Listoptionvalue AS NUMERIC( 3, 2 ))  Occ,        
            1 ,  
            0,  
           ISNULL(ISNULL(t.sdeposit0,0) + ISNULL(t.sdeposit1,0) + ISNULL(t.sdeposit2,0) + ISNULL(t.sdeposit3,0)  
           + ISNULL(t.sdeposit4,0) + ISNULL(t.sdeposit5,0) + ISNULL(t.sdeposit6,0) + ISNULL(t.sdeposit7,0) + ISNULL(t.sdeposit8,0)   
           + ISNULL(t.sdeposit9,0), 0.00)  ResDeposit       
         FROM       #proptmp  P        
         INNER JOIN Tenant T ON T.Hproperty = P.Propertyid        
               AND @flag IN ( 0, 1, 2, 3 )        
               AND @Type = 'Report'        
         INNER JOIN Seniorresident Sr ON T.Hmyperson = Sr.Residentid   
    INNER JOIN #ResidentHistoryStatus rs ON rs.hResident = sr.ResidentId  
    INNER JOIN unit u ON u.hmy = t.hunit               
         INNER JOIN  Listoptionvalue Lv ON Lv.Listname = 'PrivacyLevel'          
               AND Lv.Listoptioncode = rs.PrivacyLevelCode       
         UNION ALL          
         /* Dashboard will not consider resident history for Physical Occupancy*/          
         SELECT          
           'Physical Occupancy',          
           P.Propertyid       Phmy,          
           T.Hunit,          
           T.Hmyperson                                                                                                                                               Residentid,          
           Rtrim( Ltrim( Isnull( T.Slastname, '' ) ) ) + ', ' + Rtrim( Ltrim( Isnull( T.Sfirstname, '' ) ) ) + ' (' + Rtrim( Ltrim( Isnull( T.Scode, '' ) ) ) + ') ' Residentname,          
           T.Dtmovein,          
           CASE          
              WHEN T.Istatus = 4 THEN NULL          
              ELSE T.Dtmoveout          
           END,          
           NULL,          
           NULL,          
           Sr.Privacylevelcode,          
           Sr.Carelevelcode,          
           Cast( Lv.Listoptionvalue AS NUMERIC( 3, 2 ))  Occ,          
           1   ,  
      0,  
     ISNULL(ISNULL(t.sdeposit0,0) + ISNULL(t.sdeposit1,0) + ISNULL(t.sdeposit2,0) + ISNULL(t.sdeposit3,0)  
           + ISNULL(t.sdeposit4,0) + ISNULL(t.sdeposit5,0) + ISNULL(t.sdeposit6,0) + ISNULL(t.sdeposit7,0) + ISNULL(t.sdeposit8,0)   
           + ISNULL(t.sdeposit9,0), 0.00)  ResDeposit       
         FROM       #proptmp P          
         INNER JOIN Tenant T ON T.Hproperty = P.Propertyid          
                AND T.Istatus IN ( 0, 4, 11 )          
                AND @flag IN ( 0, 1, 2, 3 )          
                AND @Type <> 'Report'          
                AND T.Dtmovein <= @BOM  
         INNER JOIN Seniorresident Sr ON T.Hmyperson = Sr.Residentid          
       INNER JOIN unit u on u.hmy = t.hunit and isnull(u.exclude,0) = 0   ---geo  
         LEFT JOIN  Listoption L1 ON ( Sr.Carelevelcode = L1.Listoptioncode          
                                       AND L1.Listname = 'CareLevel' )          
         LEFT JOIN  Listoption L2 ON ( Sr.Privacylevelcode = L2.Listoptioncode          
                                       AND L2.Listname = 'PrivacyLevel' )          
         LEFT JOIN  Listoptionvalue Lv ON Lv.Listname = 'PrivacyLevel'          
                                          AND Lv.Listoptioncode = L2.Listoptioncode          
         UNION ALL        
          SELECT        
            'Financial Occupancy',        
            P.Propertyid  Phmy,        
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
            Cast( Lv.Listoptionvalue AS NUMERIC( 3, 2 ))    Occ,        
            1,  
            0,  
      ISNULL(ISNULL(t.sdeposit0,0) + ISNULL(t.sdeposit1,0) + ISNULL(t.sdeposit2,0) + ISNULL(t.sdeposit3,0)  
           + ISNULL(t.sdeposit4,0) + ISNULL(t.sdeposit5,0) + ISNULL(t.sdeposit6,0) + ISNULL(t.sdeposit7,0) + ISNULL(t.sdeposit8,0)   
           + ISNULL(t.sdeposit9,0), 0.00)  ResDeposit       
          FROM       #proptmp P        
          INNER JOIN Tenant T ON T.Hproperty = P.Propertyid        
                                 AND @flag IN ( 0, 4, 5, 6 )        
     INNER JOIN unit u ON u.hmy = t.hunit /*and isnull(u.exclude,0) = 0 */  
          INNER JOIN #ServiceInstancetmp Si ON ( T.Hmyperson = Si.Residentid )  
    INNER JOIN #ServiceInstance Si1 ON (Si1.ServiceInstanceid = Si.Serviceinstanceid and Si1.residentid = Si.residentid)            
          INNER JOIN Seniorresident Rs ON ( T.Hmyperson = Rs.Residentid )             
          INNER JOIN  Listoptionvalue Lv ON Lv.Listname = 'PrivacyLevel'        
                AND Lv.Listoptioncode = Si.Privacylevelcode   
   Where Si1.Serviceinstanceactiveflag <> 0     
         AND  Isnull( Si1.Serviceinstancetodate, @EOM ) > = Si1.Serviceinstancefromdate      
         AND Si1.Serviceinstancefromdate <= @EOM     
         AND @BOM <= Isnull( Si1.Serviceinstancetodate, @EOM )     
    /*TR #480225 - add additional unit residents*/     
     INSERT INTO #tmpOccupancy        
          (        
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
            ,Occupancy        
            ,Beliminate   
            ,AdditionalUnit  
      ,ResDeposit      
          )         
     SELECT 'Physical Occupancy',   
         P.propertyid                                            Phmy,   
         sau.hunit,   
         T.hmyperson                                             Residentid,   
         Rtrim( Ltrim( Isnull( T.slastname, '' ) ) ) + ', '   
         + Rtrim( Ltrim( Isnull( T.sfirstname, '' ) ) )   
         + ' (' + Rtrim( Ltrim( Isnull( T.scode, '' ) ) ) + ') ' Residentname,   
         T.dtmovein,   
         CASE   
           WHEN T.istatus = 4 THEN NULL   
           ELSE T.dtmoveout   
         END,   
         NULL,   
         NULL,   
         sau.sprivacylevelcode,   
         '',   
         Cast(Lv.listoptionvalue AS NUMERIC(3, 2))               Occ,   
         1,   
         1,  
   ISNULL(ISNULL(t.sdeposit0,0) + ISNULL(t.sdeposit1,0) + ISNULL(t.sdeposit2,0) + ISNULL(t.sdeposit3,0)  
         + ISNULL(t.sdeposit4,0) + ISNULL(t.sdeposit5,0) + ISNULL(t.sdeposit6,0) + ISNULL(t.sdeposit7,0) + ISNULL(t.sdeposit8,0)   
         + ISNULL(t.sdeposit9,0), 0.00)  ResDeposit   
     FROM   #proptmp P   
     INNER JOIN tenant T ON T.hproperty = P.propertyid   
           AND @flag IN ( 0, 1, 2, 3 )   
           AND @Type = 'Report'   
     INNER JOIN seniorresident Sr ON T.hmyperson = Sr.residentid   
     INNER JOIN senioradditionalunit sau ON T.hmyperson = sau.hTenant   
     INNER JOIN unit u ON u.hmy = t.hunit   
           AND Isnull(u.exclude, 0) = 0   
     INNER JOIN listoptionvalue Lv ON Lv.listname = 'PrivacyLevel'   
           AND Lv.listoptioncode = sau.sprivacylevelcode       
     INNER JOIN (SELECT Max(Si3.historyid) SeniorRcurringChargeID,   
                            Si3.hresident,   
                            Si3.unitid,  
                            Si3.PrivacyLevelCode   
                 FROM   #residenthistorystatusadditionalunit Si3   
                 INNER JOIN (SELECT Max(Si2.dtStartdate) dtStartdate,   
                                        Si2.hresident,   
                                        si2.unitid,  
                                        Si2.PrivacyLevelCode   
                             FROM   #residenthistorystatusadditionalunit Si2   
                             WHERE  Isnull(Si2.dtEnddate, @EOM) > = Si2.dtStartdate   
                             GROUP  BY si2.unitid,   
                                       Si2.hresident,  
                                       Si2.PrivacyLevelCode  
        )myview ON myview.hresident = Si3.hresident   
                  AND myview.dtStartdate = Si3.dtStartdate   
                  AND myview.unitid = Si3.unitid   
                  GROUP  BY Si3.hresident,   
                            Si3.unitid,  
                            Si3.PrivacyLevelCode  
     )myview1 ON myview1.hresident = sau.hTenant   
     AND myview1.unitid = sau.hUnit   
     AND myview1.seniorrcurringchargeid = sau.hMy   
     INNER JOIN #tmpOccupancy tocc ON tocc.ResidentID = t.HMYPERSON  
     UNION ALL   
     SELECT 'Financial Occupancy',   
         P.propertyid                                            Phmy,   
         src.unitid,   
         T.hmyperson                                             Residentid,   
         Rtrim( Ltrim( Isnull( T.slastname, '' ) ) ) + ', '   
         + Rtrim( Ltrim( Isnull( T.sfirstname, '' ) ) )   
         + ' (' + Rtrim( Ltrim( Isnull( T.scode, '' ) ) ) + ') ' Residentname,   
         T.dtmovein,   
         CASE   
           WHEN T.istatus = 4 THEN NULL   
           ELSE T.dtmoveout   
         END,   
         src.recurringchargefromdate,   
         src.recurringchargetodate,   
         src.privacylevelcode,   
         '',   
         Cast(Lv.listoptionvalue AS NUMERIC(3, 2))               Occ,   
         1,   
         1,  
      ISNULL(ISNULL(t.sdeposit0,0) + ISNULL(t.sdeposit1,0) + ISNULL(t.sdeposit2,0) + ISNULL(t.sdeposit3,0)  
         + ISNULL(t.sdeposit4,0) + ISNULL(t.sdeposit5,0) + ISNULL(t.sdeposit6,0) + ISNULL(t.sdeposit7,0) + ISNULL(t.sdeposit8,0)   
         + ISNULL(t.sdeposit9,0), 0.00)  ResDeposit   
     FROM   #proptmp P   
         INNER JOIN tenant T ON T.hproperty = P.propertyid   
               AND @flag IN ( 0, 4, 5, 6 )   
         INNER JOIN unit u ON u.hmy = t.hunit   
               AND Isnull(u.exclude, 0) = 0   
         INNER JOIN seniorrecurringcharge src ON ( T.hmyperson = src.residentid )   
         INNER JOIN seniorresident Rs ON ( T.hmyperson = Rs.residentid )   
         INNER JOIN listoptionvalue Lv ON Lv.listname = 'PrivacyLevel'   
               AND Lv.listoptioncode = src.privacylevelcode   
         INNER JOIN (SELECT Max(Si3.seniorrcurringchargeid) SeniorRcurringChargeID,   
                            Si3.residentid,   
                            Si3.unitid,  
                            Si3.PrivacyLevelCode   
                     FROM   #serviceinstanceadditionalunit Si3   
                     INNER JOIN (SELECT Max(Si2.recurringchargefromdate)   
                                            recurringchargefromdate,   
                                            Si2.residentid,   
                                            si2.unitid,  
                                            Si2.PrivacyLevelCode   
                                 FROM   #serviceinstanceadditionalunit Si2   
                                 WHERE  Isnull(Si2.recurringchargetodate,  @EOM)  > = Si2.recurringchargefromdate   
                                 GROUP  BY si2.unitid,   
                                           Si2.residentid,  
                                           Si2.PrivacyLevelCode  
         )myview ON myview.residentid = Si3.residentid   
                   AND myview.recurringchargefromdate = Si3.recurringchargefromdate   
                   AND myview.unitid = Si3.unitid   
                   GROUP  BY Si3.residentid,   
                               Si3.unitid,  
                            Si3.PrivacyLevelCode  
     )myview1 ON myview1.residentid = src.residentid   
     AND myview1.unitid = src.unitid   
     AND myview1.seniorrcurringchargeid = src.recurringchargeid   
     INNER JOIN #tmpOccupancy tocc ON tocc.ResidentID = t.HMYPERSON  
     ORDER  BY 2, 3, 4        
  UPDATE T        
     SET    T.Residentid = Occ.Residentid        
           ,T.Residentname = Occ.Residentname        
           ,T.Dtmovein = Occ.Dtmovein        
           ,T.Dtmoveout = Occ.Dtmoveout        
           ,T.Pubocc = CASE WHEN @ShowSeccondResident = 'Yes' THEN  
                    CASE       
                          WHEN Occ.Privacylevelcode in ('SEC','DAS','DBS','TAS','TBS','TCS','QAS','QBS','QCS','QDS') THEN 0        
                          ELSE Occ.Occupancy END  
                ELSE  Occ.Occupancy       
                      END        
           ,T.Plbocc = CASE WHEN @ShowSeccondResident = 'Yes' THEN        
                            CASE WHEN Occ.Privacylevelcode in ('SEC','DAS','DBS','TAS','TBS','TCS','QAS','QBS','QCS','QDS') THEN 0        
                            ELSE        
                               CASE        
                                  WHEN Isnull( Occ.Residentid, 0 ) = 0 THEN 0        
          ELSE   
            CASE Privacylevelcode when  'PRI' then   
              Case Unitcapacity when 1 then 1  
                                    when 2 then 2  
                  when 3 then 3  
                  when 4 then 4   
                  End  
         Else 1   
              End      
                               END     
          END   
         ELSE        
                             CASE WHEN Isnull( Occ.Residentid, 0 ) = 0 THEN 0        
                             ELSE    
            CASE Privacylevelcode when  'PRI' then   
              Case Unitcapacity when 1 then 1  
                                    when 2 then 2  
                  when 3 then 3  
                  when 4 then 4   
                  End  
          Else 1  
                  end   
              End            
                        END        
                 ,T.Pubdcocc = CASE WHEN @ShowSeccondResident = 'Yes' THEN   
                       CASE        
                                      WHEN Occ.Privacylevelcode in ('SEC','DAS','DBS','TAS','TBS','TCS','QAS','QBS','QCS','QDS') THEN 0        
                                   ELSE        
                                      CASE        
                                         WHEN Isnull( Occ.ResidentId, 0 ) <> 0 THEN 1        
                                      ELSE 0        
                                      END   
           END  
          ELSE        
                                    CASE        
                                       WHEN Isnull( Occ.ResidentId, 0 ) <> 0 THEN 1        
                                       ELSE 0        
                                    END           
                               END        
                 ,T.Beliminate = Occ.Beliminate        
                 ,T.Rescarelevelcode = Occ.Rescarelvlcode        
                 ,t.additionalunit=Occ.additionalunit  
     ,t.ResDeposit = Occ.ResDeposit  
     FROM   #tmpConditionalOccDetail T        
     INNER JOIN #tmpOccupancy Occ ON Occ.Unitid = T.Unitid        
           AND T.Privacylvlcode = Occ.Privacylevelcode        
           AND Occ.Title = 'Physical Occupancy'                         
     UPDATE T        
     SET    T.Residentid = Occ.Residentid        
            ,T.Residentname = Occ.Residentname        
            ,T.Dtmovein = Occ.Dtmovein        
            ,T.Dtmoveout = Occ.Dtmoveout        
            ,T.Fubocc = CASE WHEN @ShowSeccondResident = 'Yes' THEN  
                 CASE        
                                WHEN Occ.Privacylevelcode in ('SEC','DAS','DBS','TAS','TBS','TCS','QAS','QBS','QCS','QDS') THEN 0        
                                ELSE Occ.Occupancy   
        END  
       ELSE Occ.Occupancy    
                         END        
            ,T.Flbocc = CASE WHEN @ShowSeccondResident = 'Yes' THEN  
                  CASE        
                                WHEN Occ.Privacylevelcode in ('SEC','DAS','DBS','TAS','TBS','TCS','QAS','QBS','QCS','QDS') THEN 0        
                              ELSE        
                                  CASE        
                                     WHEN Isnull( Occ.Residentid, 0 ) = 0 THEN 0        
          ELSE   
            CASE Privacylevelcode when  'PRI' then   
              Case Unitcapacity when 1 then 1  
                                    when 2 then 2  
                  when 3 then 3  
                  when 4 then 4   
                  End  
         Else 1   
              End      
                                  END   
         END   
       ELSE        
                             CASE WHEN Isnull( Occ.Residentid, 0 ) = 0 THEN 0        
                             ELSE    
            CASE Privacylevelcode when  'PRI' then   
              Case Unitcapacity when 1 then 1  
                                    when 2 then 2  
                  when 3 then 3  
                  when 4 then 4   
                  End  
          Else 1  
                  end   
              End            
                         END        
            ,T.Fubdcocc = CASE WHEN @ShowSeccondResident = 'Yes' THEN  
                   CASE        
                                  WHEN Occ.Privacylevelcode in ('SEC','DAS','DBS','TAS','TBS','TCS','QAS','QBS','QCS','QDS') THEN 0        
                               ELSE        
                                    CASE        
                                       WHEN Isnull( Occ.Residentid, 0 ) <> 0 THEN 1        
                                    ELSE 0        
                                    END      
           END   
        ELSE        
                                 CASE        
                                     WHEN Isnull( Occ.Residentid, 0 ) <> 0 THEN 1        
                                 ELSE 0        
                                 END   
                          END        
                 ,T.Serviceinstancefromdate = Occ.Serviceinstancefromdate        
                 ,T.Serviceinstancetodate = Occ.Serviceinstancetodate        
                ,T.Beliminate = Occ.Beliminate        
                 ,T.Rescarelevelcode = Occ.Rescarelvlcode        
                 ,t.additionalunit=Occ.additionalunit  
     ,t.ResDeposit = Occ.ResDeposit      
     FROM   #tmpConditionalOccDetail T        
     INNER JOIN #tmpOccupancy Occ ON Occ.Unitid = T.Unitid        
           AND T.Privacylvlcode = Occ.Privacylevelcode        
           AND Occ.Title = 'Financial Occupancy'        
  INSERT INTO #tmpConditionalOccDetail      
  SELECT           
      td.Propertyid                    
     ,td.Propertyname                  
     ,td.Propcode        
     ,td.Unitid                        
     ,td.Unitcode                      
     ,td.Unittypeid                    
     ,td.Unittype                      
     ,td.Carelevelcode                 
     ,t.Privacylevelcode                
     ,td.Unitcapacity                  
     ,td.Unitbudgetcapacity            
     ,td.Unitsqft                      
     ,isnull(td1.Unitrentmonthly,td.Unitrentmonthly)              
     ,isnull(td1.Unitrentdaily,td.Unitrentdaily)                 
     ,td.Unitwaitlistflag              
     ,td.Unitexcludeflag               
     ,t.Residentid                    
     ,t.Residentname                  
     ,t.Dtmovein                      
     ,t.Dtmoveout  
  ,t.Residentname    
  ,NULL  
  ,0                       
     ,CASE WHEN @flag in (0,1,2,3) THEN t.Occupancy ELSE 0 END        
     ,CASE WHEN @flag in (0,1,2,3) THEN  
                           CASE WHEN @ShowSeccondResident = 'Yes' THEN   
                                CASE  WHEN t.Privacylevelcode in ('SEC','DAS','DBS','TAS','TBS','TCS','QAS','QBS','QCS','QDS')  THEN 0  
                                   ELSE CASE   
                       WHEN Isnull( t.Residentid, 0 ) = 0  THEN 0 ELSE 1   
              END   
            END  
         ELSE CASE   
                       WHEN Isnull( t.Residentid, 0 ) = 0  THEN 0 ELSE 1   
            END    
            END     
   END          
     ,CASE WHEN @flag in (0,1,2,3) THEN CASE WHEN Isnull( t.Residentid, 0 ) <> 0 THEN 1 ELSE 0 END END                
     ,CASE WHEN @flag in (0,4,5,6) THEN t.Occupancy ELSE 0 END        
     ,CASE WHEN @flag in (0,4,5,6) THEN   
                    CASE WHEN @ShowSeccondResident = 'Yes' THEN   
                                 CASE  WHEN t.Privacylevelcode in ('SEC','DAS','DBS','TAS','TBS','TCS','QAS','QBS','QCS','QDS')  THEN 0  
                                    ELSE CASE   
                        WHEN Isnull( t.Residentid, 0 ) = 0  THEN 0 ELSE 1   
               END   
             END  
        ELSE   
                     CASE   
                       WHEN Isnull( t.Residentid, 0 ) = 0  THEN 0 ELSE 1   
             END    
        END    
   END    
     ,CASE WHEN @flag in (0,4,5,6) THEN CASE WHEN Isnull( t.Residentid, 0 ) <> 0 THEN 1 ELSE 0 END END                                                  
     ,t.Serviceinstancefromdate       
     ,t.Serviceinstancetodate         
     ,t.Rescarelvlcode              
     ,t.Beliminate                    
     ,0      
     ,CASE t.additionalunit WHEN 1 THEN 0 ELSE 1 END   
     ,t.additionalunit  
  ,t.ResDeposit  
  ,0   
  ,0  
  ,0  
  ,0   
  ,0  
  ,0    
  ,''  
  ,0  
  ,0  
  ,0  
  ,''                                                                                                                             
     ,0   
   FROM #tmpOccupancy  t          
   INNER JOIN #tmpConditionalOccDetail td ON td.unitid=t.unitid AND td.PrivacyLvlCode='PRI'  
         AND t.PrivacyLevelCode<>'SEC'       
   LEFT JOIN #tmpConditionalOccDetail td1 ON td1.unitid=t.unitid AND td1.PrivacyLvlCode= t.Privacylevelcode       
   /*TR #480225 - Added to include multiple residents with same additional unit*/  
   LEFT JOIN #tmpConditionalOccDetail td2 ON td2.residentid=t.residentid AND td2.UnitID=t.UnitID AND td2.AdditionalUnit=t.additionalunit AND td2.PrivacyLvlCode= t.Privacylevelcode     
   WHERE ISNULL(td2.residentid,0)=0  
   SELECT MIN(ResidentID) ResidentID , unitid INTO #temp FROM #tmpConditionalOccDetail       
   WHERE 1=1 AND ResidentId > 0      
   GROUP BY unitid      
   HAVING COUNT(UNITID)> 1    
  UPDATE #tmpConditionalOccDetail      
  SET removeRecord=1      
  FROM #tmpConditionalOccDetail t      
  INNER JOIN ( SELECT t.unitid,sum(residentid)residents   
               FROM #tmpConditionalOccDetail t       
               INNER JOIN #tmpUnit tu ON tu.unitid=t.unitid AND tu.flag=0         
               GROUP by t.unitid      
               HAVING sum(residentid) =0      
             ) tu ON tu.unitid=t.unitid        
   DELETE FROM #tmpConditionalOccDetail WHERE removerecord=1      
   UPDATE d      
   SET d.Pubdcocc = 0,      
       d.Fubdcocc =0      
   FROM #tmpConditionalOccDetail d       
   INNER JOIN #temp t ON t.UnitId = d.UnitId AND t.ResidentId <> d.ResidentId      
   WHERE d.ResidentId > 0 AND d.Privacylvlcode <> 'PRI'   
   DELETE FROM #tmpConditionalOccDetail   
   WHERE residentid in (SELECT t.residentid  
         FROM #tmpConditionalOccDetail t  
         WHERE Privacylvlcode IN ( SELECT CASE WHEN ltrim(rtrim(@ShowSeccondResident)) = 'No' THEN secondaryprivacylevel ELSE '' END  
                                FROM SeniorPrivacyLevelMapping) )   
    
   DELETE FROM #tmpConditionalOccDetail      
   WHERE  Privacylvlcode in ('SEC','DAS','DBS','TAS','TBS','TCS','QAS','QBS','QCS','QDS')     
   AND Residentid = 0    
   UPDATE T      
   SET    T.Beliminate = 1    
   FROM   #tmpConditionalOccDetail T      
   INNER JOIN ( SELECT DISTINCT T1.Unitid,      
                           LEFT(T1.Privacylvlcode, 2) Privacylvlcode      
                             FROM   #tmpConditionalOccDetail T1      
                             WHERE  T1.Privacylvlcode is not NULL     
                             AND T1.Beliminate <> 0      
                             AND T1.Privacylvlcode not in ('SEC','DAS','DBS','TAS','TBS','TCS','QAS','QBS','QCS','QDS')   
        GROUP BY T1.Unitid, LEFT(T1.Privacylvlcode, 2)   
     ) T1 ON T1.Unitid = T.Unitid      
    AND LEFT( T.Privacylvlcode, 2 ) <> T1.Privacylvlcode      
    AND T.Privacylvlcode not in ('SEC','DAS','DBS','TAS','TBS','TCS','QAS','QBS','QCS','QDS')      
    UPDATE #tmpConditionalOccDetail      
    SET    Residentname = '*Vacant'      
    WHERE  Beliminate = 0       
    UPDATE #tmpConditionalOccDetail      
    SET  Residentname = '*Vacant'      
    WHERE UnitId in (SELECT UnitId  FROM #tmpConditionalOccDetail WHERE DataIssue =1)      
    AND isnull(Residentid,0)=0      
  /*TR #480225 - Copy primary unit resident care level to it's additional unit resident */  
    UPDATE occ1   
    SET    occ1.rescarelevelcode = Occ2.rescarelevelcode   
    FROM   #tmpconditionaloccdetail Occ1   
    INNER JOIN #tmpconditionaloccdetail Occ2 ON Occ1.residentid = Occ2.residentid   
    WHERE  occ1.additionalunit = 1   
    AND Occ2.additionalunit = 0   
    UPDATE #tmpconditionaloccdetail   
    SET SecOccupantRateMonthly =  SEC.AMT  
    FROM   
      (SELECT si.residentid rid,  
            SUM(CASE WHEN si.RateTypeCode='DLY' THEN (si.serviceInstanceAmount* dbo.SeniorProration(rr.Propertyid, @EOM))   
             ELSE isnull(si.serviceInstanceAmount,0) END)AMT  
       FROM #tmpconditionaloccdetail rr   
       INNER JOIN #ServiceInstancetmp si ON rr.Residentid = si.residentid   
    INNER JOIN #ServiceInstance Si1 ON (Si1.ServiceInstanceid = si.Serviceinstanceid and Si1.residentid = si.residentid)             
       INNER JOIN #service s ON s.serviceid = si1.serviceid    
       INNER JOIN #sec sec ON s.serviceid = sec.serviceid   
       LEFT OUTER JOIN SeniorProspect sp ON sp.hTenant = rr.Residentid AND sp.sStatus IN ('Prospect', 'Inactive')  
       INNER JOIN seniorcontact scon ON (scon.residentid = IsNull(sp.hMy, rr.Residentid) AND scon.relationshipcode <> 'SLF' AND scon.ContactRoommateFlag <> 0 and ContactActiveFlag <> 0)  
    WHERE 1=1  
       AND s.serviceclassid <> 1  
       AND( (SELECT count(s1.serviceid) FROM service s1 ) <> (SELECT count(s.serviceid) FROM service s WHERE 1=1) )   
       AND   si.rateTypeCode='MLY'  
       GROUP BY  si.residentid) SEC  
    INNER JOIN #tmpconditionaloccdetail rr ON sec.rid =rr.Residentid  
 UPDATE #tmpconditionaloccdetail   
    SET ResOtherMonthlyChargesAmt = OMC.MonthlyAmount,  
        ResAdditionUnitRent = OMC.AdditionalUnitRent,   
     ResAdditionUnitRentMonthly = OMC.AdditionalUnitRentMonthly,  
     ResAdditionalUnitOtherCharge = OMC.AdditionalUnitOtherChargeAmount   
    FROM (SELECT DISTINCT src.residentid resid, tt.UnitID, tt.Privacylvlcode,   
          sum(CASE WHEN ISNULL(sauc.hRecurringCharge,0)=0 THEN   
                CASE WHEN src.ratetypecode='DLY' THEN (src.recurringchargeamount* dbo.SeniorProration(tt.Propertyid, @EOM))   
          ELSE isnull(src.recurringchargeamount,0)   
       END   
     ELSE 0   
     END) MonthlyAmount,  
    SUM(CASE WHEN ISNULL(cta.hmy,0)<>0 THEN isnull(src.recurringchargeamount,0) ELSE 0 END) AdditionalUnitRent,  
    SUM(CASE WHEN ISNULL(cta.hmy,0)<>0 THEN   
             CASE WHEN src.ratetypecode='DLY' THEN (src.recurringchargeamount* dbo.SeniorProration(tt.Propertyid, @EOM))    
             ELSE isnull(src.recurringchargeamount,0)   
       END   
     ELSE 0   
     END) AdditionalUnitRentMonthly,  
    SUM(CASE WHEN ISNULL(sau.hMy,0)<>0 AND ISNULL(cta.hmy,0)=0 THEN   
             CASE WHEN src.ratetypecode='DLY' THEN (src.recurringchargeamount* dbo.SeniorProration(tt.Propertyid, @EOM))    
             ELSE isnull(src.recurringchargeamount,0)   
       END   
     ELSE 0   
     END) AdditionalUnitOtherChargeAmount   
      FROM #tmpconditionaloccdetail tt   
      INNER JOIN seniorrecurringcharge src  ON  tt.Residentid = src.residentid  and src.RecurringChargeActiveFlag <> 0 AND tt.UnitID=src.UnitID AND src.PrivacyLevelCode=tt.Privacylvlcode   
      INNER JOIN chargtyp ct ON ct.hmy = src.chargetypeid   
      INNER JOIN seniorpayor sp ON sp.payorid = src.payorid   
      LEFT JOIN ServiceInstance si ON (si.serviceinstanceid = src.serviceinstanceid )   
      LEFT JOIN service s ON (s.serviceid = si.serviceid )  
      LEFT JOIN SeniorAdditionalUnitCharge sauc ON sauc.hRecurringCharge=src.RecurringChargeID   
      LEFT JOIN SeniorAdditionalUnit sau ON sauc.hAdditionalUnit=sau.hMy AND sau.dtStart <= ISNULL(sau.dtEnd,'01/01/2100') AND sau.bActive=1   
      LEFT JOIN ChargTyp cta ON cta.hmy=src.chargetypeid AND src.recurringchargeid=sauc.hRecurringCharge AND cta.itype=2   
      WHERE 1=1   
      AND @BOM BETWEEN src.RecurringChargeFromDate AND isnull(src.RecurringChargeToDate,@BOM)   
      AND src.RecurringChargeFromDate <=  isnull(src.RecurringChargeToDate,src.RecurringChargeFromDate)   
      AND isnull(s.serviceclassid,0) <>1   
      GROUP BY src.residentid,tt.UnitID,tt.Privacylvlcode) OMC   
 INNER JOIN #tmpconditionaloccdetail tt ON tt.Residentid = OMC.resid AND tt.UnitID=OMC.UnitID AND tt.Privacylvlcode=OMC.Privacylvlcode    
 UPDATE #tmpconditionaloccdetail  
 set SecResId = r.hCooccupant,  
 SecResName = CASE WHEN t.sLastName is null THEN '' ELSE rtrim(ltrim(t.sLastName)) +', '+ltrim(rtrim(t.sFirstName)) end,  
 SecResBDt = CASE WHEN Isnull(@encryptionEnabled, 0) = -1 THEN Convert(DateTime, dbo.Db_datadecrypt(r.ResidentBirthDateSecure))  
                  ELSE r.ResidentBirthDate END,  
 SecResAge = CASE WHEN Isnull(@encryptionEnabled, 0) = -1 THEN   
                    CASE WHEN isnull(Convert(DateTime, dbo.Db_datadecrypt(r.ResidentBirthDateSecure)), '01/01/1900') = '01/01/1900' then 0 else  datediff(yy, Convert(DateTime, dbo.Db_datadecrypt(r.ResidentBirthDateSecure)), @BOM) end   
                       ELSE CASE WHEN isnull(r.ResidentBirthDate, '01/01/1900') = '01/01/1900' THEN 0   
             ELSE  datediff(yy, r.ResidentBirthDate, @BOM) END   
          End                
 from tenant t   
 inner join seniorresident r on r.hCoOccupant=  t.hmyPerson and r.privacylevelcode not in ('SEC','DAS','DBS','TAS','TBS','TCS','QAS','QBS','QCS','QDS')                         
 inner join #tmpconditionaloccdetail h on h.residentid= r.residentid   
 INNER JOIN SeniorResidentHistoryStatus srh1 On srh1.hresident = t.hmyperson  
 WHERE  srh1.iStatusCode in ( 0,1,4,11)  
 AND srh1.dtfrom <= isnull(srh1.dtto, srh1.dtfrom)    
 AND CONVERT(DATETIME, @EOM, 101) BETWEEN srh1.dtfrom AND isnull(CASE WHEN srh1.istatuscode =1 THEN srh1.dtfrom ELSE srh1.dtto END , @EOM)   
 UPDATE #tmpconditionaloccdetail  
 Set SecResBDt = CASE WHEN Isnull(@encryptionEnabled, 0) = -1 THEN Convert(DateTime, dbo.Db_datadecrypt(r.ResidentBirthDateSecure))  
                  ELSE r.ResidentBirthDate END,  
 SecResAge = CASE WHEN Isnull(@encryptionEnabled, 0) = -1 THEN   
                    CASE WHEN isnull(Convert(DateTime, dbo.Db_datadecrypt(r.ResidentBirthDateSecure)), '01/01/1900') = '01/01/1900' then 0 else  datediff(yy, Convert(DateTime, dbo.Db_datadecrypt(r.ResidentBirthDateSecure)), @BOM) end   
                       ELSE CASE WHEN isnull(r.ResidentBirthDate, '01/01/1900') = '01/01/1900' THEN 0   
             ELSE  datediff(yy, r.ResidentBirthDate, @BOM) END   
          End               
 from tenant t   
 inner join seniorresident r on r.residentid=  t.hmyPerson   
 inner join #tmpconditionaloccdetail h on h.secresid= r.residentid  
 Update #tmpconditionaloccdetail   
 set  Residentname = Residentname ,  
 ResBDt = myView.m_dtResidentBirth  ,  
 ResAge = myView.m_ResAge      
 from #tmpconditionaloccdetail rr   
 inner join (  select  t.hmyperson m_resid,    
    CASE WHEN Isnull(@encryptionEnabled, 0) = -1 THEN Convert(DateTime, dbo.Db_datadecrypt(rs.ResidentBirthDateSecure))  
                   ELSE rs.ResidentBirthDate END as m_dtResidentBirth ,    
    CASE WHEN Isnull(@encryptionEnabled, 0) = -1 THEN   
                     CASE WHEN isnull(Convert(DateTime, dbo.Db_datadecrypt(rs.ResidentBirthDateSecure)), '01/01/1900') = '01/01/1900' then 0 else  datediff(yy, Convert(DateTime, dbo.Db_datadecrypt(rs.ResidentBirthDateSecure)), @BOM) end   
                        ELSE CASE WHEN isnull(rs.ResidentBirthDate, '01/01/1900') = '01/01/1900' THEN 0   
              ELSE  datediff(yy, rs.ResidentBirthDate, @BOM) END   
           End   M_resage          
 from #tmpconditionaloccdetail r   
 Inner Join Tenant t  on t.hmyperson = r.residentid   
 inner JOIN SeniorResident rs ON (rs.residentID = t.hmyperson))myView on myView.m_resid  = rr.residentid  
 update #tmpconditionaloccdetail   
 set ResBDt = NULL  
 where ResBDt = '1900-01-01 00:00:00.000'  
  Update #tmpconditionaloccdetail   
 set Rescarelevelcode = myView.m_ResCLC  ,  
 ResPrimaryServiceAmtMonthly = myView.m_ActualRentM  ,  
 RateType = m_RateType  
 From  #tmpconditionaloccdetail rr    
 Inner Join (  select  c.unitid unitid  ,t.hmyperson m_resid ,    
     isnull(c.serviceInstanceAmount,0) AS m_ActualRentM  ,  
     isnull(c.rateTypeCode,'')  AS m_RateType  ,  
                 c.PrivacyLevelCode m_ResPriLC  ,isnull(s.carelevelcode,c.CarelevelCode) m_ResCLC    
                 FROM #tmpconditionaloccdetail r    
                 Inner Join Tenant t  on t.hmyperson = r.residentid    
                 inner JOIN #serviceInstancetmp c ON (c.residentid = t.hmyperson)   
                 INNER JOIN #ServiceInstance Si1 ON (Si1.ServiceInstanceid = c.Serviceinstanceid and Si1.residentid = c.residentid)    
                 inner JOIN #service s ON (s.serviceID = Si1.ServiceID)                    
                 where 1 = 1  
                 and s.serviceclassid = 1    
 )myView on myView.unitid = rr.unitid   
 and rr.Privacylvlcode = myView.m_ResPriLC and rr.residentid=myView.m_resid  
 update #tmpconditionaloccdetail  
 Set ResSecAmt = myview.MonthRent  
 FROM #tmpconditionaloccdetail rr  
 left join (select src.residentid resid,  sum(isnull(src.recurringchargeamount,0))  MonthRent,  
             si.PrivacyLevelCode, si.unitid    
            from #tmpconditionaloccdetail r       
      Inner Join seniorrecurringcharge src on src.residentid = r.residentid     
      inner  join #serviceInstancetmp si on si.serviceinstanceid = src.serviceinstanceid    
      inner  join #service s on s.serviceid = si.serviceid    
      where 1 = 1    
      and convert(datetime, @AsofDate, 101) between si.serviceinstancefromdate and isnull(si.serviceinstancetodate,convert(datetime, @AsofDate, 101))      
      and src.RecurringChargeActiveFlag <> 0    
      and isnull(s.serviceclassid,0) <>1     
      and src.chargetypeid   in (  select ct.Chargtypid   
                                    From #service s  
            inner JOIN #Servicechargetype sct on sct.serviceid = s.serviceid   
            inner join #Chargtyp ct on ct.Chargtypid=sct.chargetypeid   
            where 1 = 1    
            and (select count(Chargtypid) from #chargtyp ) <> (select count(ct.Chargtypid)   
                                                      From service s  
                                                      inner JOIN #Servicechargetype sct on sct.serviceid = s.serviceid   
                                                      inner join #Chargtyp ct on ct.Chargtypid=sct.chargetypeid   
                        )    
          )  group by src.residentid,si.PrivacyLevelCode, si.unitid  
    ) myView on myView.unitid = rr.unitid  
  and rr.Privacylvlcode = myView.PrivacyLevelCode and rr.residentid=myView.resid  
   Select Propertyid              
      ,Propertyname               
      ,Propcode                  
      ,Unitid                    
      ,Unitcode                  
      ,Unittypeid                
      ,Unittype                  
      ,Carelevelcode             
      ,Privacylvlcode            
      ,Unitcapacity              
      ,Unitbudgetcapacity        
      ,Unitsqft                     
      ,Unitrentmonthly              
      ,Unitrentdaily                
      ,Unitwaitlistflag          
      ,Unitexcludeflag           
      ,Residentid                
      ,Residentname               
      ,Dtmovein                  
      ,Dtmoveout   
   ,SecResName  
   ,SecResBDt  
   ,SecResAge                  
      ,Pubocc                       
      ,Plbocc                       
      ,Pubdcocc                     
      ,Fubocc                       
      ,Flbocc                       
      ,Fubdcocc                     
      ,Serviceinstancefromdate   
      ,Serviceinstancetodate     
      ,Rescarelevelcode          
      ,Beliminate                
      ,additionalunit  
   ,ResDeposit  
   ,ResOtherMonthlyChargesAmt  
      ,ResAdditionUnitRent   
      ,ResAdditionUnitRentMonthly  
      ,ResAdditionalUnitOtherCharge  
      ,SecOccupantRateMonthly    
   ,SecResId   
   ,ResBDt                    
   ,ResAge           
   ,ResSecAmt         
   ,ResPrimaryServiceAmtMonthly  
   ,RateType            
      ,ResPrimaryServiceAmtMonthly_Prorate     
   FROM #tmpConditionalOccDetail     
   ORDER BY Unitid       
 --END  