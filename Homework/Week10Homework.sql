-- Ensure each table has a clustered index
-- For bridge tables, make the clustered index be the two foreign keys that make up the 'original' primary key
-- Each table should still have a primary key constraint

alter table dbo.FeePayments
drop constraint fk_FeePayments_FeeId

alter table dbo.PatronFees
drop constraint pk_PatronFees

alter table dbo.PatronFees
add constraint pk_PatronFees
    primary key nonclustered (FeeId)

alter table dbo.FeePayments
add constraint fk_FeePayments_FeeId
    foreign key (FeeId)
    references PatronFees (FeeId)

create unique clustered index
    IX_PatronFees_PatronId_ItemId
    on dbo.PatronFees (PatronId, ItemId)

alter table dbo.FeePayments
drop constraint pk_FeePayments

alter table dbo.FeePayments
add constraint pk_FeePayments
    primary key nonclustered (FeePaymentId)

create unique clustered index
    IX_FeePayments_PaymentId_FeeId
    on dbo.FeePayments (PaymentId, FeeId)

alter table dbo.Loans
drop constraint pk_Loans

alter table dbo.Loans
add constraint pk_Loans
    primary key nonclustered (LoanId)

create unique clustered index
    IX_Loans_ItemId_PatronId
    on dbo.Loans (ItemId, PatronId)

-- Include unique indexes where appropriate

create unique nonclustered index
    IX_Items_BarcodeId
    on dbo.Items (BarcodeId)

create unique nonclustered index
    IX_Patron_BarcodeId
    on dbo.Patron (BarcodeId)

-- Index foreign keys as appropriate

create index IX_Loans_ItemId
    on dbo.Loans (ItemId)

create index IX_Payments_PatronId
    on dbo.Payments (PatronId)

-- Think through common search scenarios within the database and add at least 5 non-clustered indexes to assist with searches in the system
-- Include at least one filtered index
-- Include at least one columnstore index

create columnstore index ix_ItemType_RenewalsAllowed
    on dbo.ItemType (RenewalsAllowed)

create columnstore index ix_FeeType_IsActive
    on dbo.FeeType (IsActive)

create columnstore index ix_PaymentMethod_IsActive
    on dbo.PaymentMethod (IsActive)

    -- Loans that are overdue
create nonclustered index
    IX_Loans_PastDue
    on dbo.Loans (LoanId)
    include (ItemId, PatronId, DueDate)
    where (DueDate < getdate())

    -- Items with author info and title
create nonclustered index
    IX_Items_WithAuthorInfoAndTitle
    on dbo.Items (Title)
    include (AuthorFirstName, AuthorLastName)