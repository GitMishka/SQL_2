//VISTA

//notes
Case# 9540445
Desc:- Contact Export Life Loop Report Scheduler report 
client: Independent Healthcare Properties LLC
//end notes

//Database
//End Database

//Title      
Contact Export Life Loop 2
//end title

//Options
ALLOW_EXPORT
//End Options

//Select 
SELECT DISTINCT sc.contactfirstname AS ContactFirstName,
                sc.contactlastname  AS ContactLastName,
                sa.addressemail     AS ContactEmail,
                sa.primaryphone     AS ContactPrimaryPhone,
				sa.AddressWorkPhone AS AddressWorkPhone,
				sa.AddressHomePhone AS AddressHomePhone,
                p1.scode            AS Community,
                lr.listoptionname   AS ContactRelationship,
                t.scode             AS ResidentCode,
                t.sfirstname        AS FirstName,
                t.slastname         AS LastName,
                lc.listoptionName   AS CareLevel
				/*,t.hmyperson         ResidentId*/
FROM   property p
       INNER JOIN listprop2 lp
               ON lp.hproplist = p.hmy
       INNER JOIN property p1
               ON p1.hmy = lp.hproperty
       INNER JOIN tenant t
               ON t.hproperty = p1.hmy
       INNER JOIN seniorresident sr
               ON ( t.hmyperson = sr.residentid )
       LEFT JOIN seniorpayor sp
              ON ( sr.payorid = sp.payorid )
		LEFT JOIN seniorresidentstatus srs
              ON ( srs.istatus = t.istatus )
       INNER JOIN seniorcontact sc
               ON ( sc.residentid = t.hmyperson
                    AND sc.contactactiveflag = 1 )
       LEFT JOIN senioraddress sa
              ON ( sa.addresssourceid = sc.contactid
                   AND sa.addresssourcecode = 'CON' )
       LEFT JOIN listoption lr
              ON ( lr.listoptioncode = sc.relationshipcode
                   AND lr.listname = 'Relationship' ) 
       LEFT JOIN listoption lc on (lc.listoptioncode = sr.carelevelcode and lc.listname = 'CareLevel')
WHERE  1 = 1
#condition1#
#condition2#
#condition3#
#condition4#
#condition5#
#condition6#
#condition7#
order by case WHEN '#orderby#' = '' or '#orderby#' = 'Contact First Name' THEN sc.contactfirstname
                  WHEN '#orderby#' = 'Contact Last Name' THEN sc.contactlastname
                  WHEN '#orderby#' = 'Contact Email' THEN  sa.addressemail  
                  WHEN '#orderby#' = 'Contact Primary Phone' THEN sa.primaryphone 
                  WHEN '#orderby#' = 'Community' THEN  p1.scode
				  WHEN '#orderby#' = 'Contact Relationship' THEN lr.listoptionname 
				  WHEN '#orderby#' = 'Resident Code' THEN t.scode
                  WHEN '#orderby#' = 'First Name' THEN t.sfirstname
                  WHEN '#orderby#' = 'Last Name' THEN t.slastname
                  WHEN '#orderby#' = 'CareLevel' THEN lc.listoptionName 
		 end
	
//End Select


//Columns
//Type,	Name,	H1,	H2,	H3,		H4,		Show,	Clr,	Frml,Drl,	Key,	Width,	Total
T,		,		,	,	Contact,    	First Name,	Y,	,	,	,	,	,	N
T,		,		,	,	Contact,    	Last Name,	Y,	,	,	,	,	,	N
T,		,		,	,	,    	Contact Email ID,	Y,	,	,	,	,	,	N
T,		,		,	,	Contact,    	Primary Phone,	Y,	,	,	,	,	,	N
T,		,		,	,	Contact,    	Work Phone,	Y,	,	,	,	,	,	N
T,		,		,	,	Contact,    	Home Phone,	Y,	,	,	,	,	,	N
T,		,		,	,	,    	Community,	Y,	,	,	,	,	,	N
T,		,		,	,	Contact,    	Relationship,	Y,	,	,	,	,	,	N
T,		,		,	,	,    	Resident Code,	Y,	,	,	,	,	,	N
T,		,		,	,	,    	First Name,	Y,	,	,	,	,	,	N
T,		,		,	,	,    	Last Name,	Y,	,	,	,	,	,	N
T,		,		,	,	,    	Care Level,	Y,	,	,	,	,	,	N
//End Columns

//Filter
//Type,	DataTyp,  Name,	    Caption,	Key,	List,	  Val1,                   Val2,   Mandatory, Multi-Type,	Title
C,      T,       P.hmy,        Community,             ,          61,    				"p.HMY = #p.hmy#",    ,        Y,          Y,            Y,
0,		T,		city,			Contact City,			,			,		"sa.AddressCityName like ltrim(rtrim('#city#%'))",	,        ,          ,            ,
0,		T,		cfname,			Contact First Name,			,			,		"sc.ContactFirstName like ltrim(rtrim('#cfname#%'))",	,        ,          ,            ,
0,		T,		clname,			Contact Last Name,			,			,		"sc.ContactLastName like ltrim(rtrim('#clname#%'))",	,        ,          ,            ,
0,		T,		state,			Contact State,			,			,		"sa.AddressStateCode like ltrim(rtrim('#state#%'))",	,        ,          ,            ,
0,		T,		zip,			Contact Zip,			,			,		"sa.AddressPostalCode like ltrim(rtrim('#zip#%'))",	,        ,          ,            ,
M,		T,		status,			Status,			,			"select status from SeniorResidentStatus where 1 = 1 and istatus not in (12,6)",					"srs.status = '#status#'",	,	,	,	Y,
L,		T,		orderby,		Sort By,			,			"^Contact First Name^Contact Last Name^Contact Email^Contact Primary Phone^Contact Relationship^Community^Resident^First Name^Last Name^CareLevel",		,	,        ,          ,            ,
//L,		T,		orderby2,		Sort By 2,			,			"^Contact First Name^Contact Last Name^Contact Email^Contact Primary Phone^Contact Relationship^Community^Resident Code^First Name^Last Name",		,	,        ,          ,            ,
//end filter
