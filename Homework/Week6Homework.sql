declare @FirstDate date
select @FirstDate = '7/4/2018'

declare @LastDate date
select @LastDate = '12/31/2020'

declare @CostAtTimeOfOrder table(WorkOrderID int, StandardCost money)

-- get cost at time of order
insert into @CostAtTimeOfOrder
select wo.WorkOrderID,
       pch.StandardCost
from Production.WorkOrder wo
         join Production.Product p
              on wo.ProductID = p.ProductID
         left join Production.ProductCostHistory pch
              on p.ProductID = pch.ProductID
where wo.StartDate between @FirstDate and @LastDate
  and wo.ScrapReasonID is not null
  and pch.StartDate < wo.StartDate
  and (pch.EndDate is null or pch.EndDate > wo.StartDate)

-- get calculated work order info
select wo.WorkOrderID,
       p.Name ProductName,
       sr.Name ScrapReason,
       wo.ScrappedQty,
       catoo.StandardCost,
       wo.ScrappedQty * catoo.StandardCost ScrappedMetalCost,
       sum(wor.ActualResourceHrs) * l.CostRate / wo.OrderQty,
       l.CostRate,
       wo.OrderQty
from Production.WorkOrder wo
         join Production.WorkOrderRouting wor
              on wo.WorkOrderID = wor.WorkOrderID
         join Production.Location l
              on wor.LocationID = l.LocationID
         join Production.Product p
              on wo.ProductID = p.ProductID
         join Production.ScrapReason sr
              on wo.ScrapReasonID = sr.ScrapReasonID
         left join @CostAtTimeOfOrder catoo
              on wo.WorkOrderID = catoo.WorkOrderID
where wo.StartDate between @FirstDate and @LastDate
  and wo.ScrapReasonID is not null
group by wo.WorkOrderID,
         p.Name,
         sr.Name,
         wo.ScrappedQty,
         catoo.StandardCost,
         wo.ScrappedQty * catoo.StandardCost,
         l.CostRate,
         wo.OrderQty

/*
WorkOrderID: Production.WorkOrder
ProductName: Production.Product
ScrapReason: Production.ScrapReason
ScrappedQty: Production.WorkOrder
StandardCost: Production.ProductCostHistory on date of Production.WorkOrder.StartDate
ScrappedMetalCost: Qty * StandardCost
LaborCost: Production.WorkOrderRouting.ActualResourceHrs * Production.Location.CostRate / Production.WorkOrder.OrderQty
*/

select l.LocationID, l.CostRate
from Production.Location l