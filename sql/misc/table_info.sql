SELECT TABLE_SCHEMA,
       TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME LIKE '%assessment%'
ORDER BY TABLE_SCHEMA, TABLE_NAME;

SELECT 
    t.name AS Table_Name,
    s.name AS Schema_Name,
    p.rows AS Row_Count,
    (SUM(a.total_pages) * 8) / 1024 AS Total_Size_MB,
    (SUM(a.used_pages) * 8) / 1024 AS Used_Size_MB,
    (SUM(a.data_pages) * 8) / 1024 AS Data_Size_MB
FROM 
    sys.tables t
INNER JOIN 
    sys.indexes i ON t.object_id = i.object_id
INNER JOIN 
    sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
INNER JOIN 
    sys.allocation_units a ON p.partition_id = a.container_id
INNER JOIN 
    sys.schemas s ON t.schema_id = s.schema_id
WHERE 
    t.name LIKE '%assessment%'
GROUP BY 
    t.name, s.name, p.rows
ORDER BY 
    row_count desc;