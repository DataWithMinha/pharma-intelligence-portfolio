USE Pharma_Intelligence;
GO

CREATE TABLE STG.STG_CLINICAL_TRIAL (
    StgClinicalTrialID bigint IDENTITY(1,1) NOT NULL PRIMARY KEY,
    RawClinicalTrialID bigint NOT NULL UNIQUE,
    NCTNumber nvarchar(50) NOT NULL,
    StudyTitle nvarchar(1000) NOT NULL,
    OverallStatus nvarchar(100) NULL,
    Phase nvarchar(100) NULL,
    Enrollment int NULL,
    StartDate date NULL,
    CompletionDate date NULL,
    SponsorName nvarchar(500) NULL,
    Conditions nvarchar(max) NULL,
    Interventions nvarchar(max) NULL,
    Geography nvarchar(100) NULL,
    StandardizedDrugName nvarchar(500) NULL,
    LoadedAt datetime2(0) NOT NULL CONSTRAINT DF_STG_CLINICAL_TRIAL_LoadedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_STG_CLINICAL_TRIAL_RAW FOREIGN KEY (RawClinicalTrialID) REFERENCES RAW.RAW_CLINICAL_TRIAL(RawClinicalTrialID)
);
GO

CREATE TABLE STG.STG_REGULATORY_EVENT (
    StgRegulatoryEventID bigint IDENTITY(1,1) NOT NULL PRIMARY KEY,
    RawFdaRegulatoryID bigint NOT NULL UNIQUE,
    ApplicationNumber nvarchar(100) NOT NULL,
    ProductName nvarchar(500) NOT NULL,
    SponsorName nvarchar(500) NULL,
    EventDate date NULL,
    EventName nvarchar(200) NOT NULL,
    EventStatus nvarchar(100) NULL,
    Description nvarchar(max) NULL,
    StandardizedDrugName nvarchar(500) NULL,
    LoadedAt datetime2(0) NOT NULL CONSTRAINT DF_STG_REGULATORY_EVENT_LoadedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_STG_REGULATORY_EVENT_RAW FOREIGN KEY (RawFdaRegulatoryID) REFERENCES RAW.RAW_FDA_REGULATORY(RawFdaRegulatoryID)
);
GO

CREATE TABLE STG.STG_PATENT_EVENT (
    StgPatentEventID bigint IDENTITY(1,1) NOT NULL PRIMARY KEY,
    RawPatentID bigint NOT NULL UNIQUE,
    PatentNumber nvarchar(100) NOT NULL,
    StandardizedDrugName nvarchar(500) NULL,
    AssigneeName nvarchar(500) NULL,
    FilingDate date NULL,
    GrantDate date NULL,
    ExpiryDate date NULL,
    PatentStatus nvarchar(100) NULL,
    Jurisdiction nvarchar(100) NULL,
    PatentTitle nvarchar(1000) NULL,
    LoadedAt datetime2(0) NOT NULL CONSTRAINT DF_STG_PATENT_EVENT_LoadedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_STG_PATENT_EVENT_RAW FOREIGN KEY (RawPatentID) REFERENCES RAW.RAW_PATENT(RawPatentID)
);
GO

CREATE TABLE STG.STG_MARKET (
    StgMarketID bigint IDENTITY(1,1) NOT NULL PRIMARY KEY,
    RawMarketID bigint NOT NULL UNIQUE,
    TherapeuticAreaName nvarchar(250) NOT NULL,
    Geography nvarchar(100) NOT NULL,
    MarketDate date NOT NULL,
    MarketSizeUsdM decimal(19,2) NULL,
    GrowthRatePct decimal(9,4) NULL,
    CompetitiveIntensity decimal(9,4) NULL,
    SourceScoreValue decimal(9,4) NULL,
    SourceReference nvarchar(1000) NULL,
    LoadedAt datetime2(0) NOT NULL CONSTRAINT DF_STG_MARKET_LoadedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_STG_MARKET_RAW FOREIGN KEY (RawMarketID) REFERENCES RAW.RAW_MARKET(RawMarketID)
);
GO
