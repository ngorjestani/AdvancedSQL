-- here are the fields from the file ProductName,ProductNumber,SafetyStockLevel,ReorderPoint,StandardCost,ListPrice,Subcategory,SellStartDate
-- with bulk insert, we need to already have a table to insert these into
-- data types for columns selected based on the production.product table, as this is where the data will end up
-- since this table isn't meant to be permanent, we aren't going to worry about a pk or constraints or anything
Create table dbo.NewProducts(
ProductName nvarchar(50),
ProductNumber nvarchar(25),
SafetyStockLevel smallint,
ReorderPoint smallint,
StandardCost money,
ListPrice money,
Subcategory nvarchar(50),
SellStartDate datetime)
-- now bulk insert the new products file
-- it does exist on the server at D:\Backups\Archive\Adv_SQL\Lesson 5 - New Products.csv
Bulk insert NewProducts
From 'D:\Backups\Archive\Adv_SQL\Lesson 5 - New Products.csv' -- location ON THE SERVER! not your computer
with (FieldTerminator = ',',FirstRow = 2)
-- and here's the data
Select * from NewProducts
-- after import export wizard
Select * from NewProducts_ImportExportWizard
-- after flat file import wizard
Select * from NewProducts_FlatFileImport
-- after azure data studio import wizard
select * from NewProducts_azureDataStudio
-- string functions
-- substring, left, right all return pieces of a string
Select np.ProductName,
Substring(np.ProductName, 1, 3), -- start at position 1 (SQL is 1-based) and go for3 characters
Substring(np.ProductName, 5, 4), -- starts at position 5, return the next 4 characters
Left(np.ProductName, 5),
Right(np.ProductName, 3)
from NewProducts np
-- string split is a table-valued function - we use it in the from clause
Select *
From String_Split('here is my fancy string', ' ')
-- or with a cross apply for a real-life example
Select np.ProductName, sp.value
From newProducts np
cross apply (Select * from String_Split(np.ProductName, ' ')) sp
-- reverse mirrors the string around
Select np.ProductName, reverse(np.ProductName) reveresed
From NewProducts np
-- Stuff literally stuffs one string inside another
Select np.ProductName,
stuff(np.ProductName, 3, 4, 'NewString') -- start at position 3, remove 4 characters and put "NewString" in their place
From NewProducts np
-- some combo examples with substring
-- pull the first word of the product name
-- substring from the beginning of the word until we find the space
Select np.ProductName,
Charindex(' ', np.ProductName) posOfSpace,
PATINDEX('% %', np.ProductName) posOfSpacePatindex,
substring(np.productName, 1, Charindex(' ', np.ProductName) - 1)
FirstWordOfProductName, -- remove one character from the position of the space so it isn't included in the output
len(np.ProductName) lengthOfString,
Substring(np.ProductName, -- substring this field
Charindex(' ', np.ProductName), -- start at the position of the space
len(np.ProductName) - Charindex(' ', np.ProductName) + 1 -- go for the lengthof the string minus the position of the space, plus one character because the last one got cut off
) as RemainderOfProductName
From NewProducts np
-- grab the last word of the product name
-- use reverse to help us out
Select np.ProductName,
reverse(np.ProductName), -- reverse it so we can find the 'first' word
Charindex(' ', reverse(np.ProductName)) FirstSpacePos,
substring(reverse(np.ProductName), 1, Charindex(' ', reverse(np.ProductName)) - 1)
LastWordOfProductNameReversed,
reverse(substring(reverse(np.ProductName), 1, Charindex(' ',
reverse(np.ProductName)) - 1)) LastWordOfProductName
From NewProducts np
-- replicate and space
-- returns the requested number of the character
Select replicate('A', 10) + space(2) + replicate('B', 3)
-- this can also be used with columns
select replicate(np.ProductName, 3)
From newProducts np
-- trims
Select ' string1 ',
Ltrim(' string1 ') Ltrimmed,
Rtrim(' string1 ') Rtrimmed,
Trim(' string1 ') Trimmed
-- replace replaces a value if found; if not, returns the original string
Select np.ProductName,
replace(np.ProductName, 'Unicorn','Dragon')
From newProducts np
-- multiple replaces
Select '(123)-456-7890',
Replace(Replace(Replace('(123)-456-7890', '(', ''), ')', ''), '-', ' '),
Trim(Translate('(123)-456-7890', '()-', '   ')),
Translate('[123]-123-1234', '[]-','() ') --replaces the found characters in the first string with the matching character in the second (based on character position)
-- concat concatenates. it also does data type conversion to strings
-- this fails with a type conversion error
Select np.ProductName + ' ' + np.ListPrice
From NewProducts np
-- this does not
Select Concat(np.ProductName, ' ', np.ListPrice)
From NewProducts np
-- concat_ws <- ws means with separator. puts the separator BETWEEN the columns to concat
Select CONCAT_WS( ';', np.productName, Np.ListPrice, np.StandardCost) -- separator goes first, then the columns to concatenate
From NewProducts np
-- string_agg is a new-ish aggregate function
Select string_agg( np.ProductName, ';')
From NewProducts np
-- better real example
-- show all products in the subcategory on one row, all put together and separated by a ;
Select ps.name Subcategory, string_agg(p.name, '; ') Products
From production.product p
join production.ProductSubcategory ps
on p.ProductSubcategoryID = ps.ProductSubcategoryID
Group by ps.Name
Order by ps.Name
-- case conversion
Select np.ProductName,
upper(np.ProductName),
lower(np.ProductName)
From NewProducts np
-- Most SQL Server databases are not case sensitive
-- all of the below queries return the same row
Select *
From NewProducts
where ProductName = 'Unicorn Helmet'
Select *
From NewProducts
where ProductName = 'unicorn helmet'
Select *
From NewProducts
where ProductName = 'UNICORN HELMET'
-- all collations in the system
select * from sys.fn_helpcollations()
where name like '%Latin%'
order by name
-- searching with a case sensitive collation
-- this still returns a row, because its stored exactly like this
Select *
From NewProducts
where ProductName = 'Unicorn Helmet' Collate SQL_Latin1_General_CP1_CS_AS
-- this doesn't return a row; case doesn't match what is stored in the db
Select *
From NewProducts
where ProductName = 'unicorn helmet' Collate SQL_Latin1_General_CP1_CS_AS
-- this doesn't return a row; case doesn't match what is stored in the db
Select *
From NewProducts
where ProductName = 'UNICORN HELMET' Collate SQL_Latin1_General_CP1_CS_AS
-- collation can be changed per table, per column, etc.
-- ONLY the productName is now case sensitive
Create table dbo.NewProductsCaseSensitive(
ProductName nvarchar(50) collate SQL_Latin1_General_CP1_CS_AS,
ProductNumber nvarchar(25),
SafetyStockLevel smallint,
ReorderPoint smallint,
StandardCost money,
ListPrice money,
Subcategory nvarchar(50),
SellStartDate datetime)
Bulk insert NewProductsCaseSensitive
From 'D:\Backups\Archive\Adv_SQL\Lesson 5 - New Products.csv' -- location ON THE SERVER! not your computer
with (
FieldTerminator = ',',
FirstRow = 2
)
-- prove its case sensitive for the productName column
Select * from NewProductsCaseSensitive
Where ProductName = 'UNICORN HELMET'
-- prove other string columns are not
Select * from NewProductsCaseSensitive
where productNumber = 'uh98342'
-- implicit conversion occurring
Select *
From NewProducts np
where ReorderPoint >= '45' -- This is a string because its in quotes
-- cast and convert
Select np.StandardCost,
cast(np.standardCost as int),
Convert(int, np.StandardCost)
From NewProducts np
-- Removing extra decimal places
Select np.StandardCost * 1.015 as calc,
cast(np.StandardCost * 1.015 as numeric(4,2)) as CastCol, -- 4 total digits, 2 are decimals
convert(numeric(4,2), np.StandardCost * 1.015) as ConvertCol,
Format( np.StandardCost * 1.015, 'N2') as FormatCol
into NewPrices
From newProducts np
-- here's the table it created
CREATE TABLE [dbo].[NewPrices](
[calc] [numeric](24, 7) NULL,
[CastCol] [numeric](4, 2) NULL,
[ConvertCol] [numeric](4, 2) NULL,
[FormatCol] [nvarchar](4000) NULL
) ON [PRIMARY]
GO
-- convert and format can change the display of dates; both return strings rather than date datatypes
Select GetDate(), -- the date
Convert(Varchar, GetDate(), 101) , -- converted
Format(GetDate(), 'MM/dd/yyyy'), -- formatted
Convert(varchar, getDate(), 113)