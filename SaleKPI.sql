//Vista

//Notes
  Script Name : rs_sql_IHP_Sales_KPI.txt
  Client Name : Independent Healthcare Properties LLC
  Date        : 05/01/2019
  Description : Populate IHP Sales KPI Report
//End Notes


//Database
SSRS rs_IHP_Sales_KPI.rdlc
//End Database




//Title
IHP Sales KPI
//end title




//SELECT Dataset1


DECLARE
@wk_startdate DATETIME,
@wk_enddate DATETIME,
@mtd_startdate DATETIME,
@mtd_enddate DATETIME,
@lm_startdate DATETIME,
@lm_enddate DATETIME

SET @wk_startdate = '#dat1#'
SET @wk_enddate = dateadd(DAY,6,@wk_startdate) 
SET @mtd_startdate = DATEADD(month, DATEDIFF(month, 0, @wk_enddate), 0)
SET @mtd_enddate = @wk_enddate  
SET @lm_startdate = CONVERT(DATE, DATEADD(d, -( DAY(DATEADD(m, -1, @wk_enddate - 2)) ), DATEADD(m, -1, @wk_enddate - 1))) 
SET @lm_enddate = CONVERT(DATE, DATEADD(d, -( DAY(@wk_enddate) ), @wk_enddate))

/*

	Create Goal Values
*/

IF OBJECT_ID ('TempDb..#Sales_Goals') IS NOT NULL
DROP TABLE #Sales_Goals

Create Table #Sales_Goals
(
        Community_Code      varchar(300),
        Period          	varchar (3),
        Measure        		int,
		Goal				int
)

insert into #Sales_Goals select 'lenl','WK',10,5
insert into #Sales_Goals select 'lenl','MTD',10,20
insert into #Sales_Goals select 'lenl','WK',20,15
insert into #Sales_Goals select 'lenl','MTD',20,60
insert into #Sales_Goals select 'lenl','WK',30,15
insert into #Sales_Goals select 'lenl','MTD',30,60
insert into #Sales_Goals select 'lenl','WK',40,5
insert into #Sales_Goals select 'lenl','MTD',40,20
insert into #Sales_Goals select 'lenl','WK',50,2
insert into #Sales_Goals select 'lenl','MTD',50,8
insert into #Sales_Goals select 'lenl','MTD',60,4
insert into #Sales_Goals select 'lenl','MTD',70,4
insert into #Sales_Goals select 'lenc','WK',10,5
insert into #Sales_Goals select 'lenc','MTD',10,20
insert into #Sales_Goals select 'lenc','WK',20,15
insert into #Sales_Goals select 'lenc','MTD',20,60
insert into #Sales_Goals select 'lenc','WK',30,15
insert into #Sales_Goals select 'lenc','MTD',30,60
insert into #Sales_Goals select 'lenc','WK',40,5
insert into #Sales_Goals select 'lenc','MTD',40,20
insert into #Sales_Goals select 'lenc','WK',50,2
insert into #Sales_Goals select 'lenc','MTD',50,8
insert into #Sales_Goals select 'lenc','MTD',60,4
insert into #Sales_Goals select 'lenc','MTD',70,4
insert into #Sales_Goals select 'powl','WK',10,5
insert into #Sales_Goals select 'powl','MTD',10,20
insert into #Sales_Goals select 'powl','WK',20,15
insert into #Sales_Goals select 'powl','MTD',20,60
insert into #Sales_Goals select 'powl','WK',30,20
insert into #Sales_Goals select 'powl','MTD',30,80
insert into #Sales_Goals select 'powl','WK',40,5
insert into #Sales_Goals select 'powl','MTD',40,20
insert into #Sales_Goals select 'powl','WK',50,2
insert into #Sales_Goals select 'powl','MTD',50,8
insert into #Sales_Goals select 'powl','MTD',60,4
insert into #Sales_Goals select 'powl','MTD',70,4
insert into #Sales_Goals select 'hixn','WK',10,5
insert into #Sales_Goals select 'hixn','MTD',10,20
insert into #Sales_Goals select 'hixn','WK',20,15
insert into #Sales_Goals select 'hixn','MTD',20,60
insert into #Sales_Goals select 'hixn','WK',30,20
insert into #Sales_Goals select 'hixn','MTD',30,80
insert into #Sales_Goals select 'hixn','WK',40,5
insert into #Sales_Goals select 'hixn','MTD',40,20
insert into #Sales_Goals select 'hixn','WK',50,2
insert into #Sales_Goals select 'hixn','MTD',50,8
insert into #Sales_Goals select 'hixn','MTD',60,4
insert into #Sales_Goals select 'hixn','MTD',70,4
insert into #Sales_Goals select 'frkl','WK',10,5
insert into #Sales_Goals select 'frkl','MTD',10,20
insert into #Sales_Goals select 'frkl','WK',20,15
insert into #Sales_Goals select 'frkl','MTD',20,60
insert into #Sales_Goals select 'frkl','WK',30,15
insert into #Sales_Goals select 'frkl','MTD',30,60
insert into #Sales_Goals select 'frkl','WK',40,5
insert into #Sales_Goals select 'frkl','MTD',40,20
insert into #Sales_Goals select 'frkl','WK',50,2
insert into #Sales_Goals select 'frkl','MTD',50,8
insert into #Sales_Goals select 'frkl','MTD',60,4
insert into #Sales_Goals select 'frkl','MTD',70,4
insert into #Sales_Goals select 'frkt','WK',10,5
insert into #Sales_Goals select 'frkt','WK',20,15
insert into #Sales_Goals select 'frkt','WK',30,15
insert into #Sales_Goals select 'frkt','WK',40,5
insert into #Sales_Goals select 'frkt','WK',50,2
insert into #Sales_Goals select 'frkt','MTD',10,20
insert into #Sales_Goals select 'frkt','MTD',20,60
insert into #Sales_Goals select 'frkt','MTD',30,60
insert into #Sales_Goals select 'frkt','MTD',40,20
insert into #Sales_Goals select 'frkt','MTD',50,8
insert into #Sales_Goals select 'frkt','MTD',60,4
insert into #Sales_Goals select 'frkt','MTD',70,4
insert into #Sales_Goals select 'lvll','WK',10,5
insert into #Sales_Goals select 'lvll','MTD',10,20
insert into #Sales_Goals select 'lvll','WK',20,35
insert into #Sales_Goals select 'lvll','MTD',20,140
insert into #Sales_Goals select 'lvll','WK',30,20
insert into #Sales_Goals select 'lvll','MTD',30,80
insert into #Sales_Goals select 'lvll','WK',40,5
insert into #Sales_Goals select 'lvll','MTD',40,20
insert into #Sales_Goals select 'lvll','WK',50,2
insert into #Sales_Goals select 'lvll','MTD',50,8
insert into #Sales_Goals select 'lvll','MTD',60,4
insert into #Sales_Goals select 'lvll','MTD',70,4
insert into #Sales_Goals select 'frln','WK',10,5
insert into #Sales_Goals select 'frln','MTD',10,20
insert into #Sales_Goals select 'frln','WK',20,15
insert into #Sales_Goals select 'frln','MTD',20,60
insert into #Sales_Goals select 'frln','WK',30,20
insert into #Sales_Goals select 'frln','MTD',30,80
insert into #Sales_Goals select 'frln','WK',40,5
insert into #Sales_Goals select 'frln','MTD',40,20
insert into #Sales_Goals select 'frln','WK',50,2
insert into #Sales_Goals select 'frln','MTD',50,8
insert into #Sales_Goals select 'frln','MTD',60,4
insert into #Sales_Goals select 'frln','MTD',70,4
insert into #Sales_Goals select 'calh','WK',10,5
insert into #Sales_Goals select 'calh','WK',20,15
insert into #Sales_Goals select 'calh','WK',30,20
insert into #Sales_Goals select 'calh','WK',40,5
insert into #Sales_Goals select 'calh','WK',50,2
insert into #Sales_Goals select 'calh','MTD',10,20
insert into #Sales_Goals select 'calh','MTD',20,60
insert into #Sales_Goals select 'calh','MTD',30,80
insert into #Sales_Goals select 'calh','MTD',40,20
insert into #Sales_Goals select 'calh','MTD',50,8
insert into #Sales_Goals select 'calh','MTD',60,4
insert into #Sales_Goals select 'calh','MTD',70,4
insert into #Sales_Goals select 'chtt','WK',10,5
insert into #Sales_Goals select 'chtt','WK',20,15
insert into #Sales_Goals select 'chtt','WK',30,20
insert into #Sales_Goals select 'chtt','WK',40,5
insert into #Sales_Goals select 'chtt','WK',50,2
insert into #Sales_Goals select 'chtt','MTD',10,20
insert into #Sales_Goals select 'chtt','MTD',20,60
insert into #Sales_Goals select 'chtt','MTD',30,80
insert into #Sales_Goals select 'chtt','MTD',40,20
insert into #Sales_Goals select 'chtt','MTD',50,8
insert into #Sales_Goals select 'chtt','MTD',60,4
insert into #Sales_Goals select 'chtt','MTD',70,4
insert into #Sales_Goals select 'cgdl','WK',10,5
insert into #Sales_Goals select 'cgdl','WK',20,15
insert into #Sales_Goals select 'cgdl','WK',30,15
insert into #Sales_Goals select 'cgdl','WK',40,5
insert into #Sales_Goals select 'cgdl','WK',50,2
insert into #Sales_Goals select 'cgdl','MTD',10,20
insert into #Sales_Goals select 'cgdl','MTD',20,60
insert into #Sales_Goals select 'cgdl','MTD',30,60
insert into #Sales_Goals select 'cgdl','MTD',40,20
insert into #Sales_Goals select 'cgdl','MTD',50,8
insert into #Sales_Goals select 'cgdl','MTD',60,4
insert into #Sales_Goals select 'cgdl','MTD',70,4
insert into #Sales_Goals select 'danv','WK',10,5
insert into #Sales_Goals select 'danv','WK',20,15
insert into #Sales_Goals select 'danv','WK',30,20
insert into #Sales_Goals select 'danv','WK',40,5
insert into #Sales_Goals select 'danv','WK',50,2
insert into #Sales_Goals select 'danv','MTD',10,20
insert into #Sales_Goals select 'danv','MTD',20,60
insert into #Sales_Goals select 'danv','MTD',30,80
insert into #Sales_Goals select 'danv','MTD',40,20
insert into #Sales_Goals select 'danv','MTD',50,8
insert into #Sales_Goals select 'danv','MTD',60,4
insert into #Sales_Goals select 'danv','MTD',70,4
insert into #Sales_Goals select 'lexn','WK',10,5
insert into #Sales_Goals select 'lexn','WK',20,35
insert into #Sales_Goals select 'lexn','WK',30,20
insert into #Sales_Goals select 'lexn','WK',40,5
insert into #Sales_Goals select 'lexn','WK',50,2
insert into #Sales_Goals select 'lexn','MTD',10,20
insert into #Sales_Goals select 'lexn','MTD',20,140
insert into #Sales_Goals select 'lexn','MTD',30,80
insert into #Sales_Goals select 'lexn','MTD',40,20
insert into #Sales_Goals select 'lexn','MTD',50,8
insert into #Sales_Goals select 'lexn','MTD',60,4
insert into #Sales_Goals select 'lexn','MTD',70,4
insert into #Sales_Goals select 'lexl','WK',10,5
insert into #Sales_Goals select 'lexl','WK',20,35
insert into #Sales_Goals select 'lexl','WK',30,20
insert into #Sales_Goals select 'lexl','WK',40,5
insert into #Sales_Goals select 'lexl','WK',50,2
insert into #Sales_Goals select 'lexl','MTD',10,20
insert into #Sales_Goals select 'lexl','MTD',20,140
insert into #Sales_Goals select 'lexl','MTD',30,80
insert into #Sales_Goals select 'lexl','MTD',40,20
insert into #Sales_Goals select 'lexl','MTD',50,8
insert into #Sales_Goals select 'lexl','MTD',60,4
insert into #Sales_Goals select 'lexl','MTD',70,4
insert into #Sales_Goals select 'lexe','WK',10,5
insert into #Sales_Goals select 'lexe','WK',20,15
insert into #Sales_Goals select 'lexe','WK',30,20
insert into #Sales_Goals select 'lexe','WK',40,5
insert into #Sales_Goals select 'lexe','WK',50,2
insert into #Sales_Goals select 'lexe','MTD',10,20
insert into #Sales_Goals select 'lexe','MTD',20,60
insert into #Sales_Goals select 'lexe','MTD',30,80
insert into #Sales_Goals select 'lexe','MTD',40,20
insert into #Sales_Goals select 'lexe','MTD',50,8
insert into #Sales_Goals select 'lexe','MTD',60,4
insert into #Sales_Goals select 'lexe','MTD',70,4
insert into #Sales_Goals select 'rich','WK',10,1
insert into #Sales_Goals select 'rich','WK',20,4
insert into #Sales_Goals select 'rich','WK',30,10
insert into #Sales_Goals select 'rich','WK',40,5
insert into #Sales_Goals select 'rich','WK',50,1
insert into #Sales_Goals select 'rich','MTD',10,4
insert into #Sales_Goals select 'rich','MTD',20,16
insert into #Sales_Goals select 'rich','MTD',30,40
insert into #Sales_Goals select 'rich','MTD',40,20
insert into #Sales_Goals select 'rich','MTD',50,4
insert into #Sales_Goals select 'rich','MTD',60,4
insert into #Sales_Goals select 'rich','MTD',70,4
insert into #Sales_Goals select 'lvlm','WK',10,5
insert into #Sales_Goals select 'lvlm','WK',20,35
insert into #Sales_Goals select 'lvlm','WK',30,20
insert into #Sales_Goals select 'lvlm','WK',40,5
insert into #Sales_Goals select 'lvlm','WK',50,2
insert into #Sales_Goals select 'lvlm','MTD',10,20
insert into #Sales_Goals select 'lvlm','MTD',20,140
insert into #Sales_Goals select 'lvlm','MTD',30,80
insert into #Sales_Goals select 'lvlm','MTD',40,20
insert into #Sales_Goals select 'lvlm','MTD',50,8
insert into #Sales_Goals select 'lvlm','MTD',60,4
insert into #Sales_Goals select 'lvlm','MTD',70,4
insert into #Sales_Goals select 'brwd','WK',10,5
insert into #Sales_Goals select 'brwd','WK',20,15
insert into #Sales_Goals select 'brwd','WK',30,20
insert into #Sales_Goals select 'brwd','WK',40,5
insert into #Sales_Goals select 'brwd','WK',50,2
insert into #Sales_Goals select 'brwd','MTD',10,20
insert into #Sales_Goals select 'brwd','MTD',20,60
insert into #Sales_Goals select 'brwd','MTD',30,80
insert into #Sales_Goals select 'brwd','MTD',40,20
insert into #Sales_Goals select 'brwd','MTD',50,8
insert into #Sales_Goals select 'brwd','MTD',60,4
insert into #Sales_Goals select 'brwd','MTD',70,4
insert into #Sales_Goals select 'colm','WK',10,1
insert into #Sales_Goals select 'colm','WK',20,4
insert into #Sales_Goals select 'colm','WK',30,10
insert into #Sales_Goals select 'colm','WK',40,5
insert into #Sales_Goals select 'colm','WK',50,1
insert into #Sales_Goals select 'colm','MTD',10,4
insert into #Sales_Goals select 'colm','MTD',20,16
insert into #Sales_Goals select 'colm','MTD',30,40
insert into #Sales_Goals select 'colm','MTD',40,20
insert into #Sales_Goals select 'colm','MTD',50,4
insert into #Sales_Goals select 'colm','MTD',60,4
insert into #Sales_Goals select 'colm','MTD',70,4

