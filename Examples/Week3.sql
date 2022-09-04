-- Number Rows
select top 100
    row_number() over (order by OrderDate) as rowcnt, soh.SalesOrderID, soh.OrderDate
from Sales.SalesOrderHeader soh

-- Partition by lets you 'reset' the numbering when what you partition by changes
-- reset the row count when order date changes
select top 100
    row_number() over (partition by cast(OrderDate as date) order by cast(OrderDate as date)) as rowcnt, soh.SalesOrderID, soh.OrderDate
from Sales.SalesOrderHeader soh

-- revisit Alberta, Canada example and use row number
select CustomerID, OrderDate,
       row_number() over (partition by CustomerID order by OrderDate) row
          from Sales.SalesOrderHeader

select p.BusinessEntityID, p.LastName, p.FirstName, soh.SalesOrderID, soh.OrderDate, soh.SubTotal
from Sales.Customer c
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
    join (select CustomerID, OrderDate, SalesOrderID, SubTotal,
          row_number() over (partition by CustomerID order by OrderDate) row
          from Sales.SalesOrderHeader
          where OnlineOrderFlag = 1) soh
    on c.CustomerID = soh.CustomerID and soh.row = 1
and sp.Name = 'Alberta'
and CountryRegionCode = 'CA'

-- Ranking sales people
select
    p.BusinessEntityID,
    p.LastName,
    p.FirstName,
    format(sp.SalesYTD, 'c') SalesTotalThisYear,
    rank() over (order by sp.SalesYTD desc) SalesRankThisYear,
    format(sp.SalesLastYear, 'c') SalesTotalLastYear,
    rank() over (order by sp.SalesLastYear desc) SalesRankLastYear
from Sales.SalesPerson sp
join Person.Person p
on sp.BusinessEntityID = p.BusinessEntityID

-- top 3
select * from
    (select
    p.BusinessEntityID,
    p.LastName,
    p.FirstName,
    format(sp.SalesYTD, 'c') SalesTotalThisYear,
    rank() over (order by sp.SalesYTD desc) SalesRankThisYear,
    format(sp.SalesLastYear, 'c') SalesTotalLastYear,
    rank() over (order by sp.SalesLastYear desc) SalesRankLastYear
    from Sales.SalesPerson sp
        join Person.Person p
        on sp.BusinessEntityID = p.BusinessEntityID) x
where x.SalesRankThisYear <= 3

-- lag/lead look at previous/future rows
select top 100
soh.SalesOrderID as CurrentSalesOrder,
lag(SalesOrderID, 1) over (order by SalesOrderID) as PreviousSalesOrderId,
lead(SalesOrderID, 1) over (order by SalesOrderID) as NextSalesOrderId
from Sales.SalesOrderHeader soh

select p.LastName,
       soh.SalesOrderID,
       soh.OrderDate as CurrentOrderDate,
       lead(soh.OrderDate) over (partition by soh.CustomerID order by soh.OrderDate) as NextOrderDate,
       datediff(day, soh.OrderDate, lead(soh.OrderDate) over (partition by soh.CustomerID order by soh.OrderDate)) DaysBetweenOrders
from Sales.SalesOrderHeader soh
    join Sales.Customer c
    on soh.CustomerID = c.CustomerID
    join Person.Person p
    on c.PersonID = p.BusinessEntityID
where soh.CustomerID = 11000

-- first/last value
-- show first & most recent order IDs for customer 11000
select soh.CustomerID,
       soh.SalesOrderID ThisRowsSalesID,
       first_value(soh.SalesOrderID) over (partition by soh.CustomerID order by soh.OrderDate) as FirstOrderID,
       last_value(soh.SalesOrderID) over (partition by soh.CustomerID order by soh.OrderDate) as MostRecentOrderID
from Sales.SalesOrderHeader soh
where soh.CustomerID = 11000

-- more explicit
select soh.CustomerID,
       soh.SalesOrderID ThisRowsSalesID,
       first_value(soh.SalesOrderID) over (partition by soh.CustomerID order by soh.OrderDate) as FirstOrderID,
       last_value(soh.SalesOrderID)
           over (
                    partition by soh.CustomerID
                    order by soh.OrderDate
                    -- rows between unbounded preceding and current row -- this is the default
                    rows between unbounded preceding and unbounded following
               ) as MostRecentOrderID
from Sales.SalesOrderHeader soh
where soh.CustomerID = 11000

-- using the over clause on 'regular' aggregate functions
-- show total sales, total items ordered, average items ordered by customer
select
    soh.CustomerID,
    format(sum(sod.LineTotal) over (partition by soh.CustomerID), 'c') TotalSales,
    sum(sod.OrderQty) over (partition by soh.CustomerID) TotalQty,
    avg(sod.OrderQty) over (partition by soh.CustomerID) AvgQty
from Sales.SalesOrderHeader soh
    join Sales.SalesOrderDetail sod
    on soh.SalesOrderID = sod.SalesOrderID
where soh.OnlineOrderFlag = 0

-- pivot/unpivot
-- list unit sales by product, by year
-- list products as rows, years as columns
select p.Name as Product,
       sod.OrderQty,
       year(soh.OrderDate)
from Production.Product p
    join Sales.SalesOrderDetail sod
    on p.ProductID = sod.ProductID
    join Sales.SalesOrderHeader soh
    on sod.SalesOrderID = soh.SalesOrderID

select distinct year(OrderDate) from Sales.SalesOrderHeader

-- make it a pivot
select *
from (select p.Name as Product,
               sod.OrderQty,
               year(soh.OrderDate) OrderYear
        from Production.Product p
            join Sales.SalesOrderDetail sod
            on p.ProductID = sod.ProductID
            join Sales.SalesOrderHeader soh
            on sod.SalesOrderID = soh.SalesOrderID) p
pivot ( sum(OrderQty)
    for OrderYear in ([2018], [2019], [2020], [2021])) pvt

-- unpivot
-- columns to rows
-- fir product photos, we store both thumbnail and large photo file names in separate columns in the same table
-- get the source data together
select
    p.Name as Product,
    pp.ThumbnailPhotoFileName,
    pp.LargePhotoFileName
from Production.Product p
    join Production.ProductProductPhoto ppp
    on p.ProductID = ppp.ProductID
    join Production.ProductPhoto pp
    on ppp.ProductPhotoID = pp.ProductPhotoID

-- unpivot
select *
from (select
        p.Name as Product,
        pp.ThumbnailPhotoFileName,
        pp.LargePhotoFileName
    from Production.Product p
        join Production.ProductProductPhoto ppp
        on p.ProductID = ppp.ProductID
        join Production.ProductPhoto pp
        on ppp.ProductPhotoID = pp.ProductPhotoID) p
unpivot ( FileName
            for FileType
            in ([ThumbnailPhotoFileName], [LargePhotoFileName])) unpvt