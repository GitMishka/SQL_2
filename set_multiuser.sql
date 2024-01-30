ALTER DATABASE qmmfoxw_upgrade
SET MULTI_USER;
GO

SELECT request_session_id FROM sys.dm_tran_locks 

WHERE resource_database_id = DB_ID('qmmfoxw_upgrade') 

kill 64

RESTORE DATABASE qmmfoxw_upgrade WITH RECOVERY
