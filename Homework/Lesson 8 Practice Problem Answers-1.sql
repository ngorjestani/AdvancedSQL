--1) Create a SQL statement that produces an XML document of orders and the products on each order. Include the SalesOrderID, OrderDate, DueDate, 
-- PurchaseOrderNumber, CustomerID, Subtotal, Tax, Freight, and Total. Display the Products on each order as its own node in the XML within 
-- the order – include the productID, name, quantity ordered, unitprice, and unit discount. Include a root element, and ensure that all fields 
-- are elements other than the OrderID – this should be an attribute. 
-- Make sure that each order only shows up once. Only include the 5 most recent orders
Select top 5 soh.SalesOrderID '@Id', soh.OrderDate, soh.DueDate, soh.PurchaseOrderNumber,
soh.CustomerID, soh.SubTotal, soh.TaxAmt, soh.Freight, soh.TotalDue ,
(Select p.ProductID '@Id', p.Name, sod.OrderQty, 
	sod.UnitPrice, sod.UnitPriceDiscount
	From Sales.SalesOrderDetail sod
	join production.Product p
	on sod.ProductID = p.ProductID
	where sod.SalesOrderID = soh.SalesOrderID
	For XML Path('Product'), Root('Products'), Elements, Type)
From Sales.SalesOrderHeader soh
Order by OrderDate desc
For XML Path('Order'), Root('Orders'), Elements

--2)	Same as #2, but use JSON. Make the products be a nested object. Make sure that each order only shows up once.
Select top 5 soh.SalesOrderID 'Order.Id', soh.OrderDate 'Order.OrderDate', 
soh.DueDate 'Order.DueDate', soh.PurchaseOrderNumber 'Order.PurchaseOrderNumber',
soh.CustomerID 'Order.CustomerID', soh.SubTotal 'Order.Subtotal', 
soh.TaxAmt 'Order.TaxAmt', soh.Freight 'Order.Freight', soh.TotalDue 'Order.TotalDue',
(Select p.ProductID 'Product.Id', p.Name 'Product.Name', sod.OrderQty 'Product.OrderQty', 
	sod.UnitPrice 'Product.UnitPrice', sod.UnitPriceDiscount 'Product.UnitPriceDiscount'
	From Sales.SalesOrderDetail sod
	join production.Product p
	on sod.ProductID = p.ProductID
	where sod.SalesOrderID = soh.SalesOrderID
	For JSON Path, Root('Products')) products 
From Sales.SalesOrderHeader soh
Order by OrderDate desc
For JSON Path, Root('Orders')


--3)	Using the XML file attached to the assignment, parse all the fields in 
-- the file except for the phone information

Declare @XML XML = '<Resume><Name><Prefix>Mr.</Prefix><First>Stephen</First><Middle>Y </Middle><Last>Jiang</Last><Suffix></Suffix></Name><Employment><StartDate>1998-03-01Z</StartDate><EndDate>2000-12-30Z</EndDate><OrgName>Wide World Imports</OrgName><JobTitle>Sales Manager</JobTitle><Responsibility> Managed a sales force of 20 sales representatives and 5 support staff distributed across 5 states. Also managed relationships with vendors for lead generation.Lead the effort to leverage IT capabilities to improve communication with the field. Improved lead-to-contact turnaround by 15 percent. Did all sales planning and forecasting. Re-mapped territory assignments for maximum sales force productivity. Worked with marketing to map product placement to sales strategy and goals.Under my management, sales increased 10% per year at a minimum.</Responsibility><FunctionCategory>Sales</FunctionCategory><IndustryCategory>Import/Export</IndustryCategory><Location><Location><CountryRegion>US </CountryRegion><State>WA </State><City>Renton</City></Location></Location></Employment><Employment><StartDate>1992-06-14Z</StartDate><EndDate>1998-06-01Z</EndDate><OrgName>Fourth Coffee</OrgName><JobTitle>Sales Associater</JobTitle><Responsibility>Selling product to supermarkets and cafes. Worked heavily with value-add techniques to increase sales volume, provide exposure to secondary products.Skilled at order development. Observed and built relationships with buyers that allowed me to identify opportunities for increased traffic.</Responsibility><FunctionCategory>Sales</FunctionCategory><IndustryCategory>Food and Beverage</IndustryCategory><Location><Location><CountryRegion>US </CountryRegion><State>WA </State><City>Spokane</City></Location></Location></Employment>
<Education><Level>Bachelor</Level><StartDate>1986-09-15Z</StartDate><EndDate>1990-05-20Z</EndDate><Degree>Bachelor of Arts and Science</Degree><Major>Business</Major><Minor></Minor><GPA>3.3</GPA><GPAScale>4</GPAScale><School>Louisiana Business College of New Orleans</School><Location><Location><CountryRegion>US </CountryRegion><State>LA</State><City>New Orleans</City></Location></Location></Education><Address><Type>Home</Type><Street>30 151st Place SE</Street><Location><Location><CountryRegion>US </CountryRegion><State>WA </State><City>Redmond</City></Location></Location><PostalCode>98052</PostalCode><Telephone><Telephone><Type>Voice</Type><IntlCode>1</IntlCode><AreaCode>425</AreaCode><Number>555-1119</Number></Telephone><Telephone><Type>Voice</Type><IntlCode>1</IntlCode><AreaCode>425</AreaCode><Number>555-1981</Number></Telephone></Telephone></Address><EMail>Stephen@example.com</EMail><WebSite></WebSite></Resume>'

