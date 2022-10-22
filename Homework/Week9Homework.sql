use master;
go

create database LibrarySystem
go

use LibrarySystem;
go

create table ItemStatus
(
    ItemStatusCode   char(1) identity (1,1),
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

create table Category
(
    CategoryId       tinyint identity (1,1),
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