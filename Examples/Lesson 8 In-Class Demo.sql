-- This is the base query we are going to work with
Select e.BusinessEntityID, e.FirstName, e.LastName,
e.JobTitle, e.Department, e.GroupName
From HumanResources.vEmployeeDepartment e

-- this is XML Raw - one node per row, each column is an attribute
Select e.BusinessEntityID, e.FirstName, e.LastName,
e.JobTitle, e.Department, e.GroupName
From HumanResources.vEmployeeDepartment e
For XML Raw

-- XML Auto - similar to XML raw but the name of the node is the table alias
Select e.BusinessEntityID, e.FirstName, e.LastName,
e.JobTitle, e.Department, e.GroupName
From HumanResources.vEmployeeDepartment e
For XML Auto



-- We could use that to our advantage and actually change the alias, so each row says "Employee"
Select Employee.BusinessEntityID, Employee.FirstName, Employee.LastName,
Employee.JobTitle, Employee.Department, Employee.GroupName
From HumanResources.vEmployeeDepartment Employee -- note the alias change here - each node comes out as "Employee"
For XML Auto

-- Add the Elements option to XML Auto. Now the fields are elements rather than attributes
Select Employee.BusinessEntityID, Employee.FirstName, Employee.LastName,
Employee.JobTitle, Employee.Department, Employee.GroupName
From HumanResources.vEmployeeDepartment Employee -- note the alias change here - each node comes out as "Employee"
For XML Auto, Elements

-- the PATH option lets you set the name of the node without using the table aliases
Select e.BusinessEntityID, e.FirstName, e.LastName,
e.JobTitle, e.Department, e.GroupName
From HumanResources.vEmployeeDepartment e
For XML Path ('Employee') -- this now names the nodes

-- the ROOT option lets you set the name of root (or header) of the XML document)
Select e.BusinessEntityID, e.FirstName, e.LastName,
e.JobTitle, e.Department, e.GroupName
From HumanResources.vEmployeeDepartment e
For XML Path ('Employee'), Root('Employees')

-- mixing attributes & Elements
Select e.BusinessEntityID as '@EmployeeID', e.FirstName, e.LastName,
e.JobTitle, e.Department, e.GroupName
From HumanResources.vEmployeeDepartment e
For XML Path ('Employee'), Root('Employees')


-- nesting nodes
-- show each department, then the employees within that department

-- query 1 - the department information
Select d.DepartmentID as '@Id', d.Name as DepartmentName, d.GroupName
From HumanResources.Department d
For XML Path('Department'), Root ('OrgStructure')

-- subquery: correlated subquery - we will have to tie the employees to the department we're "on"
-- we need to include the TYPE option otherwise when it is embedded as a subquery,
-- SQL Server will escape each < and > to make the XML believe it is a literal value rather than an XML symbol
-- at this point we really don't need the Department and GroupName fields selected in the subquery, but will leave them
-- for now just to show that it is matching them correctly
Select e.BusinessEntityID as '@EmployeeID', e.FirstName, e.LastName,
e.JobTitle, e.Department, e.GroupName
From HumanResources.vEmployeeDepartment e
where e.Department = ?
For XML Path ('Employee'), Root('Employees'), Type

-- Now put the queries together
Select d.DepartmentID as '@Id', d.Name as DepartmentName, d.GroupName,
	(Select e.BusinessEntityID as '@EmployeeID', e.FirstName, e.LastName,
	e.JobTitle, e.Department, e.GroupName
	From HumanResources.vEmployeeDepartment e
	where e.Department = d.Name -- correlate the queries here
	For XML Path ('Employee'), Root('Employees'), TYPE)
From HumanResources.Department d
For XML Path('Department'), Root ('OrgStructure')

---------------
-- JSON
---------------

-- keep using the same base query
Select e.BusinessEntityID, e.FirstName, e.LastName,
e.JobTitle, e.Department, e.GroupName
From HumanResources.vEmployeeDepartment e

