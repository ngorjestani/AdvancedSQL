-- 1. For each store, calculate the lifetime total sales, the average order total, and the total number of orders. Display each store only once. Use window functions for this.

-- Does not account for stores with 0 sales
/*select distinct
    c.StoreID,
    s.Name,
    format(sum(soh.SubTotal) over ( partition by soh.CustomerID), 'c') TotalSales,
    format(avg(soh.SubTotal) over ( partition by soh.CustomerID), 'c') AvgSales,
    count(*) over (partition by soh.CustomerID) TotalOrders
from Sales.SalesOrderHeader soh
join Sales.Customer c on soh.CustomerID = c.CustomerID
join Sales.Store s on c.StoreID = s.BusinessEntityID
where c.StoreID is not null*/

-- Correct
select distinct s.Name StoreName,
       sum(soh.SubTotal) over (partition by s.BusinessEntityID) TotalSales,
       avg(soh.SubTotal) over (partition by s.BusinessEntityID) AvgOrderTotal,
       count(soh.SalesOrderID) over (partition by s.BusinessEntityID) OrderCount
from Sales.Store s
    join Sales.Customer c
    on s.BusinessEntityID = c.StoreID
    left join Sales.SalesOrderHeader soh
    on s.BusinessEntityID = c.StoreID

-- 2. Rank products by total number of units sold to show which products sell best. Display the name, the total units sold, and the ranking.

select rank() over (order by x.TotalOrders desc) Rank, *
from (select distinct
    sod.ProductID,
    p.Name,
    count(*) over ( partition by sod.ProductID ) TotalOrders
from Sales.SalesOrderHeader soh
    join Sales.SalesOrderDetail sod on soh.SalesOrderID = sod.SalesOrderID
    join Production.Product p on sod.ProductID = p.ProductID) x

-- Correct

select distinct p.Name Product,
                rank() over (order by sd.UnitsSold desc) SalesRank
from Production.Product p
    join (select p.ProductID,
    isnull(sum(sod.OrderQty), 0) UnitsSold
from Production.Product p
    left join Sales.SalesOrderDetail sod
    on p.ProductID = sod.ProductID
group by p.ProductID) sd
on p.ProductID = sd.ProductID



-- 3. Display each employee’s time-off hours as a separate row – one row for vacation hours, another for sick.

/*select * from (select p.FirstName + ' ' + p.LastName Name, e.VacationHours, e.SickLeaveHours
from HumanResources.Employee e
    join Person.Person p
    on e.BusinessEntityID = p.BusinessEntityID) pvt
pivot (  )*/

select * from (select e.BusinessEntityID EmployeeId, p.LastName, p.FirstName, e.VacationHours, e.SickLeaveHours
from HumanResources.Employee e
    join Person.Person p
    on e.BusinessEntityID = p.BusinessEntityID) unpvt
unpivot ( PTO for Hours in ([VacationHours], [SickLeaveHours]) ) PTO