Select r.Resume.query('./Name/Prefix').value('.','varchar(10)') as Prefix, 
 r.Resume.query('./Name/First').value('.','varchar(20)') as FirstName,
 r.Resume.query('./Name/Middle').value('.','varchar(20)') as MiddleName,
 r.Resume.query('./Name/Last').value('.','varchar(20)') as LastName,
 r.Resume.query('./Name/Suffix').value('.','varchar(10)') as Suffix,
 e.Employment.query('./StartDate').value('.','Date') as StartDate,
 e.Employment.query('./EndDate').value('.','Date') as EndDate,
 e.Employment.query('./OrgName').value('.','varchar(30)') as CompanyName,
 e.Employment.query('./JobTitle').value('.','varchar(30)') as JobTitle,
 e.Employment.query('./Responsibility').value('.','varchar(100)') as Responsibility,
 e.Employment.query('./FunctionCategory').value('.','varchar(20)') as FunctionCategory,
 e.Employment.query('./IndustryCategory').value('.','varchar(20)') as IndustryCategory,
 e.Employment.query('./Location/Location/CountryRegion').value('.','varchar(50)') as CountryRegion,
 e.Employment.query('./Location/Location/State').value('.','varchar(50)') as State,
 e.Employment.query('./Location/Location/City').value('.','varchar(50)') as City
 from @xml.nodes('/Resume') r(Resume)
 cross apply r.Resume.nodes('./Employment') e(Employment)


-- 4) The Lesson 12 Practice Problem JSON  Download Lesson 12 Practice Problem JSON file contains Employee changes 
-- (new employees and changes to existing employees) from AdventureWorks’ separate HR system. 
-- Integrate the information, then test to ensure the changes worked.
-- 		Create a procedure that takes a JSON string and merges the data into the Person.Person and HumanResources.Employee tables.
--		Define the test cases. Document all the test cases you can think of for the procedure.
--		Perform testing! Include the SQL for the tests you performed
--		Document the outcome of each test. Was the test successful? Why or why not?
--		Document any errors you found


