-- Size of the database
DECLARE @DatabaseSize NVARCHAR(50);
SELECT @DatabaseSize = 
    LTRIM(STR((SUM(size * 8.00) / 1024.00), 15, 2) + ' MB') 
FROM sys.master_files 
WHERE database_id = DB_ID() AND type_desc = 'ROWS';

-- Number of tables
DECLARE @TableCount INT;
SELECT @TableCount = COUNT(*) 
FROM information_schema.tables 
WHERE table_type = 'BASE TABLE';

-- Number of columns across all tables
DECLARE @ColumnCount INT;
SELECT @ColumnCount = COUNT(*) 
FROM information_schema.columns c
JOIN information_schema.tables t
ON t.table_name = c.table_name AND t.table_schema = c.table_schema
WHERE t.table_type = 'BASE TABLE';

-- Output results
SELECT 
    @DatabaseSize AS 'Database Size',
    @TableCount AS 'Table Count',
    @ColumnCount AS 'Column Count';
