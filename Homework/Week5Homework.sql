select * from Person.NewAddress

-- City
select substring(na.[City State Postal], 1, charindex(',', na.[City State Postal]) - 1)
from Person.NewAddress na

-- State
select sp.StateProvinceID
from Person.StateProvince sp
join (select substring(
    na.[City State Postal],
    charindex(',', na.[City State Postal]) + 2,
    len(na.[City State Postal]) - charindex(' ', reverse(na.[City State Postal])) - charindex(',', na.[City State Postal]) - 1) State
from Person.NewAddress na) NewAddressState
on NewAddressState.State = sp.Name

--ZIP
select substring(
    na.[City State Postal],
    len(na.[City State Postal]) - charindex(' ', reverse(na.[City State Postal])) + 2,
    5)
from Person.NewAddress na

-- Address Type
select at.AddressTypeID
from Person.NewAddress na
join Person.AddressType at
on na.[Address Type] = at.Name

begin tran
/*
select
    substring(na.[City State Postal], 1, charindex(',', na.[City State Postal]) - 1),
    (select sp.StateProvinceID
        from Person.StateProvince sp
        join (select substring(
            na.[City State Postal],
            charindex(',', na.[City State Postal]) + 2,
            len(na.[City State Postal]) - charindex(' ', reverse(na.[City State Postal])) - charindex(',', na.[City State Postal]) - 1) State
        from Person.NewAddress na) NewAddressState
        on NewAddressState.State = sp.Name) StateProvinceId
from Person.NewAddress na*/

-- couldn't figure out how to actually update these fields in the database

rollback tran

-- correct
alter table Person.NewAddress
    add City varchar(50),
    State varchar(50),
    PostalCode char(5)

select * from Person.NewAddress

select na.[City State Postal],
       substring(na.[City State Postal], 1, charindex(',', na.[City State Postal]) - 1)
from Person.NewAddress na

 update Person.NewAddress
set NewAddress.City = substring([City State Postal], 1, charindex(',', [City State Postal]) - 1)

update Person.NewAddress
set [City State Postal] = right(replace([City State Postal], city, ''), len(replace([City State Postal], city, '')) - 2)

update Person.NewAddress
set NewAddress.PostalCode = right([City State Postal], 5)

update Person.NewAddress
set NewAddress.State = trim(replace([City State Postal], NewAddress.PostalCode, ''))

alter table Person.NewAddress
drop column [City State Postal]

select na.*, a.AddressLine1, a.City, sp.Name State, a.PostalCode
from Person.NewAddress na
join Person.BusinessEntityAddress bea
on na.[Business Entity ID] = bea.BusinessEntityID
join Person.AddressType at
on bea.AddressTypeID = at.AddressTypeID
and na.[Address Type] = at.Name
join Person.Address a
on bea.AddressID = a.AddressID
join Person.StateProvince sp
on a.StateProvinceID = sp.StateProvinceID

-- No changes to state or address

begin tran

update Person.Address
set AddressLine1 = na.[Address 1 ],
    City = na.City,
    PostalCode = na.PostalCode,
    ModifiedDate = getdate()

from Person.NewAddress na
join Person.BusinessEntityAddress bea
on na.[Business Entity ID] = bea.BusinessEntityID
join Person.AddressType at
on bea.AddressTypeID = at.AddressTypeID
and na.[Address Type] = at.Name
join Person.Address a
on bea.AddressID = a.AddressID
join Person.StateProvince sp
on a.StateProvinceID = sp.StateProvinceID

commit tran
