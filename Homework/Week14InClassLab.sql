-- 1.
-- Using the following table/data below, ank players by their score into two categories.
-- Players that rank in the top half must be given a value of 1, and the remaining players must be given a value of 2.

CREATE TABLE #PlayerScores
(
    PlayerID VARCHAR(MAX),
    Score    INT
);

INSERT INTO #PlayerScores
VALUES (1001, 2343),
       (2002, 9432),
       (3003, 6548),
       (4004, 1054),
       (5005, 6832);

-- *************************************************

SELECT ps.PlayerID,
       ps.Score,
       IIF((RANK() OVER (ORDER BY ps.Score) <= COUNT(*) OVER () / 2), 1, 2)
FROM #PlayerScores ps
ORDER BY ps.Score

-- *************************************************

-- 2.
-- Write an SQL statement that deletes the duplicate data:

CREATE TABLE #SampleData
(
    IntegerValue INT
);
INSERT INTO #SampleData
VALUES (1),
       (1),
       (2),
       (3),
       (3),
       (4);

-- *********************************************************************************

;
WITH duplicates AS (SELECT IntegerValue,
                           ROW_NUMBER() OVER (PARTITION BY IntegerValue ORDER BY IntegerValue) rowNumber
                    FROM #SampleData)

DELETE
FROM duplicates
WHERE rowNumber > 1

-- *********************************************************************************

-- 3.
-- You are part of an office lottery pool where you keep a table of the winning lottery numbers along with a table of each tickets chosen numbers.
-- If a ticket has some but not all the winning numbers, you win $10.
-- If a ticket has all the winning numbers, you win $100. Calculate the total winnings for today’s drawing.
-- The expected output would be $110, as you have one winning ticket, and one ticket that has some but not all the winning number

CREATE TABLE #WinningNumbers
(
    Number INT
);
INSERT INTO #WinningNumbers
VALUES (25),
       (45),
       (78);

CREATE TABLE #LotteryTickets
(
    TicketNumber VARCHAR(10),
    Number       INT
);
INSERT INTO #LotteryTickets
VALUES ('A23423', 25),
       ('A23423', 45),
       ('A23423', 78),
       ('B35643', 25),
       ('B35643', 45),
       ('B35643', 98),
       ('C98787', 67),
       ('C98787', 86),
       ('C98787', 91);

-- **************************************************

CREATE TABLE #LotteryWinnings
(
    TicketNumber VARCHAR(10),
    Winnings     DECIMAL
);

SELECT TicketNumber,
       CASE
           WHEN COUNT(wn.Number) = 3 THEN 100
           WHEN COUNT(wn.Number) > 0 THEN 10
           ELSE 0
           END Winnings
INTO #LotteryWinnings
FROM #LotteryTickets lt
         LEFT JOIN #WinningNumbers wn ON lt.Number = wn.Number
GROUP BY TicketNumber

SELECT SUM(Winnings) TotalWinnings
FROM #LotteryWinnings

-- **************************************************

-- 4.
-- This is a well-known problem that is called the Traveling Salesman among programmers.
-- Write a SQL statement that shows all the possible flight routes from Austin to Des Moines.
-- Which flight route is the most expensive? Which flight route is the least expensive? Make any necessary assumptions to complete the puzzle.

CREATE TABLE #Routes
(
    DepartureCity VARCHAR(20),
    ArrivalCity   VARCHAR(20),
    Cost          INT
);
INSERT INTO #Routes
VALUES ('Austin', 'Dallas', 100),
       ('Dallas', 'Memphis', 200),
       ('Memphis', 'Des Moines', 300),
       ('Dallas', 'Des Moines', 400);
;
WITH recursive AS (SELECT CAST(DepartureCity AS VARCHAR(100)) AS PlacesChain,
                          Cost                                AS TotalCost,
                          DepartureCity                       AS LastDepartureCity,
                          ArrivalCity                         AS LastArrivalCity
                   FROM #Routes
                   UNION ALL
                   SELECT CAST(rec.PlacesChain + ' ' + r.DepartureCity AS VARCHAR(100)),
                          rec.TotalCost + r.Cost,
                          r.DepartureCity,
                          r.ArrivalCity
                   FROM #Routes r
                            JOIN recursive rec ON r.DepartureCity = rec.LastArrivalCity)

SELECT PlacesChain + ' ' + LastArrivalCity,
       TotalCost
FROM recursive
WHERE PlacesChain LIKE 'Austin%'
  AND LastArrivalCity = 'Des Moines'