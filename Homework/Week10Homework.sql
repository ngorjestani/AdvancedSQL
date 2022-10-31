-- Ensure each table has a clustered index
-- For bridge tables, make the clustered index be the two foreign keys that make up the 'original' primary key
-- Each table should still have a primary key constraint



-- Include unique indexes where appropriate



-- Index foreign keys as appropriate



-- Think through common search scenarios within the database and add at least 5 non-clustered indexes to assist with searches in the system
-- Include at least one filtered index
-- Include at least one columnstore index