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



    -- b. Rewrite the query using a CTE - try to make it different



    -- c. Rewrite the query using the Apply operator



    -- d. How does the execution plans compare between the three queries?


