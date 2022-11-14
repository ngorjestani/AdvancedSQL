-- Let's add some new products
-- if there is no column list, we need a value for every column (excluding identities)
INSERT INTO Production.Product
VALUES ('Helmet with Visor', 'H01234', 0, 1, 'Pink', 15, 10, 12.39, 29.99, 'Adult',
        NULL, NULL, NULL, 0, NULL, NULL, NULL, 31, NULL, '9/15/2021', NULL, NULL, NEWID(),
        GETDATE())
SELECT *
FROM Production.product
ORDER BY ProductID DESC
-- now insert with a column list, and add multiple rows at a time
-- this will throw an error because the product names are duplicates
INSERT INTO Production.Product (Name, ProductNumber, Color, ListPrice,
                                StandardCost, MakeFlag, FinishedGoodsFlag, SafetyStockLevel, ReorderPoint,
                                DaysToManufacture, SellStartDate, rowguid, ModifiedDate)
VALUES ('Spiked Pedals', 'SP012354', 'Orange', 140.00, 56.90, 0, 1, 100, 50, 0,
        '9/6/2022', NEWID(), GETDATE()),
       ('Spiked Pedals', 'SP012355', 'Red', 140.00, 56.90, 0, 1, 100, 50, 0, '9/6/2022',
        NEWID(), GETDATE()),
       ('Spiked Pedals', 'SP012356', 'Black', 140.00, 56.90, 0, 1, 100, 50, 0, '9/6/2022',
        NEWID(), GETDATE()),
       ('Spiked Pedals', 'SP012357', 'Neon Green', 140.00, 56.90, 0, 1, 100, 50, 0, NULL,
        NEWID(), GETDATE())
-- try again 
-- you'll notice two IDs are skipped - this is because it tried to insert 2 rows earlier and hit the duplicate value for the name
-- which violated the constraint and caused the rows not to be inserted
INSERT INTO Production.Product (Name, ProductNumber, Color, ListPrice,
                                StandardCost, MakeFlag, FinishedGoodsFlag, SafetyStockLevel, ReorderPoint,
                                DaysToManufacture, SellStartDate, rowguid, ModifiedDate)
VALUES ('Spiked Pedals - Orange', 'SP012354', 'Orange', 140.00, 56.90, 0, 1, 100,
        50, 0, '9/6/2022', NEWID(), GETDATE()),
       ('Spiked Pedals - Red', 'SP012355', 'Red', 140.00, 56.90, 0, 1, 100, 50, 0,
        '9/6/2022', NEWID(), GETDATE()),
       ('Spiked Pedals - Black', 'SP012356', 'Black', 140.00, 56.90, 0, 1, 100, 50, 0,
        '9/6/2022', NEWID(), GETDATE()),
       ('Spiked Pedals - Green', 'SP012357', 'Neon Green', 140.00, 56.90, 0, 1, 100, 50, 0,
        '9/6/2022', NEWID(), GETDATE())
SELECT TOP 5 *
FROM production.Product
ORDER BY ProductID DESC
-- typically this would come from an actual table, rather than just selecting the values
-- but the concept is the same
-- columns selected must match the order set by the column list (or the table if nocolumn list)
INSERT INTO Production.Product (Name, ProductNumber, Color, ListPrice,
                                StandardCost, MakeFlag, FinishedGoodsFlag, SafetyStockLevel, ReorderPoint,
                                DaysToManufacture, SellStartDate, rowguid, ModifiedDate)
SELECT 'Spiked Pedals - Blue',
       'SP012358',
       'Blue',
       140.00,
       56.90,
       0,
       1,
       100,
       50,
       0,
       '9/6/2022',
       NEWID(),
       GETDATE()