-- For JSON Auto
-- this is usually pretty close to what is needed, just may need a little tweaking with extra options
Select e.BusinessEntityID, e.FirstName, e.LastName,
e.JobTitle, e.Department, e.GroupName
From HumanResources.vEmployeeDepartment e
For JSON Auto

-- For JSON Path
Select e.BusinessEntityID, e.FirstName, e.LastName,
e.JobTitle, e.Department, e.GroupName
From HumanResources.vEmployeeDepartment e
For JSON Path

-- The Root option for JSON
Select e.BusinessEntityID, e.FirstName, e.LastName,
e.JobTitle, e.Department, e.GroupName
From HumanResources.vEmployeeDepartment e
For JSON Path, ROOT ('Employees')

-- For JSON Path allows us to use .notation for restructuring
Select e.BusinessEntityID as 'Employee.Id', 
e.FirstName as 'Employee.FirstName', 
e.LastName as 'Employee.LastName',
e.JobTitle as 'Employee.JobTitle',
e.Department as 'Department.Name',
e.GroupName as 'Department.GroupName'
From HumanResources.vEmployeeDepartment e
For JSON Path, ROOT ('Employees')

-- same nesting-type example from XML
-- the main query
Select d.DepartmentID as 'Department.Id', d.Name as 'Department.Name', d.GroupName as 'Department.GroupName'
From HumanResources.Department d
For JSON Path, Root ('OrgStructure')

-- the subquery
Select e.BusinessEntityID as 'Employee.Id', 
e.FirstName as 'Employee.FirstName', 
e.LastName as 'Employee.LastName',
e.JobTitle as 'Employee.JobTitle'
From HumanResources.vEmployeeDepartment e
where e.Department = ?
For JSON Path, Root('Employees')

-- put them together...
Select d.DepartmentID as 'Department.Id', d.Name as 'Department.Name', d.GroupName as 'Department.GroupName',
(Select e.BusinessEntityID as 'Employee.Id', 
	e.FirstName as 'Employee.FirstName', 
	e.LastName as 'Employee.LastName',
	e.JobTitle as 'Employee.JobTitle'
	From HumanResources.vEmployeeDepartment e
	where e.Department = d.Name -- correlate the queries here
	For JSON Path) as Employees
From HumanResources.Department d
For JSON Path, Root ('OrgStructure')

-------------------------
-- Shredding XML
-------------------------

Declare @XML XML = 
'<OrgStructure>
<Department Id="12">
<Name>Document Control</Name>
<Employees>
<Employee Id="217">
<FirstName>Zainal</FirstName>
<LastName>Arifin</LastName>
<JobTitle>Document Control Manager</JobTitle>
</Employee>
<Employee Id="218">
<FirstName>Tengiz</FirstName>
<LastName>Kharatishvili</LastName>
<JobTitle>Control Specialist</JobTitle>
</Employee>
<Employee Id="219">
<FirstName>Sean</FirstName>
<LastName>Chai</LastName>
<JobTitle>Document Control Assistant</JobTitle>
</Employee>
<Employee Id="220">
<FirstName>Karen</FirstName>
<LastName>Berge</LastName>
<JobTitle>Document Control Assistant</JobTitle>
</Employee>
<Employee Id="221">
<FirstName>Chris</FirstName>
<LastName>Norred</LastName>
<JobTitle>Control Specialist</JobTitle>
</Employee>
</Employees>
</Department>
</OrgStructure>'
-- simply take a look at our data
--Select @XML

-- this will show everything under the department node
Select x.Dept.query('.') -- everything within the node
From @XML.nodes('/OrgStructure/Department') x(Dept) 

