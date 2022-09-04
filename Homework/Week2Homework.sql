-- 1. Create a listing of current employees, their names, job titles, years employed, and their current pay rate

select
    p.FirstName + ' ' + p.LastName as Name,
    e.JobTitle,
    datediff(year, e.HireDate, getdate()) as 'Years Employed',
    format(eph.Rate, 'c') as 'Pay Rate'
from HumanResources.Employee e
    join Person.Person p
    on e.BusinessEntityID = p.BusinessEntityID
    join HumanResources.EmployeePayHistory eph
    on e.BusinessEntityID = eph.BusinessEntityID
where e.CurrentFlag = 1

-- **** Correct ****
select eph.BusinessEntityID, max(RateChangeDate) RateDate
from HumanResources.EmployeePayHistory eph
group by eph.BusinessEntityID

select
    e.BusinessEntityID,
    p.LastName,
    p.FirstName,
    e.JobTitle,
    datediff(year, e.HireDate, getdate()) as 'Years Employed',
    format(eph.Rate, 'c') as 'Pay Rate'
from HumanResources.Employee e
         join Person.Person p
              on e.BusinessEntityID = p.BusinessEntityID
         join HumanResources.EmployeePayHistory eph
              on e.BusinessEntityID = eph.BusinessEntityID
         join (select eph.BusinessEntityID, max(RateChangeDate) RateDate
               from HumanResources.EmployeePayHistory eph
               group by eph.BusinessEntityID) pay
              on eph.BusinessEntityID = pay.BusinessEntityID
where e.CurrentFlag = 1

-- 2. For internet sales made to Alberta, Canada, list the name of the customer and order information about the first order each customer made.
    -- a. Write the query using a subquery

select
    p.FirstName + ' ' + p.LastName Name,
    SalesOrderID,
    OrderDate
from Sales.SalesOrderHeader soh
    join Sales.Customer c
    on soh.CustomerID = c.CustomerID
    join Person.Person p
    on c.PersonID = p.BusinessEntityID
where SalesOrderID in (
    select soh.SalesOrderID
    from Sales.SalesOrderHeader soh
        join Person.Address a on soh.ShipToAddressID = a.AddressID
    where soh.OnlineOrderFlag = 1 and a.StateProvinceID = 1
)

-- **** Correct ****
select p.BusinessEntityID, p.LastName, p.FirstName, soh.SalesOrderID, soh.OrderDate, soh.SubTotal
from Sales.SalesOrderHeader soh
    join Sales.Customer c
    on soh.CustomerID = c.CustomerID
    join Person.Person p
    on c.PersonID = p.BusinessEntityID
    join Person.BusinessEntityAddress bea
    on p.BusinessEntityID = bea.BusinessEntityID
    join Person.AddressType atype
    on bea.AddressTypeID = atype.AddressTypeID
    join Person.Address a
    on bea.AddressID = a.AddressID
    join Person.StateProvince sp
    on a.StateProvinceID = sp.StateProvinceID
    join (select min(OrderDate) FirstOrderDate
          from Sales.SalesOrderHeader
          group by CustomerID) f
    on soh.OrderDate = f.FirstOrderDate
where soh.OnlineOrderFlag = 1
and sp.Name = 'Alberta'
and CountryRegionCode = 'CA'


    -- b. Rewrite the query using a CTE - try to make it different



    -- c. Rewrite the query using the Apply operator



    -- d. How does the execution plans compare between the three queries?


