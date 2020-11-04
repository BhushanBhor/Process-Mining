USE BPI_Challenge_Abia

-- TO HANDLE NULL VALUES AND CHANGE DATATYPES OF COLUMNS

UPDATE BPI_Challenge_V2
SET ItemArea = 'NONE'
WHERE ItemArea = '';

UPDATE BPI_Challenge_V2
SET ItemAreaDesc = 'NONE'
WHERE ItemAreaDesc = '';

UPDATE BPI_Challenge_V2
SET ItemClass = 'NONE'
WHERE ItemClass = '';


ALTER TABLE BPI_Challenge_V2
ALTER COLUMN InvoiceAfterGRValue bit NOT NULL;

ALTER TABLE BPI_Challenge_V2
ALTER COLUMN ThreeWayMatchValue bit NOT NULL;

ALTER TABLE BPI_Challenge_V2
ALTER COLUMN EventID bigint NOT NULL;

ALTER TABLE BPI_Challenge_V2
ALTER COLUMN PODocID bigint NOT NULL;

ALTER TABLE BPI_Challenge_V2
ALTER COLUMN EventCumNetWoth float NOT NULL;

ALTER TABLE BPI_Challenge_V2
ALTER COLUMN EventCumNetWoth int NOT NULL;

ALTER TABLE BPI_Challenge_V2
ALTER COLUMN ItemID Int NOT NULL;

ALTER TABLE BPI_Challenge_V2
ALTER COLUMN Date Date NOT NULL;

ALTER TABLE BPI_Challenge_V2
ALTER COLUMN Time time NOT NULL;


-- TO CREATE DIMENSION TABLES


Select distinct EventUser
into Dim_EventUser
from BPI_Challenge_V2
WHERE EventUser IS NOT NULL;

Alter table Dim_EventUser
ADD EventUser_ID Int IDENTITY(1,1) PRIMARY KEY;




Select distinct Purchaser
into Dim_Purchaser
from BPI_Challenge_V2
WHERE Purchaser IS NOT NULL;

Alter table Dim_Purchaser
ADD Purchaser_ID Int IDENTITY(1,1) PRIMARY KEY;





Select distinct ThreeWayMatch, ThreeWayMatchValue
into Dim_ThreeWayMatch
from BPI_Challenge_V2
WHERE ThreeWayMatch IS NOT NULL AND ThreeWayMatchValue IS NOT NULL;

Alter table Dim_ThreeWayMatch
ADD CONSTRAINT PK_ThreeWayMatch PRIMARY KEY (ThreeWayMatchValue);




Select distinct ItemID, ItemType, ItemPOProcess
into Dim_Item
from BPI_Challenge_V2
WHERE (ItemID IS NOT NULL) AND (ItemType IS NOT NULL) AND (ItemPOProcess IS NOT NULL);

Alter table Dim_Item
ADD Item_ID Int IDENTITY(1,1) PRIMARY KEY;







Select distinct EventType
into Dim_EventType
from BPI_Challenge_V2
WHERE EventType IS NOT NULL;

Alter table Dim_EventType
ADD EventType_ID Int IDENTITY(1,1) PRIMARY KEY;






Select distinct InvoiceAfterGR, InvoiceAfterGRValue
into Dim_InvoiceAfterGR
from BPI_Challenge_V2
WHERE (InvoiceAfterGRValue IS NOT NULL) AND (InvoiceAfterGRValue IS NOT NULL);

Alter table Dim_InvoiceAfterGR
ADD CONSTRAINT PK_InvoiceAfterGR PRIMARY KEY (InvoiceAfterGRValue);





Select distinct Vendor, VendorReceivedPO
into Dim_Vendor
from BPI_Challenge_V2
WHERE (Vendor IS NOT NULL) AND (VendorReceivedPO IS NOT NULL);

Alter table Dim_Vendor
ADD Vendor_ID Int IDENTITY(1,1) PRIMARY KEY;