insert into #Sales_Goals select 'sprh','WK',10,5
insert into #Sales_Goals select 'sprh','WK',20,35
insert into #Sales_Goals select 'sprh','WK',30,20
insert into #Sales_Goals select 'sprh','WK',40,5
insert into #Sales_Goals select 'sprh','WK',50,2
insert into #Sales_Goals select 'sprh','MTD',10,20
insert into #Sales_Goals select 'sprh','MTD',20,140
insert into #Sales_Goals select 'sprh','MTD',30,80
insert into #Sales_Goals select 'sprh','MTD',40,20
insert into #Sales_Goals select 'sprh','MTD',50,8
insert into #Sales_Goals select 'sprh','MTD',60,4
insert into #Sales_Goals select 'sprh','MTD',70,4
insert into #Sales_Goals select 'tula','WK',10,1
insert into #Sales_Goals select 'tula','WK',20,4
insert into #Sales_Goals select 'tula','WK',30,10
insert into #Sales_Goals select 'tula','WK',40,5
insert into #Sales_Goals select 'tula','WK',50,1
insert into #Sales_Goals select 'tula','MTD',10,4
insert into #Sales_Goals select 'tula','MTD',20,16
insert into #Sales_Goals select 'tula','MTD',30,40
insert into #Sales_Goals select 'tula','MTD',40,20
insert into #Sales_Goals select 'tula','MTD',50,4
insert into #Sales_Goals select 'tula','MTD',60,4
insert into #Sales_Goals select 'tula','MTD',70,4
insert into #Sales_Goals select 'tusc','WK',10,5
insert into #Sales_Goals select 'tusc','WK',20,15
insert into #Sales_Goals select 'tusc','WK',30,20
insert into #Sales_Goals select 'tusc','WK',40,5
insert into #Sales_Goals select 'tusc','WK',50,2
insert into #Sales_Goals select 'tusc','MTD',10,20
insert into #Sales_Goals select 'tusc','MTD',20,60
insert into #Sales_Goals select 'tusc','MTD',30,80
insert into #Sales_Goals select 'tusc','MTD',40,20
insert into #Sales_Goals select 'tusc','MTD',50,8
insert into #Sales_Goals select 'tusc','MTD',60,4
insert into #Sales_Goals select 'tusc','MTD',70,4
insert into #Sales_Goals select 'aths','WK',10,1
insert into #Sales_Goals select 'aths','WK',20,4
insert into #Sales_Goals select 'aths','WK',30,10
insert into #Sales_Goals select 'aths','WK',40,5
insert into #Sales_Goals select 'aths','WK',50,1
insert into #Sales_Goals select 'aths','MTD',10,4
insert into #Sales_Goals select 'aths','MTD',20,16
insert into #Sales_Goals select 'aths','MTD',30,40
insert into #Sales_Goals select 'aths','MTD',40,20
insert into #Sales_Goals select 'aths','MTD',50,4
insert into #Sales_Goals select 'aths','MTD',60,4
insert into #Sales_Goals select 'aths','MTD',70,4
insert into #Sales_Goals select 'grnv','WK',10,1
insert into #Sales_Goals select 'grnv','WK',20,4
insert into #Sales_Goals select 'grnv','WK',30,10
insert into #Sales_Goals select 'grnv','WK',40,5
insert into #Sales_Goals select 'grnv','WK',50,1
insert into #Sales_Goals select 'grnv','MTD',10,4
insert into #Sales_Goals select 'grnv','MTD',20,16
insert into #Sales_Goals select 'grnv','MTD',30,40
insert into #Sales_Goals select 'grnv','MTD',40,20
insert into #Sales_Goals select 'grnv','MTD',50,4
insert into #Sales_Goals select 'grnv','MTD',60,4
insert into #Sales_Goals select 'grnv','MTD',70,4
insert into #Sales_Goals select 'knox','WK',10,5
insert into #Sales_Goals select 'knox','WK',20,35
insert into #Sales_Goals select 'knox','WK',30,20
insert into #Sales_Goals select 'knox','WK',40,5
insert into #Sales_Goals select 'knox','WK',50,2
insert into #Sales_Goals select 'knox','MTD',10,20
insert into #Sales_Goals select 'knox','MTD',20,140
insert into #Sales_Goals select 'knox','MTD',30,80
insert into #Sales_Goals select 'knox','MTD',40,20
insert into #Sales_Goals select 'knox','MTD',50,8
insert into #Sales_Goals select 'knox','MTD',60,4
insert into #Sales_Goals select 'knox','MTD',70,4
insert into #Sales_Goals select 'eham','WK',10,5
insert into #Sales_Goals select 'eham','WK',20,15
insert into #Sales_Goals select 'eham','WK',30,20
insert into #Sales_Goals select 'eham','WK',40,5
insert into #Sales_Goals select 'eham','WK',50,2
insert into #Sales_Goals select 'eham','MTD',10,20
insert into #Sales_Goals select 'eham','MTD',20,60
insert into #Sales_Goals select 'eham','MTD',30,80
insert into #Sales_Goals select 'eham','MTD',40,20
insert into #Sales_Goals select 'eham','MTD',50,8
insert into #Sales_Goals select 'eham','MTD',60,4
insert into #Sales_Goals select 'eham','MTD',70,4
/* 2019-10-02 Changed Goals */
/* Replaced on 2019-12-11
insert into #Sales_Goals select 'fktl','WK',10,1
insert into #Sales_Goals select 'fktl','WK',20,4
insert into #Sales_Goals select 'fktl','WK',30,10
insert into #Sales_Goals select 'fktl','WK',40,5
insert into #Sales_Goals select 'fktl','WK',50,1
insert into #Sales_Goals select 'fktl','MTD',10,4
insert into #Sales_Goals select 'fktl','MTD',20,16
insert into #Sales_Goals select 'fktl','MTD',30,40
insert into #Sales_Goals select 'fktl','MTD',40,20
insert into #Sales_Goals select 'fktl','MTD',50,4
insert into #Sales_Goals select 'fktl','MTD',60,4
insert into #Sales_Goals select 'fktl','MTD',70,4
*/



/* 2020-03-04 Changed Goals */
insert into #Sales_Goals select 'chtl','WK',10,1
insert into #Sales_Goals select 'chtl','WK',20,4
insert into #Sales_Goals select 'chtl','WK',30,10
insert into #Sales_Goals select 'chtl','WK',40,5
insert into #Sales_Goals select 'chtl','WK',50,1
insert into #Sales_Goals select 'chtl','MTD',10,4
insert into #Sales_Goals select 'chtl','MTD',20,16
insert into #Sales_Goals select 'chtl','MTD',30,40
insert into #Sales_Goals select 'chtl','MTD',40,20
insert into #Sales_Goals select 'chtl','MTD',50,4
insert into #Sales_Goals select 'chtl','MTD',60,4
insert into #Sales_Goals select 'chtl','MTD',70,4

insert into #Sales_Goals select 'grnb','WK',10,5
insert into #Sales_Goals select 'grnb','WK',20,15
insert into #Sales_Goals select 'grnb','WK',30,15
insert into #Sales_Goals select 'grnb','WK',40,5
insert into #Sales_Goals select 'grnb','WK',50,2
insert into #Sales_Goals select 'grnb','MTD',10,20
insert into #Sales_Goals select 'grnb','MTD',20,60
insert into #Sales_Goals select 'grnb','MTD',30,60
insert into #Sales_Goals select 'grnb','MTD',40,20
insert into #Sales_Goals select 'grnb','MTD',50,8
insert into #Sales_Goals select 'grnb','MTD',60,4
insert into #Sales_Goals select 'grnb','MTD',70,4

insert into #Sales_Goals select 'sprl','WK',10,5
insert into #Sales_Goals select 'sprl','WK',20,35
insert into #Sales_Goals select 'sprl','WK',30,15
insert into #Sales_Goals select 'sprl','WK',40,5
insert into #Sales_Goals select 'sprl','WK',50,2
insert into #Sales_Goals select 'sprl','MTD',10,20
insert into #Sales_Goals select 'sprl','MTD',20,140
insert into #Sales_Goals select 'sprl','MTD',30,60
insert into #Sales_Goals select 'sprl','MTD',40,20
insert into #Sales_Goals select 'sprl','MTD',50,8
insert into #Sales_Goals select 'sprl','MTD',60,4
insert into #Sales_Goals select 'sprl','MTD',70,4

insert into #Sales_Goals select 'clin','WK',10,1
insert into #Sales_Goals select 'clin','WK',20,4
insert into #Sales_Goals select 'clin','WK',30,10
insert into #Sales_Goals select 'clin','WK',40,5
insert into #Sales_Goals select 'clin','WK',50,1
insert into #Sales_Goals select 'clin','MTD',10,4
insert into #Sales_Goals select 'clin','MTD',20,16
insert into #Sales_Goals select 'clin','MTD',30,40
insert into #Sales_Goals select 'clin','MTD',40,20
insert into #Sales_Goals select 'clin','MTD',50,4
insert into #Sales_Goals select 'clin','MTD',60,4
insert into #Sales_Goals select 'clin','MTD',70,4

/* 2020-07-31 Added Goal for Knoxville Lantern */
insert into #Sales_Goals select 'knxl','WK',10,5
insert into #Sales_Goals select 'knxl','WK',20,35
insert into #Sales_Goals select 'knxl','WK',30,20
insert into #Sales_Goals select 'knxl','WK',40,5
insert into #Sales_Goals select 'knxl','WK',50,2
insert into #Sales_Goals select 'knxl','MTD',10,20
insert into #Sales_Goals select 'knxl','MTD',20,140
insert into #Sales_Goals select 'knxl','MTD',30,80
insert into #Sales_Goals select 'knxl','MTD',40,20
insert into #Sales_Goals select 'knxl','MTD',50,8
insert into #Sales_Goals select 'knxl','MTD',60,4
insert into #Sales_Goals select 'knxl','MTD',70,4

/* 2020-10-30 Changed Goal for Franklins */
insert into #Sales_Goals select 'fktn','WK',10,5
insert into #Sales_Goals select 'fktn','WK',20,15
insert into #Sales_Goals select 'fktn','WK',30,20
insert into #Sales_Goals select 'fktn','WK',40,5
insert into #Sales_Goals select 'fktn','WK',50,2
insert into #Sales_Goals select 'fktn','MTD',10,20
insert into #Sales_Goals select 'fktn','MTD',20,140
insert into #Sales_Goals select 'fktn','MTD',30,80
insert into #Sales_Goals select 'fktn','MTD',40,20
insert into #Sales_Goals select 'fktn','MTD',50,8
insert into #Sales_Goals select 'fktn','MTD',60,4
insert into #Sales_Goals select 'fktn','MTD',70,4

insert into #Sales_Goals select 'fktl','WK',10,5
insert into #Sales_Goals select 'fktl','WK',20,15
insert into #Sales_Goals select 'fktl','WK',30,20
insert into #Sales_Goals select 'fktl','WK',40,5
insert into #Sales_Goals select 'fktl','WK',50,2
insert into #Sales_Goals select 'fktl','MTD',10,20
insert into #Sales_Goals select 'fktl','MTD',20,140
insert into #Sales_Goals select 'fktl','MTD',30,80
insert into #Sales_Goals select 'fktl','MTD',40,20
insert into #Sales_Goals select 'fktl','MTD',50,8
insert into #Sales_Goals select 'fktl','MTD',60,4
insert into #Sales_Goals select 'fktl','MTD',70,4

/* 2021-02-25 Changed Goal for Russells */
insert into #Sales_Goals select 'russ','WK',10,5
insert into #Sales_Goals select 'russ','WK',20,22
insert into #Sales_Goals select 'russ','WK',30,15
insert into #Sales_Goals select 'russ','WK',40,5
insert into #Sales_Goals select 'russ','WK',50,2
insert into #Sales_Goals select 'russ','MTD',10,20
insert into #Sales_Goals select 'russ','MTD',20,60
insert into #Sales_Goals select 'russ','MTD',30,60
insert into #Sales_Goals select 'russ','MTD',40,20
insert into #Sales_Goals select 'russ','MTD',50,8
insert into #Sales_Goals select 'russ','MTD',60,4
insert into #Sales_Goals select 'russ','MTD',70,4
insert into #Sales_Goals select 'rusl','WK',10,5
insert into #Sales_Goals select 'rusl','WK',20,22
insert into #Sales_Goals select 'rusl','WK',30,15
insert into #Sales_Goals select 'rusl','WK',40,5
insert into #Sales_Goals select 'rusl','WK',50,2
insert into #Sales_Goals select 'rusl','MTD',10,20
insert into #Sales_Goals select 'rusl','MTD',20,60
insert into #Sales_Goals select 'rusl','MTD',30,60
insert into #Sales_Goals select 'rusl','MTD',40,20
insert into #Sales_Goals select 'rusl','MTD',50,8
insert into #Sales_Goals select 'rusl','MTD',60,4
insert into #Sales_Goals select 'rusl','MTD',70,4

insert into #Sales_Goals
select
Community_Code
,'LM'
,Measure
,Goal
from #Sales_Goals where Period = 'MTD'


/*
	Create Findings Table
*/


IF OBJECT_ID ('TempDb..#Sales_KPI_Findings') IS NOT NULL
DROP TABLE #Sales_KPI_Findings

Create Table #Sales_KPI_Findings
(
        hprop           int,
        Community       varchar(300),
        Period          varchar (3),
        Measure         int,
		Measure_Desc	varchar(100),
		Goal			int,
        Count           int
)

/*
	Create 1st Tourd Table
*/


IF OBJECT_ID ('TempDb..#Sales_KPI_First_Tours') IS NOT NULL
DROP TABLE #Sales_KPI_First_Tours

Create Table #Sales_KPI_First_Tours
(
        hprop           int,
        Community       varchar(300),
        Period          varchar (3),
        Measure         int,
		Measure_Desc	varchar(100),
		Goal			int,
        Count           int
)

/*
	Create Final Reports Collection Table
*/
IF OBJECT_ID ('TempDb..#Sales_KPI') IS NOT NULL
DROP TABLE #Sales_KPI

CREATE TABLE [dbo].[#Sales_KPI](
	[hprop] [int] ,
	[Community] [varchar](300) ,
	[Community_Abbr] [varchar](300) ,
	[Region] [varchar](300) ,
	[CRD] [varchar](300) ,
	[RDSM] [varchar](300) ,
	[Report_Index] [varchar](300) ,
	[Report_Index_Desc] [varchar](300) ,	
	[Period] [varchar](3) ,
	[Measure] int ,
	[Measure_Desc]	[varchar](100),	
	[Goal] [int] ,
	[Count] [int] ,
	[Percentage] [decimal](18, 5) ,
	[Score] [decimal](18, 5) ,
	[wk_startdate] [datetime] ,
	[wk_enddate] [datetime] ,
	[mtd_startdate] [datetime] ,
	[mtd_enddate] [datetime] ,
	[lm_startdate] [datetime] ,
	[lm_enddate] [datetime] 	
) 


/*
	Week Leads
*/



insert into #Sales_KPI_Findings
select 
	p.hMy
	, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')'   PropertyName
	, 'WK'
	, 40
	,'Leads/Inquiries'
	, isnull(g.goal,0)
	, isnull(count(distinct sp.hMy),0) as NewLeads
from 
	Property p
	left join #Sales_Goals g on p.scode = g.Community_Code and g.Period = 'WK' and g.Measure = 40

	left join (
	select 
		ph.hProperty
		,sp.hMy
		,sp.slastname
		,sp.sfirstname
		,sp.dtFirstContact
        ,ph.dtDate

	from 
		SeniorProspect sp
		left join 
      (SELECT tbl.*
FROM SeniorProspectHistory tbl
  INNER JOIN
  (
    SELECT hProspect, MIN(hMy) hMy
    FROM SeniorProspectHistory
    group by hProspect
  ) tbl1
   ON tbl1.hmy = tbl.hmy

) ph 
      on sp.hMy = ph.hProspect

	where  
		ph.dtDate  between @wk_startdate and @wk_enddate
	        and sp.sStatus <> 'Referral'
	) sp on p.hMy = sp.hProperty


Group By
	p.hMy, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')', g.goal


                 

/*
	Month-to-Date Leads
*/


insert into #Sales_KPI_Findings
select 
	p.hMy
	,Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')'   PropertyName
	, 'MTD'
	, 40
	,'Leads/Inquiries'
	, isnull(g.goal,0)
	, isnull(count(distinct sp.hMy),0) as NewLeads
from 
	Property p
	left join #Sales_Goals g on p.scode = g.Community_Code and g.Period = 'MTD' and g.Measure = 40
	left join (
	select 
		ph.hProperty
		,sp.hMy
		,sp.slastname
		,sp.sfirstname
		,sp.dtFirstContact
        ,ph.dtDate

	from 
		SeniorProspect sp
		left join 
      (SELECT tbl.*
FROM SeniorProspectHistory tbl
  INNER JOIN
  (
    SELECT hProspect, MIN(hMy) hMy
    FROM SeniorProspectHistory
    group by hProspect
  ) tbl1
   ON tbl1.hmy = tbl.hmy

) ph 
      on sp.hMy = ph.hProspect

	where  
		ph.dtDate  between @mtd_startdate and @mtd_enddate
	        and sp.sStatus <> 'Referral'
	) sp on p.hMy = sp.hProperty


