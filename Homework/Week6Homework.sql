create procedure ScrappedMaterialAnalysis(@FirstDate date, @LastDate date)
as
begin
    declare @CostAtTimeOfOrder table
                               (
                                   WorkOrderID  int,
                                   StandardCost money
                               )
    declare @ScrappedMaterialLaborCost table
                                       (
                                           WorkOrderID int,
                                           Cost        money
                                       )

    select * from Production.WorkOrderRouting wor where wor.WorkOrderID = 1344

    insert into @ScrappedMaterialLaborCost
    select wo.WorkOrderID, sum(CostByLocation.LaborCost)
    from Production.WorkOrder wo
             join (select wo.WorkOrderID, wor.ActualResourceHrs * l.CostRate LaborCost
                   from Production.WorkOrder wo
                            join Production.WorkOrderRouting wor
                                 on wo.WorkOrderID = wor.WorkOrderID
                            join Production.Location l
                                 on wor.LocationID = l.LocationID) CostByLocation
                  on CostByLocation.WorkOrderID = wo.WorkOrderID
    where wo.StartDate between @FirstDate and @LastDate
      and wo.ScrapReasonID is not null
    group by wo.WorkOrderID

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
           p.Name  ProductName,
           sr.Name ScrapReason,
           wo.ScrappedQty,
           catoo.StandardCost,
           smlc.Cost / wo.OrderQty
    from Production.WorkOrder wo
             join @ScrappedMaterialLaborCost smlc
                  on wo.WorkOrderID = smlc.WorkOrderID
             join Production.Product p
                  on wo.ProductID = p.ProductID
             join Production.ScrapReason sr
                  on wo.ScrapReasonID = sr.ScrapReasonID
             left join @CostAtTimeOfOrder catoo
                       on wo.WorkOrderID = catoo.WorkOrderID
    where wo.StartDate between @FirstDate and @LastDate
      and wo.ScrapReasonID is not null
end

-- correct
declare @StartDate date, @EndDate date
select @StartDate = '12/1/2019', @EndDate = '12/31/2019'

select wo.WorkOrderID, p.ProductID, p.Name, sr.Name as ScrapReason, wo.OrderQty, wo.StartDate
into #scrap
from Production.WorkOrder wo
    join Production.Product p
    on wo.ProductID = p.ProductID
    join Production.ScrapReason sr
    on wo.ScrapReasonID = sr.ScrapReasonID
where wo.ScrappedQty > 0
and wo.StartDate between @StartDate and @EndDate

select * from #scrap

--add a column to temp table for standard cost
alter table #scrap
add Cost money

update #scrap
set Cost = pch.StandardCost
from #scrap s
join Production.ProductCostHistory pch
on s.ProductID = pch.ProductID
and s.StartDate between pch.StartDate and isnull(pch.EndDate, '12/31/9999')

select wor.WorkOrderID,
       sum(wor.ActualResourceHrs) * sum(wor.ActualCost) TotalResourceCost
from #scrap s
    join Production.WorkOrderRouting wor
    on s.WorkOrderID = wor.WorkOrderID
group by wor.WorkOrderID

alter table #scrap
add TotalResourceCost money, UnitResourceCost money

update #scrap
set TotalResourceCost = x.TotalResourceCost
    from #scrap
    join (select wor.WorkOrderID,
       sum(wor.ActualResourceHrs) * sum(wor.ActualCost) TotalResourceCost
from #scrap s
    join Production.WorkOrderRouting wor
    on s.WorkOrderID = wor.WorkOrderID
group by wor.WorkOrderID) x
on x.WorkOrderID = #scrap.WorkOrderID

update #scrap
set UnitResourceCost = TotalResourceCost / OrderQty
