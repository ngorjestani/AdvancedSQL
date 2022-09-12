-- Let's add some new products
-- if there is no column list, we need a value for every column (excluding identities)
Insert into Production.Product
Values ('Helmet with Visor','H01234', 0, 1, 'Pink', 15, 10, 12.39, 29.99, 'Adult', 
null, null, null, 0, null, null, null, 31, null, '9/15/2021', null, null, NewID(), 
GetDate())
Select * from Production.product order by ProductID desc
-- now insert with a column list, and add multiple rows at a time
-- this will throw an error because the product names are duplicates
Insert into Production.Product (Name, ProductNumber, Color, ListPrice, 
StandardCost, MakeFlag, FinishedGoodsFlag, SafetyStockLevel, ReorderPoint, 
DaysToManufacture,SellStartDate, rowguid, ModifiedDate) 
Values ('Spiked Pedals','SP012354', 'Orange', 140.00, 56.90, 0, 1, 100, 50, 0, 
'9/6/2022', NewID(), GetDate()),
('Spiked Pedals','SP012355', 'Red', 140.00, 56.90, 0, 1, 100, 50, 0, '9/6/2022', 
NewID(), GetDate()),
('Spiked Pedals','SP012356', 'Black', 140.00, 56.90, 0, 1, 100, 50, 0, '9/6/2022', 
NewID(), GetDate()),
('Spiked Pedals','SP012357', 'Neon Green', 140.00, 56.90, 0, 1, 100, 50, 0, null, 
NewID(), GetDate())
-- try again 
-- you'll notice two IDs are skipped - this is because it tried to insert 2 rows earlier and hit the duplicate value for the name
-- which violated the constraint and caused the rows not to be inserted
Insert into Production.Product (Name, ProductNumber, Color, ListPrice, 
StandardCost, MakeFlag, FinishedGoodsFlag, SafetyStockLevel, ReorderPoint, 
DaysToManufacture,SellStartDate, rowguid, ModifiedDate) 
Values ('Spiked Pedals - Orange','SP012354', 'Orange', 140.00, 56.90, 0, 1, 100, 
50, 0, '9/6/2022', NewID(), GetDate()),
('Spiked Pedals - Red','SP012355', 'Red', 140.00, 56.90, 0, 1, 100, 50, 0, 
'9/6/2022', NewID(), GetDate()),
('Spiked Pedals - Black','SP012356', 'Black', 140.00, 56.90, 0, 1, 100, 50, 0, 
'9/6/2022', NewID(), GetDate()),
('Spiked Pedals - Green','SP012357', 'Neon Green', 140.00, 56.90, 0, 1, 100, 50, 0,
'9/6/2022', NewID(), GetDate())
Select top 5 * from production.Product 
order by ProductID desc
-- typically this would come from an actual table, rather than just selecting the values
-- but the concept is the same
-- columns selected must match the order set by the column list (or the table if nocolumn list)
Insert into Production.Product (Name, ProductNumber, Color, ListPrice, 
StandardCost, MakeFlag, FinishedGoodsFlag, SafetyStockLevel, ReorderPoint, 
DaysToManufacture,SellStartDate, rowguid, ModifiedDate) 
Select 'Spiked Pedals - Blue','SP012358', 'Blue', 140.00, 56.90, 0, 1, 100, 50, 0, 
'9/6/2022', NewID(), GetDate()
-- forcing a value into an identity column
-- must use a column list and must include the identity column and its value
-- must turn the identity insert on before running and off after
Set identity_insert Production.product on-- Let's add some new products
-- if there is no column list, we need a value for every column (excluding identities)
Insert into Production.Product
Values ('Helmet with Visor','H01234', 0, 1, 'Pink', 15, 10, 12.39, 29.99, 'Adult', 
null, null, null, 0, null, null, null, 31, null, '9/15/2021', null, null, NewID(), 
GetDate())
Select * from Production.product order by ProductID desc
-- now insert with a column list, and add multiple rows at a time
-- this will throw an error because the product names are duplicates
Insert into Production.Product (Name, ProductNumber, Color, ListPrice, 
StandardCost, MakeFlag, FinishedGoodsFlag, SafetyStockLevel, ReorderPoint, 
DaysToManufacture,SellStartDate, rowguid, ModifiedDate) 
Values ('Spiked Pedals','SP012354', 'Orange', 140.00, 56.90, 0, 1, 100, 50, 0, 
'9/6/2022', NewID(), GetDate()),
('Spiked Pedals','SP012355', 'Red', 140.00, 56.90, 0, 1, 100, 50, 0, '9/6/2022', 
NewID(), GetDate()),
('Spiked Pedals','SP012356', 'Black', 140.00, 56.90, 0, 1, 100, 50, 0, '9/6/2022', 
NewID(), GetDate()),
('Spiked Pedals','SP012357', 'Neon Green', 140.00, 56.90, 0, 1, 100, 50, 0, null, 
NewID(), GetDate())
-- try again 
-- you'll notice two IDs are skipped - this is because it tried to insert 2 rows earlier and hit the duplicate value for the name
-- which violated the constraint and caused the rows not to be inserted
Insert into Production.Product (Name, ProductNumber, Color, ListPrice, 
StandardCost, MakeFlag, FinishedGoodsFlag, SafetyStockLevel, ReorderPoint, 
DaysToManufacture,SellStartDate, rowguid, ModifiedDate) 
Values ('Spiked Pedals - Orange','SP012354', 'Orange', 140.00, 56.90, 0, 1, 100, 
50, 0, '9/6/2022', NewID(), GetDate()),
('Spiked Pedals - Red','SP012355', 'Red', 140.00, 56.90, 0, 1, 100, 50, 0, 
'9/6/2022', NewID(), GetDate()),
('Spiked Pedals - Black','SP012356', 'Black', 140.00, 56.90, 0, 1, 100, 50, 0, 
'9/6/2022', NewID(), GetDate()),
('Spiked Pedals - Green','SP012357', 'Neon Green', 140.00, 56.90, 0, 1, 100, 50, 0,
'9/6/2022', NewID(), GetDate())
Select top 5 * from production.Product 
order by ProductID desc
-- typically this would come from an actual table, rather than just selecting the values
-- but the concept is the same
-- columns selected must match the order set by the column list (or the table if nocolumn list)
Insert into Production.Product (Name, ProductNumber, Color, ListPrice, 
StandardCost, MakeFlag, FinishedGoodsFlag, SafetyStockLevel, ReorderPoint, 
DaysToManufacture,SellStartDate, rowguid, ModifiedDate) 
Select 'Spiked Pedals - Blue','SP012358', 'Blue', 140.00, 56.90, 0, 1, 100, 50, 0, 
'9/6/2022', NewID(), GetDate()
-- forcing a value into an identity column
-- must use a column list and must include the identity column and its value
-- must turn the identity insert on before running and off after
Set identity_insert Production.product on
Insert into Production.Product (ProductID, Name, ProductNumber, Color, ListPrice, 
StandardCost, MakeFlag, FinishedGoodsFlag, SafetyStockLevel, ReorderPoint, 
DaysToManufacture,SellStartDate, rowguid, ModifiedDate) 
Select 1007, 'Spiked Pedals - Purple','SP012359', 'Purple', 140.00, 56.90, 0, 1, 
100, 50, 0, '9/6/2022', NewID(), GetDate()
Set identity_insert Production.product off
-- There is a way to fix the gap - say you try to insert a large number of rows andit fails,
-- and you want to go back before you try again
-- I re-ran a failed insert statement a few times to get a gap
-- 1008 is the last data value we had
-- to see the next 'slated' value of the identity, we can use dbcc checkident
dbcc checkident('production.product')
-- output: Checking identity information: current identity value '1023', current column value '1008'.
-- we can reset it back to an older value if we want/need to
dbcc checkident('production.product', reseed, 1008)
Insert into Production.Product (Name, ProductNumber, Color, ListPrice, 
StandardCost, MakeFlag, FinishedGoodsFlag, SafetyStockLevel, ReorderPoint, 
DaysToManufacture,SellStartDate, rowguid, ModifiedDate) 
Select 'Spiked Pedals - Yellow','SP012360', 'Yellow', 140.00, 56.90, 0, 1, 100, 50,
0, '9/6/2022', NewID(), GetDate()
-- the Scope_Identity() function returns the value of the last identity inserted onthe connection
Select SCOPE_IDENTITY()
-----------
-- Updates
-----------
-- start by writing a select statement that identifies the rows to be modified
Select *
From Production.Product p 
where p.name like 'Spiked Pedals - %'
-- steal the where-clause to use in our actual update
Update Production.Product
set Size = 'Med',
ProductSubcategoryID = 13
where name like 'Spiked Pedals - %'
-- we decided for random reasons, we don't want to work with vendors in Texas anymore. Inactivate them
Select v.* 
from Purchasing.Vendor v
Join Purchasing.vVendorWithAddresses va 
on v.BusinessEntityID = va.BusinessEntityID
where va.StateProvinceName = 'Texas'
-- now that we've identified the rows, do the update statement
Update Purchasing.Vendor 
Set ActiveFlag = 0
from Purchasing.Vendor v
Join Purchasing.vVendorWithAddresses va 
on v.BusinessEntityID = va.BusinessEntityID
where va.StateProvinceName = 'Texas'
--------------
-- Delete
--------------
Select * from Production.Product
Where FinishedGoodsFlag = 1
-- try to delete a product that has been sold (ID 717) - this will not work - foreign key constraint
Delete from Production.Product 
where ProductID = 717
-- delete one of our new products (ID 1000)
Delete from Production.Product 
where ProductID = 1000
Select * from Production.ProductSubcategory
insert into Production.ProductSubcategory
Values (2, 'Fancy items', newID(), GetDate())
-- change the product subcategoryID for all the new products we added
Update Production.Product 
set ProductSubcategoryID = 38 
where ProductID > 1000
-- now we decide we want to delete 'fancy items' subcategory
Delete from Production.ProductSubcategory 
where ProductSubcategoryID = 38
-- for now, set those products' subcategoryID null so we can delete this product subcategory row
Update Production.Product
set ProductSubcategoryID = null
where ProductSubcategoryID = 38
-- now re-run the delete 
Delete from Production.ProductSubcategory 
where ProductSubcategoryID = 38
-- re-add our fancy items subcategory
insert into Production.ProductSubcategory
Values (2, 'Fancy items', newID(), GetDate())
-- change the product subcategoryID for all the new products we added
Update Production.Product 
set ProductSubcategoryID = 39 
where ProductID > 1000
-- Now delete all products where the name of the subcategory is 'fancy items'
-- again, start with the select statement
Select p.* 
From Production.Product p 
Join production.ProductSubcategory ps 
on p.ProductSubcategoryID = ps.ProductSubcategoryID
Where ps.name = 'Fancy Items'
-- now copy everything after the select clause and use it with the delete
Delete from Production.Product
From Production.Product p 
Join production.ProductSubcategory ps 
on p.ProductSubcategoryID = ps.ProductSubcategoryID
Where ps.name = 'Fancy Items'
select * from dbo.DatabaseLog
-- truncate the database log table
truncate table dbo.DatabaseLog
select * from dbo.DatabaseLog
-----------------------------------
-- Transactions
-----------------------------------
-- implicit transactions
Set implicit_transactions on 
Create table Test (
ID int identity(1,1), 
Name varchar(50)
)
-- select from our new table
Select * from test
-- add data
Insert into Test 
Values ('New Test')
-- its really here!
Select * from test
Rollback -- now the table doesn't exist
Select * from test
Set implicit_Transactions off
Drop table Test
-- Explicit transactions
Begin tran 
Create table Test (
ID int identity(1,1), 
Name varchar(50)
)
Select * from test
-- add data
Insert into Test 
Values ('New Test')
-- its really here!
Select * from test
Commit -- keep the table this time
Insert into Test 
Values ('New Test2')
Drop table Test
Begin Tran
Select @@TRANCOUNT
Rollback
Begin tran
Create table Test (
ID int identity(1,1), 
Name varchar(50)
)
-- create a "save point"
Save transaction TableCreate
-- now insert a row
Insert into Test 
Values ('New Test')
-- it exists
Select * from Test
-- rollback to the savepoint
Rollback transaction TableCreate
-- transaction still active
Select @@TRANCOUNT
-- row is not there
Select * from Test
-- commit the transaction
commit
-- transaction not running
Select @@TRANCOUNT
-- table exists but row doesn't
Select * from Test
Drop table Test
-- testing auto-rollback
Begin tran
Create table Test2 (
ID int identity(1,1), 
number int
)
Insert into Test2
Values (1)
Select * from Test2
Select @@TRANCOUNT
-- should throw an error - can't put text into a number column
Insert into Test2
Values ('Test one')
-- now the transaction isn't running
Select @@TRANCOUNT
-- transactions aren't the best way to handle validating DML statements
-- Backup tables are a better way to keep the data while we check if our DML commands were 'good'
-- Select Into lets you create a quick backup table
-- this creates a new table with the same structure, datatypes, etc (but not keys or constraints) and data as the one it came from
Select *
Into Production.Product_bkup -- new table name
From production.Product
-- let's write a bad update
Update Production.Product 
Set ListPrice = 0
--oops!
select * from Production.Product
-- so fix it from the backup table
Select p.ProductID, 
p.ListPrice,
b.ListPrice
from production.Product p
Join Production.Product_bkup b
on p.ProductID = b.ProductID
-- now write the update to fix it
Update Production.Product
Set ListPrice = b.ListPrice -- the backup table's list price
from production.Product p
Join Production.Product_bkup b
on p.ProductID = b.ProductID
-- all fixed
select * from Production.Product