select *
from HumanResources.EmployeePayHistory eph

-- set up the table to have a new primary key
alter table HumanResources.EmployeePayHistory
add EmployeePayHistoryId int identity (1,1)

alter table HumanResources.EmployeePayHistory
drop constraint PK_EmployeePayHistory_BusinessEntityID_RateChangeDate

-- make it non-clustered because it is an artificial key
alter table HumanResources.EmployeePayHistory
add constraint pk_EmployeePayHistory primary key nonclustered (EmployeePayHistoryId)

-- add more useful clustered index
create unique clustered index IX_EmployeePayHistory_BusinessEntityID_RateChangedDate
on HumanResources.EmployeePayHistory(BusinessEntityID, RateChangeDate)

create index IX_Address_City_PostalCode
on Person.Address (City, PostalCode)

select City, PostalCode
from Person.Address a
where a.City = 'Houston'

drop index IX_Address_City_PostalCode
on Person.Address

create index IX_Address_City_PostalCode
on Person.Address (City, PostalCode)
include (AddressLine1, AddressLine2)


