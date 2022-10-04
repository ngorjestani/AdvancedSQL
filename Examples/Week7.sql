-- Scalar functions
-- create a currency converter based on a given date and a to/from currency
-- setup the variables
Declare @date       date
Declare @ToCurrency char(3), @FromCurrency char(3)
Declare @Amt        money
Select @date = '7/1/2018', @FromCurrency = 'AUD', @ToCurrency = 'USD', @Amt = 100
-- test out the calculations the way they should be with the to/from currencies
Select @amt * AverageRate as ConvertedAmt
from Sales.CurrencyRate
Where CurrencyRateDate = @date
  and FromCurrencyCode = @FromCurrency
  and ToCurrencyCode = @ToCurrency
-- if it doesn't have it for the from and to currencies, see if we have it the other way around
Select @amt / AverageRate as ConvertedAmt
from Sales.CurrencyRate
Where CurrencyRateDate = @date
  and ToCurrencyCode = @FromCurrency
  and FromCurrencyCode = @ToCurrency
go
-- now start to set it up like a function
-- setup the variables
Declare @date       date
Declare @ToCurrency char(3), @FromCurrency char(3)
Declare @Amt        money
Select @date = '7/2/2018', @FromCurrency = 'AUD', @ToCurrency = 'USD', @Amt = 100
-- create one last variable that will keep the data and return it
Declare @convertedAmt money
-- test out the calculations the way they should be with the to/from currencies
Select @convertedAmt = @amt * AverageRate
from Sales.CurrencyRate
Where CurrencyRateDate = @date
  and FromCurrencyCode = @FromCurrency
  and ToCurrencyCode = @ToCurrency
-- look at the variable
Select @convertedAmt
-- if it doesn't have it for the from and to currencies, see if we have it the other way around
Select @convertedAmt = @amt / AverageRate
from Sales.CurrencyRate
Where CurrencyRateDate = @date
  and ToCurrencyCode = @FromCurrency
  and FromCurrencyCode = @ToCurrency
-- look at the variable
Select @convertedAmt
Go
-- now actually create the function
/***************************************
* CurrencyConversion
* Author: Nkowalchuk
* created: 9/27/2022
*
* Parameters: Date - date of currency conversion
* ToCurrency, FromCurrency - The currency codes we want to convert
to/from
* Amount - the amount we want to calculate the conversion of
*
* This function attempts to convert the amount into the requested currency based on
a particular date and the to/from currencies
*
* Change log
* --------------------------------------
*
*
****************************************/
Create or alter function CurrencyConverter(@date date, @ToCurrency char(3), @FromCurrency char(3), @Amt money)
    Returns money -- the data type of the variable we will be returning
As
Begin
    Declare @convertedAmt money
-- test out the calculations the way they should be with the to/from currencies
    Select @convertedAmt = @amt * AverageRate
    from Sales.CurrencyRate
    Where CurrencyRateDate = @date
      and FromCurrencyCode = @FromCurrency
      and ToCurrencyCode = @ToCurrency
    If (@convertedAmt is not null)
        Return @ConvertedAmt
-- if it doesn't have it for the from and to currencies, see if we have it the other way around
    Select @convertedAmt = @amt / AverageRate
    from Sales.CurrencyRate
    Where CurrencyRateDate = @date
      and ToCurrencyCode = @FromCurrency
      and FromCurrencyCode = @ToCurrency
-- either way, if it has a value or not, return the variable
    Return @ConvertedAmt
End
Go
-- get the results
Select dbo.currencyConverter('7/2/2020', 'USD', 'AUD', 500)
-- in a more practical application...
Select top 50 cr.FromCurrencyCode,
              cr.ToCurrencyCode,
              soh.SubTotal,
              dbo.CurrencyConverter(soh.orderDate, ToCurrencyCode, FromCurrencyCode,
                                    soh.subTotal) as ConvertedAmt
from Sales.SalesOrderHeader soh
         join Sales.CurrencyRate cr
              on soh.CurrencyRateID = cr.CurrencyRateID
---------------------------------
-- Table-valued functions
---------------------------------
-- Return a particular customer's orders during a date range
Declare @CustomerID int, @StartDate date, @EndDate date
Select @CustomerID = 29825, @StartDate = '7/1/2018', @EndDate = '12/31/2018'
Select soh.SalesOrderID,
       soh.OrderDate,
       soh.ShipDate,
       soh.subtotal,
       soh.TaxAmt,
       soh.Freight,
       soh.TotalDue
from Sales.SalesOrderHeader soh
where customerID = @CustomerID
  and OrderDate >= @StartDate
  and OrderDate < DateAdd(day, 1, @EndDate)
