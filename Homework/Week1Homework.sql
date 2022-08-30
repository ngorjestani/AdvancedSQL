-- 1. Create a query of sales orders that occurred on 9/1/2020.
-- Include the order number and date, if the order was an online order, the customer’s first and last name,
-- and the name of the company the order was for.

select
    soh.SalesOrderNumber as 'Order Number',
    soh.OrderDate,
    soh.OnlineOrderFlag as 'Is Online Order',
    p.FirstName + ' ' + p.LastName as Name,
    s.Name as Company
from Sales.SalesOrderHeader as soh
    join Sales.Customer as c on soh.CustomerID = c.CustomerID
    join Person.Person as p on c.PersonID = p.BusinessEntityID
--  join Sales.Store as s on c.StoreID = s.BusinessEntityID : incorrect, excludes nulls
    left join Sales.Store as s on c.StoreID = s.BusinessEntityID
-- where soh.OrderDate = '9/1/2020' : incorrect, excludes times other than midnight
where cast(soh.OrderDate as date) = '9/1/2020'

-- 2. Create a query that lists the components currently necessary to build the produce 'ML Road Frame - Red, 58' (ProductID 734).
-- Include the name of both the product and the component, as well as the quantities.

select p.Name as 'Product Name', c.Name as 'Component Name', bom.PerAssemblyQty as Quantity
from Production.BillOfMaterials as bom
    join Production.Product as c on bom.ComponentID = c.ProductID
    join Production.Product as p on bom.ProductAssemblyID = p.ProductID
-- where bom.ProductAssemblyID = 734 : incorrect, also includes components not current anymore
where bom.ProductAssemblyID = 734 and bom.EndDate is null

-- 3. Create a query that displays customers with lifetime sales of $10,000 or more.
-- Display the total sales, the total tax, and the total freight.
-- If the customer is a store, display the store name; otherwise display the customer’s name. Sort by the customer’s name.

select
    IIF(c.StoreID is null, p.FirstName + ' ' + p.LastName, s.Name) as Name,
    format(sum(soh.SubTotal), 'c') as 'Total Sales',
    format(sum(soh.TaxAmt), 'c') as 'Total Tax',
    format(sum(soh.Freight), 'c') as 'Total Freight'
from Sales.SalesOrderHeader as soh
    join Sales.Customer as c on soh.CustomerID = c.CustomerID
    -- left join Person.Person as p on c.PersonID = p.BusinessEntityID : doesn't need to be a left join
    join Person.Person as p on c.PersonID = p.BusinessEntityID
    left join Sales.Store as s on c.StoreID = s.BusinessEntityID
group by soh.CustomerID, p.FirstName, p.LastName, s.Name, c.StoreID
    having sum(soh.SubTotal) > 10000
order by IIF(c.StoreID is null, p.FirstName + ' ' + p.LastName, s.Name)