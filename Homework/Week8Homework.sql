-- Create a SQL statement that produces an XML document of orders and the products on each order.
-- Include the SalesOrderID, OrderDate, DueDate, PurchaseOrderNumber, CustomerID, Subtotal, Tax, Freight, and Total.
-- Display the Products on each order as its own node in the XML within the order – include the productID, name, quantity ordered, unitprice, and unit discount.
-- Include a root element, and ensure that all fields are elements other than the OrderID – this should be an attribute. Make sure that each order only shows up once.
-- Only include the 5 most recent orders.

select soh.SalesOrderID,
       soh.OrderDate,
       soh.DueDate,
       soh.PurchaseOrderNumber,
       soh.CustomerID,
       soh.SubTotal,
       soh.TaxAmt,
       soh.Freight,
       soh.SubTotal + soh.TaxAmt + soh.Freight as Total
from Sales.SalesOrderHeader soh

-- Same as #1, but use JSON. Make the products be a nested object. Make sure that each order only shows up once.

-- Using the attached XMLDownload XML file, parse all the fields in the name and employment nodes. You will end up with multiple rows.

-- The Lesson 8 Practice Problem JSONDownload Lesson 8 Practice Problem JSON file contains Employee changes (new employees and changes to existing employees) from AdventureWorks’ separate HR system.
-- Integrate the information, then test to ensure the changes worked.
-- Note: the emphasis of this question is on the testing portion. It is ok if your procedures don't fully work, as long as they work well enough that you can do some decent testing. The procedures functioning correctly is only a small portion of the points for this assignment.
-- Create a procedure that takes a JSON document as an input and merges the data into the Person.Person and HumanResources.Employee tables.
-- Define the test cases. Document all the test cases you can think of for the procedure.
-- Perform testing! Include the SQL for the tests you performed
-- Document the outcome of each test. Was the test successful? Why or why not?
-- Document any errors you found