-- forcing a value into an identity column
-- must use a column list and must include the identity column and its value
-- must turn the identity insert on before running and off after
SET IDENTITY_INSERT Production.product ON
-- Let's add some new products
-- if there is no column list, we need a value for every column (excluding identities)
INSERT INTO Production.Product
VALUES ('Helmet with Visor', 'H01234', 0, 1, 'Pink', 15, 10, 12.39, 29.99, 'Adult',
        NULL, NULL, NULL, 0, NULL, NULL, NULL, 31, NULL, '9/15/2021', NULL, NULL, NEWID(),
        GETDATE())
SELECT *
FROM Production.product
ORDER BY ProductID DESC
-- now insert with a column list, and add multiple rows at a time
-- this will throw an error because the product names are duplicates
INSERT INTO Production.Product (Name, ProductNumber, Color, ListPrice,
                                StandardCost, MakeFlag, FinishedGoodsFlag, SafetyStockLevel, ReorderPoint,
                                DaysToManufacture, SellStartDate, rowguid, ModifiedDate)
VALUES ('Spiked Pedals', 'SP012354', 'Orange', 140.00, 56.90, 0, 1, 100, 50, 0,
        '9/6/2022', NEWID(), GETDATE()),
       ('Spiked Pedals', 'SP012355', 'Red', 140.00, 56.90, 0, 1, 100, 50, 0, '9/6/2022',
        NEWID(), GETDATE()),
       ('Spiked Pedals', 'SP012356', 'Black', 140.00, 56.90, 0, 1, 100, 50, 0, '9/6/2022',
        NEWID(), GETDATE()),
       ('Spiked Pedals', 'SP012357', 'Neon Green', 140.00, 56.90, 0, 1, 100, 50, 0, NULL,
        NEWID(), GETDATE())
-- try again 
-- you'll notice two IDs are skipped - this is because it tried to insert 2 rows earlier and hit the duplicate value for the name
-- which violated the constraint and caused the rows not to be inserted
INSERT INTO Production.Product (Name, ProductNumber, Color, ListPrice,
                                StandardCost, MakeFlag, FinishedGoodsFlag, SafetyStockLevel, ReorderPoint,
                                DaysToManufacture, SellStartDate, rowguid, ModifiedDate)
VALUES ('Spiked Pedals - Orange', 'SP012354', 'Orange', 140.00, 56.90, 0, 1, 100,
        50, 0, '9/6/2022', NEWID(), GETDATE()),
       ('Spiked Pedals - Red', 'SP012355', 'Red', 140.00, 56.90, 0, 1, 100, 50, 0,
        '9/6/2022', NEWID(), GETDATE()),
       ('Spiked Pedals - Black', 'SP012356', 'Black', 140.00, 56.90, 0, 1, 100, 50, 0,
        '9/6/2022', NEWID(), GETDATE()),
       ('Spiked Pedals - Green', 'SP012357', 'Neon Green', 140.00, 56.90, 0, 1, 100, 50, 0,
        '9/6/2022', NEWID(), GETDATE())
SELECT TOP 5 *
FROM production.Product
ORDER BY ProductID DESC
-- typically this would come from an actual table, rather than just selecting the values
-- but the concept is the same
-- columns selected must match the order set by the column list (or the table if nocolumn list)
INSERT INTO Production.Product (Name, ProductNumber, Color, ListPrice,
                                StandardCost, MakeFlag, FinishedGoodsFlag, SafetyStockLevel, ReorderPoint,
                                DaysToManufacture, SellStartDate, rowguid, ModifiedDate)
SELECT 'Spiked Pedals - Blue',
       'SP012358',
       'Blue',
       140.00,
       56.90,
       0,
       1,
       100,
       50,
       0,
       '9/6/2022',
       NEWID(),
       GETDATE()
-- forcing a value into an identity column
-- must use a column list and must include the identity column and its value
-- must turn the identity insert on before running and off after
SET IDENTITY_INSERT Production.product ON
INSERT INTO Production.Product (ProductID, Name, ProductNumber, Color, ListPrice,
                                StandardCost, MakeFlag, FinishedGoodsFlag, SafetyStockLevel, ReorderPoint,
                                DaysToManufacture, SellStartDate, rowguid, ModifiedDate)