Select distinct POType, PODocID
into Dim_PurchaseOrder
from BPI_Challenge_V2
WHERE (PODocID IS NOT NULL) AND (POType IS NOT NULL);

Alter table Dim_PurchaseOrder
ADD PO_ID Int IDENTITY(1,1) PRIMARY KEY;




Select distinct ItemArea, ItemAreaDesc, ItemClass
into Dim_Spend
from BPI_Challenge_V2
WHERE ItemArea IS NOT NULL AND ItemAreaDesc IS NOT NULL AND ItemClass IS NOT NULL;

Alter table Dim_Spend
ADD Spend_ID Int IDENTITY(1,1) PRIMARY KEY;






-- TO CREATE DATE DIMENSION TABLE

CREATE TABLE [dbo].[Dim_Date](
	[DateKey] [int] NULL,
	[Date] [date] NULL,
	[Year No] [int] NULL,
	[Quarter Year No] [varchar](100) NULL,
	[Quarter Year Desc] [varchar](100) NULL,
	[Month Year No] [int] NULL,
	[Month Year Desc] [varchar](100) NULL,
	[Week Year No] [varchar](100) NULL,
	[Week Year Desc] [varchar](100) NULL,
	[Day of Month] [int] NULL,
	[Day Name Abbr] [varchar](100) NULL,
	[Day Name] [varchar](100) NULL,
	[Week Details] [varchar](100) NULL,
	[Day Name Order] [int] NULL
) 

--------------------------------------------------------------------------------------------------------------------------------


create Procedure [dbo].[DimdateSP]   
@StartDate Date ,   ------------------------MM-DD-YYYY    
@EndDate Date	----------------------------MM-DD-YYYY

--Example: Data from 01-jan-2014 to 31-dec-2014 
--@StartDate='01-01-2014' and @EndDate='12-31-2014'

As   
DECLARE @CurrDate DateTime   
SET @CurrDate= @StartDate
DECLARE @FinalYear Datetime   
SET @FinalYear = @EndDate

DECLARE @DateKey int
DECLARE @years VARCHAR(100)
DECLARE @QuarterNo VARCHAR(100)
DECLARE @QuarterDesc VARCHAR(100)
DECLARE @MonthNo INT
DECLARE @MonthDesc VARCHAR(100)
DECLARE @WeekNo VARCHAR(100)
DECLARE @WeekDesc VARCHAR(100)
DECLARE @FirstdayofWeek VARCHAR(100)
DECLARE @LastdayofWeek VARCHAR(100)
DECLARE @MonthDay INT
DECLARE @WeekDay VARCHAR(100)
DECLARE @WeekDetails VARCHAR(100)
DECLARE @weekfirstdate Date DECLARE @weekLastdate Date

declare @dim table(
[DateKey] [int] NULL,
	[Date] [datetime] NULL,
	[Year No] [int] NULL,
	[Quarter Year No] [varchar](100) NULL,
	[Quarter Year Desc] [varchar](100) NULL,
	[Month Year No] [int] NULL,
	[Month Year Desc] [varchar](100) NULL,
	[Week Year No] [varchar](100) NULL,
	[Week Year Desc] [varchar](100) NULL,
	[Day of Month] [int] NULL,
	[Day Name] [varchar](100) NULL,
	[Week Details] [varchar](100) NULL,
	[Day Name Order] [int] NULL,
	[Week First Date] Date null,
	[Week Last Date] Date null
	)

SET @DateKey=CONVERT(varchar, @CurrDate, 112)
set @years =DATEPART(YYYY,@CurrDate)  
SET @QuarterNo=DATEPART(Q,@CurrDate)
SET @MonthNo=CONVERT(varchar(6), @CurrDate, 112)
SET @MonthDesc=cast((DATENAME(month,@CurrDate))as varchar(3))+'-'+RIGHT(DATENAME(YEAR, @CurrDate),4)
SET @WeekNo=DatePart(week, @CurrDate)
SET @FirstdayofWeek=DATEPART(D,DATEADD(wk, DATEDIFF(wk, 7, @CurrDate), 6))