Declare @XML XML = 
'<OrgStructure>
<Department Id="12">
<Name>Document Control</Name>
<Employees>
<Employee Id="217">
<FirstName>Zainal</FirstName>
<LastName>Arifin</LastName>
<JobTitle>Document Control Manager</JobTitle>
</Employee>
<Employee Id="218">
<FirstName>Tengiz</FirstName>
<LastName>Kharatishvili</LastName>
<JobTitle>Control Specialist</JobTitle>
</Employee>
<Employee Id="219">
<FirstName>Sean</FirstName>
<LastName>Chai</LastName>
<JobTitle>Document Control Assistant</JobTitle>
</Employee>
<Employee Id="220">
<FirstName>Karen</FirstName>
<LastName>Berge</LastName>
<JobTitle>Document Control Assistant</JobTitle>
</Employee>
<Employee Id="221">
<FirstName>Chris</FirstName>
<LastName>Norred</LastName>
<JobTitle>Control Specialist</JobTitle>
</Employee>
</Employees>
</Department>
</OrgStructure>'
-- now show just the employees within the department
Select x.Empl.query('.') -- everything within the node
From @XML.nodes('/OrgStructure/Department/Employees') x(Empl) 


Declare @XML XML = 
'<OrgStructure>
<Department Id="12">
<Name>Document Control</Name>
<Employees>
<Employee Id="217">
<FirstName>Zainal</FirstName>
<LastName>Arifin</LastName>
<JobTitle>Document Control Manager</JobTitle>
</Employee>
<Employee Id="218">
<FirstName>Tengiz</FirstName>
<LastName>Kharatishvili</LastName>
<JobTitle>Control Specialist</JobTitle>
</Employee>
<Employee Id="219">
<FirstName>Sean</FirstName>
<LastName>Chai</LastName>
<JobTitle>Document Control Assistant</JobTitle>
</Employee>
<Employee Id="220">
<FirstName>Karen</FirstName>
<LastName>Berge</LastName>
<JobTitle>Document Control Assistant</JobTitle>
</Employee>
<Employee Id="221">
<FirstName>Chris</FirstName>
<LastName>Norred</LastName>
<JobTitle>Control Specialist</JobTitle>
</Employee>
</Employees>
</Department>
</OrgStructure>'
-- now show just the employees within the department
-- we get multiple rows now, because we got multiple nodes returned to us
-- we get one row per employee in the department
Select x.Empl.query('.') 
From @XML.nodes('/OrgStructure/Department/Employees/Employee') x(Empl) 

Declare @XML XML = 
'<OrgStructure>
<Department Id="12">
<Name>Document Control</Name>
<Employees>
<Employee Id="217">
<FirstName>Zainal</FirstName>
<LastName>Arifin</LastName>
<JobTitle>Document Control Manager</JobTitle>
</Employee>
<Employee Id="218">
<FirstName>Tengiz</FirstName>
<LastName>Kharatishvili</LastName>
<JobTitle>Control Specialist</JobTitle>
</Employee>
<Employee Id="219">
<FirstName>Sean</FirstName>
<LastName>Chai</LastName>
<JobTitle>Document Control Assistant</JobTitle>
</Employee>
<Employee Id="220">
<FirstName>Karen</FirstName>
<LastName>Berge</LastName>
<JobTitle>Document Control Assistant</JobTitle>
</Employee>
<Employee Id="221">
<FirstName>Chris</FirstName>
<LastName>Norred</LastName>
<JobTitle>Control Specialist</JobTitle>
</Employee>
</Employees>
</Department>
</OrgStructure>'
-- now actually get the values out
Select 
x.Empl.query('./FirstName').value('.', 'varchar(50)') as FirstName,
x.Empl.query('./LastName').value('.', 'varchar(50)') as LastName
From @XML.nodes('/OrgStructure/Department/Employees/Employee') x(Empl) 