SELECT 1007,
       'Spiked Pedals - Purple',
       'SP012359',
       'Purple',
       140.00,
       56.90,
       0,
       1,
       100,
       50,
       0,
       '9/6/2022',
       NEWID(),
       GETDATE()
SET IDENTITY_INSERT Production.product OFF
-- There is a way to fix the gap - say you try to insert a large number of rows andit fails,
-- and you want to go back before you try again
-- I re-ran a failed insert statement a few times to get a gap
-- 1008 is the last data value we had
-- to see the next 'slated' value of the identity, we can use dbcc checkident
DBCC CHECKIDENT ('production.product')
-- output: Checking identity information: current identity value '1023', current column value '1008'.
-- we can reset it back to an older value if we want/need to
DBCC CHECKIDENT ('production.product', RESEED, 1008)
INSERT INTO Production.Product (Name, ProductNumber, Color, ListPrice,
                                StandardCost, MakeFlag, FinishedGoodsFlag, SafetyStockLevel, ReorderPoint,
                                DaysToManufacture, SellStartDate, rowguid, ModifiedDate)
SELECT 'Spiked Pedals - Yellow',
       'SP012360',
       'Yellow',
       140.00,
       56.90,
       0,
       1,
       100,
       50,
       0,
       '9/6/2022',
       NEWID(),
       GETDATE()
-- the Scope_Identity() function returns the value of the last identity inserted onthe connection
SELECT SCOPE_IDENTITY()
-----------
-- Updates
-----------
-- start by writing a select statement that identifies the rows to be modified
SELECT *
FROM Production.Product p
WHERE p.name LIKE 'Spiked Pedals - %'
-- steal the where-clause to use in our actual update
UPDATE Production.Product
SET Size                 = 'Med',
    ProductSubcategoryID = 13
WHERE name LIKE 'Spiked Pedals - %'
-- we decided for random reasons, we don't want to work with vendors in Texas anymore. Inactivate them
SELECT v.*
FROM Purchasing.Vendor v
         JOIN Purchasing.vVendorWithAddresses va
              ON v.BusinessEntityID = va.BusinessEntityID
WHERE va.StateProvinceName = 'Texas'
-- now that we've identified the rows, do the update statement
UPDATE Purchasing.Vendor
SET ActiveFlag = 0
FROM Purchasing.Vendor v
         JOIN Purchasing.vVendorWithAddresses va
              ON v.BusinessEntityID = va.BusinessEntityID
WHERE va.StateProvinceName = 'Texas'
--------------
-- Delete
--------------
SELECT *
FROM Production.Product
WHERE FinishedGoodsFlag = 1
-- try to delete a product that has been sold (ID 717) - this will not work - foreign key constraint
DELETE
FROM Production.Product
WHERE ProductID = 717
-- delete one of our new products (ID 1000)
DELETE
FROM Production.Product
WHERE ProductID = 1000
SELECT *
FROM Production.ProductSubcategory
INSERT INTO Production.ProductSubcategory
VALUES (2, 'Fancy items', NEWID(), GETDATE())
-- change the product subcategoryID for all the new products we added
UPDATE Production.Product
SET ProductSubcategoryID = 38
WHERE ProductID > 1000
-- now we decide we want to delete 'fancy items' subcategory
DELETE
FROM Production.ProductSubcategory
WHERE ProductSubcategoryID = 38
-- for now, set those products' subcategoryID null so we can delete this product subcategory row
UPDATE Production.Product
SET ProductSubcategoryID = NULL
WHERE ProductSubcategoryID = 38
-- now re-run the delete 
DELETE
FROM Production.ProductSubcategory
WHERE ProductSubcategoryID = 38
-- re-add our fancy items subcategory
INSERT INTO Production.ProductSubcategory
VALUES (2, 'Fancy items', NEWID(), GETDATE())
-- change the product subcategoryID for all the new products we added
UPDATE Production.Product
SET ProductSubcategoryID = 39
WHERE ProductID > 1000
-- Now delete all products where the name of the subcategory is 'fancy items'
-- again, start with the select statement
SELECT p.*
FROM Production.Product p
         JOIN production.ProductSubcategory ps
              ON p.ProductSubcategoryID = ps.ProductSubcategoryID
