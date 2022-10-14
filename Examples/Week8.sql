-- base query
select e.BusinessEntityID,
       e.FirstName,
       e.LastName
from HumanResources.vEmployeeDepartment e

-- xml raw
select e.BusinessEntityID,
       e.FirstName,
       e.LastName
from HumanResources.vEmployeeDepartment e
for xml raw

-- xml auto
select e.BusinessEntityID,
       e.FirstName,
       e.LastName
from HumanResources.vEmployeeDepartment e
for xml auto, elements

-- xml path & root
select e.BusinessEntityID '@ID',
       e.FirstName,
       e.LastName
from HumanResources.vEmployeeDepartment e
for xml path('Employee'), root('Employees')

-- Nesting nodes
select d.DepartmentID,
       d.Name as DepartmentName,
       d.GroupName
from HumanResources.Department d
for xml path('Department'), root('OrgStructure')

-- json
select d.DepartmentID,
       d.Name as DepartmentName,
       d.GroupName
from HumanResources.Department d
for json auto