Group By
	p.hMy, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')', g.goal


/*
	Last Month Leads
*/


insert into #Sales_KPI_Findings
select 
	p.hMy
	,Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')'   PropertyName
	, 'LM'
	, 40
	,'Leads/Inquiries'
	, isnull(g.goal,0)
	, isnull(count(distinct sp.hMy),0) as NewLeads
from 
	Property p
	left join #Sales_Goals g on p.scode = g.Community_Code and g.Period = 'LM' and g.Measure = 40
	left join (
	select 
		ph.hProperty
		,sp.hMy
		,sp.slastname
		,sp.sfirstname
		,sp.dtFirstContact
        ,ph.dtDate

	from 
		SeniorProspect sp
		left join 
      (SELECT tbl.*
FROM SeniorProspectHistory tbl
  INNER JOIN
  (
    SELECT hProspect, MIN(hMy) hMy
    FROM SeniorProspectHistory
    group by hProspect
  ) tbl1
   ON tbl1.hmy = tbl.hmy

) ph 
      on sp.hMy = ph.hProspect

	where  
		ph.dtDate  between @lm_startdate and @lm_enddate
	        and sp.sStatus <> 'Referral'
	) sp on p.hMy = sp.hProperty


Group By
	p.hMy, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')', g.goal

	
	

/*
	Week Tours
*/

insert into #Sales_KPI_Findings
select 
	p.hMy
	, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')'   PropertyName
	, 'WK'
	, 50
	, 'Tours'
	, isnull(g.goal,0)
	, isnull(count(sp.hMY),0) 
from 
	Property p
	left join #Sales_Goals g on p.scode = g.Community_Code and g.Period = 'WK' and g.Measure = 50
	left join (
      			select
                    p.hMy
                    ,sp.hProperty
                    ,ph.dtCompleted
                    ,pa.ActivityCategory
                from 
                    SeniorProspect sp
                    left join SeniorProspectHistory ph on sp.hMy = ph.hProspect
                    left join SeniorProspectActivity pa on ph.ActivityID = pa.ActivityID
      		    left join Property p on p.hmy = ph.hproperty

                    where 
                    ph.dtCompleted between @wk_startdate and @wk_enddate
                    and pa.ActivityCategory = 'TOU'
		    and sp.sStatus <> 'Referral'
                  ) sp on p.hMy = sp.hMy


Group By
p.hMy, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')', g.goal
 



/*
	Month-to-Date Tours
*/

insert into #Sales_KPI_Findings
select 
	p.hMy
	, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')'   PropertyName
	, 'MTD'
	, 50
	, 'Tours'
	, isnull(g.goal,0)
	, isnull(count(sp.hMY),0) 
from 
	Property p
	left join #Sales_Goals g on p.scode = g.Community_Code and g.Period = 'MTD' and g.Measure = 50
	left join (
      			select
                    p.hMy
                    ,sp.hProperty
                    ,ph.dtCompleted
                    ,pa.ActivityCategory
                from 
                    SeniorProspect sp
                    left join SeniorProspectHistory ph on sp.hMy = ph.hProspect
                    left join SeniorProspectActivity pa on ph.ActivityID = pa.ActivityID
		    left join Property p on p.hmy = ph.hproperty

                    where 
                    ph.dtCompleted between @mtd_startdate and @mtd_enddate
                    and pa.ActivityCategory = 'TOU'
					and sp.sStatus <> 'Referral'      
                  ) sp on p.hMy = sp.hMy


Group By
p.hMy, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')', g.goal


/*
	Last Month Tours
*/

insert into #Sales_KPI_Findings
select 
	p.hMy
	, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')'   PropertyName
	, 'LM'
	, 50
	, 'Tours'
	, isnull(g.goal,0)
	, isnull(count(sp.hMY),0)
from 
	Property p
	left join #Sales_Goals g on p.scode = g.Community_Code and g.Period = 'LM' and g.Measure = 50
	left join (
      			select
                    p.hMy
                    ,sp.hProperty
                    ,ph.dtCompleted
                    ,pa.ActivityCategory
                from 
                    SeniorProspect sp
                    left join SeniorProspectHistory ph on sp.hMy = ph.hProspect
                    left join SeniorProspectActivity pa on ph.ActivityID = pa.ActivityID
		    left join Property p on p.hmy = ph.hproperty

                    where 
                    ph.dtCompleted between @lm_startdate and @lm_enddate
                    and pa.ActivityCategory = 'TOU'
					and sp.sStatus <> 'Referral'      
                  ) sp on p.hMy = sp.hMy


Group By
p.hMy, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')', g.goal

/*
	Week First Tours
*/

insert into #Sales_KPI_First_Tours
select 
	p.hMy
	, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')'   PropertyName
	, 'WK'
	, 50
	, 'First Tours'
	, isnull(g.goal,0)
	, isnull(count(sp.hMY),0) 
from 
	Property p
	left join #Sales_Goals g on p.scode = g.Community_Code and g.Period = 'WK' and g.Measure = 50
	left join (
      			select
                    p.hMy
                    ,sp.hProperty
                    ,ph.dtCompleted
                    ,pa.ActivityCategory
                from 
                    SeniorProspect sp
                    left join SeniorProspectHistory ph on sp.hMy = ph.hProspect
                    left join SeniorProspectActivity pa on ph.ActivityID = pa.ActivityID
      		    left join Property p on p.hmy = ph.hproperty

                    where 
                    ph.dtCompleted between @wk_startdate and @wk_enddate
                    and pa.ActivityCategory = 'TOU' and pa.ActivityID = 1
		    and sp.sStatus <> 'Referral'
                  ) sp on p.hMy = sp.hMy


Group By
p.hMy, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')', g.goal
 



/*
	Month-to-Date First Tours
*/

insert into #Sales_KPI_First_Tours
select 
	p.hMy
	, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')'   PropertyName
	, 'MTD'
	, 50
	, 'First Tours'
	, isnull(g.goal,0)
	, isnull(count(sp.hMY),0) 
from 
	Property p
	left join #Sales_Goals g on p.scode = g.Community_Code and g.Period = 'MTD' and g.Measure = 50
	left join (
      			select
                    p.hMy
                    ,sp.hProperty
                    ,ph.dtCompleted
                    ,pa.ActivityCategory
                from 
                    SeniorProspect sp
                    left join SeniorProspectHistory ph on sp.hMy = ph.hProspect
                    left join SeniorProspectActivity pa on ph.ActivityID = pa.ActivityID
		    left join Property p on p.hmy = ph.hproperty

                    where 
                    ph.dtCompleted between @mtd_startdate and @mtd_enddate
                    and pa.ActivityCategory = 'TOU' and pa.ActivityID = 1
					and sp.sStatus <> 'Referral'      
                  ) sp on p.hMy = sp.hMy


Group By
p.hMy, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')', g.goal


/*
	Last Month First Tours
*/

insert into #Sales_KPI_First_Tours
select 
	p.hMy
	, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')'   PropertyName
	, 'LM'
	, 50
	, 'First Tours'
	, isnull(g.goal,0)
	, isnull(count(sp.hMY),0)
from 
	Property p
	left join #Sales_Goals g on p.scode = g.Community_Code and g.Period = 'LM' and g.Measure = 50
	left join (
      			select
                    p.hMy
                    ,sp.hProperty
                    ,ph.dtCompleted
                    ,pa.ActivityCategory
                from 
                    SeniorProspect sp
                    left join SeniorProspectHistory ph on sp.hMy = ph.hProspect
                    left join SeniorProspectActivity pa on ph.ActivityID = pa.ActivityID
		    left join Property p on p.hmy = ph.hproperty

                    where 
                    ph.dtCompleted between @lm_startdate and @lm_enddate
                    and pa.ActivityCategory = 'TOU' and pa.ActivityID = 1
					and sp.sStatus <> 'Referral'      
                  ) sp on p.hMy = sp.hMy


Group By
p.hMy, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')', g.goal


/*
	Week Prospect Follow-Up Activity
*/

insert into #Sales_KPI_Findings
select 
	p.hMy
	, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')'   PropertyName
	, 'WK'
	, 30
	, 'Prospect Follow-Up Activity'
	, isnull(g.goal,0)
	, isnull(count(sp.hMY),0)
from 
	Property p
	left join #Sales_Goals g on p.scode = g.Community_Code and g.Period = 'WK' and g.Measure = 30
	left join (
      			select
                    p.hMy
                    ,sp.hProperty
                    ,ph.dtCompleted
		    ,ph.dtDate
                    ,pa.ActivityCategory
                from 
                    SeniorProspect sp
                    left join SeniorProspectHistory ph on sp.hMy = ph.hProspect
		    left join Property p on p.hmy = ph.hproperty
                    left join SeniorProspectActivity pa on ph.ActivityID = pa.ActivityID

                    where 
                    ph.dtCompleted between @wk_startdate and @wk_enddate
                    and pa.ActivityCategory not in ('NRF','RFF','STT')
					and sp.sStatus <> 'Referral'      
                  ) sp on p.hMy = sp.hMy


Group By
p.hMy, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')', g.goal




/*
	Month-to-Date Prospect Follow-Up Activity
*/


insert into #Sales_KPI_Findings
select 
	p.hMy
	, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')'   PropertyName
	, 'MTD'
	, 30
	, 'Prospect Follow-Up Activity'
	, isnull(g.goal,0)
	, isnull(count(sp.hMY),0) 
from 
	Property p
	left join #Sales_Goals g on p.scode = g.Community_Code and g.Period = 'MTD' and g.Measure = 30
	left join (
      			select
                    p.hMy
                    ,sp.hProperty
                    ,ph.dtCompleted
		    ,ph.dtDate
                    ,pa.ActivityCategory
                from 
                    SeniorProspect sp
                    left join SeniorProspectHistory ph on sp.hMy = ph.hProspect
                    left join SeniorProspectActivity pa on ph.ActivityID = pa.ActivityID
		    left join Property p on p.hmy = ph.hproperty

                    where 
                    ph.dtCompleted between @mtd_startdate and @mtd_enddate
                    and pa.ActivityCategory not in ('NRF','RFF','STT')
					and sp.sStatus <> 'Referral'      
                  ) sp on p.hMy = sp.hMy


Group By
p.hMy, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')', g.goal


/*
	Last Month Prospect Follow-Up Activity
*/


insert into #Sales_KPI_Findings
select 
	p.hMy
	, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')'   PropertyName
	, 'LM'
	, 30
	, 'Prospect Follow-Up Activity'
	, isnull(g.goal,0)
	, isnull(count(sp.hMY),0) 
from 
	Property p
	left join #Sales_Goals g on p.scode = g.Community_Code and g.Period = 'LM' and g.Measure = 30
	left join (
      			select
                    p.hMy
                    ,sp.hProperty
                    ,ph.dtCompleted
		    ,ph.dtDate
                    ,pa.ActivityCategory
                from 
                    SeniorProspect sp
                    left join SeniorProspectHistory ph on sp.hMy = ph.hProspect
                    left join SeniorProspectActivity pa on ph.ActivityID = pa.ActivityID
		    left join Property p on p.hmy = ph.hproperty

                    where 
                    ph.dtCompleted between @lm_startdate and @lm_enddate
                    and pa.ActivityCategory not in ('NRF','RFF','STT')
					and sp.sStatus <> 'Referral'      
                  ) sp on p.hMy = sp.hMy


Group By
p.hMy, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')', g.goal



/*
	Week Completed New Referral F to F Activity
*/

insert into #Sales_KPI_Findings
select 
	p.hMy
	, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')'   PropertyName
	, 'WK'
	, 10
	, 'Sales Calls - New Referrals'
	, isnull(g.goal,0)
	, isnull(count(sp.hMY),0) 
from 
	Property p
	left join #Sales_Goals g on p.scode = g.Community_Code and g.Period = 'WK' and g.Measure = 10
	left join (
 		select 
			p.hMy
			,sp.hProperty
			,Ltrim(Rtrim(sp.sfirstname)) + ' ' + Ltrim(Rtrim(sp.slastname))            ProspectName
			,pa.ActivityCategory
			,pa.ActivityName
			,ph.dtCompleted
		from 
			SeniorProspectHistory ph
			left join Property p on p.hmy = ph.hproperty
			left join SeniorProspectActivity pa on ph.ActivityID = pa.ActivityID
			left join SeniorProspect sp on sp.hMy = ph.hProspect

  
                where 
                ph.dtCompleted between @wk_startdate and @wk_enddate
                and pa.ActivityCategory in ('NRF')
				and sp.sStatus = 'Referral'      
                  ) sp on p.hMy = sp.hMy


Group By
p.hMy, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')', g.goal




/*
	Month-to-Date Completed New Referral F to F Activity
*/

insert into #Sales_KPI_Findings
select 
	p.hMy
	, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')'   PropertyName
	, 'MTD'
	, 10	 
	, 'Sales Calls - New Referrals'
	, isnull(g.goal,0)
	, isnull(count(sp.hMY),0) 
from 
	Property p
	left join #Sales_Goals g on p.scode = g.Community_Code and g.Period = 'MTD' and g.Measure = 10
	left join (
 		select 
			p.hMy
			,sp.hProperty
			,Ltrim(Rtrim(sp.sfirstname)) + ' ' + Ltrim(Rtrim(sp.slastname))            ProspectName
			,pa.ActivityCategory
			,pa.ActivityName
			,ph.dtCompleted
		from 
			SeniorProspectHistory ph
			left join Property p on p.hmy = ph.hproperty
			left join SeniorProspectActivity pa on ph.ActivityID = pa.ActivityID
			left join SeniorProspect sp on sp.hMy = ph.hProspect

  
                where 
                ph.dtCompleted between @mtd_startdate and @mtd_enddate
                and pa.ActivityCategory in ('NRF')
				and sp.sStatus = 'Referral'      
                  ) sp on p.hMy = sp.hMy


Group By
p.hMy, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')', g.goal


/*
	Last Month Completed New Referral F to F Activity
*/

insert into #Sales_KPI_Findings
select 
	p.hMy
	, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')'   PropertyName
	, 'LM'
	, 10	 
	, 'Sales Calls - New Referrals'
	, isnull(g.goal,0)
	, isnull(count(sp.hMY),0) 
from 
	Property p
	left join #Sales_Goals g on p.scode = g.Community_Code and g.Period = 'LM' and g.Measure = 10
	left join (
 		select 
			p.hMy
			,sp.hProperty
			,Ltrim(Rtrim(sp.sfirstname)) + ' ' + Ltrim(Rtrim(sp.slastname))            ProspectName
			,pa.ActivityCategory
			,pa.ActivityName
			,ph.dtCompleted
		from 
			SeniorProspectHistory ph
			left join Property p on p.hmy = ph.hproperty
			left join SeniorProspectActivity pa on ph.ActivityID = pa.ActivityID
			left join SeniorProspect sp on sp.hMy = ph.hProspect

  
                where 
                ph.dtCompleted between @lm_startdate and @lm_enddate
                and pa.ActivityCategory in ('NRF')
				and sp.sStatus = 'Referral'      
                  ) sp on p.hMy = sp.hMy


Group By
p.hMy, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')', g.goal





/*
	Week Completed Existing Referral F to F Activity
*/

insert into #Sales_KPI_Findings
select 
	p.hMy
	, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')'   PropertyName
	, 'WK'
	, 20
	, 'Sales Calls - Existing Referrals (in person only)'
	, isnull(g.goal,0)
	, isnull(count(sp.hMY),0) 
from 
	Property p
	left join #Sales_Goals g on p.scode = g.Community_Code and g.Period = 'WK' and g.Measure = 20
	left join (
 		select 
			p.hMy
			,sp.hProperty
			,Ltrim(Rtrim(sp.sfirstname)) + ' ' + Ltrim(Rtrim(sp.slastname))            ProspectName
			,pa.ActivityCategory
			,pa.ActivityName
			,ph.dtCompleted
		from 
			SeniorProspectHistory ph
			left join Property p on p.hmy = ph.hproperty
			left join SeniorProspectActivity pa on ph.ActivityID = pa.ActivityID
			left join SeniorProspect sp on sp.hMy = ph.hProspect

  
                where 
                ph.dtCompleted between @wk_startdate and @wk_enddate
                and pa.ActivityCategory in ('ERA')
				and sp.sStatus = 'Referral'      
                  ) sp on p.hMy = sp.hMy


