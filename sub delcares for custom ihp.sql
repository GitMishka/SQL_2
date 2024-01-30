
declare @BegMonth datetime
declare @EndMonth datetime,
@propCode VARCHAR(4000),
@CareLevelCode VARCHAR(4000),
@iOccType VARCHAR(1),
@bIncludeSec VARCHAR(3),
@bIncludeMoveOutDate VARCHAR(3),
@bAdditionalUnit VARCHAR(3)

SET @BegMonth = '1-1-2022'
SET @EndMonth = '3-28-2022'
SET @bIncludeSec = 'No'
SET @bAdditionalUnit = 'No'

DECLARE @BegDefault DATETIME,
        @EndDefault DATETIME;

SET @BegDefault = '01/01/1900';
SET @EndDefault = '12/31/2200';

SET @propCode = '20'
DECLARE @encryptionEnabled INTEGER
SET @encryptionEnabled=isnull( (SELECT svalue
                         FROM   paramopt2
                         WHERE  Upper(stype) = 'ENABLEDATAENCRYPTION'),0)

SELECT @propCode = @propCode + CONVERT(VARCHAR(100), p.hmy) + ',' 
FROM Property P
WHERE
1 = 1

SET @propCode = LEFT( @propCode, Len( @propCode ) - 1 )

SET @CareLevelCode = ''
SELECT @CareLevelCode = @CareLevelCode + CONVERT(VARCHAR(100), l1.hmy) + ','
FROM listoption l1
WHERE l1.listname = 'CareLevel' 


SET @CareLevelCode = LEFT( @CareLevelCode, Len( @CareLevelCode ) - 1 )
SET @iOccType = 4

SET @bIncludeMoveOutDate = CASE WHEN @iOccType IN ('1','2','3') THEN 'No' ELSE 'YES' END

IF OBJECT_ID ('TempDb..#tmpOccupancyResultLocal') IS NOT NULL
     DROP TABLE #tmpOccupancyResultLocal

CREATE TAble #tmpOccupancyResultLocal (
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

INSERT INTO #tmpOccupancyResultLocal
EXEC SeniorIHPPortfolioCensusReport @hprop  = @propCode, @BOM = @BegMonth, @EOM = @EndMonth, @flag = @iOccType, @ShowSeccondResident = @bIncludeSec, @IncludeMoveOutDate = @bIncludeMoveOutDate, @CareLevel = @CareLevelCode, @AdditionalUnit = @bAdditionalUnit  

SELECT t.PropertyId,propertyname,CareLevelCode,MoveInCount,MoveOutCount
FROM #tmpOccupancyResultLocal t
ORDER  BY 2,4	
