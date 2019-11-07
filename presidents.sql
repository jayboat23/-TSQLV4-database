Drop table if exists dbo.Presidents;

Create table dbo.Presidents(
[Presidents] text,
[Took office] text,
[Left office] text,
[Party] text,
[House State] text,
)
Bulk insert dbo.Presidents
From 'C:\Users\DaGriot\Desktop\c#scripts\PresidentsShort.csv'
with
(
DATAFILETYPE = 'char',
FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n');
------------------------
Delete from dbo.Presidents
where Presidents like 'President';

SELECT * FROM dbo.Presidents

ALTER table dbo.Presidents
ADD presidentid int identity(1,1);

ALTER table dbo.Presidents
DROP Column presidentid;

