USE master;
GO

CREATE DATABASE CarRentalApplication_NG
GO

USE CarRentalApplication_NG;
GO

/* Create tables */

CREATE TABLE Customers
(
    CustomerId   INT IDENTITY (1,1),
    FirstName    VARCHAR(50) NULL,
    LastName     VARCHAR(50) NULL,
    CompanyName  VARCHAR(50) NULL,
    PhoneNumber  VARCHAR(20) NOT NULL,
    EmailAddress VARCHAR(50) NOT NULL,
    Address      VARCHAR(50) NOT NULL,
    City         VARCHAR(20) NOT NULL,
    State        CHAR(2)     NOT NULL,
    ZipCode      VARCHAR(5)  NOT NULL,
    CONSTRAINT pk_Customers PRIMARY KEY (CustomerId),
    CONSTRAINT uk_Customers_EmailAddress UNIQUE (EmailAddress)
);

CREATE TABLE Employees
(
    EmployeeId INT IDENTITY (1,1),
    FirstName  VARCHAR(50) NOT NULL,
    LastName   VARCHAR(50) NOT NULL,
    CONSTRAINT pk_Employees PRIMARY KEY (EmployeeId)
);

CREATE TABLE VehicleTypes
(
    VehicleTypeId INT IDENTITY (1,1),
    Type          VARCHAR(30)  NOT NULL,
    Description   VARCHAR(250) NULL,
    CONSTRAINT pk_VehicleTypes PRIMARY KEY (VehicleTypeId),
    CONSTRAINT uk_VehicleTypes_Type UNIQUE (Type)
);

CREATE TABLE LocationType
(
    LocationTypeId INT IDENTITY (1,1),
    LocationType   VARCHAR(30) NOT NULL,
    CONSTRAINT pk_LocationType PRIMARY KEY (LocationTypeId),
    CONSTRAINT uk_LocationType_LocationType UNIQUE (LocationType)
);

CREATE TABLE Location
(
    LocationId     INT IDENTITY (1,1),
    Name           VARCHAR(50)  NOT NULL,
    Address        VARCHAR(100) NOT NULL,
    City           VARCHAR(50)  NOT NULL,
    State          CHAR(2)      NOT NULL,
    ZipCode        VARCHAR(10)  NOT NULL,
    LocationTypeId INT          NOT NULL,
    CONSTRAINT pk_Location PRIMARY KEY (LocationId),
    CONSTRAINT fk_Location_LocationTypeId FOREIGN KEY (LocationTypeId)
        REFERENCES LocationType (LocationTypeId)
);

CREATE TABLE Vehicles
(
    VehicleId             INT IDENTITY (1,1),
    Vin                   VARCHAR(20) NOT NULL,
    LicensePlate          VARCHAR(10) NOT NULL,
    Make                  VARCHAR(20) NOT NULL,
    Model                 VARCHAR(20) NOT NULL,
    Year                  INT         NOT NULL,
    Mileage               INT         NOT NULL,
    VehicleType           INT         NOT NULL,
    Color                 VARCHAR(20) NOT NULL,
    FuelType              VARCHAR(10) NOT NULL DEFAULT 'Gasoline',
    TransmissionType      VARCHAR(10) NOT NULL DEFAULT 'Automatic',
    CurrentLocation       INT         NOT NULL,
    Capacity              INT         NOT NULL,
    NumberOfDoors         INT         NOT NULL,
    CurrentDailyRentalFee DECIMAL     NOT NULL DEFAULT 0,
    CONSTRAINT pk_Vehicles PRIMARY KEY (VehicleId),
    CONSTRAINT fk_Vehicles_VehicleType FOREIGN KEY (VehicleType)
        REFERENCES VehicleTypes (VehicleTypeId),
    CONSTRAINT fk_Vehicles_CurrentLocation FOREIGN KEY (CurrentLocation)
        REFERENCES Location (LocationId),
    CONSTRAINT uk_Vehicles_Vin UNIQUE (Vin),
    CONSTRAINT ck_Vehicles_Capacity CHECK (Capacity > 0),
    CONSTRAINT ck_Vehicles_NumberOfDoors CHECK (NumberOfDoors > 0),
    CONSTRAINT ck_Vehicles_CurrentDailyRentalFee CHECK (CurrentDailyRentalFee > 0),
);

CREATE TABLE Reservation
(
    ReservationId       INT IDENTITY (1,1),
    CustomerId          INT      NOT NULL,
    ReservationDateTime DATETIME NOT NULL,
    PickupDate          DATE     NOT NULL,
    ReturnDate          DATE     NULL,
    EmployeeId          INT      NULL,
    PickupLocationId    INT      NOT NULL,
    DropoffLocationId   INT      NULL,
    CONSTRAINT pk_Reservation PRIMARY KEY (ReservationId),
    CONSTRAINT fk_Reservation_Customer FOREIGN KEY (ReservationId)
        REFERENCES Reservation (ReservationId),
    CONSTRAINT fk_Reservation_EmployeeId FOREIGN KEY (EmployeeId)
        REFERENCES Employees (EmployeeId),
    CONSTRAINT fk_Reservation_PickupLocationId FOREIGN KEY (PickupLocationId)
        REFERENCES Location (LocationId),
    CONSTRAINT fk_Reservation_DropoffLocationId FOREIGN KEY (DropoffLocationId)
        REFERENCES Location (LocationId),
    CONSTRAINT ck_Reservation_ReturnDate CHECK (ReturnDate >= PickupDate)
);

