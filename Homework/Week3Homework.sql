-- 1. For each store, calculate the lifetime total sales, the average order total, and the total number of orders. Display each store only once. Use window functions for this.

select distinct
    c.StoreID,
    s.Name,
    format(sum(soh.SubTotal) over ( partition by soh.CustomerID), 'c') TotalSales,
    format(avg(soh.SubTotal) over ( partition by soh.CustomerID), 'c') AvgSales,
    count(*) over (partition by soh.CustomerID) TotalOrders
from Sales.SalesOrderHeader soh
join Sales.Customer c on soh.CustomerID = c.CustomerID
join Sales.Store s on c.StoreID = s.BusinessEntityID
where c.StoreID is not null

-- 2. Rank products by total number of units sold to show which products sell best. Display the name, the total units sold, and the ranking.

select rank() over (order by x.TotalOrders desc) Rank, *
from (select distinct
    sod.ProductID,
    p.Name,
    count(*) over ( partition by sod.ProductID ) TotalOrders
from Sales.SalesOrderHeader soh
    join Sales.SalesOrderDetail sod on soh.SalesOrderID = sod.SalesOrderID
    join Production.Product p on sod.ProductID = p.ProductID) x

-- 3. Display each employee’s time-off hours as a separate row – one row for vacation hours, another for sick.

select * from (select p.FirstName + ' ' + p.LastName Name, e.VacationHours, e.SickLeaveHours
from HumanResources.Employee e
    join Person.Person p
    on e.BusinessEntityID = p.BusinessEntityID) pvt
pivot (  )