Group By
p.hMy, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')', g.goal


/*
	Month-to-Date Completed Existing Referral F to F Activity
*/

insert into #Sales_KPI_Findings
select 
	p.hMy
	, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')'   PropertyName
	, 'MTD'
	, 20
	, 'Sales Calls - Existing Referrals (in person only)'
	, isnull(g.goal,0)
	, isnull(count(sp.hMY),0) 
from 
	Property p
	left join #Sales_Goals g on p.scode = g.Community_Code and g.Period = 'MTD' and g.Measure = 20
	left join (
 		select 
			p.hMy
			,sp.hProperty
			,Ltrim(Rtrim(sp.sfirstname)) + ' ' + Ltrim(Rtrim(sp.slastname))            ProspectName
			,pa.ActivityCategory
			,pa.ActivityName
			,ph.dtCompleted
		from 
			SeniorProspectHistory ph
			left join Property p on p.hmy = ph.hproperty
			left join SeniorProspectActivity pa on ph.ActivityID = pa.ActivityID
			left join SeniorProspect sp on sp.hMy = ph.hProspect

  
                where 
                ph.dtCompleted between @mtd_startdate and @mtd_enddate
                and pa.ActivityCategory in ('ERA')
				and sp.sStatus = 'Referral'      
                  ) sp on p.hMy = sp.hMy


Group By
p.hMy, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')', g.goal


/*
	Last Month Completed Existing Referral F to F Activity
*/

insert into #Sales_KPI_Findings
select 
	p.hMy
	, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')'   PropertyName
	, 'LM'
	, 20
	, 'Sales Calls - Existing Referrals (in person only)'
	, isnull(g.goal,0)
	, isnull(count(sp.hMY),0) 
from 
	Property p
	left join #Sales_Goals g on p.scode = g.Community_Code and g.Period = 'LM' and g.Measure = 20
	left join (
 		select 
			p.hMy
			,sp.hProperty
			,Ltrim(Rtrim(sp.sfirstname)) + ' ' + Ltrim(Rtrim(sp.slastname))            ProspectName
			,pa.ActivityCategory
			,pa.ActivityName
			,ph.dtCompleted
		from 
			SeniorProspectHistory ph
			left join Property p on p.hmy = ph.hproperty
			left join SeniorProspectActivity pa on ph.ActivityID = pa.ActivityID
			left join SeniorProspect sp on sp.hMy = ph.hProspect

  
                where 
                ph.dtCompleted between @lm_startdate and @lm_enddate
                and pa.ActivityCategory in ('ERA')
				and sp.sStatus = 'Referral'      
                  ) sp on p.hMy = sp.hMy


Group By
p.hMy, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')', g.goal


/*
	Weekly Deposits
*/

insert into #Sales_KPI_Findings
select 
	p.hMy
	, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')'   PropertyName
	, 'WK'
	, 60
	, 'Deposits'
	, isnull(g.goal,0)
	, isnull(count(distinct d.ProspectID),0)

from 
	Property p
	left join #Sales_Goals g on p.scode = g.Community_Code and g.Period = 'WK' and g.Measure = 60
	left join 	(
				select 
					sp.hProperty as hProp
					,s1.ProspectID
					,s1.ModDateTime
					,Max(s1.ModDateTime) as MaxDt
					from seniorprospectmodifications s1
					left join seniorprospectmodifications s2 on s1.ProspectID = s2.ProspectID 
						and (s2.ModDesc  like '%Prospect status changed from Future Resident to Prospect%' or s2.ModDesc  like '%Prospect status changed from Waitlisted to Prospect%')
						and s2.ModDateTime > s1.ModDateTime
					left join SeniorProspect sp on s1.ProspectID = sp.hMy
					where  (s1.ModDesc  like '%Prospect converted to a Future Resident%' or s1.ModDesc  like '%Prospect converted to a Waitlisted Resident%')
						and Cast(s1.ModDateTime as Date) between @wk_startdate and @wk_enddate
						and s1.ModType = 'Status Change' 	
						and s2.ModDateTime is null

					group by 
						sp.hProperty 
						,s1.ProspectID
						,s1.ModDateTime
			) d on d.hProp = p.hMy
		

	
Group By
	p.hMy, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')', g.goal

/*
	Month-to-Date Deposits
*/

insert into #Sales_KPI_Findings
select 
	p.hMy
	, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')'   PropertyName
	, 'MTD'
	, 60
	, 'Deposits'
	, isnull(g.goal,0)
	, isnull(count(distinct d.ProspectID),0)

from 
	Property p
	left join #Sales_Goals g on p.scode = g.Community_Code and g.Period = 'MTD' and g.Measure = 60
	left join 	(
				select 
					sp.hProperty as hProp
					,s1.ProspectID
					,s1.ModDateTime
					,Max(s1.ModDateTime) as MaxDt
					from seniorprospectmodifications s1
					left join seniorprospectmodifications s2 on s1.ProspectID = s2.ProspectID 
						and (s2.ModDesc  like '%Prospect status changed from Future Resident to Prospect%' or s2.ModDesc  like '%Prospect status changed from Waitlisted to Prospect%')
						and s2.ModDateTime > s1.ModDateTime
					left join SeniorProspect sp on s1.ProspectID = sp.hMy
					where  (s1.ModDesc  like '%Prospect converted to a Future Resident%' or s1.ModDesc  like '%Prospect converted to a Waitlisted Resident%')
						and Cast(s1.ModDateTime as Date) between @mtd_startdate and @mtd_enddate
						and s1.ModType = 'Status Change' 	
						and s2.ModDateTime is null

					group by 
						sp.hProperty 
						,s1.ProspectID
						,s1.ModDateTime
			) d on d.hProp = p.hMy
		
	
Group By
	p.hMy, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')', g.goal

/*
	Last Month Deposits
*/

insert into #Sales_KPI_Findings
select 
	p.hMy
	, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')'   PropertyName
	, 'LM'
	, 60
	, 'Deposits'
	, isnull(g.goal,0)
	, isnull(count(distinct d.ProspectID),0)

from 
	Property p
	left join #Sales_Goals g on p.scode = g.Community_Code and g.Period = 'LM' and g.Measure = 60
	left join 	(
				select 
					sp.hProperty as hProp
					,s1.ProspectID
					,s1.ModDateTime
					,Max(s1.ModDateTime) as MaxDt
					from seniorprospectmodifications s1
					left join seniorprospectmodifications s2 on s1.ProspectID = s2.ProspectID 
						and (s2.ModDesc  like '%Prospect status changed from Future Resident to Prospect%' or s2.ModDesc  like '%Prospect status changed from Waitlisted to Prospect%')						
						and s2.ModDateTime > s1.ModDateTime
					left join SeniorProspect sp on s1.ProspectID = sp.hMy
					where  (s1.ModDesc  like '%Prospect converted to a Future Resident%' or s1.ModDesc  like '%Prospect converted to a Waitlisted Resident%')
						and Cast(s1.ModDateTime as Date) between @lm_startdate and @lm_enddate
						and s1.ModType = 'Status Change' 	
						and s2.ModDateTime is null

					group by 
						sp.hProperty 
						,s1.ProspectID
						,s1.ModDateTime
			) d on d.hProp = p.hMy
		
Group By
	p.hMy, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')', g.goal





/*
	Weekly Move Ins
*/

insert into #Sales_KPI_Findings
select 
	p.hMy
	, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')'   PropertyName
	, 'WK'
	, 70
	, 'Move In'
	, isnull(g.goal,0)
	, isnull(count(distinct sp.hMy),0)

from 
	Property p
	left join #Sales_Goals g on p.scode = g.Community_Code and g.Period = 'WK' and g.Measure = 70
	left join SeniorProspect sp on p.hmy = sp.hProperty and sp.dtPrefMoveIn between @wk_startdate and @wk_enddate and sp.hContractType is not null /* and sp.hPrivacyLevel = 'PRI' */


	
Group By
	p.hMy, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')', g.goal

/*
	Month-to-Date Move Ins
*/

insert into #Sales_KPI_Findings
select 
	p.hMy
	, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')'   PropertyName
	, 'MTD'
	, 70
	, 'Move In'
	, isnull(g.goal,0)
	, isnull(count(distinct sp.hMy),0)

from 
	Property p
	left join #Sales_Goals g on p.scode = g.Community_Code and g.Period = 'MTD' and g.Measure = 70
	left join SeniorProspect sp on p.hmy = sp.hProperty and sp.dtPrefMoveIn between @mtd_startdate and @mtd_enddate and sp.hContractType is not null /* and sp.hPrivacyLevel = 'PRI' */


Group By
	p.hMy, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')', g.goal


/*
	Last Month Move Ins
*/

insert into #Sales_KPI_Findings
select 
	p.hMy
	, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')'   PropertyName
	, 'LM'
	, 70
	, 'Move In'
	, isnull(g.goal,0)
	, isnull(count(distinct sp.hMy),0)

from 
	Property p
	left join #Sales_Goals g on p.scode = g.Community_Code and g.Period = 'LM' and g.Measure = 70
	left join SeniorProspect sp on p.hmy = sp.hProperty and sp.dtPrefMoveIn between @lm_startdate and @lm_enddate and sp.hContractType is not null /* and sp.hPrivacyLevel = 'PRI' */


Group By
	p.hMy, Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')', g.goal




/*
	Insert Weekly Census Budget in to Goals Table
*/



insert into #Sales_Goals 
SELECT 
	p.scode
	, 'WK'
	, 80
	, abs(sum(t.sBudget))
	from Property p
	left join Total t on p.hmy = t.hppty
	Inner join acct a on a.hmy = t.hAcct

	WHERE 
		a.scode IN ( '001005', '001006', '001007' )
       		AND t.iBook = 1
		AND (CAST(MONTH(@wk_enddate) AS VARCHAR(2)) + '/' + CAST(YEAR(@wk_enddate) AS VARCHAR(4)))=(CAST(MONTH(t.uMonth) AS VARCHAR(2)) + '/' + CAST(YEAR(t.uMonth) AS VARCHAR(4)))

	Group By 
		p.scode	
	

/*
	Insert Month-to-Date Census Budget in to Goals Table
*/



insert into #Sales_Goals 
SELECT 
	p.scode
	, 'MTD'
	, 80
	, abs(sum(t.sBudget))
	from Property p
	left join Total t on p.hmy = t.hppty
	Inner join acct a on a.hmy = t.hAcct

	WHERE 
		a.scode IN ( '001005', '001006', '001007' )
       		AND t.iBook = 1
		AND (CAST(MONTH(@mtd_enddate) AS VARCHAR(2)) + '/' + CAST(YEAR(@mtd_enddate) AS VARCHAR(4)))=(CAST(MONTH(t.uMonth) AS VARCHAR(2)) + '/' + CAST(YEAR(t.uMonth) AS VARCHAR(4)))

	Group By 
		p.scode


/*
	Insert Last Month Census Budget in to Goals Table
*/



insert into #Sales_Goals 
SELECT 
	p.scode
	, 'LM'
	, 80
	, abs(sum(t.sBudget))
	from Property p
	left join Total t on p.hmy = t.hppty
	Inner join acct a on a.hmy = t.hAcct

	WHERE 
		a.scode IN ( '001005', '001006', '001007' )
       		AND t.iBook = 1
		AND (CAST(MONTH(@lm_enddate) AS VARCHAR(2)) + '/' + CAST(YEAR(@lm_enddate) AS VARCHAR(4)))=(CAST(MONTH(t.uMonth) AS VARCHAR(2)) + '/' + CAST(YEAR(t.uMonth) AS VARCHAR(4)))

	Group By 
		p.scode

/*
	Units
*/

/*

			SELECT COUNT(u.hmy) [Total Units]
			FROM Unit u
			WHERE u.hProperty = 21
				AND isnull(u.exclude, 0) = 0


*/

/*
	Weekly Census & Budget
*/


insert into #Sales_KPI_Findings
select 
	occ.PropertyID
	, occ.PropertyName
	, 'WK'
	, 80
	, 'Census to Budget'
	, b.Goal
	, round(abs(sum(occ.OccupancyCount)),0)