-- now also grab data from higher-level nodes
Declare @XML XML = 
'<OrgStructure>
<Department Id="12">
<Name>Document Control</Name>
<Employees>
<Employee Id="217">
<FirstName>Zainal</FirstName>
<LastName>Arifin</LastName>
<JobTitle>Document Control Manager</JobTitle>
</Employee>
<Employee Id="218">
<FirstName>Tengiz</FirstName>
<LastName>Kharatishvili</LastName>
<JobTitle>Control Specialist</JobTitle>
</Employee>
<Employee Id="219">
<FirstName>Sean</FirstName>
<LastName>Chai</LastName>
<JobTitle>Document Control Assistant</JobTitle>
</Employee>
<Employee Id="220">
<FirstName>Karen</FirstName>
<LastName>Berge</LastName>
<JobTitle>Document Control Assistant</JobTitle>
</Employee>
<Employee Id="221">
<FirstName>Chris</FirstName>
<LastName>Norred</LastName>
<JobTitle>Control Specialist</JobTitle>
</Employee>
</Employees>
</Department>
</OrgStructure>'

Select x.Dept.value('@Id', 'int') as DepartmentID,
x.Dept.query('./Name').value('.', 'varchar(100)') as DepartmentName,
y.Empl.value('@Id','int') as EmployeeID,
y.Empl.query('./FirstName').value('.', 'varchar(50)') as FirstName,
y.Empl.query('./LastName').value('.', 'varchar(50)') as LastName
From @XML.nodes('./OrgStructure/Department') as x(Dept)
Cross apply x.Dept.nodes('./Employees/Employee') as y(Empl) -- cross apply the nodes method. the path is shortened because we already went down 2 levels

-------------------
-- Parsing JSON
-------------------

-- use nvarchar(max) as the datatype to store JSON
-- download the file from Canvas, then open in a text editor and copy the values out
Declare @JSON nvarchar(max) = '{"OrgStructure":[{"Department":{"Id":12,"Name":"Document Control"},"Employees":[{"Id":217,"FirstName":"Zainal","LastName":"Arifin","JobTitle":"Document Control Manager"},{"Id":218,"FirstName":"Tengiz","LastName":"Kharatishvili","JobTitle":"Control Specialist"},{"Id":219,"FirstName":"Sean","LastName":"Chai","JobTitle":"Document Control Assistant"},{"Id":220,"FirstName":"Karen","LastName":"Berge","JobTitle":"Document Control Assistant"},{"Id":221,"FirstName":"Chris","LastName":"Norred","JobTitle":"Control Specialist"}]}]}'

Select * 
From OpenJSON (@JSON, '$.OrgStructure')
With (DepartmentId int '$.Department.Id',
	DepartmentName varchar(100) '$.Department.Name')

-- if we also want the employee information, it gets a bit more complicated, just like it did with the XML
Declare @JSON nvarchar(max) = '{"OrgStructure":[{"Department":{"Id":12,"Name":"Document Control"},"Employees":[{"Id":217,"FirstName":"Zainal","LastName":"Arifin","JobTitle":"Document Control Manager"},{"Id":218,"FirstName":"Tengiz","LastName":"Kharatishvili","JobTitle":"Control Specialist"},{"Id":219,"FirstName":"Sean","LastName":"Chai","JobTitle":"Document Control Assistant"},{"Id":220,"FirstName":"Karen","LastName":"Berge","JobTitle":"Document Control Assistant"},{"Id":221,"FirstName":"Chris","LastName":"Norred","JobTitle":"Control Specialist"}]}]}'

Select departmentID, DepartmentName, EmployeeID, FirstName, LastName
From OpenJSON (@JSON, '$.OrgStructure')
With (DepartmentId int '$.Department.Id',
	DepartmentName varchar(100) '$.Department.Name',
	Employees nvarchar(max) as JSON) -- this returns the rest of the stuff as JSON for us to further work with
as Depts
Cross apply OpenJSON(Depts.Employees)
with (EmployeeID int '$.Id',
	FirstName varchar(50) '$.FirstName',
	LastName varchar(50) '$.LastName')
