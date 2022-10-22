-- when creating a new database, we have to do it against the master database
use master;
go

create database ScholarshipApp_AdvSQL25_NAG
go

use ScholarshipApp_AdvSQL25_NAG;
go

-- create a schema
use ScholarshipApp_AdvSQL25_NAG;
go

create schema TestSchema

create sequence seq_ScholarshipId
    start with 1
    increment by 1
go

select next value for seq_ScholarshipId

create table Scholarship
(
    ScholarshipID int                   default next value for seq_ScholarshipId,
    Name          varchar(100) not null,
    Description   varchar(max) not null,
    Amount        int          not null,
    IsActive      bit          not null default 1,
    constraint pk_Scholarship primary key (ScholarshipID),
    constraint uk_Scholarship_Name unique (Name),
    constraint ck_ScholarShip_Amount check (Amount >= 0)
)

create table ScholarshipEligibility
(
    ScholarshipEligibilityId int identity (1,1),
    ScholarshipId            int          not null,
    EligibilityDescription   varchar(100) not null,
    constraint pk_ScholarshipEligibility primary key (ScholarshipEligibilityId),
    constraint fk_ScholarshipEligibility_ScholarshipId foreign key (ScholarshipId)
        references Scholarship (ScholarshipID)
        on delete cascade
        on update cascade
)