CREATE TABLE ReservationVehicleTypes
(
    ReservationVehicleTypeId INT IDENTITY (1,1),
    ReservationId            INT          NOT NULL,
    VehicleTypeId            INT          NOT NULL,
    Quantity                 INT          NOT NULL DEFAULT 1,
    Notes                    VARCHAR(250) NOT NULL,
    CONSTRAINT pk_ReservationVehicleTypes PRIMARY KEY (ReservationVehicleTypeId),
    CONSTRAINT fk_ReservationVehicleTypes_ReservationId FOREIGN KEY (ReservationId)
        REFERENCES Reservation (ReservationId),
    CONSTRAINT fk_ReservationVehicleTypes_VehicleTypeId FOREIGN KEY (VehicleTypeId)
        REFERENCES VehicleTypes (VehicleTypeId),
    CONSTRAINT ck_ReservationVehicleTypes_Quantity CHECK (Quantity > 0)
);

CREATE TABLE Rentals
(
    RentalId          INT IDENTITY (1,1),
    ReservationId     INT  NOT NULL,
    RentalDate        DATE NOT NULL,
    ReturnDate        DATE NULL,
    CustomerId        INT  NOT NULL,
    PickupLocationId  INT  NOT NULL,
    DropoffLocationId INT  NULL,
    EmployeeId        INT  NOT NULL,
    CONSTRAINT pk_Rentals PRIMARY KEY (RentalId),
    CONSTRAINT fk_Rentals_ReservationId FOREIGN KEY (ReservationId)
        REFERENCES Reservation (ReservationId),
    CONSTRAINT fk_Rentals_CustomerId FOREIGN KEY (CustomerId)
        REFERENCES Customers (CustomerId),
    CONSTRAINT fk_Rentals_PickupLocationId FOREIGN KEY (PickupLocationId)
        REFERENCES Location (LocationId),
    CONSTRAINT fk_Rentals_DropoffLocationId FOREIGN KEY (DropoffLocationId)
        REFERENCES Location (LocationId),
    CONSTRAINT fk_Rentals_LocationId FOREIGN KEY (EmployeeId)
        REFERENCES Location (LocationId),
    CONSTRAINT ck_Rentals_ReturnDate CHECK (ReturnDate >= Rentals.RentalDate)
);

CREATE TABLE RentalVehicles
(
    RentalVehicleId INT IDENTITY (1,1),
    RentalId        INT     NOT NULL,
    VehicleId       INT     NOT NULL,
    DailyRentalFee  DECIMAL NOT NULL DEFAULT 0,
    CONSTRAINT pk_RentalVehicles PRIMARY KEY (RentalVehicleId),
    CONSTRAINT fk_RentalVehicles_RentalId FOREIGN KEY (RentalId)
        REFERENCES Rentals (RentalId),
    CONSTRAINT fk_RentalVehicles_VehicleId FOREIGN KEY (VehicleId)
        REFERENCES Vehicles (VehicleId),
    CONSTRAINT ck_RentalVehicles_DailyRentalFee CHECK (DailyRentalFee >= 0)
);

CREATE TABLE Payment
(
    PaymentId     INT IDENTITY (1,1),
    PaymentType   VARCHAR(10) NOT NULL DEFAULT 'Credit',
    PaymentAmount DECIMAL     NOT NULL DEFAULT 0,
    RentalId      INT         NULL,
    PaymentDate   DATE        NOT NULL DEFAULT GETDATE(),
    CONSTRAINT pk_Payment PRIMARY KEY (PaymentId),
    CONSTRAINT fk_Payment_RentalId FOREIGN KEY (RentalId)
        REFERENCES Rentals (RentalId)
);

GO

/* Indexes */

-- Fix clustered indexes on bridge tables

ALTER TABLE ReservationVehicleTypes
    DROP CONSTRAINT pk_ReservationVehicleTypes

ALTER TABLE ReservationVehicleTypes
    ADD CONSTRAINT pk_ReservationVehicleTypes
        PRIMARY KEY NONCLUSTERED (ReservationVehicleTypeId)

CREATE UNIQUE CLUSTERED INDEX
    IX_ReservationVehicleTypes_ReservationId_VehicleTypeId
    ON ReservationVehicleTypes (ReservationId, VehicleTypeId)

ALTER TABLE RentalVehicles
    DROP CONSTRAINT pk_RentalVehicles

ALTER TABLE RentalVehicles
    ADD CONSTRAINT pk_RentalVehicles
        PRIMARY KEY NONCLUSTERED (RentalVehicleId)

CREATE UNIQUE CLUSTERED INDEX
    IX_RentalVehicles_RentalId_VehicleId
    ON RentalVehicles (RentalId, VehicleId)

-- Foreign key indexes

CREATE INDEX IX_Reservation_CustomerId
    ON Reservation (CustomerId)

CREATE INDEX IX_Vehicles_CurrentLocation
    ON Vehicles (CurrentLocation)

CREATE INDEX IX_Payment_RentalId
    ON Payment (RentalId)

-- Columnstore indexes

CREATE COLUMNSTORE INDEX IX_Payment_PaymentType
    ON Payment (PaymentType)

CREATE COLUMNSTORE INDEX IX_Vehicles_FuelType
    ON Vehicles (FuelType)

-- Common query indexes

CREATE INDEX IX_Customers_Name
    ON Customers (LastName, FirstName)

CREATE INDEX IX_Employees_Name
    ON Employees (LastName, FirstName)

CREATE INDEX IX_Reservations_ReservationDate
    ON Reservation (ReservationDateTime, CustomerId, PickupLocationId)

CREATE INDEX IX_Rentals_RentalsNotReturned
    ON Rentals (CustomerId, RentalDate)
    WHERE (ReturnDate IS NULL)

CREATE INDEX IX_Vehicles_VehiclesByMakeModel
    ON Vehicles (Vin, Make, Model, LicensePlate)