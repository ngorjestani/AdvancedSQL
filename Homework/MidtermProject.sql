/****************************************
* Author: ngorjestani
* Create Date: 11/6/2022
*
* This procedure takes a JSON file and updates the salesperson's commission and bonus information
* while adding a new quota history with the information from the JSON file
*
******************************************/
CREATE PROCEDURE Sales.UpdateSalesQuotasFromJson(@json NVARCHAR(MAX))
AS
BEGIN
    SELECT *
    INTO #SalesBonusInfo
    FROM OPENJSON(@json, '$.SalesGoals')
                  WITH (SalesPersonId INT '$.SalesPerson.Id',
                      CommissionPercent SMALLMONEY '$.SalesPerson.CommissionPercent',
                      GoalDate DATE '$.SalesGoal.GoalDate',
                      QuarterlyGoal MONEY '$.SalesGoal.QuarterlyGoal',
                      SalesBonus MONEY '$.SalesGoal.SalesBonus') AS jsonData;

    UPDATE Sales.SalesPerson
    SET SalesQuota    = sbi.QuarterlyGoal,
        Bonus         = sbi.SalesBonus,
        CommissionPct = sbi.CommissionPercent
    FROM Sales.SalesPerson
             JOIN #SalesBonusInfo sbi
                  ON BusinessEntityID = sbi.SalesPersonId;

    MERGE INTO Sales.SalesPersonQuotaHistory AS tgt
    USING #SalesBonusInfo AS src
    ON src.SalesPersonId = tgt.BusinessEntityID AND tgt.QuotaDate = src.GoalDate
    WHEN MATCHED THEN
        UPDATE
        SET SalesQuota   = src.QuarterlyGoal,
            ModifiedDate = GETDATE()
    WHEN NOT MATCHED BY TARGET AND src.QuarterlyGoal IS NOT NULL THEN
        INSERT (BusinessEntityID,
                QuotaDate,
                SalesQuota,
                rowguid,
                ModifiedDate)
        VALUES (src.SalesPersonId,
                src.GoalDate,
                src.QuarterlyGoal,
                NEWID(),
                GETDATE())
        ;
END
GO