SET @LastdayofWeek=DATEPART(D,DATEADD(wk, DATEDIFF(wk, 6, @CurrDate), 6 + 6))
SET @WeekDesc = cast((DATENAME(month,@CurrDate))as varchar(3))+'-'+RIGHT(DATENAME(YEAR, @CurrDate),4)
SET @MonthDay =DATEPART(d,@CurrDate) 
SET @WeekDay = cast(datename(DW,DATEPART(DW,@CurrDate-2))as varchar(3))  
SET @weekfirstdate=convert(date,dateadd(week, datediff(week, 0, @CurrDate), -1))
SET @weekLastdate=convert(date,DATEADD(wk, DATEDIFF(wk, 6, @CurrDate), 6 + 6))


WHILE YEAR(@CurrDate)<= YEAR(@FinalYear)
BEGIN   
IF((@WeekDay='Sat') or(@WeekDay='Sun'))   
SET @WeekDetails='Week Ends' 
ELSE   
SET @WeekDetails='Week Days'  
  
If DATEPART(Q,@CurrDate) = 1  
begin  
set @QuarterDesc='Jan-Mar'+' '+RIGHT(DATENAME(YEAR, @CurrDate),4)
end  
If DATEPART(Q,@CurrDate) = 2  
begin  
set @QuarterDesc='Apr-Jun'+' '+RIGHT(DATENAME(YEAR, @CurrDate),4)
end  
If DATEPART(Q,@CurrDate) = 3  
begin  
set @QuarterDesc='Jul-Sep' +' '+RIGHT(DATENAME(YEAR, @CurrDate),4)
end  
If DATEPART(Q,@CurrDate) = 4  
begin  
set @QuarterDesc='Oct-Dec'+' '+RIGHT(DATENAME(YEAR, @CurrDate),4)
end  

	IF MONTH(@weekfirstdate)>MONTH(@weekLastdate) and Year(@weekfirstdate)=Year(@CurrDate) 
	BEGIN
			if day(@weekfirstdate)>day(@weekLastdate)
			begin
			set @LastdayofWeek=datepart(d,CONVERT(date,DATEADD(dd,-(DAY(DATEADD(mm,1,@weekfirstdate))),DATEADD(mm,1,@weekfirstdate)),101))
			end
			else
			set @FirstdayofWeek=datepart(d,CONVERT(date,DATEADD(dd,-(DAY(@weekLastdate)-1),@weekLastdate),101))
	END
	else if MONTH(@weekfirstdate)>MONTH(@weekLastdate) and Year(@weekfirstdate)<Year(@CurrDate)
	BEGIN
			if day(@weekfirstdate)>day(@weekLastdate)
			begin
			set @FirstdayofWeek=datepart(d,CONVERT(date,DATEADD(dd,-(DAY(@weekLastdate)-1),@weekLastdate),101))
			end
	END
	else if Year(@weekfirstdate)=Year(@weekLastdate) and Month(@weekfirstdate)<Month(@weekLastdate) and Month(@CurrDate)=month(@weekLastdate)
	begin
	set @FirstdayofWeek=datepart(d,CONVERT(date,DATEADD(dd,-(DAY(@weekLastdate)-1),@weekLastdate),101))
	end
	else if Year(@weekfirstdate)=Year(@weekLastdate) and Month(@weekfirstdate)<Month(@weekLastdate) and Month(@CurrDate)<month(@weekLastdate)
	begin
	set @LastdayofWeek=datepart(d,CONVERT(date,DATEADD(dd,-(DAY(DATEADD(mm,1,@weekfirstdate))),DATEADD(mm,1,@weekfirstdate)),101))
	end




IF (@CurrDate>@FinalYear)  
BEGIN   
BREAK   
END 

