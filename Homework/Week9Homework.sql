USE master;
GO

CREATE DATABASE LibrarySystem_NG
GO

USE LibrarySystem_NG;
GO

CREATE TABLE ItemStatus
(
    ItemStatusCode   CHAR(1)     NOT NULL,
    Name             VARCHAR(20) NOT NULL,
    IsActive         BIT         NOT NULL,
    InactiveDateTime DATETIME    NULL,
    CreatedDateTime  DATETIME    NOT NULL,
    CreatedBy        VARCHAR(50) NOT NULL,
    ModifiedDatetime DATETIME    NULL,
    ModifiedBy       VARCHAR(50) NULL,
    CONSTRAINT pk_ItemStatus PRIMARY KEY (ItemStatusCode),
    CONSTRAINT uk_ItemStatus_Name UNIQUE (Name)
);

CREATE SEQUENCE seq_CategoryId
    START WITH 1
    INCREMENT BY 1
GO

CREATE TABLE Category
(
    CategoryId       TINYINT DEFAULT NEXT VALUE FOR seq_CategoryId,
    Name             VARCHAR(50) NOT NULL,
    IsActive         BIT         NOT NULL,
    InactiveDateTime DATETIME    NULL,
    CreatedDateTime  DATETIME    NOT NULL,
    CreatedBy        VARCHAR(50) NOT NULL,
    ModifiedDateTime DATETIME    NULL,
    ModifiedBy       VARCHAR(50) NULL,
    CONSTRAINT pk_Category PRIMARY KEY (CategoryId),
    CONSTRAINT uk_Category_Name UNIQUE (Name)
);

CREATE TABLE ItemType
(
    ItemTypeCode             CHAR(1)       NOT NULL,
    Name                     VARCHAR(20)   NOT NULL,
    DefaultLoanPeriodInWeeks TINYINT       NOT NULL,
    RenewalsAllowed          BIT           NOT NULL,
    RenewalLimit             TINYINT       NOT NULL,
    RenewalPeriodInWeeks     TINYINT       NOT NULL,
    ItemTypeLimitPerCheckout TINYINT       NULL,
    ItemTypeLimitPerCard     TINYINT       NULL,
    LateFeeAmountPerDate     NUMERIC(4, 2) NOT NULL,
    LateFeeMaxAmount         NUMERIC(4, 2) NULL,
    CreatedDateTime          DATETIME      NOT NULL,
    CreatedBy                VARCHAR(50)   NOT NULL,
    ModifiedDateTime         DATETIME      NULL,
    ModifiedBy               VARCHAR(50)   NULL,
    CONSTRAINT pk_ItemType PRIMARY KEY (ItemTypeCode),
    CONSTRAINT uk_ItemType_Name UNIQUE (Name)
);

CREATE TABLE Items
(
    ItemId           BIGINT IDENTITY (1,1),
    BarcodeId        VARCHAR(20)   NOT NULL,
    Title            VARCHAR(100)  NOT NULL,
    Description      VARCHAR(1000) NOT NULL,
    YearPublished    SMALLINT      NOT NULL,
    AuthorLastName   VARCHAR(50)   NOT NULL,
    AuthorFirstName  VARCHAR(50)   NOT NULL,
    CallNumber       VARCHAR(10)   NOT NULL,
    ReplacementCost  NUMERIC(6, 2) NOT NULL,
    CategoryId       TINYINT       NOT NULL,
    ItemStatusCode   CHAR(1)       NOT NULL,
    ItemTypeCode     CHAR(1)       NOT NULL,
    CreatedDateTime  DATETIME      NOT NULL,
    CreatedBy        VARCHAR(50)   NOT NULL,
    ModifiedDateTime DATETIME      NULL,
    ModifiedBy       VARCHAR(50)   NULL,
    CONSTRAINT pk_Items PRIMARY KEY (ItemId),
    CONSTRAINT uk_Item_Title UNIQUE (Title),
    CONSTRAINT fk_Items_CategoryId FOREIGN KEY (CategoryId)
        REFERENCES Category (CategoryId),
    CONSTRAINT fk_Items_ItemStatusCode FOREIGN KEY (ItemStatusCode)
        REFERENCES ItemStatus (ItemStatusCode),
    CONSTRAINT fk_ItemTypeCode FOREIGN KEY (ItemTypeCode)
        REFERENCES ItemType (ItemTypeCode)
);

CREATE TABLE Patron
(
    PatronId         BIGINT IDENTITY (1,1),
    BarcodeId        VARCHAR(20) NOT NULL,
    FirstName        VARCHAR(50) NOT NULL,
    MiddleName       VARCHAR(50) NULL,
    LastName         VARCHAR(50) NOT NULL,
    Suffix           VARCHAR(20) NULL,
    BirthDate        DATE        NOT NULL,
    Address          VARCHAR(50) NOT NULL,
    City             VARCHAR(30) NOT NULL,
    State            CHAR(2)     NOT NULL,
    ZipCode          VARCHAR(10) NOT NULL,
    ParentGuardianId BIGINT      NULL,
    CreatedDateTime  DATETIME    NOT NULL,
    CreatedBy        VARCHAR(50) NOT NULL,
    ModifiedDateTime DATETIME    NULL,
    ModifiedBy       VARCHAR(50) NULL,
    CONSTRAINT pk_Patron PRIMARY KEY (PatronId),
    CONSTRAINT fk_Patron_ParentGuardianId FOREIGN KEY (ParentGuardianId)
        REFERENCES Patron (PatronId)
);

