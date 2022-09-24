-- TSQL is procedural programming
-- A TSQL block is just code we write and execute
-- TSQL can also be user to create stored procedures

-- declare some variables

declare @BusinessEntityId int
set @BusinessEntityId = 430

-- return employees' most recent pay rows
select eph.BusinessEntityID, max(RateChangeDate) as MaxDate
from HumanResources.EmployeePayHistory eph
group by eph.BusinessEntityID

select eph.*
from HumanResources.EmployeePayHistory eph
         join (select eph.BusinessEntityID, max(RateChangeDate) as MaxDate
               from HumanResources.EmployeePayHistory eph
               group by eph.BusinessEntityID) x
              on eph.BusinessEntityID = x.BusinessEntityID
                  and eph.RateChangeDate = x.MaxDate

-- make it a stored procedure
go
create procedure GetCurrentPayRow
as
begin
    select eph.*
    from HumanResources.EmployeePayHistory eph
             join (select eph.BusinessEntityID, max(RateChangeDate) as MaxDate
                   from HumanResources.EmployeePayHistory eph
                   group by eph.BusinessEntityID) x
                  on eph.BusinessEntityID = x.BusinessEntityID
                      and eph.RateChangeDate = x.MaxDate
end

    exec GetCurrentPayRow

-- now add the employee name and a parameter for the employee
go

select p.LastName, p.FirstName, eph.*
from HumanResources.EmployeePayHistory eph
         join (select eph.BusinessEntityID, max(RateChangeDate) as MaxDate
               from HumanResources.EmployeePayHistory eph
               group by eph.BusinessEntityID) x
              on eph.BusinessEntityID = x.BusinessEntityID
                  and eph.RateChangeDate = x.MaxDate
         join Person.Person p
              on eph.BusinessEntityID = p.BusinessEntityID

declare @EmployeeId int
select @EmployeeId = 290 -- for testing

select p.LastName, p.FirstName, eph.*
from HumanResources.EmployeePayHistory eph
         join (select eph.BusinessEntityID, max(RateChangeDate) as MaxDate
               from HumanResources.EmployeePayHistory eph
               group by eph.BusinessEntityID) x
              on eph.BusinessEntityID = x.BusinessEntityID
                  and eph.RateChangeDate = x.MaxDate
         join Person.Person p
              on eph.BusinessEntityID = p.BusinessEntityID
where eph.BusinessEntityID = @EmployeeId

-- now alter the procedure
go

/************************
  * Author: NGorjestani
  * Create date: 9/20/2022
  *
  * Pulls an employees most recent pay row
  * Parameters:
  *     @EmployeeId: The ID of the employee to get pay row for
*************************/

alter procedure GetCurrentPayRow(@EmployeeId int) -- this is the parameter
as
begin
    select p.LastName, p.FirstName, eph.*
    from HumanResources.EmployeePayHistory eph
             join (select eph.BusinessEntityID, max(RateChangeDate) as MaxDate
                   from HumanResources.EmployeePayHistory eph
                   group by eph.BusinessEntityID) x
                  on eph.BusinessEntityID = x.BusinessEntityID
                      and eph.RateChangeDate = x.MaxDate
             join Person.Person p
                  on eph.BusinessEntityID = p.BusinessEntityID
    where eph.BusinessEntityID = @EmployeeId
end

go

exec GetCurrentPayRow 290

-- now make EmployeeId parameter optional

go

/************************
  * Author: NGorjestani
  * Create date: 9/20/2022
  *
  * Pulls an employees most recent pay row or all employees most recent pay rows
  * Parameters:
  *     @EmployeeId: The ID of the employee to get pay row for. This is optional
*************************/

alter procedure GetCurrentPayRow(@EmployeeId int = null) -- this is the parameter
as
begin
    select p.LastName, p.FirstName, eph.*
    from HumanResources.EmployeePayHistory eph
             join (select eph.BusinessEntityID, max(RateChangeDate) as MaxDate
                   from HumanResources.EmployeePayHistory eph
                   group by eph.BusinessEntityID) x
                  on eph.BusinessEntityID = x.BusinessEntityID
                      and eph.RateChangeDate = x.MaxDate
             join Person.Person p
                  on eph.BusinessEntityID = p.BusinessEntityID
    where eph.BusinessEntityID = @EmployeeId
       or @EmployeeId is null
end

go

exec GetCurrentPayRow 290

-- if/else example
go

declare @EmployeeID int
select @EmployeeID = 290

