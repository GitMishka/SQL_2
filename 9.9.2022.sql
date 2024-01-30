
  DECLARE @Date1 DATETIME DECLARE @Date2 DATETIME 
  SET 
    @Date1 = CONVERT(
      VARCHAR(20), 
      convert(datetime, '01-Dec-2021', 106), 
      101
    )+ ' ' + '10:45 AM' 
  SET 
    @Date2 = CONVERT(
      VARCHAR(20), 
      convert(datetime, '13-Sep-2022', 106), 
      101
    )+ ' ' + '10:45 AM' IF @Date1 = '01/01/1900' 
 
  SELECT 
    DISTINCT i.Hmy as IncidentHmy, 
    Ltrim(
      Rtrim(p.sAddr1)
    ) prop, 
    i.dtIncidentDate, 
    Convert(
      Varchar(10), 
      COnvert(Datetime, i.dtIncidentDate, 121), 
      101
    ), 
    CASE WHEN DATEPART(hh, i.dtIncidentDate) > 12 THEN 24 - DATEPART(hh, i.dtIncidentDate) ELSE DATEPART(hh, i.dtIncidentDate) END hh, 
    Datepart(mi, i.dtIncidentDate) mm, 
    Datepart(ss, i.dtIncidentDate) ss, 
    rtrim(
      ltrim(
        isnull(t.sLastName, '')
      )
    )+ ', ' + rtrim(
      ltrim(
        isnull(t.sFirstName, '')
      )
    ) tname, 
    ltrim(
      rtrim(u.scode)
    ) unit, 
    REPLACE(
      dbo.GetSeniorIncidentTypeLocationTreatment(
        i.Hmy, t.hmyperson, 'IncidentLocation', 
        i.sIncidentCategory
      ), 
      '^', 
      ','
    ) LOCATION, 
    l1.ListoptionName typeres, 
    lit.listoptionname IA, 
    lia.listoptionname IT, 
    t.hmyperson thmy 
  FROM 
    Property p 
    INNER JOIN SeniorIncident i ON p.hmy = i.hProperty 
    AND i.bActive = 1 
    AND i.sIncidentCategory = 'RES' 
    INNER JOIN Tenant t ON t.hmyperson = i.hAffectedPerson 
    INNER JOIN seniorresident sr ON sr.residentid = t.hmyperson 
    INNER JOIN Unit U on u.hmy = t.hUnit 
    LEFT JOIN SeniorIncidentTypeLocationTreatment il ON il.hincident = i.hmy 
    LEFT JOIN SeniorIncidentInjury iju ON iju.hincident = i.hmy 
    LEFT JOIN Listoption lit ON lit.ListOptionCode = iju.sInjuryType 
    AND lit.listname = 'IncidentInjuryType' 
    LEFT JOIN LIstoption lia ON lia.ListOptionCode = iju.sInjuryLocation 
    AND lia.listname = 'IncidentInjuryArea' 
    LEFT JOIN LIstoption l1 ON l1.ListOptionCode = i.sIncidentType 
    AND l1.listname = 'IncidentTypeResident' 
    LEFT JOIN SeniorIncidentActionTaken iat ON iat.hincident = i.hmy 
    AND ISNULL(iat.bActive, 0) = 1 
    LEFT JOIN SeniorIncidentActionTakenDetail iatd ON iat.hmy = iatd.hActionTaken 
    LEFT JOIN Listoption ListAction ON ListAction.ListOptionCode = iatd.sListValue 
    AND ListAction.listname = 'IncidentActionTakenResident' 
    LEFT JOIN SeniorIncidentActionPlan iap ON iap.Hincident = i.hmy 
    AND ISNULL(iap.bActive, 0) = 1 
    LEFT JOIN SeniorIncidentActionPlanConfigurationDetail apcd ON apcd.hmy = iap.hActionlist 
    /*LEFT JOIN ServiceInstance si ON Si.residentid = i.hAffectedPerson AND si.ServiceInstanceID in (SELECT MAX(i.ServiceInstanceID) FROM ServiceInstance i INNER JOIN Service s ON s.serviceid = i.serviceid AND s.serviceclassid =1 WHERE i.residentid = t.hmyperson AND i.ServiceInstanceFROMDate in (SELECT MAX(i2.ServiceInstanceFROMDate) FROM ServiceInstance i2 INNER JOIN Service s ON s.serviceid = i2.serviceid AND s.serviceclassid =1 WHERE i2.residentid = t.hmyperson AND i2.ServiceInstanceFROMDate < = @Date2 GROUP BY i2.residentid) GROUP BY i.residentid) LEFT JOIN Unit u ON u.hmy = si.UNitid*/
    INNER JOIN SHCrGiverZone CGZ ON CGZ.hProperty = p.HMY 
    INNER JOIN SHCrGiverZoneunit CGZU ON CGZU.hSHCrGiverZone = cgz.hmy 
    AND u.HMY = cgzu.hUnit 
    INNER JOIN SeniorUserZoneXref xref ON xref.hshcrgiverzone = CGZ.hmy 
    AND CGZU.hSHCrGiverZone = xref.hshcrgiverzone 
    INNER JOIN Pmuser Pm ON Pm.hmy = xref.huser 
    AND Pm.UNAME = 'dmihaescu@ihpllc.com' 
    LEFT JOIN SeniorGlobalContactuser SGCU ON SGCU.USERID = Pm.hmy 
    LEFT JOIN Seniorresidentuser Sru ON Sru.residentid = t.hmyperson 
    AND Sru.propertyId = p.hmy 
    AND Sru.userid = Pm.hmy 
  WHERE 
    1 = 1 
    And i.dtIncidentDate BETWEEN @Date1 
    AND @Date2 
    AND CASE WHEN isnull(SGCU.GLOBALCONTACTID, 1) = 1 THEN 1 ELSE T.HMYPERSON END = CASE WHEN isnull(SGCU.GLOBALCONTACTID, 1) = 1 THEN 1 ELSE SRU.RESIDENTID END 
    and p.hmy IN (
      'select hproperty from listprop2 where iType=3 and hproplist in ( 3) '
    ) 
  ORDER BY 
    1, 
    3, 
    11, 
    12 DESC