WHERE ps.name = 'Fancy Items'
-- now copy everything after the select clause and use it with the delete
DELETE
FROM Production.Product
FROM Production.Product p
         JOIN production.ProductSubcategory ps
              ON p.ProductSubcategoryID = ps.ProductSubcategoryID
WHERE ps.name = 'Fancy Items'
SELECT *
FROM dbo.DatabaseLog
-- truncate the database log table
TRUNCATE TABLE dbo.DatabaseLog
SELECT *
FROM dbo.DatabaseLog
-----------------------------------
-- Transactions
-----------------------------------
-- implicit transactions
SET IMPLICIT_TRANSACTIONS ON
CREATE TABLE Test
(
    ID   INT IDENTITY (1,1),
    Name VARCHAR(50)
)
-- select from our new table
SELECT *
FROM test
-- add data
INSERT INTO Test
VALUES ('New Test')
-- its really here!
SELECT *
FROM test
ROLLBACK -- now the table doesn't exist
SELECT *
FROM test
SET IMPLICIT_TRANSACTIONS OFF
DROP TABLE Test
-- Explicit transactions
BEGIN TRAN
CREATE TABLE Test
(
    ID   INT IDENTITY (1,1),
    Name VARCHAR(50)
)
SELECT *
FROM test
-- add data
INSERT INTO Test
VALUES ('New Test')
-- its really here!
SELECT *
FROM test
COMMIT -- keep the table this time
INSERT INTO Test
VALUES ('New Test2')
DROP TABLE Test
BEGIN TRAN
SELECT @@TRANCOUNT
ROLLBACK
BEGIN TRAN
CREATE TABLE Test
(
    ID   INT IDENTITY (1,1),
    Name VARCHAR(50)
)
-- create a "save point"
SAVE TRANSACTION TableCreate
-- now insert a row
INSERT INTO Test
VALUES ('New Test')
-- it exists
SELECT *
FROM Test
-- rollback to the savepoint
ROLLBACK TRANSACTION TableCreate
-- transaction still active
SELECT @@TRANCOUNT
-- row is not there
SELECT *
FROM Test
-- commit the transaction
COMMIT
-- transaction not running
SELECT @@TRANCOUNT
-- table exists but row doesn't
SELECT *
FROM Test
DROP TABLE Test
-- testing auto-rollback
BEGIN TRAN
CREATE TABLE Test2
(
    ID     INT IDENTITY (1,1),
    number INT
)
INSERT INTO Test2
VALUES (1)
SELECT *
FROM Test2
SELECT @@TRANCOUNT
-- should throw an error - can't put text into a number column
INSERT INTO Test2
VALUES ('Test one')
-- now the transaction isn't running
SELECT @@TRANCOUNT
-- transactions aren't the best way to handle validating DML statements
-- Backup tables are a better way to keep the data while we check if our DML commands were 'good'
-- Select Into lets you create a quick backup table
-- this creates a new table with the same structure, datatypes, etc (but not keys or constraints) and data as the one it came from
SELECT *
INTO Production.Product_bkup -- new table name
FROM production.Product
-- let's write a bad update
UPDATE Production.Product
SET ListPrice = 0
--oops!
SELECT *
FROM Production.Product
-- so fix it from the backup table
SELECT p.ProductID,
       p.ListPrice,
       b.ListPrice
FROM production.Product p
         JOIN Production.Product_bkup b
              ON p.ProductID = b.ProductID
-- now write the update to fix it
UPDATE Production.Product
SET ListPrice = b.ListPrice -- the backup table's list price
FROM production.Product p
         JOIN Production.Product_bkup b
              ON p.ProductID = b.ProductID
-- all fixed
SELECT *
FROM Production.Product