INSERT into @dim 
Values(@DateKey,@CurrDate,@years,@years+''+@QuarterNo,@QuarterDesc,@MonthNo,@MonthDesc,@years+''+@WeekNo,
'WK ('+@FirstdayofWeek+'-'+@LastdayofWeek+')/'+@WeekDesc,@MonthDay,@WeekDay,@WeekDetails,'',@weekfirstdate,@weekLastdate)   
 
   
SET @CurrDate = DATEADD(d,1,@CurrDate)   
SET @DateKey=CONVERT(varchar, @CurrDate, 112)
set @years =DATEPART(YYYY,@CurrDate)  
SET @QuarterNo=DATEPART(Q,@CurrDate)
SET @MonthNo=CONVERT(varchar(6), @CurrDate, 112)
SET @MonthDesc=cast((DATENAME(month,@CurrDate))as varchar(3))+'-'+RIGHT(DATENAME(YEAR, @CurrDate),4)
SET @WeekNo=DatePart(week, @CurrDate)
SET @FirstdayofWeek=DATEPART(D,DATEADD(wk, DATEDIFF(wk, 7, @CurrDate), 6))

SET @LastdayofWeek=DATEPART(D,DATEADD(wk, DATEDIFF(wk, 6, @CurrDate), 6 + 6))
SET @WeekDesc = cast((DATENAME(month,@CurrDate))as varchar(3))+'-'+RIGHT(DATENAME(YEAR, @CurrDate),4)
SET @MonthDay =DATEPART(d,@CurrDate) 
SET @WeekDay = cast(datename(DW,DATEPART(DW,@CurrDate-2))as varchar(3))  
SET @weekfirstdate=convert(date,dateadd(week, datediff(week, 0, @CurrDate), -1))
SET @weekLastdate=convert(date,DATEADD(wk, DATEDIFF(wk, 6, @CurrDate), 6 + 6))

	IF MONTH(@weekfirstdate)>MONTH(@weekLastdate) and Year(@weekfirstdate)=Year(@CurrDate) 
	BEGIN
			if day(@weekfirstdate)>day(@weekLastdate)
			begin
			set @LastdayofWeek=datepart(d,CONVERT(date,DATEADD(dd,-(DAY(DATEADD(mm,1,@weekfirstdate))),DATEADD(mm,1,@weekfirstdate)),101))
			end
			else
			set @FirstdayofWeek=datepart(d,CONVERT(date,DATEADD(dd,-(DAY(@weekLastdate)-1),@weekLastdate),101))
	END
	else if MONTH(@weekfirstdate)>MONTH(@weekLastdate) and Year(@weekfirstdate)<Year(@CurrDate)
	BEGIN
			if day(@weekfirstdate)>day(@weekLastdate)
			begin
			set @FirstdayofWeek=datepart(d,CONVERT(date,DATEADD(dd,-(DAY(@weekLastdate)-1),@weekLastdate),101))
			end
	END
	else if Year(@weekfirstdate)=Year(@weekLastdate) and Month(@weekfirstdate)<Month(@weekLastdate) and Month(@CurrDate)=month(@weekLastdate)
	begin
	set @FirstdayofWeek=datepart(d,CONVERT(date,DATEADD(dd,-(DAY(@weekLastdate)-1),@weekLastdate),101))
	end
	else if Year(@weekfirstdate)=Year(@weekLastdate) and Month(@weekfirstdate)<Month(@weekLastdate) and Month(@CurrDate)<month(@weekLastdate)
	begin
	set @LastdayofWeek=datepart(d,CONVERT(date,DATEADD(dd,-(DAY(DATEADD(mm,1,@weekfirstdate))),DATEADD(mm,1,@weekfirstdate)),101))
	end

