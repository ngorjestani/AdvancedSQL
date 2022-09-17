begin tran

update Production.Product
set StandardCost = (p.StandardCost * 1.1)
from Production.Product p
    join Production.ProductSubcategory ps
    on p.ProductSubcategoryID = ps.ProductSubcategoryID
where ps.Name = 'Tires and Tubes'

update Production.ProductCostHistory
set EndDate = GETDATE()
where ProductID in (select p.ProductID
from Production.Product p
    join Production.ProductSubcategory ps
    on p.ProductSubcategoryID = ps.ProductSubcategoryID
where ps.Name = 'Tires and Tubes') and EndDate is null

insert into Production.ProductCostHistory
select pch.ProductID, GETDATE(), null, pch.cost, GETDATE()
from (select pch.*, p.StandardCost as cost from Production.ProductCostHistory pch
    join Production.Product p on P.ProductID = pch.ProductID
    where pch.ProductID in (select p.ProductID
    from Production.Product p
        join Production.ProductSubcategory ps
        on p.ProductSubcategoryID = ps.ProductSubcategoryID
    where ps.Name = 'Tires and Tubes')) pch

commit

select * from Production.Product p
join Production.ProductSubcategory ps
on p.ProductSubcategoryID = ps.ProductSubcategoryID
where ps.Name = 'Tires and Tubes'