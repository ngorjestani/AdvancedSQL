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


declare @year int
select @year = 2021

/*select sp.BusinessEntityID,
       concat(p.FirstName, ' ', p.LastName) as Name,
       sum(soh.SubTotal)                    as TotalSales
from Sales.SalesPerson sp
         join Person.Person p
              on p.BusinessEntityID = sp.BusinessEntityID
         join Sales.SalesOrderHeader soh
              on sp.BusinessEntityID = soh.SalesPersonID
group by sp.BusinessEntityID, concat(p.FirstName, ' ', p.LastName)


select *
from Sales.SalesOrderHeader soh
where soh.SalesPersonID = 285*/

select soh.SalesPersonID
from Sales.SalesOrderHeader soh