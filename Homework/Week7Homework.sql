-- Create a user-defined function that returns the name of a customer based on a CustomerID.
-- If the customer is a store, return the store name; if not, return their first and last name concatenated.

/***************************************
* GetCustomerName
* Author: NickGorjestani
* created: 10/2/2022
*
* Parameters: CustomerID - the ID of the customer to get name for
*
* This function returns the name for the customer with the given ID.
* If the customer is a store, it will return the store name, otherwise it will return the Person's full name
*
* Change log
* --------------------------------------
*
****************************************/
create function GetCustomerName(@customerId int) returns nvarchar
as
begin
    return (select IIF(c.StoreID is null, concat(p.FirstName, ' ', p.LastName), s.Name) as Name
            from Sales.Customer c
                     left join Person.Person p
                               on c.PersonID = p.BusinessEntityID
                     left join Sales.Store s
                               on c.StoreID = s.BusinessEntityID
            where c.CustomerID = @customerId)
end

-- Create a user-defined function that returns all of a business entity's addresses.
-- Include the business entity ID, address type, both street addresses, city, state/province, postal code, and country.

/***************************************
* GetAddressesForBusinessEntity
* Author: NickGorjestani
* created: 10/2/2022
*
* Parameters: BusinessEntityId - the ID of the business entity to get addresses for
*
* This function returns the addresses for a given business entity
*
* Change log
* --------------------------------------
*
****************************************/
create function GetAddressesForBusinessEntity(@businessEntityId int)
    returns @Addresses table
                       (
                           BusinessEntityId int,
                           AddressType      nvarchar,
                           AddressLine1     nvarchar,
                           AddressLine2     nvarchar,
                           City             nvarchar,
                           [State/Province] nvarchar,
                           PostalCode       nvarchar,
                           Country          nvarchar
                       )
as
begin
    insert into @Addresses
    select bea.BusinessEntityID,
           atype.Name as AddressType,
           a.AddressLine1,
           a.AddressLine2,
           a.City,
           sp.Name    as [State/Province],
           a.PostalCode,
           cr.Name    as Country
    from Person.BusinessEntityAddress bea
             join Person.AddressType atype
                  on bea.AddressTypeID = atype.AddressTypeID
             join Person.Address a
                  on bea.AddressID = a.AddressID
             join Person.StateProvince sp
                  on a.StateProvinceID = sp.StateProvinceID
             join Person.CountryRegion cr
                  on sp.CountryRegionCode = cr.CountryRegionCode
    where bea.BusinessEntityID = @businessEntityId
    return
end

-- Create a trigger that automatically populates the Production.ProductListPrice history when the list price in the Production.Product table is changed.
-- The old list price row in the history table should be end-dated and a new row added with the current list price.

create trigger tr_iu_ProductListPriceHistory
    on Production.Product
    for insert, update
    as
begin
    if update(ListPrice)
        begin
            update Production.ProductCostHistory
            set EndDate = getdate()
            where ProductID = deleted.ProductID
              and EndDate is null

            insert into Production.ProductCostHistory
            select i.ProductID,
                   getdate(),
                   null,
                   i.ListPrice,
                   getdate()
            from deleted d
                     join inserted i
                          on d.ProductID = i.ProductID
        end
end


