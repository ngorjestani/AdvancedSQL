-- let's switch the employee pay history table to be a little bit more of 
-- a 'normal' setup for a table
-- typically we have two keys for a composite key,
--or we have an artificial primary key
Select * from HumanResources.EmployeePayHistory

-- currently the key is both BusinessEntityID and RateChangedDate
ALTER TABLE [HumanResources].[EmployeePayHistory] ADD  CONSTRAINT [PK_EmployeePayHistory_BusinessEntityID_RateChangeDate] PRIMARY KEY CLUSTERED 
(
	[BusinessEntityID] ASC,
	[RateChangeDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

-- setup the table to have a new primary key
Alter table HumanResources.EmployeePayHistory
Add EmployeePayHistoryID int identity(1,1)

Alter table HumanResources.EmployeePayHistory
Drop constraint PK_EmployeePayHistory_BusinessEntityID_RateChangeDate

-- the table is now stored as a heap
-- index ID 0 for each table is how the table itself is stored
Select object_name(object_id), *
from sys.indexes
where object_id = Object_ID('HumanResources.EmployeePayHistory')

-- now add a new primary key constraint,
-- make it nonclustered since its an artificial key
-- and that doesn't really help with performance
-- we'll make the clustered index more useful
Alter table HumanResources.EmployeePayHistory
Add constraint pk_EmployeePayHistory
	primary key nonclustered (EmployeePayHistoryID)

-- now add a more useful clustered index that will help with queries
create unique clustered index 
	IX_EmployeePayHistory_BusinessEntityID_RateChangedDate
	on HumanResources.EmployeePayHistory(BusinessEntityID, RateChangeDate)

-- create a nonclustered index on city and postal code
-- first by city, then postal code
Create index IX_Address_City_PostalCode
on Person.Address (City, PostalCode)

-- here's a query that SHOULD use our index, let's see if it did
-- turn on the execution plan with ctrl + M or the buttons to turn it on
-- This query does use our index
Select City, PostalCode 
From Person.Address a
where a.City = 'Houston'

-- still used our index; it was faster
Select * 
from Person.Address a 
where a.city = 'Houston'

-- The table's clustered index (in this case the primary key) 
-- is included in the index by default
-- we can prove this since the execution plan shows no key lookups,
-- which are needed when we need data that's not in our index
Select AddressID,
City, PostalCode 
From Person.Address a
where a.City = 'Houston'

--drop the index and re-create it with an include statement
Drop index IX_Address_City_PostalCode
on Person.Address 
Go
-- also include the address lines
Create index IX_Address_City_PostalCode
on Person.Address (City, PostalCode)
include(AddressLine1, AddressLine2)

Select AddressID,
City, PostalCode,
AddressLine1, AddressLine2
From Person.Address a
where a.City = 'Houston'

--Unique indexes
-- in practice work just like unique constraints, but aren't quite the same
-- when you add a unique constraint you get a unique index
-- when you add a unique index you do not get a unique constraint

-- add a unique index to AddressType for the name
Create unique nonclustered index IX_AddressType_Name
on Person.AddressType(Name)

-- when we violate a unique index we get a slightly different error than a unique constraint
Select * from Person.AddressType

Insert into Person.AddressType 
Values ('Home', newID(), GetDate())

-- here's the error
/*
Msg 2601, Level 14, State 1, Line 94
Cannot insert duplicate key row in object 'Person.AddressType' with unique index 'AK_AddressType_Name'. The duplicate key value is (Home).
*/

drop index IX_AddressType_Name
on Person.AddressType

Alter table Person.AddressType
Add constraint uk_AddressType_Name Unique(Name)

-- try again on the constraint
Insert into Person.AddressType 
Values ('Home', newID(), GetDate())

-- same error
/*
Msg 2601, Level 14, State 1, Line 110
Cannot insert duplicate key row in object 'Person.AddressType' with unique index 'AK_AddressType_Name'. The duplicate key value is (Home).

*/

-- covering indexes
-- Assume this query runs a lot
Select soh.SalesOrderID, soh.SalesOrderNumber, soh.OrderDate, soh.ShipDate 
From Sales.SalesOrderHeader soh
where OnlineOrderFlag = 1 

/* 
Here's the index the execution plan suggests

CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>]
ON [Sales].[SalesOrderHeader] ([OnlineOrderFlag])
INCLUDE ([OrderDate],[ShipDate],[SalesOrderNumber])

It's a good idea to review the existing indexes to make sure we don't already
have something really similar before we create it

In this case we don't, so let's create this

*/

CREATE NONCLUSTERED INDEX IX_SalesOrderHeader_OnlineOrderFlag
ON [Sales].[SalesOrderHeader] ([OnlineOrderFlag])
INCLUDE ([OrderDate],[ShipDate],[SalesOrderNumber])

-- rerun the query, make sure it uses the index 
Select soh.SalesOrderID, soh.SalesOrderNumber, soh.OrderDate, soh.ShipDate 
From Sales.SalesOrderHeader soh
where OnlineOrderFlag = 1 

go
-- Filtered index example
-- scenario: Adventure works monitors unshipped orders frequently
-- add a filtered index to make unshipped order return quickly
Create index IX_SalesOrderHeader_SalesOrderNumber_Null_ShipDates
on Sales.SalesOrderHeader (SalesOrderNumber)
include (OrderDate, customerID)
where ShipDate is null

-------------------
-- Columnstore indexes
-------------------
Select * from HumanResources.Employee

-- create a columnstore index on the SalariedFlag in the Employee table
-- there are only 2 values, so we will get high compression on the column
Create columnstore index ix_Employee_SalariedFlag
on HumanResources.Employee(SalariedFlag)

----------------------
-- Materialized Views
----------------------

-- scenario: Adventureworks is trying to track overdue orders
-- and determine why they were overdue
Go
Create view OrderCompletions as
Select soh.SalesOrderID, soh.OrderDate,
soh.DueDate, soh.ShipDate,
DateDiff(day, soh.DueDate, soh.ShipDate) as DaysOverdue
From Sales.SalesOrderHeader soh
Go
-- attempt to create an index on this view
-- can't do this, the view isn't schemabound. 
Create index IX_OrderCompletions_DaysOverdue
on OrderCompletions(DaysOverdue)

-- so let's fix this
Go
Create or alter view OrderCompletions 
with schemabinding 
as
Select soh.SalesOrderID, soh.OrderDate,
soh.DueDate, soh.ShipDate,
DateDiff(day, soh.DueDate, soh.ShipDate) as DaysOverdue
From Sales.SalesOrderHeader soh
Go

-- now try again
-- still nope -  no unique clustered index. so let's add one
Create index IX_OrderCompletions_DaysOverdue
on OrderCompletions(DaysOverdue)

-- so let's add one. SalesOrderID is unique, so that will be our clustered index column
Create unique clustered index IX_OrderCompletions_SalesOrderID
on OrderCompletions(SalesOrderID)

-- now create the nonclustered index
Create index IX_OrderCompletions_DaysOverdue
on OrderCompletions(DaysOverdue)

-- test out the index
Select SalesOrderID, DaysOverdue
from OrderCompletions
where DaysOverdue > 0

-- index actually didn't get used... Like we said, it's an art not a science
-- but this is how we would create an index on a 'calculated' field