UPDATE @dim SET [Day Name Order]=1 WHERE [Day Name]='Mon'
UPDATE @dim SET [Day Name Order]=2 WHERE [Day Name]='Tue'
UPDATE @dim SET [Day Name Order]=3 WHERE [Day Name]='Wed'
UPDATE @dim SET [Day Name Order]=4 WHERE [Day Name]='Thu'
UPDATE @dim SET [Day Name Order]=5 WHERE [Day Name]='Fri'
UPDATE @dim SET [Day Name Order]=6 WHERE [Day Name]='Sat'
UPDATE @dim SET [Day Name Order]=7 WHERE [Day Name]='Sun'


END 
INSERT INTO Dim_Date
([DateKey],[Date],[Year No],[Quarter Year No],[Quarter Year Desc],[Month Year No],[Month Year Desc],[Week Year No]
      ,[Week Year Desc],[Day of Month],[Day Name],[Week Details],[Day Name Order])
select [DateKey],[Date],[Year No],[Quarter Year No],[Quarter Year Desc],[Month Year No],[Month Year Desc],[Week Year No]
      ,[Week Year Desc],[Day of Month],[Day Name],[Week Details],[Day Name Order] from @dim

-- EXECUTE THE PROCEDURE TO INSERT ENTRIES IN DATE TABLE





-- TO CREATE TIME DIMENSION TABLE

-- Create a new table
CREATE TABLE [dbo].[DimTime](
    [TimeId] [int] IDENTITY(1,1) NOT NULL Primary Key,
    [Time] [time](0) NULL,
    [Hour] [int] NULL,
    [Minute] [int] NULL,
    [MilitaryHour] int NOT null,
    [MilitaryMinute] int NOT null,
    [AMPM] [varchar](2) NOT NULL,
    [DayPartEN] [varchar](10) NULL,
    [DayPartNL] [varchar](10) NULL,
    [HourFromTo12] [varchar](17) NULL,
    [HourFromTo24] [varchar](13) NULL,
    [Notation12] [varchar](10) NULL,
    [Notation24] [varchar](10) NULL
);
GO
 
-- Create a time and a counter variable for the loop
DECLARE @Time as time;
SET @Time = '0:00';
 
DECLARE @counter as int;
SET @counter = 0;
 
 
-- Two variables to store the day part for two languages
DECLARE @daypartEN as varchar(20);
set @daypartEN = '';
 
DECLARE @daypartNL as varchar(20);
SET @daypartNL = '';
 
 
-- Loop 1440 times (24hours * 60minutes)
WHILE @counter < 1440
BEGIN
 
    -- Determine datepart
    SELECT  @daypartEN = CASE
                         WHEN (@Time >= '0:00' and @Time < '6:00') THEN 'Night'
                         WHEN (@Time >= '6:00' and @Time < '12:00') THEN 'Morning'
                         WHEN (@Time >= '12:00' and @Time < '18:00') THEN 'Afternoon'
                         ELSE 'Evening'
                         END
    ,       @daypartNL = CASE
                         WHEN (@Time >= '0:00' and @Time < '6:00') THEN 'Nacht'
                         WHEN (@Time >= '6:00' and @Time < '12:00') THEN 'Ochtend'
                         WHEN (@Time >= '12:00' and @Time < '18:00') THEN 'Middag'
                         ELSE 'Avond'
                         END;
 
    INSERT INTO DimTime ([Time]
                       , [Hour]
                       , [Minute]
                       , [MilitaryHour]
                       , [MilitaryMinute]
                       , [AMPM]
                       , [DayPartEN]
                       , [DayPartNL]
                       , [HourFromTo12]
                       , [HourFromTo24]
                       , [Notation12]
                       , [Notation24])
                VALUES (@Time
                       , DATEPART(Hour, @Time) + 1
                       , DATEPART(Minute, @Time) + 1
                       , DATEPART(Hour, @Time)
                       , DATEPART(Minute, @Time)
                       , CASE WHEN (DATEPART(Hour, @Time) < 12) THEN 'AM' ELSE 'PM' END
                       , @daypartEN
                       , @daypartNL
                       , CONVERT(varchar(10), DATEADD(Minute, -DATEPART(Minute,@Time), @Time),100)  + ' - ' + CONVERT(varchar(10), DATEADD(Hour, 1, DATEADD(Minute, -DATEPART(Minute,@Time), @Time)),100)
                       , CAST(DATEADD(Minute, -DATEPART(Minute,@Time), @Time) as varchar(5)) + ' - ' + CAST(DATEADD(Hour, 1, DATEADD(Minute, -DATEPART(Minute,@Time), @Time)) as varchar(5))
                       , CONVERT(varchar(10), @Time,100)
                       , CAST(@Time as varchar(5))
                       );
 
    -- Raise time with one minute
    SET @Time = DATEADD(minute, 1, @Time);
 
    -- Raise counter by one
    set @counter = @counter + 1;
