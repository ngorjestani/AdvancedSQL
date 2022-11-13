declare @json nvarchar(max)
select @json = '{
    "SalesGoals": [
        {
            "SalesPerson": {
                "Id": 274,
                "Name": "Jiang, Stephen",
                "CommissionPercent": 0.0050
            },
            "SalesGoal": {
                "GoalDate": "07-01-2021",
                "QuarterlyGoal": 80000.0000,
                "SalesBonus": 1000.0000
            }
        },
        {
            "SalesPerson": {
                "Id": 275,
                "Name": "Blythe, Michael",
                "CommissionPercent": 0.0120
            },
            "SalesGoal": {
                "GoalDate": "07-01-2021",
                "QuarterlyGoal": 750000.0000,
                "SalesBonus": 4500.0000
            }
        },
        {
            "SalesPerson": {
                "Id": 276,
                "Name": "Mitchell, Linda",
                "CommissionPercent": 0.0150
            },
            "SalesGoal": {
                "GoalDate": "07-01-2021",
                "QuarterlyGoal": 900000.0000,
                "SalesBonus": 2000.0000
            }
        },
        {
            "SalesPerson": {
                "Id": 277,
                "Name": "Carson, Jillian",
                "CommissionPercent": 0.0150
            },
            "SalesGoal": {
                "GoalDate": "07-01-2021",
                "QuarterlyGoal": 600000.0000,
                "SalesBonus": 2500.0000
            }
        },
        {
            "SalesPerson": {
                "Id": 278,
                "Name": "Vargas, Garrett",
                "CommissionPercent": 0.0100
            },
            "SalesGoal": {
                "GoalDate": "07-01-2021",
                "QuarterlyGoal": 220000.0000,
                "SalesBonus": 700.0000
            }
        },
        {
            "SalesPerson": {
                "Id": 279,
                "Name": "Reiter, Tsvi",
                "CommissionPercent": 0.0100
            },
            "SalesGoal": {
                "GoalDate": "07-01-2021",
                "QuarterlyGoal": 500000.0000,
                "SalesBonus": 5000.0000
            }
        },
        {
            "SalesPerson": {
                "Id": 280,
                "Name": "Ansman-Wolfe, Pamela",
                "CommissionPercent": 0.0100
            },
            "SalesGoal": {
                "GoalDate": "07-01-2021",
                "QuarterlyGoal": 250000.0000,
                "SalesBonus": 5000.0000
            }
        },
        {
            "SalesPerson": {
                "Id": 281,
                "Name": "Ito, Shu",
                "CommissionPercent": 0.0100
            },
            "SalesGoal": {
                "GoalDate": "07-01-2021",
                "QuarterlyGoal": 450000.0000,
                "SalesBonus": 2650.0000
            }
        },
        {
            "SalesPerson": {
                "Id": 282,
                "Name": "Saraiva, José",
                "CommissionPercent": 0.0150
            },
            "SalesGoal": {
                "GoalDate": "07-01-2021",
                "QuarterlyGoal": 600000.0000,
                "SalesBonus": 5000.0000
            }
        },
        {
            "SalesPerson": {
                "Id": 283,
                "Name": "Campbell, David",
                "CommissionPercent": 0.0120
            },
            "SalesGoal": {
                "GoalDate": "07-01-2021",
                "QuarterlyGoal": 225000.0000,
                "SalesBonus": 3500.0000
            }
        },
        {
            "SalesPerson": {
                "Id": 284,
                "Name": "Mensa-Annan, Tete",
                "CommissionPercent": 0.0190
            },
            "SalesGoal": {
                "GoalDate": "07-01-2021",
                "QuarterlyGoal": 320000.0000,
                "SalesBonus": 3900.0000
            }
        },
        {
            "SalesPerson": {
                "Id": 285,
                "Name": "Abbas, Syed",
                "CommissionPercent": 0.0000
            },
            "SalesGoal": {
                "GoalDate": "07-01-2021",
                "SalesBonus": 0.0000
            }
        },
        {
            "SalesPerson": {
                "Id": 286,
                "Name": "Tsoflias, Lynn",
                "CommissionPercent": 0.0180
            },
            "SalesGoal": {
                "GoalDate": "07-01-2021",
                "QuarterlyGoal": 280000.0000,
                "SalesBonus": 4500.0000
            }
        },
        {
            "SalesPerson": {
                "Id": 287,
                "Name": "Alberts, Amy",
                "CommissionPercent": 0.0000
            },
            "SalesGoal": {
                "GoalDate": "07-01-2021",
                "SalesBonus": 0.0000
            }
        },
        {
            "SalesPerson": {
                "Id": 288,
                "Name": "Valdez, Rachel",
                "CommissionPercent": 0.0180
            },
            "SalesGoal": {
                "GoalDate": "07-01-2021",
                "QuarterlyGoal": 425000.0000,
                "SalesBonus": 2200.0000
            }
        },
        {
            "SalesPerson": {
                "Id": 289,
                "Name": "Pak, Jae",
                "CommissionPercent": 0.0200
            },
            "SalesGoal": {
                "GoalDate": "07-01-2021",
                "QuarterlyGoal": 870000.0000,
                "SalesBonus": 6650.0000
            }
        },
        {
            "SalesPerson": {
                "Id": 290,
                "Name": "Varkey Chudukatil, Ranjit",
                "CommissionPercent": 0.0160
            },
            "SalesGoal": {
                "GoalDate": "07-01-2021",
                "QuarterlyGoal": 600000.0000,
                "SalesBonus": 1275.0000
            }
        }
    ]
}'

