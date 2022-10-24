use master;
go

create database LibrarySystem_NG
go

use LibrarySystem_NG;
go

create table ItemStatus
(
    ItemStatusCode   char(1)     not null,
    Name             varchar(20) not null,
    IsActive         bit         not null,
    InactiveDateTime datetime    null,
    CreatedDateTime  datetime    not null,
    CreatedBy        varchar(50) not null,
    ModifiedDatetime datetime    null,
    ModifiedBy       varchar(50) null,
    constraint pk_ItemStatus primary key (ItemStatusCode),
    constraint uk_ItemStatus_Name unique (Name)
);

create sequence seq_CategoryId
    start with 1
    increment by 1
go

create table Category
(
    CategoryId       tinyint default next value for seq_CategoryId,
    Name             varchar(50) not null,
    IsActive         bit         not null,
    InactiveDateTime datetime    null,
    CreatedDateTime  datetime    not null,
    CreatedBy        varchar(50) not null,
    ModifiedDateTime datetime    null,
    ModifiedBy       varchar(50) null,
    constraint pk_Category primary key (CategoryId),
    constraint uk_Category_Name unique (Name)
);

create table ItemType
(
    ItemTypeCode             char(1)       not null,
    Name                     varchar(20)   not null,
    DefaultLoanPeriodInWeeks tinyint       not null,
    RenewalsAllowed          bit           not null,
    RenewalLimit             tinyint       not null,
    RenewalPeriodInWeeks     tinyint       not null,
    ItemTypeLimitPerCheckout tinyint       null,
    ItemTypeLimitPerCard     tinyint       null,
    LateFeeAmountPerDate     numeric(4, 2) not null,
    LateFeeMaxAmount         numeric(4, 2) null,
    CreatedDateTime          datetime      not null,
    CreatedBy                varchar(50)   not null,
    ModifiedDateTime         datetime      null,
    ModifiedBy               varchar(50)   null,
    constraint pk_ItemType primary key (ItemTypeCode),
    constraint uk_ItemType_Name unique (Name)
);

create table Items
(
    ItemId           bigint identity (1,1),
    BarcodeId        varchar(20)   not null,
    Title            varchar(100)  not null,
    Description      varchar(1000) not null,
    YearPublished    smallint      not null,
    AuthorLastName   varchar(50)   not null,
    AuthorFirstName  varchar(50)   not null,
    CallNumber       varchar(10)   not null,
    ReplacementCost  numeric(6, 2) not null,
    CategoryId       tinyint       not null,
    ItemStatusCode   char(1)       not null,
    ItemTypeCode     char(1)       not null,
    CreatedDateTime  datetime      not null,
    CreatedBy        varchar(50)   not null,
    ModifiedDateTime datetime      null,
    ModifiedBy       varchar(50)   null,
    constraint pk_Items primary key (ItemId),
    constraint uk_Item_Title unique (Title),
    constraint fk_Items_CategoryId foreign key (CategoryId)
        references Category (CategoryId),
    constraint fk_Items_ItemStatusCode foreign key (ItemStatusCode)
        references ItemStatus (ItemStatusCode),
    constraint fk_ItemTypeCode foreign key (ItemTypeCode)
        references ItemType (ItemTypeCode)
);

create table Patron
(
    PatronId         bigint identity (1,1),
    BarcodeId        varchar(20) not null,
    FirstName        varchar(50) not null,
    MiddleName       varchar(50) null,
    LastName         varchar(50) not null,
    Suffix           varchar(20) null,
    BirthDate        date        not null,
    Address          varchar(50) not null,
    City             varchar(30) not null,
    State            char(2)     not null,
    ZipCode          varchar(10) not null,
    ParentGuardianId bigint      null,
    CreatedDateTime  datetime    not null,
    CreatedBy        varchar(50) not null,
    ModifiedDateTime datetime    null,
    ModifiedBy       varchar(50) null,
    constraint pk_Patron primary key (PatronId),
    constraint fk_Patron_ParentGuardianId foreign key (ParentGuardianId)
        references Patron (PatronId)
);