if (@EmployeeID is not null)
    begin
        declare @CurrentFlag bit
        select @CurrentFlag = e.CurrentFlag
        from HumanResources.Employee e
        where BusinessEntityID = @EmployeeID

        if (@CurrentFlag = 0)
            begin
                print 'Employee has been terminated.'
                return
            end
    end

select p.LastName, p.FirstName, eph.*
from HumanResources.EmployeePayHistory eph
         join (select eph.BusinessEntityID, max(RateChangeDate) as MaxDate
               from HumanResources.EmployeePayHistory eph
               group by eph.BusinessEntityID) x
              on eph.BusinessEntityID = x.BusinessEntityID
                  and eph.RateChangeDate = x.MaxDate
         join Person.Person p
              on eph.BusinessEntityID = p.BusinessEntityID
where eph.BusinessEntityID = @EmployeeId
   or @EmployeeId is null


/************************
  * Author: NGorjestani
  * Create date: 9/20/2022
  *
  * Pulls an employees most recent pay row or all employees most recent pay rows
  * Parameters:
  *     @EmployeeId: The ID of the employee to get pay row for. This is optional
*************************/

alter procedure GetCurrentPayRow(@EmployeeId int = null) -- this is the parameter
as
begin
    if (@EmployeeID is not null)
        begin
            declare @CurrentFlag bit
            select @CurrentFlag = e.CurrentFlag
            from HumanResources.Employee e
            where BusinessEntityID = @EmployeeID

            if (@CurrentFlag = 0)
                begin
                    print 'Employee has been terminated.'
                    return
                end
        end

    select p.LastName, p.FirstName, eph.*
    from HumanResources.EmployeePayHistory eph
             join (select eph.BusinessEntityID, max(RateChangeDate) as MaxDate
                   from HumanResources.EmployeePayHistory eph
                   group by eph.BusinessEntityID) x
                  on eph.BusinessEntityID = x.BusinessEntityID
                      and eph.RateChangeDate = x.MaxDate
             join Person.Person p
                  on eph.BusinessEntityID = p.BusinessEntityID
    where eph.BusinessEntityID = @EmployeeId
       or @EmployeeId is null
end

go

exec GetCurrentPayRow 290

go

/************************
  * Author: NGorjestani
  * Create date: 9/20/2022
  *
  * Pulls an employees most recent pay row or all employees most recent pay rows
  * Parameters:
  *     @EmployeeId: The ID of the employee to get pay row for. This is optional
*************************/

alter procedure GetCurrentPayRow(@EmployeeId int = null) -- this is the parameter
as
begin
    if (@EmployeeID is not null)
        begin
            declare @CurrentFlag bit
            select @CurrentFlag = e.CurrentFlag
            from HumanResources.Employee e
            where BusinessEntityID = @EmployeeID

            if (@CurrentFlag = 0)
                begin
                    ;throw 51000, 'Employee has been terminated.', 1;
                    return
                end
        end

    select p.LastName, p.FirstName, eph.*
    from HumanResources.EmployeePayHistory eph
             join (select eph.BusinessEntityID, max(RateChangeDate) as MaxDate
                   from HumanResources.EmployeePayHistory eph
                   group by eph.BusinessEntityID) x
                  on eph.BusinessEntityID = x.BusinessEntityID
                      and eph.RateChangeDate = x.MaxDate
             join Person.Person p
                  on eph.BusinessEntityID = p.BusinessEntityID
    where eph.BusinessEntityID = @EmployeeId
       or @EmployeeId is null
end

go

exec GetCurrentPayRow 290

-- Temp tables & temp vairables

create table ##TempNick(
    num int,
    name varchar(20)
)

select * from ##TempNick

-- table variable

declare @TableVar TABLE(
    num int,
    name varchar(20)
                       )

select * from @TableVar

-- temp table example

select * from Production.ProductInventory
select * from Production.Location

--consolidate inventory
select pin.ProductID, min(pin.LocationID) FirstLocation
into #ProductLocations
from Production.ProductInventory pin
group by pin.ProductID

select * from #ProductLocations

begin tran

select pin.*, q.qty
from Production.ProductInventory pin
join #ProductLocations PL
    on pin.ProductID = PL.ProductID
    and pin.LocationID = PL.FirstLocation
join
        (select ProductID, sum(pin.Quantity) qty
        from Production.ProductInventory pin
        group by ProductID) q
    on pin.ProductID = q.ProductID

update Production.ProductInventory
set Quantity =
    from Production.ProductInventory pin
    join
        (select ProductID, sum(pin.Quantity) qty
        from Production.ProductInventory pin
        group by ProductID) q
    on pin.ProductID = q.ProductID