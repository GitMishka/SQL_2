-- Creating the   tables and inserting data
DROP TABLE IF EXISTS #Temp2018;
DROP TABLE IF EXISTS #Temp2019;
DROP TABLE IF EXISTS #Temp2022;
DROP TABLE IF EXISTS #Temp2023;
DROP TABLE IF EXISTS #ConsolidatedData;
CREATE   TABLE #Temp2018 (
    Region VARCHAR(50),
    Community VARCHAR(100),
    TotalUnits INT,
    Budget INT
);

INSERT INTO #Temp2018 (Region, Community, TotalUnits, Budget) VALUES
('Bluegrass', 'Russell Lantern (rusl)', 44, 39),
('Cumberland', 'Tullahoma (tula)', 50, 49),
('Lookout', 'Greenbriar (grnb)', 58, 57),
('Lookout', 'Calhoun (calh)', 61, 59),
('Lookout', 'Chattanooga Shallowford (chtt)', 77, 76),
('Bluegrass', 'Frankfort (frkt)', 42, 41),
('Smoky', 'Greeneville (grnv)', 44, 43),
('Smoky', 'Lenoir City Lantern (lenl)', 44, 42),
('Cumberland', 'Columbia (colm)', 42, 40),
('Smoky', 'Lenoir City (lenc)', 59, 58),
('Cumberland', 'Spring Hill (sprh)', 73, 72),
('Bluegrass', 'Russell (russ)', 58, 54),
('Bluegrass', 'Danville (danv)', 60, 58),
('Lookout', 'Chattanooga Lantern (chtl)', 58, 57),
('Bluegrass', 'Franklin (frln)', 65, 64),
('Smoky', 'Powell (powl)', 73, 72),
('Cumberland', 'Brentwood (brwd)', 73, 70),
('Lookout', 'Hixson (hixn)', 69, 67),
('Smoky', 'Athens (aths)', 44, 42),
('Bluegrass', 'Frankfort Lantern (frkl)', 36, 35),
('Lookout', 'Collegedale Lantern (cgdl)', 35, 34),
('Cumberland', 'Tuscaloosa (tusc)', 54, 53),
('Bluegrass', 'Louisville (lvlm)', 73, 60),
('Bluegrass', 'Lexington-East (lexe)', 73, 72),
('Bluegrass', 'Lexington Lantern (lexl)', 44, 43),
('Smoky', 'Clinton (clin)', 51, 47),
('Bluegrass', 'Lexington (lexn)', 73, 68),
('Bluegrass', 'Richmond (rich)', 42, 41),
('Cumberland', 'Franklin, TN Lantern (fktl)', 44, 38),
('Bluegrass', 'Louisville Lantern (lvll)', 44, 40),
('Cumberland', 'Franklin, TN (fktn)', 73, 60);

CREATE   TABLE #Temp2019 (
    Region VARCHAR(50),
    Community VARCHAR(100),
    TotalUnits INT,
    Budget INT
);

INSERT INTO #Temp2019 (Region, Community, TotalUnits, Budget) VALUES
('Appalachian', 'Chattanooga Shallowford (chtt)', 77, 76),
('Bluegrass West', 'Frankfort Lantern (frkl)', 36, 35),
('Bluegrass West', 'Frankfort (frkt)', 42, 41),
('Bluegrass East', 'Lexington Lantern (lexl)', 44, 43),
('Cumberland', 'Powell (powl)', 73, 72),
('Appalachian', 'Athens (aths)', 44, 43),
('Appalachian', 'Lenoir City Lantern (lenl)', 44, 43),
('Appalachian', 'Knoxville (knox)', 73, 61),
('Cumberland', 'Tullahoma (tula)', 50, 49),
('Appalachian', 'Hixson (hixn)', 69, 68),
('Appalachian', 'Greeneville (grnv)', 44, 43),
('Appalachian', 'Chattanooga Lantern (chtl)', 59, 58),
('Bluegrass East', 'Russell Lantern (rusl)', 44, 43),
('Cumberland', 'Brentwood (brwd)', 73, 72),
('Appalachian', 'Greenbriar (grnb)', 58, 57),
('Appalachian', 'Calhoun (calh)', 61, 59),
('Bluegrass East', 'Danville (danv)', 60, 59),
('Cumberland', 'Spring Hill (sprh)', 73, 72),
('Bluegrass East', 'Richmond (rich)', 42, 41),
('Cumberland', 'Columbia (colm)', 43, 42),
('Appalachian', 'Collegedale Lantern (cgdl)', 35, 34),
('Cumberland', 'Tuscaloosa (tusc)', 54, 53),
('Bluegrass West', 'Franklin (frln)', 65, 64),
('Appalachian', 'Lenoir City (lenc)', 59, 58),
('Bluegrass West', 'Louisville (lvlm)', 73, 72),
('Bluegrass East', 'Russell (russ)', 58, 57),
('Bluegrass East', 'Lexington (lexn)', 73, 72),
('Cumberland', 'Clinton (clin)', 51, 50),
('Cumberland', 'Franklin, TN Lantern (fktl)', 44, 43),
('Bluegrass East', 'Lexington-East (lexe)', 73, 72),
('Cumberland', 'Franklin, TN (fktn)', 73, 72),
('Bluegrass West', 'Louisville Lantern (lvll)', 44, 43),
('Appalachian', 'East Hamilton (eham)', 73, 22);