/****************************************
* Author: ngorjestani
* Create Date: 11/6/2022
*
* This procedure takes a JSON file and updates the salesperson's commision and bonus information
* while adding a new quota history with the information from the JSON file
*
******************************************/
create procedure Sales.UpdateSalesQuotasFromJson(@json nvarchar(max))
as
begin
    select *
    into #SalesBonusInfo
    from openjson(@json, '$.SalesGoals')
                  with (SalesPersonId int '$.SalesPerson.Id',
                      CommissionPercent smallmoney '$.SalesPerson.CommissionPercent',
                      GoalDate date '$.SalesGoal.GoalDate',
                      QuarterlyGoal money '$.SalesGoal.QuarterlyGoal',
                      SalesBonus money '$.SalesGoal.SalesBonus') as jsonData;

    update Sales.SalesPerson
    set SalesQuota    = sbi.QuarterlyGoal,
        Bonus         = sbi.SalesBonus,
        CommissionPct = sbi.CommissionPercent
    from Sales.SalesPerson
             join #SalesBonusInfo sbi
                  on BusinessEntityID = sbi.SalesPersonId;

    merge into Sales.SalesPersonQuotaHistory as tgt
    using #SalesBonusInfo as src
    on src.SalesPersonId = tgt.BusinessEntityID and tgt.QuotaDate = src.GoalDate
    when matched then
        update
        set SalesQuota   = src.QuarterlyGoal,
            ModifiedDate = getdate()
    when not matched by target and src.QuarterlyGoal is not null then
        insert (BusinessEntityID,
                QuotaDate,
                SalesQuota,
                rowguid,
                ModifiedDate)
        values (src.SalesPersonId,
                src.GoalDate,
                src.QuarterlyGoal,
                newid(),
                getdate())
        ;
end
go