from
#Sales_Goals b
left join
( SELECT P.hmy PropertyID
	,p.scode
	,Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')'   PropertyName
	,sum(cast(lv.listoptionValue AS NUMERIC(10, 2))) OccupancyCount

from  property P 
INNER JOIN Tenant T ON T.Hproperty = P.hmy
INNER JOIN unit u ON u.hmy = t.hunit
	AND isnull(u.exclude, 0) = 0
INNER JOIN Serviceinstance Si ON (T.Hmyperson = Si.Residentid)
	AND si.carelevelcode IN (
		'AL'
		,'ALZ'
		,'PC','LL','BUN'
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

Where  
	 Si.Serviceinstanceid = (
		SELECT Max(Si3.Serviceinstanceid)
		FROM Serviceinstance Si3
		INNER JOIN Service S1 ON Si3.Serviceid = S1.Serviceid
			AND S1.Serviceclassid = 1
		WHERE Si3.Residentid = Si.Residentid
			AND Si3.Serviceinstanceactiveflag <> 0
			AND Isnull(CONVERT(DATETIME, CONVERT(VARCHAR(11), si3.ServiceInstanceTODate), 101), @wk_enddate) > = CONVERT(DATETIME, CONVERT(VARCHAR(11), si3.ServiceInstanceFromDate), 101)
			AND Si3.Serviceinstancefromdate = (
				SELECT Max(Si2.Serviceinstancefromdate)
				FROM Serviceinstance Si2
				INNER JOIN Service S ON Si2.Serviceid = S.Serviceid
					AND S.Serviceclassid = 1
				WHERE Si2.Residentid = Si.Residentid
					AND Si2.Serviceinstanceactiveflag <> 0
					AND Isnull(CONVERT(DATETIME, CONVERT(VARCHAR(11), si2.ServiceInstanceTODate), 101), @wk_enddate) > = CONVERT(DATETIME, CONVERT(VARCHAR(11), si2.ServiceInstanceFromDate), 101)
					AND CONVERT(DATETIME, CONVERT(VARCHAR(11), si2.ServiceInstanceFromDate), 101) <= @wk_enddate
					AND @wk_enddate <= Isnull(CONVERT(DATETIME, CONVERT(VARCHAR(11), si2.ServiceInstanceTODate), 101), @wk_enddate)
				)
		)

GROUP BY p.HMY
	,P.sCode
	,p.saddr1

UNION ALL

SELECT p.hmy propid
	,p.scode
	,Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')'   PropertyName
	,sum(cast(lv.listoptionValue AS NUMERIC(10, 2))) OccupancyCount

from Property p
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
Where  
	Si.Serviceinstanceid = (
		SELECT Max(Si3.Serviceinstanceid)
		FROM Serviceinstance Si3
		INNER JOIN Service S1 ON Si3.Serviceid = S1.Serviceid
			AND S1.Serviceclassid = 1
		WHERE Si3.Residentid = Si.Residentid
			AND Si3.Serviceinstanceactiveflag <> 0
			AND Isnull(Si3.Serviceinstancetodate, @wk_enddate) > = Si3.Serviceinstancefromdate
			AND Si3.Serviceinstancefromdate = (
				SELECT Max(Si2.Serviceinstancefromdate)
				FROM Serviceinstance Si2
				INNER JOIN Service S ON Si2.Serviceid = S.Serviceid
					AND S.Serviceclassid = 1
				WHERE Si2.Residentid = Si.Residentid
					AND Si2.Serviceinstanceactiveflag <> 0
					AND Isnull(Si2.Serviceinstancetodate, @wk_enddate) > = Si2.Serviceinstancefromdate
					AND Si2.Serviceinstancefromdate <= @wk_enddate
					AND @wk_enddate <= Isnull(Si2.Serviceinstancetodate, @wk_enddate)
				)
		)

GROUP BY p.HMY
	,P.sCode
	,p.saddr1 ) Occ on occ.sCode = b.Community_Code 



	WHERE 
		b.Period = 'WK' and b.Measure = 80
    
Group By
occ.PropertyID
,occ.sCode
,occ.PropertyName                 
,b.goal


/*
	Month-to-Date Census & Budget
*/


insert into #Sales_KPI_Findings
select 
	occ.PropertyID
	, occ.PropertyName
	, 'MTD'
	, 80
	, 'Census to Budget'
	, b.Goal
	, round(abs(sum(occ.OccupancyCount)),0)



from
#Sales_Goals b
left join
( SELECT P.hmy PropertyID
	,p.scode
	,Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')'   PropertyName
	,sum(cast(lv.listoptionValue AS NUMERIC(10, 2))) OccupancyCount

from  property P 
INNER JOIN Tenant T ON T.Hproperty = P.hmy
INNER JOIN unit u ON u.hmy = t.hunit
	AND isnull(u.exclude, 0) = 0
INNER JOIN Serviceinstance Si ON (T.Hmyperson = Si.Residentid)
	AND si.carelevelcode IN (
		'AL'
		,'ALZ'
		,'PC','LL','BUN'
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

Where  
	 Si.Serviceinstanceid = (
		SELECT Max(Si3.Serviceinstanceid)
		FROM Serviceinstance Si3
		INNER JOIN Service S1 ON Si3.Serviceid = S1.Serviceid
			AND S1.Serviceclassid = 1
		WHERE Si3.Residentid = Si.Residentid
			AND Si3.Serviceinstanceactiveflag <> 0
			AND Isnull(CONVERT(DATETIME, CONVERT(VARCHAR(11), si3.ServiceInstanceTODate), 101), @mtd_enddate) > = CONVERT(DATETIME, CONVERT(VARCHAR(11), si3.ServiceInstanceFromDate), 101)
			AND Si3.Serviceinstancefromdate = (
				SELECT Max(Si2.Serviceinstancefromdate)
				FROM Serviceinstance Si2
				INNER JOIN Service S ON Si2.Serviceid = S.Serviceid
					AND S.Serviceclassid = 1
				WHERE Si2.Residentid = Si.Residentid
					AND Si2.Serviceinstanceactiveflag <> 0
					AND Isnull(CONVERT(DATETIME, CONVERT(VARCHAR(11), si2.ServiceInstanceTODate), 101), @mtd_enddate) > = CONVERT(DATETIME, CONVERT(VARCHAR(11), si2.ServiceInstanceFromDate), 101)
					AND CONVERT(DATETIME, CONVERT(VARCHAR(11), si2.ServiceInstanceFromDate), 101) <= @mtd_enddate
					AND @mtd_enddate <= Isnull(CONVERT(DATETIME, CONVERT(VARCHAR(11), si2.ServiceInstanceTODate), 101), @mtd_enddate)
				)
		)

GROUP BY p.HMY
	,P.sCode
	,p.saddr1

UNION ALL

SELECT p.hmy propid
	,p.scode
	,Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')'   PropertyName
	,sum(cast(lv.listoptionValue AS NUMERIC(10, 2))) OccupancyCount

from Property p
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
Where  
	Si.Serviceinstanceid = (
		SELECT Max(Si3.Serviceinstanceid)
		FROM Serviceinstance Si3
		INNER JOIN Service S1 ON Si3.Serviceid = S1.Serviceid
			AND S1.Serviceclassid = 1
		WHERE Si3.Residentid = Si.Residentid
			AND Si3.Serviceinstanceactiveflag <> 0
			AND Isnull(Si3.Serviceinstancetodate, @mtd_enddate) > = Si3.Serviceinstancefromdate
			AND Si3.Serviceinstancefromdate = (
				SELECT Max(Si2.Serviceinstancefromdate)
				FROM Serviceinstance Si2
				INNER JOIN Service S ON Si2.Serviceid = S.Serviceid
					AND S.Serviceclassid = 1
				WHERE Si2.Residentid = Si.Residentid
					AND Si2.Serviceinstanceactiveflag <> 0
					AND Isnull(Si2.Serviceinstancetodate, @mtd_enddate) > = Si2.Serviceinstancefromdate
					AND Si2.Serviceinstancefromdate <= @mtd_enddate
					AND @mtd_enddate <= Isnull(Si2.Serviceinstancetodate, @mtd_enddate)
				)
		)

GROUP BY p.HMY
	,P.sCode
	,p.saddr1 ) Occ on occ.sCode = b.Community_Code 



	WHERE 
		b.Period = 'MTD' and b.Measure = 80
    
Group By
occ.PropertyID
,occ.sCode
,occ.PropertyName                 
,b.goal


/*
	Last Month Census & Budget
*/


insert into #Sales_KPI_Findings
select 
	occ.PropertyID
	, occ.PropertyName
	, 'LM'
	, 80
	, 'Census to Budget'
	, b.Goal
	, round(abs(sum(occ.OccupancyCount)),0)



from
#Sales_Goals b
left join
( SELECT P.hmy PropertyID
	,p.scode
	,Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')'   PropertyName
	,sum(cast(lv.listoptionValue AS NUMERIC(10, 2))) OccupancyCount

from  property P 
INNER JOIN Tenant T ON T.Hproperty = P.hmy
INNER JOIN unit u ON u.hmy = t.hunit
	AND isnull(u.exclude, 0) = 0
INNER JOIN Serviceinstance Si ON (T.Hmyperson = Si.Residentid)
	AND si.carelevelcode IN (
		'AL'
		,'ALZ'
		,'PC','LL','BUN'
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

Where  
	Si.Serviceinstanceid = (
		SELECT Max(Si3.Serviceinstanceid)
		FROM Serviceinstance Si3
		INNER JOIN Service S1 ON Si3.Serviceid = S1.Serviceid
			AND S1.Serviceclassid = 1
		WHERE Si3.Residentid = Si.Residentid
			AND Si3.Serviceinstanceactiveflag <> 0
			AND Isnull(CONVERT(DATETIME, CONVERT(VARCHAR(11), si3.ServiceInstanceTODate), 101), @lm_enddate) > = CONVERT(DATETIME, CONVERT(VARCHAR(11), si3.ServiceInstanceFromDate), 101)
			AND Si3.Serviceinstancefromdate = (
				SELECT Max(Si2.Serviceinstancefromdate)
				FROM Serviceinstance Si2
				INNER JOIN Service S ON Si2.Serviceid = S.Serviceid
					AND S.Serviceclassid = 1
				WHERE Si2.Residentid = Si.Residentid
					AND Si2.Serviceinstanceactiveflag <> 0
					AND Isnull(CONVERT(DATETIME, CONVERT(VARCHAR(11), si2.ServiceInstanceTODate), 101), @lm_enddate) > = CONVERT(DATETIME, CONVERT(VARCHAR(11), si2.ServiceInstanceFromDate), 101)
					AND CONVERT(DATETIME, CONVERT(VARCHAR(11), si2.ServiceInstanceFromDate), 101) <= @lm_enddate
					AND @lm_enddate <= Isnull(CONVERT(DATETIME, CONVERT(VARCHAR(11), si2.ServiceInstanceTODate), 101), @lm_enddate)
				)
		)

GROUP BY p.HMY
	,P.sCode
	,p.saddr1

UNION ALL

SELECT p.hmy propid
	,p.scode
	,Ltrim(Rtrim(p.saddr1)) + ' (' + Ltrim(Rtrim(p.scode)) + ')'   PropertyName
	,sum(cast(lv.listoptionValue AS NUMERIC(10, 2))) OccupancyCount

from Property p
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
Where  
	Si.Serviceinstanceid = (
		SELECT Max(Si3.Serviceinstanceid)
		FROM Serviceinstance Si3
		INNER JOIN Service S1 ON Si3.Serviceid = S1.Serviceid
			AND S1.Serviceclassid = 1
		WHERE Si3.Residentid = Si.Residentid
			AND Si3.Serviceinstanceactiveflag <> 0
			AND Isnull(Si3.Serviceinstancetodate, @lm_enddate) > = Si3.Serviceinstancefromdate
			AND Si3.Serviceinstancefromdate = (
				SELECT Max(Si2.Serviceinstancefromdate)
				FROM Serviceinstance Si2
				INNER JOIN Service S ON Si2.Serviceid = S.Serviceid
					AND S.Serviceclassid = 1
				WHERE Si2.Residentid = Si.Residentid
					AND Si2.Serviceinstanceactiveflag <> 0
					AND Isnull(Si2.Serviceinstancetodate, @lm_enddate) > = Si2.Serviceinstancefromdate
					AND Si2.Serviceinstancefromdate <= @lm_enddate
					AND @lm_enddate <= Isnull(Si2.Serviceinstancetodate, @lm_enddate)
				)
		)

GROUP BY p.HMY
	,P.sCode
	,p.saddr1 ) Occ on occ.sCode = b.Community_Code 



	WHERE 
		b.Period = 'LM' and b.Measure = 80
    
Group By
occ.PropertyID
,occ.sCode
,occ.PropertyName                 
,b.goal


/*

	Final Select and Cleanup

*/

/* insert into #Sales_KPI
select 
     kpi.hprop
	,ltrim(rtrim(kpi.Community)) as Community
        ,case 
		when kpi.Community like '%Lantern%' then replace(kpi.Community,'The Lantern at Morning Pointe of ','') + ' ' +'Lantern'
		else replace(kpi.Community,'Morning Pointe of ','') 
	end as Community_Abbr
	,case when isnull(ltrim(rtrim(a.SubGroup2)),'') = '' then '???' else  ltrim(rtrim(a.SubGroup2)) end as Region
	,' ' as CRD
	,' ' as RDSM
	,' ' as Report_Index
	,' ' as Report_Index_Desc
    ,kpi.Period
    ,kpi.Measure
	,kpi.Measure_Desc
	,isnull(kpi.Goal,0) as Goal
        ,isnull(kpi.Count,0) as Count
	,case
		when isnull(kpi.Goal,0) = 0 then 0
		when isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0) > 1.25000 then 1.25000
		else isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal*1.00000,0) 
	end as Percentage

	,case
		when isnull(kpi.Goal,0) = 0 then 0

		when kpi.Period in ('WK','MTD') and kpi.Measure =10 and (isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)) > 1.25000 then .1 * 1.25000 
		when kpi.Period in ('WK','MTD') and kpi.Measure =20 and (isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)) > 1.25000 then .4 * 1.25000 
		when kpi.Period in ('WK','MTD') and kpi.Measure =30 and (isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)) > 1.25000 then .25 * 1.25000 
		when kpi.Period in ('WK','MTD') and kpi.Measure =40 and (isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)) > 1.25000 then .1 * 1.25000 
		when kpi.Period in ('WK','MTD') and kpi.Measure =50 and (isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)) > 1.25000 then .15 * 1.25000 
		when kpi.Period in ('WK','MTD') and kpi.Measure =60 and (isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)) > 1.25000 then .1 * 1.25000 
		when kpi.Period in ('WK','MTD') and kpi.Measure =70 and (isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)) > 1.25000 then .4 * 1.25000 
		when kpi.Period in ('WK','MTD') and kpi.Measure =80 and (isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)) > 1.25000 then .5 * 1.25000 		

		when kpi.Period in ('WK','MTD') and kpi.Measure =10 then round((isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)),2) * .1 
		when kpi.Period in ('WK','MTD') and kpi.Measure =20 then round((isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)),2) * .4 
		when kpi.Period in ('WK','MTD') and kpi.Measure =30 then round((isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)),2) * .25 
		when kpi.Period in ('WK','MTD') and kpi.Measure =40 then round((isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)),2) * .1 
		when kpi.Period in ('WK','MTD') and kpi.Measure =50 then round((isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)),2) * .15 
		when kpi.Period in ('WK','MTD') and kpi.Measure =60 then round((isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)),2) * .1  
		when kpi.Period in ('WK','MTD') and kpi.Measure =70 then round((isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)),2) * .4  
		when kpi.Period in ('WK','MTD') and kpi.Measure =80 then round((isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)),2) * .5  
		
		when kpi.Period = 'LM' and kpi.Measure =10 and (isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)) > 1.25000 then .1 * 1.25000 
		when kpi.Period = 'LM' and kpi.Measure =20 and (isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)) > 1.25000 then .4 * 1.25000 
		when kpi.Period = 'LM' and kpi.Measure =30 and (isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)) > 1.25000 then .25 * 1.25000 
		when kpi.Period = 'LM' and kpi.Measure =40 and (isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)) > 1.25000 then .1 * 1.25000 
		when kpi.Period = 'LM' and kpi.Measure =50 and (isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)) > 1.25000 then .15 * 1.25000 
		when kpi.Period = 'LM' and kpi.Measure =60 and (isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)) > 1.25000 then .1 * 1.25000 
		when kpi.Period = 'LM' and kpi.Measure =70 and (isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)) > 1.25000 then .4 * 1.25000 
		when kpi.Period = 'LM' and kpi.Measure =80 and (isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)) > 1.25000 then .5 * 1.25000 		

		when kpi.Period = 'LM' and kpi.Measure =10 then round((isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)),2) * .1 
		when kpi.Period = 'LM' and kpi.Measure =20 then round((isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)),2) * .4 
		when kpi.Period = 'LM' and kpi.Measure =30 then round((isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)),2) * .25 
		when kpi.Period = 'LM' and kpi.Measure =40 then round((isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)),2) * .1 
		when kpi.Period = 'LM' and kpi.Measure =50 then round((isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)),2) * .15 
		when kpi.Period = 'LM' and kpi.Measure =60 then round((isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)),2) * .1  
		when kpi.Period = 'LM' and kpi.Measure =70 then round((isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)),2) * .4  
		when kpi.Period = 'LM' and kpi.Measure =80 then round((isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)),2) * .5  		

	end as Score 
	,@wk_startdate as wk_startdate
	,@wk_enddate as wk_enddate
	,@mtd_startdate as mtd_startdate
	,@mtd_enddate as mtd_enddate
	,@lm_startdate as lm_startdate
	,@lm_enddate as lm_enddate

from #Sales_KPI_Findings kpi
left join Attributes a on a.hprop = kpi.hprop
order by 
case 
   when kpi.Community like '%Lantern%' then replace(kpi.Community,'The Lantern at Morning Pointe of','') + ' ' +'Lantern'
   else replace(kpi.Community,'Morning Pointe of','') 
end
, kpi.Period desc
, kpi.Measure
*/


/*

	Combine Counts for Communities with single sales person on 2 person campus

*/

select * into #Count_Backup from #Sales_KPI_Findings where hprop in (11,76,63,65,12,61,4,5,79,80,31,32,26,27,13,52,24,29)


update #Sales_KPI_Findings
set count = case 
	/* Lenoir City and Lenoir City Lantern */
	when hprop in (31,32) and measure = 10 and period = 'LM' then (select sum(count) from #Count_Backup where hprop in (31,32) and measure = 10 and period = 'LM')
	when hprop in (31,32) and measure = 20 and period = 'LM' then (select sum(count) from #Count_Backup where hprop in (31,32) and measure = 20 and period = 'LM')
	when hprop in (31,32) and measure = 10 and period = 'MTD' then (select sum(count) from #Count_Backup where hprop in (31,32) and measure = 10 and period = 'MTD')
	when hprop in (31,32) and measure = 20 and period = 'MTD' then (select sum(count) from #Count_Backup where hprop in (31,32) and measure = 20 and period = 'MTD')
	when hprop in (31,32) and measure = 10 and period = 'WK' then (select sum(count) from #Count_Backup where hprop in (31,32) and measure = 10 and period = 'WK')
	when hprop in (31,32) and measure = 20 and period = 'WK' then (select sum(count) from #Count_Backup where hprop in (31,32) and measure = 20 and period = 'WK')	

	/* Frankfort and Frankfort Lantern */
	when hprop in (26,27) and measure = 10 and period = 'LM' then (select sum(count) from #Count_Backup where hprop in (26,27) and measure = 10 and period = 'LM')
	when hprop in (26,27) and measure = 20 and period = 'LM' then (select sum(count) from #Count_Backup where hprop in (26,27) and measure = 20 and period = 'LM')
	when hprop in (26,27) and measure = 10 and period = 'MTD' then (select sum(count) from #Count_Backup where hprop in (26,27) and measure = 10 and period = 'MTD')
	when hprop in (26,27) and measure = 20 and period = 'MTD' then (select sum(count) from #Count_Backup where hprop in (26,27) and measure = 20 and period = 'MTD')
	when hprop in (26,27) and measure = 10 and period = 'WK' then (select sum(count) from #Count_Backup where hprop in (26,27) and measure = 10 and period = 'WK')
	when hprop in (26,27) and measure = 20 and period = 'WK' then (select sum(count) from #Count_Backup where hprop in (26,27) and measure = 20 and period = 'WK')	

	/* Russell and Russell Lantern  */
	when hprop in (13,52) and measure = 10 and period = 'LM' then (select sum(count) from #Count_Backup where hprop in (13,52) and measure = 10 and period = 'LM')
	when hprop in (13,52) and measure = 20 and period = 'LM' then (select sum(count) from #Count_Backup where hprop in (13,52) and measure = 20 and period = 'LM')
	when hprop in (13,52) and measure = 10 and period = 'MTD' then (select sum(count) from #Count_Backup where hprop in (13,52) and measure = 10 and period = 'MTD')
	when hprop in (13,52) and measure = 20 and period = 'MTD' then (select sum(count) from #Count_Backup where hprop in (13,52) and measure = 20 and period = 'MTD')
	when hprop in (13,52) and measure = 10 and period = 'WK' then (select sum(count) from #Count_Backup where hprop in (13,52) and measure = 10 and period = 'WK')
	when hprop in (13,52) and measure = 20 and period = 'WK' then (select sum(count) from #Count_Backup where hprop in (13,52) and measure = 20 and period = 'WK')	

	/* Chattanooga Lantern and Collegedale Lantern  */
	/* 03-04-2020 - Un-Combined */
/*
	when hprop in (1,24) and measure = 10 and period = 'LM' then (select sum(count) from #Count_Backup where hprop in (1,24) and measure = 10 and period = 'LM')
	when hprop in (1,24) and measure = 20 and period = 'LM' then (select sum(count) from #Count_Backup where hprop in (1,24) and measure = 20 and period = 'LM')
	when hprop in (1,24) and measure = 10 and period = 'MTD' then (select sum(count) from #Count_Backup where hprop in (1,24) and measure = 10 and period = 'MTD')
	when hprop in (1,24) and measure = 20 and period = 'MTD' then (select sum(count) from #Count_Backup where hprop in (1,24) and measure = 20 and period = 'MTD')
	when hprop in (1,24) and measure = 10 and period = 'WK' then (select sum(count) from #Count_Backup where hprop in (1,24) and measure = 10 and period = 'WK')
	when hprop in (1,24) and measure = 20 and period = 'WK' then (select sum(count) from #Count_Backup where hprop in (1,24) and measure = 20 and period = 'WK')	
*/



	/* Greenbriar Cove and Collegedale Lantern  */
	/* 03-04-2020 - Combined */
	when hprop in (24,29) and measure = 10 and period = 'LM' then (select sum(count) from #Count_Backup where hprop in (24,29) and measure = 10 and period = 'LM')
	when hprop in (24,29) and measure = 20 and period = 'LM' then (select sum(count) from #Count_Backup where hprop in (24,29) and measure = 20 and period = 'LM')
	when hprop in (24,29) and measure = 10 and period = 'MTD' then (select sum(count) from #Count_Backup where hprop in (24,29) and measure = 10 and period = 'MTD')
	when hprop in (24,29) and measure = 20 and period = 'MTD' then (select sum(count) from #Count_Backup where hprop in (24,29) and measure = 20 and period = 'MTD')
	when hprop in (24,29) and measure = 10 and period = 'WK' then (select sum(count) from #Count_Backup where hprop in (24,29) and measure = 10 and period = 'WK')
	when hprop in (24,29) and measure = 20 and period = 'WK' then (select sum(count) from #Count_Backup where hprop in (24,29) and measure = 20 and period = 'WK')	

	/* Knoxville and Knoxville Lantern */
	/* 07-31-2020 - Combined */
	when hprop in (79,80) and measure = 10 and period = 'LM' then (select sum(count) from #Count_Backup where hprop in (79,80) and measure = 10 and period = 'LM')
	when hprop in (79,80) and measure = 20 and period = 'LM' then (select sum(count) from #Count_Backup where hprop in (79,80) and measure = 20 and period = 'LM')
	when hprop in (79,80) and measure = 10 and period = 'MTD' then (select sum(count) from #Count_Backup where hprop in (79,80) and measure = 10 and period = 'MTD')
	when hprop in (79,80) and measure = 20 and period = 'MTD' then (select sum(count) from #Count_Backup where hprop in (79,80) and measure = 20 and period = 'MTD')
	when hprop in (79,80) and measure = 10 and period = 'WK' then (select sum(count) from #Count_Backup where hprop in (79,80) and measure = 10 and period = 'WK')
	when hprop in (79,80) and measure = 20 and period = 'WK' then (select sum(count) from #Count_Backup where hprop in (79,80) and measure = 20 and period = 'WK')	

	/* Lexington and Lexington Lantern */
	/* 07-31-2020 - Combined */
	when hprop in (4,5) and measure = 10 and period = 'LM' then (select sum(count) from #Count_Backup where hprop in (4,5) and measure = 10 and period = 'LM')
	when hprop in (4,5) and measure = 20 and period = 'LM' then (select sum(count) from #Count_Backup where hprop in (4,5) and measure = 20 and period = 'LM')
	when hprop in (4,5) and measure = 10 and period = 'MTD' then (select sum(count) from #Count_Backup where hprop in (4,5) and measure = 10 and period = 'MTD')
	when hprop in (4,5) and measure = 20 and period = 'MTD' then (select sum(count) from #Count_Backup where hprop in (4,5) and measure = 20 and period = 'MTD')
	when hprop in (4,5) and measure = 10 and period = 'WK' then (select sum(count) from #Count_Backup where hprop in (4,5) and measure = 10 and period = 'WK')
	when hprop in (4,5) and measure = 20 and period = 'WK' then (select sum(count) from #Count_Backup where hprop in (4,5) and measure = 20 and period = 'WK')	

	/* Louisville and Louisville Lantern */
	/* 07-31-2020 - Combined */
	when hprop in (12,61) and measure = 10 and period = 'LM' then (select sum(count) from #Count_Backup where hprop in (12,61) and measure = 10 and period = 'LM')
	when hprop in (12,61) and measure = 20 and period = 'LM' then (select sum(count) from #Count_Backup where hprop in (12,61) and measure = 20 and period = 'LM')
	when hprop in (12,61) and measure = 10 and period = 'MTD' then (select sum(count) from #Count_Backup where hprop in (12,61) and measure = 10 and period = 'MTD')
	when hprop in (12,61) and measure = 20 and period = 'MTD' then (select sum(count) from #Count_Backup where hprop in (12,61) and measure = 20 and period = 'MTD')
	when hprop in (12,61) and measure = 10 and period = 'WK' then (select sum(count) from #Count_Backup where hprop in (12,61) and measure = 10 and period = 'WK')
	when hprop in (12,61) and measure = 20 and period = 'WK' then (select sum(count) from #Count_Backup where hprop in (12,61) and measure = 20 and period = 'WK')	

	/* Spring Hill and Spring Hill Lantern */
	/* 07-31-2020 - Combined */
	when hprop in (63,65) and measure = 10 and period = 'LM' then (select sum(count) from #Count_Backup where hprop in (63,65) and measure = 10 and period = 'LM')
	when hprop in (63,65) and measure = 20 and period = 'LM' then (select sum(count) from #Count_Backup where hprop in (63,65) and measure = 20 and period = 'LM')
	when hprop in (63,65) and measure = 10 and period = 'MTD' then (select sum(count) from #Count_Backup where hprop in (63,65) and measure = 10 and period = 'MTD')
	when hprop in (63,65) and measure = 20 and period = 'MTD' then (select sum(count) from #Count_Backup where hprop in (63,65) and measure = 20 and period = 'MTD')
	when hprop in (63,65) and measure = 10 and period = 'WK' then (select sum(count) from #Count_Backup where hprop in (63,65) and measure = 10 and period = 'WK')
	when hprop in (63,65) and measure = 20 and period = 'WK' then (select sum(count) from #Count_Backup where hprop in (63,65) and measure = 20 and period = 'WK')


	/* Franklin TN  and Franklin TN Lantern   */
	/* 07-31-2020 - Combined */
	when hprop in (11,76) and measure = 10 and period = 'LM' then (select sum(count) from #Count_Backup where hprop in (11,76) and measure = 10 and period = 'LM')
	when hprop in (11,76) and measure = 20 and period = 'LM' then (select sum(count) from #Count_Backup where hprop in (11,76) and measure = 20 and period = 'LM')
	when hprop in (11,76) and measure = 10 and period = 'MTD' then (select sum(count) from #Count_Backup where hprop in (11,76) and measure = 10 and period = 'MTD')
	when hprop in (11,76) and measure = 20 and period = 'MTD' then (select sum(count) from #Count_Backup where hprop in (11,76) and measure = 20 and period = 'MTD')
	when hprop in (11,76) and measure = 10 and period = 'WK' then (select sum(count) from #Count_Backup where hprop in (11,76) and measure = 10 and period = 'WK')
	when hprop in (11,76) and measure = 20 and period = 'WK' then (select sum(count) from #Count_Backup where hprop in (11,76) and measure = 20 and period = 'WK')


	else Count
end


/*

	Calculate All Reporting Scores and Percentages

*/
select 
     kpi.hprop
	,ltrim(rtrim(kpi.Community)) as Community
        ,case 
		when kpi.Community like '%Lantern%' then replace(kpi.Community,'The Lantern at Morning Pointe of ','') + ' ' +'Lantern'
		else replace(kpi.Community,'Morning Pointe of','') 
	end as Community_Abbr
	,case when isnull(ltrim(rtrim(a.SubGroup2)),'') = '' then '???' else  ltrim(rtrim(a.SubGroup2)) end as Region
 	,' ' as CRD
	,' ' as RDSM

/*	,' ' as Report_Index
	,' ' as Report_Index_Desc
*/
	
	,kpi.Period
    ,kpi.Measure
	,kpi.Measure_Desc
	,isnull(kpi.Goal,0) as Goal
        ,isnull(kpi.Count,0) as Count
	,case
		when isnull(kpi.Goal,0) = 0 then 0
		when isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0) > 1.25000 then 1.25000
		else isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal*1.00000,0) 
	end as Percentage

	,case
		when isnull(kpi.Goal,0) = 0 then 0

		when kpi.Period in ('WK','MTD') and kpi.Measure =10 and (isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)) > 1.25000 then .1 * 1.25000 
		when kpi.Period in ('WK','MTD') and kpi.Measure =20 and (isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)) > 1.25000 then .4 * 1.25000 
		when kpi.Period in ('WK','MTD') and kpi.Measure =30 and (isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)) > 1.25000 then .25 * 1.25000 
		when kpi.Period in ('WK','MTD') and kpi.Measure =40 and (isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)) > 1.25000 then .1 * 1.25000 
		when kpi.Period in ('WK','MTD') and kpi.Measure =50 and (isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)) > 1.25000 then .15 * 1.25000 
		when kpi.Period in ('WK','MTD') and kpi.Measure =60 and (isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)) > 1.25000 then .1 * 1.25000 
		when kpi.Period in ('WK','MTD') and kpi.Measure =70 and (isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)) > 1.25000 then .4 * 1.25000 
		when kpi.Period in ('WK','MTD') and kpi.Measure =80 and (isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)) > 1.25000 then .5 * 1.25000 		

		when kpi.Period in ('WK','MTD') and kpi.Measure =10 then round((isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)),2) * .1 
		when kpi.Period in ('WK','MTD') and kpi.Measure =20 then round((isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)),2) * .4 
		when kpi.Period in ('WK','MTD') and kpi.Measure =30 then round((isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)),2) * .25 
		when kpi.Period in ('WK','MTD') and kpi.Measure =40 then round((isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)),2) * .1 
		when kpi.Period in ('WK','MTD') and kpi.Measure =50 then round((isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)),2) * .15 
		when kpi.Period in ('WK','MTD') and kpi.Measure =60 then round((isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)),2) * .1  
		when kpi.Period in ('WK','MTD') and kpi.Measure =70 then round((isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)),2) * .4  
		when kpi.Period in ('WK','MTD') and kpi.Measure =80 then round((isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)),2) * .5  
		
		when kpi.Period = 'LM' and kpi.Measure =10 and (isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)) > 1.25000 then .1 * 1.25000 
		when kpi.Period = 'LM' and kpi.Measure =20 and (isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)) > 1.25000 then .4 * 1.25000 
		when kpi.Period = 'LM' and kpi.Measure =30 and (isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)) > 1.25000 then .25 * 1.25000 
		when kpi.Period = 'LM' and kpi.Measure =40 and (isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)) > 1.25000 then .1 * 1.25000 
		when kpi.Period = 'LM' and kpi.Measure =50 and (isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)) > 1.25000 then .15 * 1.25000 
		when kpi.Period = 'LM' and kpi.Measure =60 and (isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)) > 1.25000 then .1 * 1.25000 
		when kpi.Period = 'LM' and kpi.Measure =70 and (isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)) > 1.25000 then .4 * 1.25000 
		when kpi.Period = 'LM' and kpi.Measure =80 and (isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)) > 1.25000 then .5 * 1.25000 		

		when kpi.Period = 'LM' and kpi.Measure =10 then round((isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)),2) * .1 
		when kpi.Period = 'LM' and kpi.Measure =20 then round((isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)),2) * .4 
		when kpi.Period = 'LM' and kpi.Measure =30 then round((isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)),2) * .25 
		when kpi.Period = 'LM' and kpi.Measure =40 then round((isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)),2) * .1 
		when kpi.Period = 'LM' and kpi.Measure =50 then round((isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)),2) * .15 
		when kpi.Period = 'LM' and kpi.Measure =60 then round((isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)),2) * .1  
		when kpi.Period = 'LM' and kpi.Measure =70 then round((isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)),2) * .4  
		when kpi.Period = 'LM' and kpi.Measure =80 then round((isnull(kpi.Count* 1.00000,0) / isnull(kpi.Goal* 1.00000,0)),2) * .5  		

	end as Score 


into #Sales_KPI_Findings_Calculations
from #Sales_KPI_Findings kpi
left join Attributes a on a.hprop = kpi.hprop


/*
	Prepare Report Index C001 - Community Weekly Activities
*/


insert into #Sales_KPI
select
    kpi.hprop
	,kpi.Community as Community
    ,kpi.Community_Abbr as Community_Abbr
	,kpi.Region as Region
	,kpi.CRD as CRD
	,kpi.RDSM as RDSM
	,'C001' as Report_Index
	,'Community Weekly Activities' as Report_Index_Desc
    ,kpi.Period
    ,kpi.Measure
	,kpi.Measure_Desc
	,kpi.Goal as Goal
    ,kpi.Count as Count
	,kpi.Percentage as Percentage
	,kpi.Score as Score 
	,@wk_startdate as wk_startdate
	,@wk_enddate as wk_enddate
	,@mtd_startdate as mtd_startdate
	,@mtd_enddate as mtd_enddate
	,@lm_startdate as lm_startdate
	,@lm_enddate as lm_enddate
from #Sales_KPI_Findings_Calculations kpi
where Period = 'WK' and Measure < 60

/*
	Prepare Report Index C002 - Community Month-to-Date Activities
*/


insert into #Sales_KPI
select
    kpi.hprop
	,kpi.Community as Community
    ,kpi.Community_Abbr as Community_Abbr
	,kpi.Region as Region
	,kpi.CRD as CRD
	,kpi.RDSM as RDSM
	,'C002' as Report_Index
	,'Community Month-to-Date Activities' as Report_Index_Desc
    ,kpi.Period
    ,kpi.Measure
	,kpi.Measure_Desc
	,kpi.Goal as Goal
    ,kpi.Count as Count
	,kpi.Percentage as Percentage
	,kpi.Score as Score 
	,@wk_startdate as wk_startdate
	,@wk_enddate as wk_enddate
	,@mtd_startdate as mtd_startdate
	,@mtd_enddate as mtd_enddate
	,@lm_startdate as lm_startdate
	,@lm_enddate as lm_enddate
from #Sales_KPI_Findings_Calculations kpi 
where Period = 'MTD' and Measure < 60

/*
	Prepare Report Index C003 - Community Last Month Activities
*/


insert into #Sales_KPI
select
    kpi.hprop
	,kpi.Community as Community
    ,kpi.Community_Abbr as Community_Abbr
	,kpi.Region as Region
	,kpi.CRD as CRD
	,kpi.RDSM as RDSM
	,'C003' as Report_Index
	,'Community Last Month Activities' as Report_Index_Desc
    ,kpi.Period
    ,kpi.Measure
	,kpi.Measure_Desc
	,kpi.Goal as Goal
    ,kpi.Count as Count
	,kpi.Percentage as Percentage
	,kpi.Score as Score 
	,@wk_startdate as wk_startdate
	,@wk_enddate as wk_enddate
	,@mtd_startdate as mtd_startdate
	,@mtd_enddate as mtd_enddate
	,@lm_startdate as lm_startdate
	,@lm_enddate as lm_enddate
from #Sales_KPI_Findings_Calculations kpi
where Period = 'LM' and Measure < 60


/*
	Prepare Report Index C004 - Community Weekly Activities Total
*/


insert into #Sales_KPI
select
    kpi.hprop
	,kpi.Community as Community
    ,kpi.Community_Abbr as Community_Abbr
	,kpi.Region as Region
	,kpi.CRD as CRD
	,kpi.RDSM as RDSM
	,'C004' as Report_Index
	,'Community Weekly Activities Total' as Report_Index_Desc
    ,kpi.Period
    ,0
	,'Total'
	,0
    ,0
	,0
	,sum(kpi.Score) as Score 
	,@wk_startdate as wk_startdate
	,@wk_enddate as wk_enddate
	,@mtd_startdate as mtd_startdate
	,@mtd_enddate as mtd_enddate
	,@lm_startdate as lm_startdate
	,@lm_enddate as lm_enddate
from #Sales_KPI_Findings_Calculations kpi
where kpi.Period = 'WK'  and Measure < 60
Group BY
   kpi.hprop
	,kpi.Community 
    ,kpi.Community_Abbr 
	,kpi.Region
	,kpi.CRD 
	,kpi.RDSM
	,kpi.Period
	
	
/*
	Prepare Report Index C005 - Community Month to Date Activities Total
*/


insert into #Sales_KPI
select
    kpi.hprop
	,kpi.Community as Community
    ,kpi.Community_Abbr as Community_Abbr
	,kpi.Region as Region
	,kpi.CRD as CRD
	,kpi.RDSM as RDSM
	,'C005' as Report_Index
	,'Community Month to Date Activities Total' as Report_Index_Desc
    ,kpi.Period
    ,0
	,'Total'
	,0
    ,0
	,0
	,sum(kpi.Score) as Score 
	,@wk_startdate as wk_startdate
	,@wk_enddate as wk_enddate
	,@mtd_startdate as mtd_startdate
	,@mtd_enddate as mtd_enddate
	,@lm_startdate as lm_startdate
	,@lm_enddate as lm_enddate
from #Sales_KPI_Findings_Calculations kpi
where kpi.Period = 'MTD' and Measure < 60
Group BY
   kpi.hprop
	,kpi.Community 
    ,kpi.Community_Abbr 
	,kpi.Region
	,kpi.CRD 
	,kpi.RDSM
	,kpi.Period	

/*
	Prepare Report Index C006 - Community Last Month Activities Total
*/


insert into #Sales_KPI
select
    kpi.hprop
	,kpi.Community as Community
    ,kpi.Community_Abbr as Community_Abbr
	,kpi.Region as Region
	,kpi.CRD as CRD
	,kpi.RDSM as RDSM
	,'C006' as Report_Index
	,'Community Last Month Activities Total' as Report_Index_Desc
    ,kpi.Period
    ,0
	,'Total'
	,0
    ,0
	,0
	,sum(kpi.Score) as Score 
	,@wk_startdate as wk_startdate
	,@wk_enddate as wk_enddate
	,@mtd_startdate as mtd_startdate
	,@mtd_enddate as mtd_enddate
	,@lm_startdate as lm_startdate
	,@lm_enddate as lm_enddate
from #Sales_KPI_Findings_Calculations kpi
where kpi.Period = 'LM'  and Measure < 60
Group BY
   kpi.hprop
	,kpi.Community 
    ,kpi.Community_Abbr 
	,kpi.Region
	,kpi.CRD 
	,kpi.RDSM
	,kpi.Period	


/*
	Prepare Report Index C007 - Community Weekly Results
*/


insert into #Sales_KPI
select
    kpi.hprop
	,kpi.Community as Community
    ,kpi.Community_Abbr as Community_Abbr
	,kpi.Region as Region
	,kpi.CRD as CRD
	,kpi.RDSM as RDSM
	,'C007' as Report_Index
	,'Community Weekly Results' as Report_Index_Desc
    ,kpi.Period
    ,kpi.Measure
	,kpi.Measure_Desc
	,kpi.Goal as Goal
    ,kpi.Count as Count
	,kpi.Percentage as Percentage
	,kpi.Score as Score 
	,@wk_startdate as wk_startdate
	,@wk_enddate as wk_enddate
	,@mtd_startdate as mtd_startdate
	,@mtd_enddate as mtd_enddate
	,@lm_startdate as lm_startdate
	,@lm_enddate as lm_enddate
from #Sales_KPI_Findings_Calculations kpi
where Period = 'WK'  and Measure >= 60

/*
	Prepare Report Index C008 - Community Month to Date Results
*/


insert into #Sales_KPI
select
    kpi.hprop
	,kpi.Community as Community
    ,kpi.Community_Abbr as Community_Abbr
	,kpi.Region as Region
	,kpi.CRD as CRD
	,kpi.RDSM as RDSM
	,'C008' as Report_Index
	,'Community Month to Date Results' as Report_Index_Desc
    ,kpi.Period
    ,kpi.Measure
	,kpi.Measure_Desc
	,kpi.Goal as Goal
    ,kpi.Count as Count
	,kpi.Percentage as Percentage
	,kpi.Score as Score 
	,@wk_startdate as wk_startdate
	,@wk_enddate as wk_enddate
	,@mtd_startdate as mtd_startdate
	,@mtd_enddate as mtd_enddate
	,@lm_startdate as lm_startdate
	,@lm_enddate as lm_enddate
from #Sales_KPI_Findings_Calculations kpi
where Period = 'MTD' and Measure >= 60

/*
	Prepare Report Index C009 - Community Last Month Results
*/


insert into #Sales_KPI
select
    kpi.hprop
	,kpi.Community as Community
    ,kpi.Community_Abbr as Community_Abbr
	,kpi.Region as Region
	,kpi.CRD as CRD
	,kpi.RDSM as RDSM
	,'C009' as Report_Index
	,'Community Last Month Results' as Report_Index_Desc
    ,kpi.Period
    ,kpi.Measure
	,kpi.Measure_Desc
	,kpi.Goal as Goal
    ,kpi.Count as Count
	,kpi.Percentage as Percentage
	,kpi.Score as Score 
	,@wk_startdate as wk_startdate
	,@wk_enddate as wk_enddate
	,@mtd_startdate as mtd_startdate
	,@mtd_enddate as mtd_enddate
	,@lm_startdate as lm_startdate
	,@lm_enddate as lm_enddate
from #Sales_KPI_Findings_Calculations kpi
where Period = 'LM'	and Measure >= 60

/*
	Prepare Report Index C010 - Community Weekly Results Total
*/


insert into #Sales_KPI
select
    kpi.hprop
	,kpi.Community as Community
    ,kpi.Community_Abbr as Community_Abbr
	,kpi.Region as Region
	,kpi.CRD as CRD
	,kpi.RDSM as RDSM
	,'C010' as Report_Index
	,'Community Weekly Results Total' as Report_Index_Desc
    ,kpi.Period
    ,0
	,'Total'
	,0
    ,0
	,0
	,sum(kpi.Score) as Score 
	,@wk_startdate as wk_startdate
	,@wk_enddate as wk_enddate
	,@mtd_startdate as mtd_startdate
	,@mtd_enddate as mtd_enddate
	,@lm_startdate as lm_startdate
	,@lm_enddate as lm_enddate
from #Sales_KPI_Findings_Calculations kpi
where kpi.Period = 'WK'  and Measure >= 60
Group BY
   kpi.hprop
	,kpi.Community 
    ,kpi.Community_Abbr 
	,kpi.Region
	,kpi.CRD 
	,kpi.RDSM
	,kpi.Period
	
	
/*
	Prepare Report Index C011 - Community Month to Date Results Total
*/


insert into #Sales_KPI
select
    kpi.hprop
	,kpi.Community as Community
    ,kpi.Community_Abbr as Community_Abbr
	,kpi.Region as Region
	,kpi.CRD as CRD
	,kpi.RDSM as RDSM
	,'C011' as Report_Index
	,'Community Month to Date Results Total' as Report_Index_Desc
    ,kpi.Period
    ,0
	,'Total'
	,0
    ,0
	,0
	,sum(kpi.Score) as Score 
	,@wk_startdate as wk_startdate
	,@wk_enddate as wk_enddate
	,@mtd_startdate as mtd_startdate
	,@mtd_enddate as mtd_enddate
	,@lm_startdate as lm_startdate
	,@lm_enddate as lm_enddate
from #Sales_KPI_Findings_Calculations kpi
where kpi.Period = 'MTD' and Measure >= 60
Group BY
   kpi.hprop
	,kpi.Community 
    ,kpi.Community_Abbr 
	,kpi.Region
	,kpi.CRD 
	,kpi.RDSM
	,kpi.Period	

/*
	Prepare Report Index C012 - Community Last Month Results Total
*/


insert into #Sales_KPI
select
    kpi.hprop
	,kpi.Community as Community
    ,kpi.Community_Abbr as Community_Abbr
	,kpi.Region as Region
	,kpi.CRD as CRD
	,kpi.RDSM as RDSM
	,'C012' as Report_Index
	,'Community Last Month Results Total' as Report_Index_Desc
    ,kpi.Period
    ,0
	,'Total'
	,0
    ,0
	,0
	,sum(kpi.Score) as Score 
	,@wk_startdate as wk_startdate
	,@wk_enddate as wk_enddate
	,@mtd_startdate as mtd_startdate
	,@mtd_enddate as mtd_enddate
	,@lm_startdate as lm_startdate
	,@lm_enddate as lm_enddate
from #Sales_KPI_Findings_Calculations kpi
where kpi.Period = 'LM'  and Measure >= 60
Group BY
   kpi.hprop
	,kpi.Community 
    ,kpi.Community_Abbr 
	,kpi.Region
	,kpi.CRD 
	,kpi.RDSM
	,kpi.Period	

	


/*
	Prepare Report Index C013 - Community Weekly Grand Total
*/


insert into #Sales_KPI
select distinct
    kpi.hprop
	,kpi.Community as Community
    ,kpi.Community_Abbr as Community_Abbr
	,kpi.Region as Region
	,kpi.CRD as CRD
	,kpi.RDSM as RDSM
	,'C013' as Report_Index
	,'Community Weekly Grand Total' as Report_Index_Desc
    ,kpi.Period
    ,0
	,'Grand Total Score'
	,0
    ,0
	,0
	,(select Score * .6 from #Sales_KPI where hprop = kpi.hprop and Report_Index = 'C004' )
		+
	 (select Score * .4 from #Sales_KPI where hprop = kpi.hprop and Report_Index = 'C010' )as Score 
	,@wk_startdate as wk_startdate
	,@wk_enddate as wk_enddate
	,@mtd_startdate as mtd_startdate
	,@mtd_enddate as mtd_enddate
	,@lm_startdate as lm_startdate
	,@lm_enddate as lm_enddate
from #Sales_KPI_Findings_Calculations kpi
where kpi.Period = 'WK' and Measure >= 60

	

/*
	Prepare Report Index C014 - Community Month to Date Grand Total
*/


insert into #Sales_KPI
select distinct
    kpi.hprop
	,kpi.Community as Community
    ,kpi.Community_Abbr as Community_Abbr
	,kpi.Region as Region
	,kpi.CRD as CRD
	,kpi.RDSM as RDSM
	,'C014' as Report_Index
	,'Community Month to Date Grand Total' as Report_Index_Desc
    ,kpi.Period
    ,0
	,'Grand Total Score'
	,0
    ,0
	,0
	,(select Score * .6 from #Sales_KPI where hprop = kpi.hprop and Report_Index = 'C005' )
		+
	 (select Score * .4 from #Sales_KPI where hprop = kpi.hprop and Report_Index = 'C011' )as Score 
	,@wk_startdate as wk_startdate
	,@wk_enddate as wk_enddate
	,@mtd_startdate as mtd_startdate
	,@mtd_enddate as mtd_enddate
	,@lm_startdate as lm_startdate
	,@lm_enddate as lm_enddate
from #Sales_KPI_Findings_Calculations kpi
where kpi.Period = 'MTD' and Measure >= 60

/*
	Prepare Report Index C015 - Community Last Month Grand Total
*/


insert into #Sales_KPI
select distinct
    kpi.hprop
	,kpi.Community as Community
    ,kpi.Community_Abbr as Community_Abbr
	,kpi.Region as Region
	,kpi.CRD as CRD
	,kpi.RDSM as RDSM
	,'C015' as Report_Index
	,'Community Last Month Grand Total' as Report_Index_Desc
    ,kpi.Period
    ,0
	,'Grand Total Score'
	,0
    ,0
	,0
	,(select Score * .6 from #Sales_KPI where hprop = kpi.hprop and Report_Index = 'C006' )
		+
	 (select Score * .4 from #Sales_KPI where hprop = kpi.hprop and Report_Index = 'C012' )as Score 
	,@wk_startdate as wk_startdate
	,@wk_enddate as wk_enddate
	,@mtd_startdate as mtd_startdate
	,@mtd_enddate as mtd_enddate
	,@lm_startdate as lm_startdate
	,@lm_enddate as lm_enddate
from #Sales_KPI_Findings_Calculations kpi
where kpi.Period = 'LM'  and Measure >= 60



/*
	Prepare Report Index C016 - Community Weekly Inquiry to Tour Ratio
*/

insert into #Sales_KPI
select distinct
    kpi.hprop
	,kpi.Community as Community
    ,kpi.Community_Abbr as Community_Abbr
	,kpi.Region as Region
	,kpi.CRD as CRD
	,kpi.RDSM as RDSM
	,'C016' as Report_Index
	,'Community Weekly Inquiry to Tour Ratio' as Report_Index_Desc
    ,kpi.Period
    ,0
	,'ED Inquiry to Tour Ratio'
	,0
    ,0
	,0
	,case
		when isnull((select Count from #Sales_KPI where hprop = kpi.hprop and Period = kpi.Period and Measure = 40 ),0) = 0 then 0.00
		else 
			(isnull((select Count from #Sales_KPI_First_Tours where hprop = kpi.hprop and Period = kpi.Period and Measure = 50 ),0)* 1.00000) 
			/	
			((select Count from #Sales_KPI where hprop = kpi.hprop and Period = kpi.Period and Measure = 40 )* 1.00000)

	end as Score 


	,@wk_startdate as wk_startdate
	,@wk_enddate as wk_enddate
	,@mtd_startdate as mtd_startdate
	,@mtd_enddate as mtd_enddate
	,@lm_startdate as lm_startdate
	,@lm_enddate as lm_enddate
from #Sales_KPI kpi
where kpi.Period = 'WK'  and Measure = 40


/*
	Prepare Report Index C017 - Community Month-to-Date Inquiry to Tour Ratio
*/

insert into #Sales_KPI
select distinct
    kpi.hprop
	,kpi.Community as Community
    ,kpi.Community_Abbr as Community_Abbr
	,kpi.Region as Region
	,kpi.CRD as CRD
	,kpi.RDSM as RDSM
	,'C017' as Report_Index
	,'Community Month-to-Date Inquiry to Tour Ratio' as Report_Index_Desc
    ,kpi.Period
    ,0
	,'ED Inquiry to Tour Ratio'
	,0
    ,0
	,0
	,case
		when isnull((select Count from #Sales_KPI where hprop = kpi.hprop and Period = kpi.Period and Measure = 40 ),0) = 0 then 0.00
		else 
			(isnull((select Count from #Sales_KPI_First_Tours where hprop = kpi.hprop and Period = kpi.Period and Measure = 50 ),0)* 1.00000) 
			/	
			((select Count from #Sales_KPI where hprop = kpi.hprop and Period = kpi.Period and Measure = 40 )* 1.00000)

	end as Score 


	,@wk_startdate as wk_startdate
	,@wk_enddate as wk_enddate
	,@mtd_startdate as mtd_startdate
	,@mtd_enddate as mtd_enddate
	,@lm_startdate as lm_startdate
	,@lm_enddate as lm_enddate
from #Sales_KPI kpi
where kpi.Period = 'MTD'  and Measure = 40


/*
	Prepare Report Index C018 - Community Last Month Inquiry to Tour Ratio
*/

insert into #Sales_KPI
select distinct
    kpi.hprop
	,kpi.Community as Community
    ,kpi.Community_Abbr as Community_Abbr
	,kpi.Region as Region
	,kpi.CRD as CRD
	,kpi.RDSM as RDSM
	,'C018' as Report_Index
	,'Community Last Month Inquiry to Tour Ratio' as Report_Index_Desc
    ,kpi.Period
    ,0
	,'ED Inquiry to Tour Ratio'
	,0
    ,0
	,0
	,case
		when isnull((select Count from #Sales_KPI where hprop = kpi.hprop and Period = kpi.Period and Measure = 40 ),0) = 0 then 0.00
		else 
			(isnull((select Count from #Sales_KPI_First_Tours where hprop = kpi.hprop and Period = kpi.Period and Measure = 50 ),0)* 1.00000) 
			/	
			((select Count from #Sales_KPI where hprop = kpi.hprop and Period = kpi.Period and Measure = 40 )* 1.00000)

	end as Score 


	,@wk_startdate as wk_startdate
	,@wk_enddate as wk_enddate
	,@mtd_startdate as mtd_startdate
	,@mtd_enddate as mtd_enddate
	,@lm_startdate as lm_startdate
	,@lm_enddate as lm_enddate
from #Sales_KPI kpi
where kpi.Period = 'LM'  and Measure = 40



/*
	Prepare Report Index C019 - Community Weekly Tour to Move In Ratio
*/

insert into #Sales_KPI
select distinct
    kpi.hprop
	,kpi.Community as Community
    ,kpi.Community_Abbr as Community_Abbr
	,kpi.Region as Region
	,kpi.CRD as CRD
	,kpi.RDSM as RDSM
	,'C019' as Report_Index
	,'Community Weekly Tour to Move In Ratio' as Report_Index_Desc
    ,kpi.Period
    ,0
	,'ED Tour to Move In Ratio'
	,0
    ,0
	,0
	,case
		when isnull((select Count from #Sales_KPI_First_Tours where hprop = kpi.hprop and Period = kpi.Period and Measure = 50 ),0) = 0 then 0.00
		else 
			(isnull((select Count from #Sales_KPI where hprop = kpi.hprop and Period = kpi.Period and Measure = 70 ),0)*1.000)
			/
			((select Count from #Sales_KPI_First_Tours where hprop = kpi.hprop and Period = kpi.Period and Measure = 50 )* 1.00000) 
			
	end as Score  


	,@wk_startdate as wk_startdate
	,@wk_enddate as wk_enddate
	,@mtd_startdate as mtd_startdate
	,@mtd_enddate as mtd_enddate
	,@lm_startdate as lm_startdate
	,@lm_enddate as lm_enddate
from #Sales_KPI kpi
where kpi.Period = 'WK'  and Measure = 70

/*
	Prepare Report Index C020 - Community Month to Date Tour to Move In Ratio
*/

insert into #Sales_KPI
select distinct
    kpi.hprop
	,kpi.Community as Community
    ,kpi.Community_Abbr as Community_Abbr
	,kpi.Region as Region
	,kpi.CRD as CRD
	,kpi.RDSM as RDSM
	,'C020' as Report_Index
	,'Community Month to Date Tour to Move In Ratio' as Report_Index_Desc
    ,kpi.Period
    ,0
	,'ED Tour to Move In Ratio'
	,0
    ,0
	,0
	,case
		when isnull((select Count from #Sales_KPI_First_Tours where hprop = kpi.hprop and Period = kpi.Period and Measure = 50 ),0) = 0 then 0.00
		else 
			(isnull((select Count from #Sales_KPI where hprop = kpi.hprop and Period = kpi.Period and Measure = 70 ),0)*1.000)
			/
			((select Count from #Sales_KPI_First_Tours where hprop = kpi.hprop and Period = kpi.Period and Measure = 50 )* 1.00000) 
			
	end as Score  


	,@wk_startdate as wk_startdate
	,@wk_enddate as wk_enddate
	,@mtd_startdate as mtd_startdate
	,@mtd_enddate as mtd_enddate
	,@lm_startdate as lm_startdate
	,@lm_enddate as lm_enddate
from #Sales_KPI kpi
where kpi.Period = 'MTD'  and Measure = 70


/*
	Prepare Report Index C021 - Community Last Month Tour to Move In Ratio
*/

insert into #Sales_KPI
select distinct
    kpi.hprop
	,kpi.Community as Community
    ,kpi.Community_Abbr as Community_Abbr
	,kpi.Region as Region
	,kpi.CRD as CRD
	,kpi.RDSM as RDSM
	,'C021' as Report_Index
	,'Community Last Month Tour to Move In Ratio' as Report_Index_Desc
    ,kpi.Period
    ,0
	,'ED Tour to Move In Ratio'
	,0
    ,0
	,0
	,case
		when isnull((select Count from #Sales_KPI_First_Tours where hprop = kpi.hprop and Period = kpi.Period and Measure = 50 ),0) = 0 then 0.00
		else 
			(isnull((select Count from #Sales_KPI where hprop = kpi.hprop and Period = kpi.Period and Measure = 70 ),0)*1.000)
			/
			((select Count from #Sales_KPI_First_Tours where hprop = kpi.hprop and Period = kpi.Period and Measure = 50 )* 1.00000) 
			
	end as Score  


	,@wk_startdate as wk_startdate
	,@wk_enddate as wk_enddate
	,@mtd_startdate as mtd_startdate
	,@mtd_enddate as mtd_enddate
	,@lm_startdate as lm_startdate
	,@lm_enddate as lm_enddate
from #Sales_KPI kpi
where kpi.Period = 'LM'  and Measure = 70


/*

	Update Region for Hardcoded Custom Changes

		REMOVED 2020-08-27
		Will now use Regions as they appear in system

		Also replaced the Custom Filter for these Regions


update kpi
set Region = case 
	when isnull(ltrim(rtrim(Region)),'') = '' then '???'
	when hprop in (46,4,5,6,14,13,52) then 'Bluegrass East'
	when hprop in (26,27,28,12,61) then 'Bluegrass West'
	else  ltrim(rtrim(Region)) 
end 
from #Sales_KPI kpi

*/



/*

	Add whether Community belonges to selected Region(s)

*/

alter table #Sales_KPI
add Community_Selected varchar(1)

update kpi
set Community_Selected = 'Y'
from #Sales_KPI kpi
where kpi.hprop in (select distinct a.hprop from Attributes a where 1=1 #Condition2#)



/*
	Gather Community and Regional Contacts
*/

select 
	hRecord as hProp
  ,r.sDesc 
  ,case
    	when hcontact is not null then ltrim(rtrim(c.sFirstName)) 
        else ltrim(rtrim(p.sFirstName)) 
     end as Name
     into #Contacts
from contactXref cxref
left join Contact c on c.hMy = cxref.hContact
left join Person p on p.hMy = cxref.hPerson
left join Role r on r.hMy = cxref.hRole

where hRecord is not null
/* and ltrim(rtrim(isnull(p.sFirstName,'')))  <> '' */

SELECT hProp, Name = 
    STUFF((SELECT ', ' + Name
           FROM #Contacts b 
           WHERE b.sDesc in ('CRD','Executive Director') and b.hProp = a.hProp
          FOR XML PATH('')), 1, 2, '')
into #Comm_Contacts
FROM #Contacts a
GROUP BY hProp
order by hprop

SELECT hProp, Name = 
    STUFF((SELECT ', ' + Name
           FROM #Contacts b 
           WHERE b.sDesc in ('RDSM') and b.hProp = a.hProp
          FOR XML PATH('')), 1, 2, '')
into #Regional_Contacts
FROM #Contacts a
GROUP BY hProp
order by hprop

/*
	Final Select Output
*/
	



	
select 
  kpi.hprop
,ltrim(rtrim(Community)) as Community
,ltrim(rtrim(replace(substring(Community_Abbr,1 , CHARINDEX('(', Community_Abbr)-1) + substring(Community_Abbr, CHARINDEX(')', Community_Abbr)+1,100),'  ',' '))) as Community_Abbr
,ltrim(rtrim(p.scode)) as Community_Code
,Region
,ltrim(rtrim(c.Name)) as Admin_CRD
,ltrim(rtrim(r.Name)) as RDSM
,Report_Index
,Report_Index_Desc
,Period
,Measure
,Measure_Desc
,Goal
,Count
,Percentage
,Score
,wk_startdate
,wk_enddate
,mtd_startdate
,mtd_enddate
,lm_startdate
,lm_enddate
,(select score from #Sales_KPI where hprop = kpi.hprop and Report_Index = 'C013') as Community_WK_Grand_Total_Score
,(select score from #Sales_KPI where hprop = kpi.hprop and Report_Index = 'C014') as Community_MTD_Grand_Total_Score
,(select score from #Sales_KPI where hprop = kpi.hprop and Report_Index = 'C015') as Community_LM_Grand_Total_Score
,(select score from #Sales_KPI where hprop = kpi.hprop and Report_Index = 'C004') as Community_WK_Total_Activity_Score
,(select score from #Sales_KPI where hprop = kpi.hprop and Report_Index = 'C005') as Community_MTD_Total_Activity_Score
,(select score from #Sales_KPI where hprop = kpi.hprop and Report_Index = 'C006') as Community_LM_Total_Activity_Score
,(select score from #Sales_KPI where hprop = kpi.hprop and Report_Index = 'C010') as Community_WK_Total_Results_Score
,(select score from #Sales_KPI where hprop = kpi.hprop and Report_Index = 'C011') as Community_MTD_Total_Results_Score
,(select score from #Sales_KPI where hprop = kpi.hprop and Report_Index = 'C012') as Community_LM_Total_Results_Score
,(select score from #Sales_KPI where hprop = kpi.hprop and Report_Index = 'C016') as Community_WK_Inquire_Tour_Ratio
,(select score from #Sales_KPI where hprop = kpi.hprop and Report_Index = 'C017') as Community_MTD_Inquire_Tour_Ratio
,(select score from #Sales_KPI where hprop = kpi.hprop and Report_Index = 'C018') as Community_LM_Inquire_Tour_Ratio
,(select score from #Sales_KPI where hprop = kpi.hprop and Report_Index = 'C019') as Community_WK_Tour_MoveIn_Ratio
,(select score from #Sales_KPI where hprop = kpi.hprop and Report_Index = 'C020') as Community_MTD_Tour_MoveIn_Ratio
,(select score from #Sales_KPI where hprop = kpi.hprop and Report_Index = 'C021') as Community_LM_Tour_MoveIn_Ratio
,Community_Selected

from #Sales_KPI kpi
left join #Comm_Contacts c on c.hProp = kpi.hProp
left join #Regional_Contacts r on r.hProp = kpi.hProp
left join Property p on kpi.hprop = p.hMY
where kpi.hprop in (select a.hProp from Attributes a where a.SubGroup3 in ('Stabilized','Focus','Start Up'))
order by kpi.hprop, Report_Index, Measure




DROP TABLE #Sales_KPI
DROP TABLE #Sales_KPI_Findings
DROP TABLE #Sales_KPI_Findings_Calculations
DROP TABLE #Sales_Goals

drop table #Contacts
drop table #Comm_Contacts
drop table #Regional_Contacts

drop table #Count_Backup

//end select



//Columns
//Type,  Name,  Head1,  Head2,  Head3,  Head4,  Show,  Color,  Formula,  Drill,  Key,  Width
I,  ,  ,  ,  ,   Property KEY,  Y,  ,  ,  ,  ,  500,  
T,  ,  ,  ,  ,      Community,  Y,  ,  ,  ,  ,  500,  
T,  ,  ,  ,  , Community_Abbr,  Y,  ,  ,  ,  ,  500,  
T,  ,  ,  ,  , Community_Code,  Y,  ,  ,  ,  ,  500,  
T,  ,  ,  ,  ,         Region,  Y,  ,  ,  ,  ,  500,  
T,  ,  ,  ,  ,            Admin_CRD,  Y,  ,  ,  ,  ,  500,  
T,  ,  ,  ,  ,           RDSM,  Y,  ,  ,  ,  ,  500,  
T,  ,  ,  ,  ,   Report_Index,  Y,  ,  ,  ,  ,  500,  
T,  ,  ,  ,  ,Report_Index_Desc,  Y,  ,  ,  ,  ,  500,  
T,  ,  ,  ,  ,         Period,  Y,  ,  ,  ,  ,  500,  
I,  ,  ,  ,  ,        Measure,  Y,  ,  ,  ,  ,  500, 
T,  ,  ,  ,  ,   Measure_Desc,  Y,  ,  ,  ,  ,  500, 
I,  ,  ,  ,  ,           Goal,  Y,  ,  ,  ,  ,  500, 
I,  ,  ,  ,  ,          Count,  Y,  ,  ,  ,  ,  500,  
F5,  ,  ,  ,  ,    Percentage,  Y,  ,  ,  ,  ,  500, 
F5,  ,  ,  ,  ,         Score,  Y,  ,  ,  ,  ,  500, 
A,  ,  ,  ,  ,         wk_startdate,  Y,  ,  ,  ,  ,  500,
A,  ,  ,  ,  ,         wk_enddate,  Y,  ,  ,  ,  ,  500,
A,  ,  ,  ,  ,         mtd_startdate,  Y,  ,  ,  ,  ,  500,
A,  ,  ,  ,  ,         mtd_enddate,  Y,  ,  ,  ,  ,  500,
A,  ,  ,  ,  ,         lm_startdate,  Y,  ,  ,  ,  ,  500,
A,  ,  ,  ,  ,         lm_enddate,  Y,  ,  ,  ,  ,  500,
F5,  ,  ,  ,  ,        Community_WK_Grand_Total_Score,  Y,  ,  ,  ,  ,  500, 
F5,  ,  ,  ,  ,        Community_MTD_Grand_Total_Score,  Y,  ,  ,  ,  ,  500, 
F5,  ,  ,  ,  ,        Community_LM_Grand_Total_Score,  Y,  ,  ,  ,  ,  500, 
F5,  ,  ,  ,  ,        Community_WK_Total_Activity_Score,  Y,  ,  ,  ,  ,  500, 
F5,  ,  ,  ,  ,        Community_MTD_Total_Activity_Score,  Y,  ,  ,  ,  ,  500, 
F5,  ,  ,  ,  ,        Community_LM_Total_Activity_Score,  Y,  ,  ,  ,  ,  500, 
F5,  ,  ,  ,  ,        Community_WK_Total_Results_Score,  Y,  ,  ,  ,  ,  500, 
F5,  ,  ,  ,  ,        Community_MTD_Total_Results_Score,  Y,  ,  ,  ,  ,  500, 
F5,  ,  ,  ,  ,        Community_LM_Total_Results_Score,  Y,  ,  ,  ,  ,  500, 
F5,  ,  ,  ,  ,        Community_WK_Inquire_Tour_Ratio,  Y,  ,  ,  ,  ,  500, 
F5,  ,  ,  ,  ,        Community_MTD_Inquire_Tour_Ratio,  Y,  ,  ,  ,  ,  500, 
F5,  ,  ,  ,  ,        Community_LM_Inquire_Tour_Ratio,  Y,  ,  ,  ,  ,  500, 
F5,  ,  ,  ,  ,        Community_WK_Tour_MoveIn_Ratio,  Y,  ,  ,  ,  ,  500, 
F5,  ,  ,  ,  ,        Community_MTD_Tour_MoveIn_Ratio,  Y,  ,  ,  ,  ,  500, 
F5,  ,  ,  ,  ,        Community_LM_Tour_MoveIn_Ratio,  Y,  ,  ,  ,  ,  500, 
T,  ,  ,  ,  ,      Community_Selected,  Y,  ,  ,  ,  ,  500,
//End Columns



//Filter
//Type, DataTyp,Name,           Caption,      Key,   List,         Val1,                    Val2, 	Mandatory,Multi-Type, Title  Title
L,      T,       			dat1,     Report Week Beginning,      ,  "select convert(varchar(10),a.ItemDate,101) as Week_Beginning  from	(SELECT	top 380 DATEADD(DAY, (ROW_NUMBER() OVER (ORDER BY a.object_id ) - 1) * -1, CONVERT(DATETIME, getdate())) AS ItemDate FROM	sys.columns a CROSS JOIN sys.columns b	) a where datepart(dw,a.ItemDate) = 4 and datediff(day,a.ItemDate,getdate()) > 6", 										 , 			 , 				 Y, 				 , 			 ,
M,      T,       			regions,     Region(s),      ,  "select distinct case when isnull(ltrim(rtrim(a.SubGroup2)),'') = '' then '???' else  ltrim(rtrim(a.SubGroup2)) end as Region from Attributes a where a.SubGroup3 in ('Stabilized','Focus','Start Up') order by Region",ltrim(rtrim(Region))='#regions#'										 , 			 , 				 Y, 				 , 			 ,
//end filter