CREATE   TABLE #Temp2022 (
    Region VARCHAR(50),
    Community VARCHAR(100),
    TotalUnits INT,
    Budget INT
);

INSERT INTO #Temp2022 (Region, Community, TotalUnits, Budget) VALUES
('Appalachian', 'Chattanooga Lantern (chtl)', 59, 58),
('Bluegrass', 'Danville (danv)', 60, 59),
('Appalachian', 'Hixson (hixn)', 69, 68),
('Cumberland', 'Tullahoma (tula)', 50, 49),
('Cumberland', 'Tuscaloosa (tusc)', 54, 53),
('Bluegrass', 'Louisville (lvlm)', 73, 72),
('Appalachian', 'Knoxville (knox)', 73, 72),
('Cumberland', 'Franklin TN (fktn)', 73, 72),
('Cumberland', 'Spring Hill (sprh)', 73, 72),
('Appalachian', 'Knoxville Lantern (knxl)', 60, 59),
('Appalachian', 'Lenoir City (lenc)', 59, 58),
('Appalachian', 'Greenbriar (grnb)', 58, 57),
('Appalachian', 'Athens (aths)', 44, 43),
('Appalachian', 'Greeneville (grnv)', 44, 42),
('Cumberland', 'Franklin TN Lantern (fktl)', 44, 43),
('Cumberland', 'Powell (powl)', 73, 52),
('Appalachian', 'Collegedale Lantern (cgdl)', 35, 34),
('Appalachian', 'Calhoun (calh)', 61, 60),
('Bluegrass', 'Russell (russ)', 58, 57),
('Bluegrass', 'Lexington (lexn)', 73, 72),
('Cumberland', 'Columbia (colm)', 43, 42),
('Bluegrass', 'Richmond (rich)', 42, 41),
('Appalachian', 'Chattanooga Shallowford (chtt)', 77, 76),
('Bluegrass', 'Russell Lantern (rusl)', 44, 43),
('Appalachian', 'Lenoir City Lantern (lenl)', 44, 43),
('Bluegrass', 'Frankfort (frkt)', 42, 41),
('Cumberland', 'Brentwood (brwd)', 73, 72),
('Cumberland', 'Spring Hill Lantern (sprl)', 43, 43),
('Appalachian', 'East Hamilton (eham)', 73, 72),
('Bluegrass', 'Lexington-East (lexe)', 73, 71),
('Bluegrass', 'Louisville Lantern (lvll)', 44, 42),
('Cumberland', 'Powell Lantern (pwll)', 44, 38),
('Appalachian', 'Hardin Valley (hard)', 77, 59);

CREATE   TABLE #Temp2023 (
    Region VARCHAR(50),
    Community VARCHAR(100),
    TotalUnits INT,
    Budget INT
);

INSERT INTO #Temp2023 (Region, Community, TotalUnits, Budget) VALUES
('Appalachian', 'Greeneville (grnv)', 44, 43),
('Cumberland', 'Brentwood (brwd)', 73, 73),
('Bluegrass', 'Frankfort (frkt)', 42, 41),
('Appalachian', 'Athens (aths)', 44, 43),
('Appalachian', 'Hixson (hixn)', 69, 68),
('Appalachian', 'Lenoir City (lenc)', 59, 58),
('Bluegrass', 'Richmond (rich)', 42, 41),
('Appalachian', 'Knoxville (knox)', 73, 72),
('Appalachian', 'Knoxville Lantern (knxl)', 60, 59),
('Cumberland', 'Tullahoma (tula)', 50, 49),
('Cumberland', 'Powell (powl)', 73, 72),
('Cumberland', 'Spring Hill Lantern (sprl)', 44, 43),
('Cumberland', 'Franklin TN (fktn)', 73, 72),
('Cumberland', 'Powell Lantern (pwll)', 44, 43),
('Appalachian', 'Chattanooga Shallowford (chtt)', 77, 76),
('Bluegrass', 'Lexington (lexn)', 73, 72),
('Appalachian', 'Chattanooga Lantern (chtl)', 59, 58),
('Bluegrass', 'Lexington Lantern (lexl)', 44, 43),
('Appalachian', 'Calhoun (calh)', 61, 60),
('Bluegrass', 'Danville (danv)', 60, 59),
('Bluegrass', 'Russell (russ)', 58, 57),
('Appalachian', 'Greenbriar (grnb)', 58, 57),
('Cumberland', 'Spring Hill (sprh)', 73, 72),
('Appalachian', 'Lenoir City Lantern (lenl)', 44, 43),
('Cumberland', 'Tuscaloosa (tusc)', 54, 53),
('Appalachian', 'Hardin Valley (hard)', 77, 71),
('Cumberland', 'Franklin TN Lantern (fktl)', 44, 43),
('Appalachian', 'East Hamilton (eham)', 73, 73),
('Cumberland', 'Columbia (colm)', 43, 42),
('Bluegrass', 'Russell Lantern (rusl)', 44, 43),
('Bluegrass', 'Louisville (lvlm)', 73, 72),
('Bluegrass', 'Frankfort Lantern (frkl)', 36, 35),
('Appalachian', 'Collegedale Lantern (cgdl)', 35, 34),
('Bluegrass', 'Franklin (frln)', 65, 63),
('Bluegrass', 'Louisville Lantern (lvll)', 44, 43),
('Bluegrass', 'Lexington-East (lexe)', 73, 72),
('Cumberland', 'Clinton (clin)', 51, 49),
('Appalachian', 'Happy Valley (hppy)', 82, 82);

