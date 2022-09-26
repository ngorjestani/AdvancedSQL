declare @FirstDate date
select @FirstDate = '7/4/2018'

declare @LastDate date
select @LastDate = '7/5/2018'

select wo.WorkOrderID,
       p.Name  as ProductName,
       sr.Name as ScrapReason,
       wo.ScrappedQty
from Production.WorkOrder wo
         join Production.ScrapReason sr
              on wo.ScrapReasonID = sr.ScrapReasonID
         join Production.Product p
              on p.ProductID = wo.ProductID
where wo.StartDate between @FirstDate and @LastDate
  and wo.ScrapReasonID is not null