END




-- TO CREATE FACT TABLE

Select Distinct BPI_Challenge_V2.EventID ,
Dim_PurchaseOrder.PO_ID,
Dim_EventType.EventType_ID,
Dim_Item.Item_ID ,
Dim_Vendor.Vendor_ID ,
Dim_EventUser.EventUser_ID ,
Dim_Purchaser.Purchaser_ID ,
Dim_InvoiceAfterGR.InvoiceAfterGRValue,
Dim_ThreeWayMatch.ThreeWayMatchValue ,
Dim_Spend.Spend_ID ,
BPI_Challenge_V2.Date ,
DimTime.TimeId ,
BPI_Challenge_V2.EventCumNetWoth 
INTO Fact_Event --1595923
FROM BPI_Challenge_V2
LEFT JOIN Dim_EventType ON BPI_Challenge_V2.EventType = Dim_EventType.EventType
LEFT JOIN Dim_EventUser ON BPI_Challenge_V2.EventUser = Dim_EventUser.EventUser
LEFT JOIN Dim_InvoiceAfterGR ON BPI_Challenge_V2.InvoiceAfterGR = Dim_InvoiceAfterGR.InvoiceAfterGR AND BPI_Challenge_V2.InvoiceAfterGRValue = Dim_InvoiceAfterGR.InvoiceAfterGRValue
LEFT JOIN Dim_Item ON BPI_Challenge_V2.ItemID = Dim_Item.ItemID AND BPI_Challenge_V2.ItemType = Dim_Item.ItemType AND BPI_Challenge_V2.ItemPOProcess = Dim_Item.ItemPOProcess
LEFT JOIN Dim_PurchaseOrder ON BPI_Challenge_V2.POType = Dim_PurchaseOrder.POType AND BPI_Challenge_V2.PODocID = Dim_PurchaseOrder.PODocID
LEFT JOIN Dim_Purchaser ON BPI_Challenge_V2.Purchaser = Dim_Purchaser.Purchaser
LEFT JOIN Dim_Spend ON BPI_Challenge_V2.ItemArea = Dim_Spend.ItemArea AND BPI_Challenge_V2.ItemAreaDesc = Dim_Spend.ItemAreaDesc AND BPI_Challenge_V2.ItemClass = Dim_Spend.ItemClass
LEFT JOIN Dim_ThreeWayMatch ON BPI_Challenge_V2.ThreeWayMatch = Dim_ThreeWayMatch.ThreeWayMatch AND BPI_Challenge_V2.ThreeWayMatchValue = Dim_ThreeWayMatch.ThreeWayMatchValue
LEFT JOIN Dim_Vendor ON BPI_Challenge_V2.Vendor = Dim_Vendor.Vendor AND BPI_Challenge_V2.VendorReceivedPO = Dim_Vendor.VendorReceivedPO
LEFT JOIN Dim_Date ON BPI_Challenge_V2.Date = Dim_Date.Date
LEFT JOIN DimTime ON BPI_Challenge_V2.Time = DimTime.Time;

Alter table Fact_Event
ADD Event_ID Int IDENTITY(1,1) PRIMARY KEY;