-- Consolidating the data into one table with the "year" column
CREATE TABLE #Temp2024 (
    Region VARCHAR(50),
    Community VARCHAR(100),
    TotalUnits INT,
    Budget INT
);

INSERT INTO #Temp2024 (Region, Community, TotalUnits, Budget) VALUES
('Cumberland', 'Tullahoma (tula)', 50, 49),
('Lookout', 'Chattanooga Lantern (chtl)', 59, 58),
('Lookout', 'Athens (aths)', 44, 43),
('Bluegrass', 'Danville (danv)', 60, 59),
('Smoky', 'Powell Lantern (pwll)', 44, 43),
('Smoky', 'Knoxville (knox)', 73, 72),
('Smoky', 'Lenoir City (lenc)', 59, 58),
('Bluegrass', 'Richmond (rich)', 42, 41),
('Cumberland', 'Spring Hill (sprh)', 73, 72),
('Smoky', 'Lenoir City Lantern (lenl)', 44, 43),
('Lookout', 'Hixson (hixn)', 69, 68),
('Smoky', 'Knoxville Lantern (knxl)', 60, 59),
('Smoky', 'Greeneville (grnv)', 44, 43),
('Smoky', 'Hardin Valley (hard)', 77, 76),
('Cumberland', 'Franklin TN (fktn)', 73, 72),
('Smoky', 'Powell (powl)', 73, 72),
('Cumberland', 'Brentwood (brwd)', 73, 72),
('Cumberland', 'Columbia (colm)', 43, 42),
('Bluegrass', 'Frankfort (frkt)', 42, 41),
('Lookout', 'East Hamilton (eham)', 73, 72),
('Cumberland', 'Spring Hill Lantern (sprl)', 44, 43),
('Lookout', 'Chattanooga Shallowford (chtt)', 77, 76),
('Lookout', 'Greenbriar (grnb)', 58, 57),
('Bluegrass', 'Russell (russ)', 59, 57),
('Cumberland', 'Franklin TN Lantern (fktl)', 44, 43),
('Lookout', 'Calhoun (calh)', 61, 60),
('Bluegrass', 'Lexington Lantern (lexl)', 44, 43),
('Lookout', 'Tuscaloosa (tusc)', 54, 53),
('Bluegrass', 'Russell Lantern (rusl)', 44, 43),
('Bluegrass', 'Frankfort Lantern (frkl)', 36, 35),
('Lookout', 'Happy Valley (hppy)', 82, 52),
('Bluegrass', 'Lexington (lexn)', 73, 72),
('Cumberland', 'Louisville (lvlm)', 73, 72),
('Lookout', 'Collegedale Lantern (cgdl)', 35, 34),
('Smoky', 'Clinton (clin)', 51, 46),
('Bluegrass', 'Lexington-East (lexe)', 73, 68),
('Bluegrass', 'Franklin (frln)', 65, 64),
('Cumberland', 'Louisville Lantern (lvll)', 44, 43);


CREATE   TABLE #ConsolidatedData (
    Region VARCHAR(50),
    Community VARCHAR(100),
    TotalUnits INT,
    Budget INT,
    Year INT
);

INSERT INTO #ConsolidatedData (Region, Community, TotalUnits, Budget, Year)
SELECT Region, Community, TotalUnits, Budget, 2018 FROM #Temp2018
UNION ALL
SELECT Region, Community, TotalUnits, Budget, 2019 FROM #Temp2019
UNION ALL
SELECT Region, Community, TotalUnits, Budget, 2022 FROM #Temp2022
UNION ALL
SELECT Region, Community, TotalUnits, Budget, 2023 FROM #Temp2023
UNION ALL
SELECT Region, Community, TotalUnits, Budget, 2024 FROM #Temp2024

-- Optional: Select all data from the consolidated table to verify
SELECT * FROM #ConsolidatedData;
-- Assuming the column Community is 'Community' and the table is 'your_table'



with budgeted as (
SELECT
    SUBSTRING(Community, CHARINDEX('(', Community) + 1, CHARINDEX(')', Community) - CHARINDEX('(', Community) - 1) AS comcode,
	*
FROM
    #ConsolidatedData )
	select year,region, sum(TotalUnits) as n_units from budgeted b
	join property p on b.comcode = p.scode 
	group by year,region 
	order by year desc