-- get around the times - 12/31/2018 is 12AM - if we just look at the date, the orders that day won't be included
-- two methods of doing the table-valued function
-- first the simple way
go
/***************************************
* GetCustomerOrders
* Author: Nkowalchuk
* created: 9/27/2022
*
* Parameters: CustomerID - this is the customerID, not the businessEntityID
* StartDate, EndDate - Date range we want the orders from
*
* This function returns orders for the customer for the date range
*
* Change log
* --------------------------------------
*
*
****************************************/
Create function GetCustomerOrders(@CustomerID int, @StartDate date, @EndDate date)
    Returns table
        as
        Return
        Select soh.SalesOrderID,
               soh.OrderDate,
               soh.ShipDate,
               soh.subtotal,
               soh.TaxAmt,
               soh.Freight,
               soh.TotalDue
        from Sales.SalesOrderHeader soh
        where customerID = @CustomerID
          and OrderDate >= @StartDate
          and OrderDate < DateAdd(day, 1, @EndDate) -- get around the times - 12/31/2018 is 12AM - if we just look at the date, the orders that day won't be included
Go
-- this is a table-valued function (because it returns a table)
-- we access it like a table... that takes parameters
-- we can treat it like a table/view
Select *
From dbo.GetCustomerOrders(29827, '7/1/2018', '12/31/2018')
-- Now the more explicit format of the Table-valued function...
Go
drop function GetCustomerOrders
go
/***************************************
* GetCustomerOrders
* Author: Nkowalchuk
* created: 9/27/2022
*
* Parameters: CustomerID - this is the customerID, not the businessEntityID
* StartDate, EndDate - Date range we want the orders from
*
* This function returns orders for the customer for the date range
*
* Change log
* --------------------------------------
* Changed the function to define the table first
*
****************************************/
Create or alter function GetCustomerOrders(@CustomerID int, @StartDate date, @EndDate date)
    Returns @Orders table
                    (
                        SalesOrderID int,
                        OrderDate    DateTime,
                        ShipDate     DateTime,
                        Subtotal     money,
                        TaxAmt       money,
                        Freight      money,
                        TotalDue     money
                    )
as
Begin
    insert into @Orders
    Select soh.SalesOrderID,
           soh.OrderDate,
           soh.ShipDate,
           soh.subtotal,
           soh.TaxAmt,
           soh.Freight,
           soh.TotalDue
    from Sales.SalesOrderHeader soh
    where customerID = @CustomerID
      and OrderDate >= @StartDate
      and OrderDate < DateAdd(day, 1, @EndDate)
    return -- automatically returns the orders variable because we said we were going to up above
End
Go
Select *
From dbo.GetCustomerOrders(29825, '7/1/2018', '12/31/2018')
Select top 50 o.*
From Sales.Customer c
         Cross apply dbo.GetCustomerOrders(c.CustomerID, '7/1/2018', '12/31/2018') o
-- alias
--------------------------
-- Triggers
--------------------------
-- AdventureWorks wants to track changes to people's names and log them to a new name history table
-- we can use a trigger to do this
Select top 50 *
from Person.Person
-- first setup the new table that we will put the information into
Create Table Person.NameHistory
(
    BusinessEntityID int,
    NameChangedDate  datetime,
    Title            nvarchar(8),
    FirstName        nvarchar(50),
    MiddleName       nvarchar(50),
    LastName         nvarchar(50),
    Suffix           nvarchar(10),
    Constraint pk_NameHistory primary key (BusinessEntityID, NameChangedDate)
)
-- when someone's name changes, automatically put a row into the name history tablewith their old name
-- just go for creating the trigger because we really have no ability to test it ahead of time
Go
/***************************************
* tr_iu_Person on Person.Person
* Author: Nkowalchuk
* created: 9/27/2022
*
*
* This trigger fires on insert or update. It logs changes to a person's name to the
name history table.
* columns include Title, FirstName, MiddleName, LastName, and Suffix
*
* Change log
* --------------------------------------
*
****************************************/
Create trigger tr_iu_Person
    on Person.Person -- trigger for insert, update
    For insert, update
    As
Begin
    -- figure out if there was a 'change' to a column we care about
    if update(Title) or update(FirstName) or update(MiddleName) or
       update(LastName) or Update(Suffix)
        Begin
            insert into Person.NameHistory
            Select d.BusinessEntityID,
                   GetDate(),
                   d.Title,
                   d.FirstName,
                   d.MiddleName,
                   d.LastName,
                   d.Suffix
            From Deleted d -- deleted psuedo table contains the old values
        End
End
Go
-- pick an person and change something
Select *
from Person.Person
Update person.Person
set Title = 'Mr.'
where BusinessEntityID = 1
-- check to see if the trigger fired
Select *
from Person.NameHistory
-- cool it worked
-- run the same update again
Update person.Person
set Title = 'Mr.'
where BusinessEntityID = 1
-- check to see if the trigger fired
-- it still did... even though its the same as it was before the second update
Select *
from Person.NameHistory
Select *
from person.person
where BusinessEntityID = 1
Go
-- have to drop the trigger first, can't alter it.
Drop trigger Person.tr_iu_Person
Go
/***************************************
* tr_iu_Person on Person.Person
* Author: Nkowalchuk
* created: 9/27/2022
*
*
* This trigger fires on insert or update. It logs changes to a person's name to the
name history table.
* columns include Title, FirstName, MiddleName, LastName, and Suffix
*
* Change log
* --------------------------------------
* 9/28/2022 NK - Modified to only insert a row if the name is actually different
****************************************/
Create trigger tr_iu_Person
    on Person.Person -- trigger for insert, update
    For insert, update
    As
