-- 1. Create a query that displays the total dollar amount of sales before tax/freight for each month and year (ie, Jan 2020, Feb 2020, etc). Months should sort in calendar order.

select
    month(soh.OrderDate) Month,
    year(soh.OrderDate) Year,
    format(sum(soh.SubTotal), 'c') MonthlySales
from Sales.SalesOrderHeader soh
group by year(soh.OrderDate), month(soh.OrderDate)
order by year(soh.OrderDate), month(soh.OrderDate)


-- 2. Create a query for an invoicing report that lists all of a customer’s orders (order #, date, subtotal, tax, freight, and total due), and has a running total of the total due field.
-- The query should split the orders by month/year  (ie, Jan 2020, Feb 2020, etc), and the running total should reset every time the customer and month/year changes.
-- The query should work for all customers. Customer 11566 April Shan is a good test case.

declare @CustomerId as integer
set @CustomerId = 11566
select
    soh.SalesOrderID,
    format(soh.OrderDate, 'M/d/yyyy') OrderDate,
    format(soh.SubTotal, 'c') Subtotal,
    format(soh.TaxAmt, 'c') Tax,
    format(soh.Freight, 'c') Freight,
    format(soh.SubTotal + soh.TaxAmt + soh.Freight, 'c') TotalDue,
    format(sum(TotalDue) over ( partition by format(soh.OrderDate, 'MMM YY') order by OrderDate), 'c') MonthlyTotal
from Sales.SalesOrderHeader soh
    join Sales.Customer c on soh.CustomerID = c.CustomerID
where soh.CustomerID = @CustomerId
order by soh.OrderDate


-- 3. Create a query that list each customer, the date of their first sale, the date of their most recent sale, and the total amount spent on all orders.
-- Include the details about the first and last orders on the same row (sales order number, totals, and shipped date). Use window functions for this

select
    c.CustomerID,
    first_value(soh.SalesOrderID) over (partition by soh.CustomerID order by soh.OrderDate)
from Sales.Customer c
    left join Sales.SalesOrderHeader soh
    on c.CustomerID = soh.CustomerID

-- 4. Re-write #3 using subqueries instead.



-- 5. Re-write #3 using the apply operator instead.



-- 6. Compare the executions plans of #'s 3, 4, & 5. How do they compare? Which query produces a plan that is more optimal? Why?