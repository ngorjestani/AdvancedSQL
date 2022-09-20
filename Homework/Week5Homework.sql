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