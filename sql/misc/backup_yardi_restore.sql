USE [master];

DECLARE @kill varchar(8000) = '';  
SELECT @kill = @kill + 'kill ' + CONVERT(varchar(5), session_id) + ';'  
FROM sys.dm_exec_sessions
WHERE database_id  = db_id('qmmfoxw_upgrade')

EXEC(@kill);

RESTORE DATABASE qmmfoxw_upgrade
FROM DISK = 'C:\Users\Administrator\Desktop\pak-files\unpack\today.bak0', 
     DISK = 'C:\Users\Administrator\Desktop\pak-files\unpack\today.bak1', 
     DISK = 'C:\Users\Administrator\Desktop\pak-files\unpack\today.bak2', 
     DISK = 'C:\Users\Administrator\Desktop\pak-files\unpack\today.bak3', 
     DISK = 'C:\Users\Administrator\Desktop\pak-files\unpack\today.bak4', 
     DISK = 'C:\Users\Administrator\Desktop\pak-files\unpack\today.bak5', 
     DISK = 'C:\Users\Administrator\Desktop\pak-files\unpack\today.bak6', 
     DISK = 'C:\Users\Administrator\Desktop\pak-files\unpack\today.bak7', 
     DISK = 'C:\Users\Administrator\Desktop\pak-files\unpack\today.bak8', 
     DISK = 'C:\Users\Administrator\Desktop\pak-files\unpack\today.bak9', 
     DISK = 'C:\Users\Administrator\Desktop\pak-files\unpack\today.bak10', 
     DISK = 'C:\Users\Administrator\Desktop\pak-files\unpack\today.bak11', 
     DISK = 'C:\Users\Administrator\Desktop\pak-files\unpack\today.bak12', 
     DISK = 'C:\Users\Administrator\Desktop\pak-files\unpack\today.bak13', 
     DISK = 'C:\Users\Administrator\Desktop\pak-files\unpack\today.bak14', 
     DISK = 'C:\Users\Administrator\Desktop\pak-files\unpack\today.bak15', 
     DISK = 'C:\Users\Administrator\Desktop\pak-files\unpack\today.bak16'
WITH 
    MOVE 'yardi_blank_Data' TO 'C:\Users\Administrator\Desktop\pak-files\Logs\qmmfoxw_upgrade.mdf', 
    MOVE 'yardi_blank_Log' TO 'C:\Users\Administrator\Desktop\pak-files\Logs\qmmfoxw_upgrade_Log.ldf', 
    REPLACE;