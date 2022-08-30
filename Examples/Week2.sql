--  **** Subqueries ****

-- Display all products that are sold, the list price, and overall average price of all products sold

-- Subquery
select avg(p.ListPrice)
from Production.Product as p
where p.FinishedGoodsFlag = 1
--Main query
select
    p.Name,
    p.ListPrice,
    (select avg(p.ListPrice)
    from Production.Product as p
    where p.FinishedGoodsFlag = 1) as OverallAvgListPrice
from Production.Product as p
where p.FinishedGoodsFlag = 1

-- Products that cost more than the average list price for all products

-- Subquery
select avg(p.ListPrice)
from Production.Product as p
where p.FinishedGoodsFlag = 1

-- Main query
select p.Name, p.ListPrice
from Production.Product p
where p.FinishedGoodsFlag = 1
    and p.ListPrice > (select avg(p.ListPrice)
        from Production.Product as p
        where p.FinishedGoodsFlag = 1)

-- Show subcategories with an avg list price that is less than the overall avg list price of finished goods
select ps.Name as Subcategory, avg(p.ListPrice) SubcatAvgListPrice
from Production.Product p
    join Production.ProductSubcategory ps
    on p.ProductSubcategoryID = ps.ProductSubcategoryID
group by ps.Name
having avg(p.ListPrice) < (select avg(p.ListPrice)
    from Production.Product as p
    where p.FinishedGoodsFlag = 1)

-- **** Some/Any ****

-- Find orders that contain at least one of the 5 most expensive products

-- Subquery: 5 most expensive products
select top 5 p.ProductID
from Production.Product p
order by p.ListPrice desc

-- Main query
select distinct sod.SalesOrderID
from Sales.SalesOrderDetail sod
where sod.ProductID = any (
    select top 5 p.ProductID
    from Production.Product p
    order by p.ListPrice desc)

-- Find orders that don't contain any of the top 5 most expensive products
select distinct sod.SalesOrderID
from Sales.SalesOrderDetail sod
where sod.ProductID <> all (
    select top 5 p.ProductID
    from Production.Product p
    order by p.ListPrice desc)

-- **** Correlated Subqueries ****

-- Find products that cost more than the average list price of finished goods in the same subcategory

-- Subquery: calculate the average list price by subcategory
select avg(p.ListPrice)
from Production.Product p
where p.ProductSubcategoryID = ?

Select ps.Name Subcategory, p.ListPrice
from Production.Product p
    join Production.ProductSubcategory ps
    on p.ProductSubcategoryID = ps.ProductSubcategoryID
where p.ListPrice > (
    select avg(p.ListPrice)
    from Production.Product p
    where ProductSubcategoryID = p.ProductSubcategoryID
)

-- To actually see the average price, it needs to be included in the select statement
Select ps.Name Subcategory,
       p.ListPrice,
        (select avg(p.ListPrice)
        from Production.Product p
        where ProductSubcategoryID = p.ProductSubcategoryID) SubcatAvg
from Production.Product p
    join Production.ProductSubcategory ps
    on p.ProductSubcategoryID = ps.ProductSubcategoryID
where p.ListPrice > (
    select avg(p.ListPrice)
    from Production.Product p
    where ProductSubcategoryID = p.ProductSubcategoryID
)

-- Rewrite the above so we only do one subquery

-- Subquery
select p.ProductSubcategoryID, avg(p.ListPrice) as SubcatAvgListPrice
from Production.Product p
where ProductSubcategoryID = p.ProductSubcategoryID
group by p.ProductSubcategoryID

-- Main query
Select ps.Name Subcategory,
       p.ListPrice,
       sa.SubcatAvgListPrice
from Production.Product p
    join Production.ProductSubcategory ps
    on p.ProductSubcategoryID = ps.ProductSubcategoryID
    join (select p.ProductSubcategoryID, avg(p.ListPrice) as SubcatAvgListPrice
        from Production.Product p
        where ProductSubcategoryID = p.ProductSubcategoryID
        group by p.ProductSubcategoryID) sa -- subcategory averages
    on p.ProductSubcategoryID = sa.ProductSubcategoryID
where p.ListPrice > sa.SubcatAvgListPrice
set statistics time on

-- **** CTEs ****
;with subcatAverages as (
    select p.ProductSubcategoryID, avg(p.ListPrice) as SubcatAvgListPrice
    from Production.Product p
    where ProductSubcategoryID = p.ProductSubcategoryID
    group by p.ProductSubcategoryID
)
Select ps.Name Subcategory,
       p.ListPrice,
       sa.SubcatAvgListPrice
from Production.Product p
    join Production.ProductSubcategory ps
    on p.ProductSubcategoryID = ps.ProductSubcategoryID
    join subcatAverages sa -- subcategory averages
    on p.ProductSubcategoryID = sa.ProductSubcategoryID
where p.ListPrice > sa.SubcatAvgListPrice

select * from Production.BillOfMaterials

-- **** Apply ****

Select ps.Name Subcategory,
       p.ListPrice,
       SubcatAvg.AvgListPrice
from Production.Product p
    join Production.ProductSubcategory ps
    on p.ProductSubcategoryID = ps.ProductSubcategoryID
cross apply (select p.ProductSubcategoryID, avg(p.ListPrice) as AvgListPrice
        from Production.Product p
        where ProductSubcategoryID = p.ProductSubcategoryID) SubcatAvg
where p.ListPrice > SubcatAvg.AvgListPrice

-- first data each product was ordered

-- Subquery
select top 1 soh.OrderDate
from Sales.SalesOrderDetail sod
    join Sales.SalesOrderHeader soh
    on sod.SalesOrderID = soh.SalesOrderID
where sod.ProductID = ?

-- Main Query
select p.Name, p.FinishedGoodsFlag, o.OrderDate
from Production.Product p
cross apply (select top 1 soh.OrderDate
    from Sales.SalesOrderDetail sod
    join Sales.SalesOrderHeader soh
    on sod.SalesOrderID = soh.SalesOrderID
    where sod.ProductID = p.ProductID
    order by OrderDate) o

-- Outer apply
select p.Name, p.FinishedGoodsFlag, o.OrderDate
from Production.Product p
outer apply (select top 1 soh.OrderDate
    from Sales.SalesOrderDetail sod
    join Sales.SalesOrderHeader soh
    on sod.SalesOrderID = soh.SalesOrderID
    where sod.ProductID = p.ProductID
    order by OrderDate) o
set statistics time on