Begin
    -- figure out if there was a 'change' to a column we care about
    if update(Title) or update(FirstName) or update(MiddleName) or
       update(LastName) or Update(Suffix)
        Begin
            insert into Person.NameHistory
            Select d.BusinessEntityID,
                   GetDate(),
                   d.Title,
                   d.FirstName,
                   d.MiddleName,
                   d.LastName,
                   d.Suffix
            From Deleted d -- the old data values
                     Join inserted i -- the new data vales
                          on d.BusinessEntityID = i.BusinessEntityID
            where -- make sure one of these fields actually changed
                isnull(i.Title, '') <> isnull(d.Title, '')
               or i.FirstName <> d.FirstName
               or isnull(i.MiddleName, '') <> isnull(d.MiddleName, '')
               or i.LastName <> d.LastName
               or isnull(i.Suffix, '') <> isnull(d.Suffix, '')
        End
End
Go
-- run the same update again to see if it still fires
Update person.Person
set Title = 'Mr.'
where BusinessEntityID = 1
-- it did not put a new row in
Select *
from Person.NameHistory
-- put it back
Update person.Person
set Title = null
where BusinessEntityID = 1
-- update a column the trigger isn't checking for
Update person.Person
set EmailPromotion = 1
where BusinessEntityID = 1
-- only one "1 row affected" -> Trigger did not attempt to log anything. it still fired and checked if the column changed was one we cared about, but did nothing
-- multiple updates to a column the trigger cares about
update Person.Person
Set Title = 'Mr.'
where BusinessEntityID in (1, 3, 4)
-- the trigger fires once, but affects the same three rows
Select *
from person.NameHistory
---------------------------
-- Dynamic SQL
---------------------------
-- basic example
Declare @SQL nvarchar(200)
Select @SQL = 'Select top 50 * from Person.Person' -- query to execute
exec sp_executeSQL @SQL
-- the bad way - don't do this unless it is TIGHTLY controlled
Declare @BusinessEntityID int = 4
Declare @SQL              nvarchar(200)
Select @SQL = concat('Select * from Person.Person where businessEntityID = ',
                     @BusinessEntityID)
exec sp_executeSQL @SQL
-- parameterize it instead
Declare @BusinessEntityID int = 4
Declare @SQL              nvarchar(200)
Select @SQL = 'Select * from Person.Person where businessEntityID =
@BusinessEntityID' -- the @BusinessEntityID is a string literal - not the actual variable
exec sp_executeSQL @SQL, N'@BusinessEntityID int', @BusinessEntityID =
    @BusinessEntityID
-- better example of bad things
-- SQL Injection!
Declare @LastName varchar(100) = ' ''''; select * from humanResources.Employee'
Declare @SQL      nvarchar(200)
Select @SQL = concat('Select * from Person.Person where LastName = ', @LastName)
exec sp_executeSQL @SQL
-- parameterize it instead
Declare @LastName varchar(100) = ' ''''; select * from humanResources.Employee'
Declare @SQL      nvarchar(200)
Select @SQL = 'Select * from Person.Person where LastName =  @LastName'
exec sp_executeSQL @SQL, N'@LastName varchar(100)', @LastName = @LastName
-- Be really naughty and drop a table for Trayton ;)
Declare @LastName varchar(100) = ' ''''; Drop table Person.nameHistory'
Declare @SQL      nvarchar(200)
Select @SQL = concat('Select * from Person.Person where LastName = ', @LastName)
exec sp_executeSQL @SQL
-- its gone :(
Select *
from person.NameHistory
-- here's a real example I might want to actually do with dynamic SQL
-- A few weeks ago we imported a lot of "New Products" tables - let's go through and delete them with dynamic SQL
-- Get all the tables that start with 'NewProducts' and put them into a temp table
Select name
into #deleteMe
From sys.tables
where name like 'NewProducts%'
Select *
From #deleteMe
Declare @TableName nvarchar(100)
Declare @SQL       nvarchar(100)
While (Select count(*)
       from #DeleteMe) > 0
    Begin
        Select @TableName = (Select top 1 Name from #DeleteMe)
        Select @SQL = 'Drop table ' + @TableName
        Exec sp_executesql @SQL
        Delete from #deleteMe where name = @TableName
    End
-- all the new products tables are gone
Select name
From sys.tables
where name like 'NewProducts%'