CREATE TABLE Loans
(
    LoanId           BIGINT IDENTITY (1,1),
    ItemId           BIGINT      NOT NULL,
    PatronId         BIGINT      NOT NULL,
    CheckoutDateTime DATETIME    NOT NULL,
    DueDate          DATE        NOT NULL,
    ReturnDate       DATE        NULL,
    RenewalCount     TINYINT     NOT NULL DEFAULT 0,
    CreatedDateTime  DATETIME    NOT NULL,
    CreatedBy        VARCHAR(50) NOT NULL,
    ModifiedDateTime DATETIME    NULL,
    ModifiedBy       VARCHAR(50) NULL,
    CONSTRAINT pk_Loans PRIMARY KEY (LoanId),
    CONSTRAINT fk_Loans_ItemId FOREIGN KEY (ItemId)
        REFERENCES Items (ItemId),
    CONSTRAINT fk_Loans_PatronId FOREIGN KEY (PatronId)
        REFERENCES Patron (PatronId)
);

CREATE TABLE FeeType
(
    FeeTypeCode      CHAR(2)     NOT NULL,
    Name             VARCHAR(30) NOT NULL,
    IsActive         BIT         NOT NULL,
    InactiveDateTime DATETIME    NULL,
    CreatedDateTime  DATETIME    NOT NULL,
    CreatedBy        VARCHAR(50) NOT NULL,
    ModifiedDateTime DATETIME    NULL,
    ModifiedBy       VARCHAR(50) NULL,
    CONSTRAINT pk_FeeType PRIMARY KEY (FeeTypeCode),
    CONSTRAINT uk_FeeType_Name UNIQUE (Name)
);

CREATE TABLE PatronFees
(
    FeeId           BIGINT IDENTITY (1,1),
    PatronId        BIGINT        NOT NULL,
    ItemId          BIGINT        NOT NULL,
    FeeTypeCode     CHAR(2)       NOT NULL,
    DateAssessed    DATE          NOT NULL,
    FeeAmount       NUMERIC(4, 2) NOT NULL,
    CreatedDateTime DATETIME      NOT NULL,
    CreatedBy       VARCHAR(50)   NOT NULL,
    CONSTRAINT pk_PatronFees PRIMARY KEY (FeeId),
    CONSTRAINT fk_PatronFees_PatronId FOREIGN KEY (PatronId)
        REFERENCES Patron (PatronId),
    CONSTRAINT fk_PatronFees_ItemId FOREIGN KEY (ItemId)
        REFERENCES Items (ItemId),
    CONSTRAINT fk_PatronFees_FeeTypeCode FOREIGN KEY (FeeTypeCode)
        REFERENCES FeeType (FeeTypeCode)
);

CREATE TABLE PaymentMethod
(
    PaymentMethodId  TINYINT IDENTITY (1,1),
    Name             VARCHAR(30) NOT NULL,
    IsActive         BIT         NOT NULL,
    InactiveDateTime DATETIME    NULL,
    CreatedDateTime  DATETIME    NOT NULL,
    CreatedBy        VARCHAR(50) NOT NULL,
    ModifiedDateTime DATETIME    NULL,
    ModifiedBy       VARCHAR(50) NULL,
    CONSTRAINT pk_PaymentMethod PRIMARY KEY (PaymentMethodId),
    CONSTRAINT uk_PaymentMethod_Name UNIQUE (Name)
);

CREATE TABLE Payments
(
    PaymentId       INT IDENTITY (1,1),
    PatronId        BIGINT        NOT NULL,
    DatePaid        DATE          NOT NULL,
    AmountPaid      NUMERIC(5, 2) NOT NULL,
    PaymentMethodId TINYINT       NOT NULL,
    CreatedDateTime DATETIME      NOT NULL,
    CreatedBy       VARCHAR(50)   NOT NULL,
    CONSTRAINT pk_Payments PRIMARY KEY (PaymentId),
    CONSTRAINT fk_Payments_PatronId FOREIGN KEY (PatronId)
        REFERENCES Patron (PatronId),
    CONSTRAINT fk_Payments_PaymentMethodId FOREIGN KEY (PaymentMethodId)
        REFERENCES PaymentMethod (PaymentMethodId),
    CONSTRAINT ck_Payments_AmountPaid CHECK (AmountPaid > 0)
);

CREATE TABLE FeePayments
(
    FeePaymentId    BIGINT IDENTITY (1,1),
    PaymentId       INT         NOT NULL,
    FeeId           BIGINT      NOT NULL,
    PaymentAmount   NUMERIC(5, 2),
    CreatedDateTime DATETIME    NOT NULL,
    CreatedBy       VARCHAR(50) NOT NULL,
    CONSTRAINT pk_FeePayments PRIMARY KEY (FeePaymentId),
    CONSTRAINT fk_FeePayments_PaymentId FOREIGN KEY (PaymentId)
        REFERENCES Payments (PaymentId),
    CONSTRAINT fk_FeePayments_FeeId FOREIGN KEY (FeeId)
        REFERENCES PatronFees (FeeId)
);

CREATE TABLE Configuration
(
    ConfigurationId  SMALLINT IDENTITY (1,1),
    Name             VARCHAR(30)  NOT NULL,
    Description      VARCHAR(100) NOT NULL,
    Value            VARCHAR(20)  NOT NULL,
    CreatedDateTime  DATETIME     NOT NULL,
    CreatedBy        VARCHAR(50)  NOT NULL,
    ModifiedDateTime DATETIME     NULL,
    ModifiedBy       VARCHAR(50)  NULL
);