go
/****************************************
* Author: NKowalchuk
* Create Date: 11/19/20
*
* This procedure accepts a JSON document containing Employee change information
* from the HR System. It will first parse the JSON document,
* then link employees to business entities based on the nationalID field 
* If the employee is new, it will insert a row into the business entity table,
* then into the person and employee tables. If the employee already exists, 
* data in the person and employee tables will be updated.
*
*
*
*
******************************************/
Create Procedure HumanResources.ETL_HRSystem
(@JSON nvarchar(Max))
as
    Begin
    -- First parse the JSON, and put the results into a temp table
    Select * into #employees
    From OPENJSON(@JSON, '$.EmployeeChanges')
    with (NationalID varchar(9) '$.Person.NationalID',
        FirstName varchar(50) '$.Person.FirstName',
        LastName varchar(50) '$.Person.LastName',
        MiddleName varchar(50) '$.Person.MiddleName',
        Birthdate date '$.Person.BirthDate',
        MaritalStatus char(1) '$.Person.MaritalStatus',
        Gender char(1) '$.Person.Gender',
        Login varchar(100) '$.Person.Login',
        JobTitle varchar(100) '$.Person.JobTitle',
        HireDate Date '$.Person.HireDate',
        IsSalaried bit '$.Person.IsSalaried',
        VacationHours smallint '$.Person.VacationHours',
        SickLeaveHours smallint '$.Person.SickLeaveHours',
        CurrentFlag bit '$.Person.CurrentFlag')

    -- alter the temp table to add the business entity ID
    Alter table #Employees
    Add BusinessEntityID int

    -- get the business entity IDs for existing employees
    Update #Employees 
    Set BusinessEntityID = hre.BusinessEntityID
    From #Employees e 
    Join HumanResources.Employee hre 
    on e.nationalID = hre.NationalIDNumber 

    -- get the rows that don't have employeeIDs
    Select NationalID into #newEmployees
    From #employees
    where businessEntityID is NULL

    -- add new business entity IDs for the new people
    Declare @B_ID int
    Declare @N_ID varchar(9)
    While (Select count(*) from #newEmployees) > 0
    BEGIN
        Select @N_ID = (select top 1 NationalID from #newEmployees)

        insert into Person.BusinessEntity(ModifiedDate)
        Values(GetDate())

        Select @B_ID = SCOPE_IDENTITY()

        Update #employees 
        set BusinessEntityID = @B_ID
        Where NationalID = @N_ID

        Delete from #newEmployees where nationalID = @N_ID

    END

    -- now merge into the person table
    Merge into Person.Person as tgt
    using (Select e.BusinessEntityID, 'EM' as PersonType, FirstName, MiddleName, LastName
        From #employees e) as src 
    on tgt.BusinessEntityID = src.BusinessEntityID
    When matched then
        Update set FirstName = src.FirstName,
            LastName = src.LastName,
            MiddleName = src.MiddleName,
            ModifiedDate = GetDate()
    When not matched by target then 
        Insert(BusinessEntityID, PersonType, FirstName, MiddleName, LastName, ModifiedDate)
        Values (src.BusinessEntityID, src.PersonType, src.FirstName, src.MiddleName, src.LastName, GetDate())
    ;


    -- now merge into the employee table
    Merge into HumanResources.Employee as tgt
    using #Employees as src 
    on tgt.BusinessEntityID = src.BusinessEntityID
    when matched then 
        Update Set LoginID = src.Login,
            JobTitle = src.JobTitle,
            BirthDate = src.BirthDate,
            MaritalStatus = src.MaritalStatus,
            Gender = src.Gender,
            HireDate = src.HireDate,
            SalariedFlag = src.IsSalaried,
            VacationHours = src.VacationHours,
            SickLeaveHours = src.SickLeaveHours,
            CurrentFlag = src.CurrentFlag,
            ModifiedDate = GetDate()
    When not matched by target then 
        insert (BusinessEntityID, 
            NationalIDNumber,
            LoginID, 
            JobTitle,
            BirthDate,
            MaritalStatus,
            Gender,
            HireDate,
            SalariedFlag,
            VacationHours,
            SickLeaveHours,
            CurrentFlag,
            ModifiedDate)
        Values (BusinessEntityID,
            src.NationalID,
            src.Login,
            src.JobTitle,
            src.BirthDate,
            src.MaritalStatus,
            src.Gender,
            src.HireDate,
            src.IsSalaried,
            src.VacationHours,
            src.SickLeaveHours,
            src.CurrentFlag,
            GetDate())
    ;

    Drop table #employees
    Drop table #newEmployees

End
Go

Declare @JSON nvarchar(max) ='{"EmployeeChanges":
	[
		{"Person":{"NationalID":"30845",
				"FirstName":"David",
				"LastName":"Liu",
				"MiddleName":"J",
				"BirthDate":"1986-08-08",
				"MaritalStatus":"M",
				"Gender":"M",
				"Login":"adventure-works\\david6",
				"JobTitle":"Accounts Manager",
				"HireDate":"2012-03-03",
				"IsSalaried":true,
				"VacationHours":57,
				"SickLeaveHours":48,
				"CurrentFlag":false}},
		{"Person":{"NationalID":"363910111",
				"FirstName":"Barbara",
				"LastName":"Moreland",
				"MiddleName":"C",
				"BirthDate":"1979-02-04",
				"MaritalStatus":"M",
				"Gender":"F",
				"Login":"adventure-works\\barbara1",
				"JobTitle":"Accounts Manager",
				"HireDate":"2012-03-22",
				"IsSalaried":true,
				"VacationHours":80,
				"SickLeaveHours":49,
				"CurrentFlag":true}},
		{"Person":{"NationalID":"239356823",
				"FirstName":"Tom",
				"LastName":"Jones",
				"MiddleName":"A",
				"BirthDate":"1990-04-21",
				"MaritalStatus":"S",
				"Gender":"M",
				"Login":"adventure-works\\tom1",
				"JobTitle":"Accountant",
				"HireDate":"2018-12-01",
				"IsSalaried":true,
				"VacationHours":80,
				"SickLeaveHours":80,
				"CurrentFlag":true}},
		{"Person":{"NationalID":"399771412",
				"FirstName":"Jenny",
				"LastName":"Sommers",
				"MiddleName":"Joy",
				"BirthDate":"1997-02-18",
				"MaritalStatus":"S",
				"Gender":"F",
				"Login":"adventure-works\\jenny0",
				"JobTitle":"Help Desk Intern",
				"HireDate":"2018-12-13",
				"IsSalaried":false,
				"VacationHours":0,
				"SickLeaveHours":20,
				"CurrentFlag":true}}
	]
}'

Exec HumanResources.ETL_HRSystem @JSON