-- BusinessEntityId: the salesperson's BusinessEntityId/SalespersonId
-- SalesPersonName: concat(p.FirstName, ' ', p.LastName) as Name
-- SalesYear: @year
-- Quarter1Quota:
-- Quarter1Sales:
-- Quarter1Bonus:
-- Quarter1Commission:
-- Quarter2Quota:
-- Quarter2Sales:
-- Quarter2Bonus:
-- Quarter2Commission:
-- Quarter3Quota:
-- Quarter3Sales:
-- Quarter3Bonus:
-- Quarter3Commission:
-- Quarter4Quota:
-- Quarter4Sales:
-- Quarter4Bonus:
-- Quarter4Commission:
-- TotalAnnualSales: sum(Quarter1Sales, Quarter2Sales, Quarter3Sales, Quarter4Sales)
-- TotalAnnualBonuses: sum(Quarter1Bonus, Quarter2Bonus, Quarter3Bonus, Quarter4Bonus)
-- TotalAnnualCommission: sum(Quarter1Commission, Quarter2Commission, Quarter3Commission, Quarter4Commission)
-- TotalAnnualSalesCompensation: sum(TotalAnnualBonuses, TotalAnnualCommission)

begin tran

declare @year int
select @year = 2021

create table #QuarterlySalesInfo
(
    BusinessEntityId int,
    Q1Sales          money,
    Q2Sales          money,
    Q3Sales          money,
    Q4Sales          money,
    Q1Quota          money,
    Q2Quota          money,
    Q3Quota          money,
    Q4Quota          money,
    Q1Bonus          money,
    Q2Bonus          money,
    Q3Bonus          money,
    Q4Bonus          money,
    Q1Commission     money,
    Q2Commission     money,
    Q3Commission     money,
    Q4Commission     money
);

insert into #QuarterlySalesInfo (BusinessEntityId, Q1Sales, Q2Sales, Q3Sales, Q4Sales)
select pvt.SalesPersonID,
       pvt.[1] as Q1Sales,
       pvt.[2] as Q2Sales,
       pvt.[3] as Q3Sales,
       pvt.[4] as Q4Sales
from (select soh.SalesPersonID,
             soh.SubTotal,
             datepart(quarter, soh.OrderDate) as Qtr
      from Sales.SalesOrderHeader soh
      where year(soh.OrderDate) = @year
        and soh.SalesPersonID is not null) p
         pivot ( sum(Subtotal) for Qtr in ([1], [2], [3], [4])) pvt

update qsi
set qsi.Q1Quota = quotas.Q1Quota,
    qsi.Q2Quota = quotas.Q2Quota,
    qsi.Q3Quota = quotas.Q3Quota,
    qsi.Q4Quota = quotas.Q4Quota
from #QuarterlySalesInfo qsi
         join (select pvt.BusinessEntityID,
                      pvt.[1] as Q1Quota,
                      pvt.[2] as Q2Quota,
                      pvt.[3] as Q3Quota,
                      pvt.[4] as Q4Quota
               from (select spqh.BusinessEntityID, datepart(quarter, spqh.QuotaDate) as Qtr, spqh.SalesQuota
                     from Sales.SalesPersonQuotaHistory spqh
                     where year(spqh.QuotaDate) = @year) p
                        pivot ( Max(SalesQuota) for Qtr in ([1], [2], [3], [4]) ) pvt) quotas
              on qsi.BusinessEntityId = quotas.BusinessEntityId

update qsi
set qsi.Q1Commission = qsi.Q1Sales * sp.CommissionPct,
    qsi.Q2Commission = qsi.Q2Sales * sp.CommissionPct,
    qsi.Q3Commission = qsi.Q3Sales * sp.CommissionPct,
    qsi.Q4Commission = qsi.Q4Sales * sp.CommissionPct
from #QuarterlySalesInfo qsi
         join Sales.SalesPerson sp
              on qsi.BusinessEntityId = sp.BusinessEntityID

select *
from #QuarterlySalesInfo

rollback tran

/****************************************
* Author: ngorjestani
* Create Date: 11/8/2022
*
* This procedure calculates the sales, commission, and bonus information for each salesperson for the given year.
* Sales, commission, bonuses, and quotas will be shown by quarter as well as the total amounts for the year
*
******************************************/
create procedure Sales.CalculateSalesCommissionInfoByYear(@year int)
as
begin

end