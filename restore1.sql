Use master

GO

ALTER DATABASE qmmfoxw_upgrade SET SINGLE_USER WITH ROLLBACK IMMEDIATE

GO
RESTORE DATABASE qmmfoxw_upgrade FROM 

DISK = 'C:\Users\Administrator\Desktop\pak files\unpacked.bak0', 
DISK = 'C:\Users\Administrator\Desktop\pak files\unpacked.bak1', 
DISK = 'C:\Users\Administrator\Desktop\pak files\unpacked.bak2', 
DISK = 'C:\Users\Administrator\Desktop\pak files\unpacked.bak3', 
DISK = 'C:\Users\Administrator\Desktop\pak files\unpacked.bak4', 
DISK = 'C:\Users\Administrator\Desktop\pak files\unpacked.bak5', 
DISK = 'C:\Users\Administrator\Desktop\pak files\unpacked.bak6', 
DISK = 'C:\Users\Administrator\Desktop\pak files\unpacked.bak7', 
DISK = 'C:\Users\Administrator\Desktop\pak files\unpacked.bak8', 
DISK = 'C:\Users\Administrator\Desktop\pak files\unpacked.bak9', 
DISK = 'C:\Users\Administrator\Desktop\pak files\unpacked.bak10', 
DISK = 'C:\Users\Administrator\Desktop\pak files\unpacked.bak11', 
DISK = 'C:\Users\Administrator\Desktop\pak files\unpacked.bak12',
DISK = 'C:\Users\Administrator\Desktop\pak files\unpacked.bak13', 
DISK = 'C:\Users\Administrator\Desktop\pak files\unpacked.bak14', 
DISK = 'C:\Users\Administrator\Desktop\pak files\unpacked.bak15', 
DISK = 'C:\Users\Administrator\Desktop\pak files\unpacked.bak16'
WITH REPLACE
