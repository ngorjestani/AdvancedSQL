-- Join Examples

-- inner join
select p.Name as 'Product Name', p.ListPrice, p.MakeFlag, p.FinishedGoodsFlag
from Production.Product p
         join Production.ProductSubcategory ps -- join is an inner join
              on p.ProductSubcategoryID = ps.ProductSubcategoryID
         join Production.ProductCategory pc
              on ps.ProductCategoryID = pc.ProductCategoryID

-- outer join if we want all products and only display categories if they have them

-- this doesn't work because the first join is an outer join and the second join is an inner join,
-- which fails for null values from the first join
select p.Name as 'Product Name', p.ListPrice, p.MakeFlag, p.FinishedGoodsFlag
from Production.Product p
         left join Production.ProductSubcategory ps
                   on p.ProductSubcategoryID = ps.ProductSubcategoryID
         join Production.ProductCategory pc
              on ps.ProductCategoryID = pc.ProductCategoryID

-- correct outer join
select p.Name as 'Product Name', p.ListPrice, p.MakeFlag, p.FinishedGoodsFlag
from Production.Product p
         left join Production.ProductSubcategory ps
                   on p.ProductSubcategoryID = ps.ProductSubcategoryID
         left join Production.ProductCategory pc
                   on ps.ProductCategoryID = pc.ProductCategoryID

-- nested joins, if an inner join between ProductSubcategory and ProductCategory was absolutely necessary while still using a left join
select p.Name as 'Product Name', p.ListPrice, p.MakeFlag, p.FinishedGoodsFlag
from Production.Product p
     left join
     Production.ProductSubcategory ps
         join Production.ProductCategory pc
              on ps.ProductCategoryID = pc.ProductCategoryID
              on p.ProductSubcategoryID = ps.ProductSubcategoryID

-- cross joins
-- if we want a list of each employee with each shift
select e.FirstName, e.LastName, s.Name
from HumanResources.vEmployee e
    cross join HumanResources.Shift s

-- another way to cross join
select e.FirstName, e.LastName, s.Name
from HumanResources.vEmployee e, HumanResources.Shift s

-- another way
select e.FirstName, e.LastName, s.Name
from HumanResources.vEmployee e
    join HumanResources.Shift s
    on 1 = 1

-- example of an inequality join
select sod.OrderQty, so.*
from Sales.SalesOrderDetail sod
    join Sales.SpecialOffer so
    on sod.OrderQty between so.MinQty and so.MaxQty
where sod.SalesOrderID = 43881

-- group by & aggregations
select sum(soh.SubTotal) as Subtotal, sum(soh.TaxAmt) as Tax, sum(soh.Freight) as Freight, sum(soh.TotalDue) as TotalDue
from Sales.SalesOrderHeader soh

-- group by to get totals
select
    soh.CustomerID,
    sum(soh.SubTotal) as Subtotal,
    sum(soh.TaxAmt) as Tax,
    sum(soh.Freight) as Freight,
    sum(soh.TotalDue) as TotalDue
from Sales.SalesOrderHeader soh
group by soh.CustomerID
order by soh.CustomerID

-- with a where clause
select
    soh.CustomerID,
    sum(soh.SubTotal) as Subtotal,
    sum(soh.TaxAmt) as Tax,
    sum(soh.Freight) as Freight,
    sum(soh.TotalDue) as TotalDue
from Sales.SalesOrderHeader soh
group by soh.CustomerID
having sum(soh.TotalDue) > 10000
order by soh.CustomerID