create table Loans
(
    LoanId           bigint identity (1,1),
    ItemId           bigint      not null,
    PatronId         bigint      not null,
    CheckoutDateTime datetime    not null,
    DueDate          date        not null,
    ReturnDate       date        null,
    RenewalCount     tinyint     not null default 0,
    CreatedDateTime  datetime    not null,
    CreatedBy        varchar(50) not null,
    ModifiedDateTime datetime    null,
    ModifiedBy       varchar(50) null,
    constraint pk_Loans primary key (LoanId),
    constraint fk_Loans_ItemId foreign key (ItemId)
        references Items (ItemId),
    constraint fk_Loans_PatronId foreign key (PatronId)
        references Patron (PatronId)
);

create table FeeType
(
    FeeTypeCode      char(2)     not null,
    Name             varchar(30) not null,
    IsActive         bit         not null,
    InactiveDateTime datetime    null,
    CreatedDateTime  datetime    not null,
    CreatedBy        varchar(50) not null,
    ModifiedDateTime datetime    null,
    ModifiedBy       varchar(50) null,
    constraint pk_FeeType primary key (FeeTypeCode),
    constraint uk_FeeType_Name unique (Name)
);

create table PatronFees
(
    FeeId           bigint identity (1,1),
    PatronId        bigint        not null,
    ItemId          bigint        not null,
    FeeTypeCode     char(2)       not null,
    DateAssessed    date          not null,
    FeeAmount       numeric(4, 2) not null,
    CreatedDateTime datetime      not null,
    CreatedBy       varchar(50)   not null,
    constraint pk_PatronFees primary key (FeeId),
    constraint fk_PatronFees_PatronId foreign key (PatronId)
        references Patron (PatronId),
    constraint fk_PatronFees_ItemId foreign key (ItemId)
        references Items (ItemId),
    constraint fk_PatronFees_FeeTypeCode foreign key (FeeTypeCode)
        references FeeType (FeeTypeCode)
);

create table PaymentMethod
(
    PaymentMethodId  tinyint identity (1,1),
    Name             varchar(30) not null,
    IsActive         bit         not null,
    InactiveDateTime datetime    null,
    CreatedDateTime  datetime    not null,
    CreatedBy        varchar(50) not null,
    ModifiedDateTime datetime    null,
    ModifiedBy       varchar(50) null,
    constraint pk_PaymentMethod primary key (PaymentMethodId),
    constraint uk_PaymentMethod_Name unique (Name)
);

create table Payments
(
    PaymentId       int identity (1,1),
    PatronId        bigint        not null,
    DatePaid        date          not null,
    AmountPaid      numeric(5, 2) not null,
    PaymentMethodId tinyint       not null,
    CreatedDateTime datetime      not null,
    CreatedBy       varchar(50)   not null,
    constraint pk_Payments primary key (PaymentId),
    constraint fk_Payments_PatronId foreign key (PatronId)
        references Patron (PatronId),
    constraint fk_Payments_PaymentMethodId foreign key (PaymentMethodId)
        references PaymentMethod (PaymentMethodId),
    constraint ck_Payments_AmountPaid check (AmountPaid > 0)
);

create table FeePayments
(
    FeePaymentId    bigint identity (1,1),
    PaymentId       int         not null,
    FeeId           bigint      not null,
    PaymentAmount   numeric(5, 2),
    CreatedDateTime datetime    not null,
    CreatedBy       varchar(50) not null,
    constraint pk_FeePayments primary key (FeePaymentId),
    constraint fk_FeePayments_PaymentId foreign key (PaymentId)
        references Payments (PaymentId),
    constraint fk_FeePayments_FeeId foreign key (FeeId)
        references PatronFees (FeeId)
);

create table Configuration
(
    ConfigurationId  smallint identity (1,1),
    Name             varchar(30)  not null,
    Description      varchar(100) not null,
    Value            varchar(20)  not null,
    CreatedDateTime  datetime     not null,
    CreatedBy        varchar(50)  not null,
    ModifiedDateTime datetime     null,
    ModifiedBy       varchar(50)  null
);