/****************************************
* Author: ngorjestani
* Create Date: 11/8/2022
*
* This procedure calculates the sales, commission, and bonus information for each salesperson for the given year.
* Sales, commission, bonuses, and quotas will be shown by quarter as well as the total amounts for the year
*
******************************************/
CREATE PROCEDURE Sales.CalculateSalesCommissionInfoByYear(@year INT)
AS
BEGIN
    CREATE TABLE #QuarterlySalesInfo
    (
        BusinessEntityId INT,
        Q1Sales          MONEY,
        Q2Sales          MONEY,
        Q3Sales          MONEY,
        Q4Sales          MONEY,
        Q1Quota          MONEY,
        Q2Quota          MONEY,
        Q3Quota          MONEY,
        Q4Quota          MONEY,
        Q1Bonus          MONEY,
        Q2Bonus          MONEY,
        Q3Bonus          MONEY,
        Q4Bonus          MONEY,
        Q1Commission     MONEY,
        Q2Commission     MONEY,
        Q3Commission     MONEY,
        Q4Commission     MONEY
    );

    INSERT INTO #QuarterlySalesInfo
    (BusinessEntityId,
     Q1Sales,
     Q2Sales,
     Q3Sales,
     Q4Sales)
    SELECT pvt.SalesPersonID,
           ISNULL(pvt.[1], 0) AS Q1Sales,
           ISNULL(pvt.[2], 0) AS Q2Sales,
           ISNULL(pvt.[3], 0) AS Q3Sales,
           ISNULL(pvt.[4], 0) AS Q4Sales
    FROM (SELECT soh.SalesPersonID,
                 soh.SubTotal,
                 DATEPART(QUARTER, soh.OrderDate) AS Qtr
          FROM Sales.SalesOrderHeader soh
          WHERE YEAR(soh.OrderDate) = @year
            AND soh.SalesPersonID IS NOT NULL) p
             PIVOT ( SUM(Subtotal) FOR Qtr IN ([1], [2], [3], [4])) pvt

    IF ((SELECT COUNT(*) FROM #QuarterlySalesInfo) < 1)
        BEGIN
            ;THROW 51000, 'There is no sales data for this year.', 1;
            RETURN
        END

    UPDATE qsi
    SET qsi.Q1Quota = ISNULL(quotas.Q1Quota, 0),
        qsi.Q2Quota = ISNULL(quotas.Q2Quota, 0),
        qsi.Q3Quota = ISNULL(quotas.Q3Quota, 0),
        qsi.Q4Quota = ISNULL(quotas.Q4Quota, 0)
    FROM #QuarterlySalesInfo qsi
             JOIN (SELECT pvt.BusinessEntityID,
                          pvt.[1] AS Q1Quota,
                          pvt.[2] AS Q2Quota,
                          pvt.[3] AS Q3Quota,
                          pvt.[4] AS Q4Quota
                   FROM (SELECT spqh.BusinessEntityID, DATEPART(QUARTER, spqh.QuotaDate) AS Qtr, spqh.SalesQuota
                         FROM Sales.SalesPersonQuotaHistory spqh
                         WHERE YEAR(spqh.QuotaDate) = @year) p
                            PIVOT ( MAX(SalesQuota) FOR Qtr IN ([1], [2], [3], [4]) ) pvt) quotas
                  ON qsi.BusinessEntityId = quotas.BusinessEntityId

    UPDATE qsi
    SET qsi.Q1Commission = ISNULL(qsi.Q1Sales * sp.CommissionPct, 0),
        qsi.Q2Commission = ISNULL(qsi.Q2Sales * sp.CommissionPct, 0),
        qsi.Q3Commission = ISNULL(qsi.Q3Sales * sp.CommissionPct, 0),
        qsi.Q4Commission = ISNULL(qsi.Q4Sales * sp.CommissionPct, 0)
    FROM #QuarterlySalesInfo qsi
             JOIN Sales.SalesPerson sp
                  ON qsi.BusinessEntityId = sp.BusinessEntityID

    UPDATE qsi
    SET Q1Bonus = IIF(qsi.Q1Sales > qsi.Q1Quota, sp.Bonus, 0),
        Q2Bonus = IIF(qsi.Q2Sales > qsi.Q2Quota, sp.Bonus, 0),
        Q3Bonus = IIF(qsi.Q3Sales > qsi.Q3Quota, sp.Bonus, 0),
        Q4Bonus = IIF(qsi.Q4Sales > qsi.Q4Quota, sp.Bonus, 0)
    FROM #QuarterlySalesInfo qsi
             JOIN Sales.SalesPerson sp
                  ON qsi.BusinessEntityId = sp.BusinessEntityID

    SELECT qsi.BusinessEntityId,
           CONCAT(p.FirstName, ' ', p.LastName) AS SalesPersonName,
           @year                                AS SalesYear,
           FORMAT(qsi.Q1Quota, 'c')             AS Quarter1Quota,
           FORMAT(qsi.Q1Sales, 'c')             AS Quarter1Sales,
           FORMAT(qsi.Q1Bonus, 'c')             AS Quarter1Bonus,
           FORMAT(qsi.Q1Commission, 'c')        AS Quarter1Commission,
           FORMAT(qsi.Q2Quota, 'c')             AS Quarter2Quota,
           FORMAT(qsi.Q2Sales, 'c')             AS Quarter2Sales,
           FORMAT(qsi.Q2Bonus, 'c')             AS Quarter2Bonus,
           FORMAT(qsi.Q2Commission, 'c')        AS Quarter2Commission,
           FORMAT(qsi.Q3Quota, 'c')             AS Quarter3Quota,
           FORMAT(qsi.Q3Sales, 'c')             AS Quarter3Sales,
           FORMAT(qsi.Q3Bonus, 'c')             AS Quarter3Bonus,
           FORMAT(qsi.Q3Commission, 'c')        AS Quarter3Commission,
           FORMAT(qsi.Q4Quota, 'c')             AS Quarter4Quota,
           FORMAT(qsi.Q4Sales, 'c')             AS Quarter4Sales,
           FORMAT(qsi.Q4Bonus, 'c')             AS Quarter4Bonus,
           FORMAT(qsi.Q4Commission, 'c')        AS Quarter4Commission,
           FORMAT(qsi.Q1Sales
                      + qsi.Q2Sales
                      + qsi.Q3Sales
                      + qsi.Q4Sales, 'c')       AS TotalAnnualSales,
           FORMAT(qsi.Q1Bonus
                      + qsi.Q2Bonus
                      + qsi.Q3Bonus
                      + qsi.Q4Bonus, 'c')       AS TotalAnnualBonuses,
           FORMAT(qsi.Q1Commission
                      + qsi.Q2Commission
                      + qsi.Q3Commission
                      + qsi.Q4Commission, 'c')  AS TotalAnnualCommission,
           FORMAT(qsi.Q1Bonus
                      + qsi.Q2Bonus
                      + qsi.Q3Bonus
                      + qsi.Q4Bonus
                      + qsi.Q1Commission
                      + qsi.Q2Commission
                      + qsi.Q3Commission
                      + qsi.Q4Commission, 'c')  AS TotalAnnualSalesCompensation
    FROM #QuarterlySalesInfo qsi
             JOIN Person.Person p
                  ON qsi.BusinessEntityId = p.BusinessEntityID
END
GO
