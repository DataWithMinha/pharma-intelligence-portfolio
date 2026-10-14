USE Pharma_Intelligence;
GO

CREATE TABLE RAW.RAW_CLINICAL_TRIAL (
    RawClinicalTrialID bigint IDENTITY(1,1) NOT NULL PRIMARY KEY,
    SourceFileName nvarchar(260) NOT NULL,
    SourceRowNumber int NULL,
    NCTNumber nvarchar(50) NULL,
    StudyTitle nvarchar(1000) NULL,
    StudyUrl nvarchar(1000) NULL,
    OverallStatus nvarchar(100) NULL,
    Phase nvarchar(100) NULL,
    StudyType nvarchar(100) NULL,
    Enrollment nvarchar(100) NULL,
    StartDate nvarchar(100) NULL,
    PrimaryCompletionDate nvarchar(100) NULL,
    CompletionDate nvarchar(100) NULL,
    Sponsor nvarchar(500) NULL,
    Collaborators nvarchar(max) NULL,
    Conditions nvarchar(max) NULL,
    Interventions nvarchar(max) NULL,
    Locations nvarchar(max) NULL,
    BriefSummary nvarchar(max) NULL,
    LastUpdatePosted nvarchar(100) NULL,
    LoadedAt datetime2(0) NOT NULL CONSTRAINT DF_RAW_CLINICAL_TRIAL_LoadedAt DEFAULT SYSUTCDATETIME()
);
GO

CREATE TABLE RAW.RAW_FDA_REGULATORY (
    RawFdaRegulatoryID bigint IDENTITY(1,1) NOT NULL PRIMARY KEY,
    SourceFileName nvarchar(260) NOT NULL,
    SourceRowNumber int NULL,
    ApplicationNumber nvarchar(100) NULL,
    ProductName nvarchar(500) NULL,
    SponsorName nvarchar(500) NULL,
    ActionDate nvarchar(100) NULL,
    ActionType nvarchar(200) NULL,
    Status nvarchar(100) NULL,
    SubmissionClass nvarchar(200) NULL,
    Description nvarchar(max) NULL,
    LoadedAt datetime2(0) NOT NULL CONSTRAINT DF_RAW_FDA_REGULATORY_LoadedAt DEFAULT SYSUTCDATETIME()
);
GO

CREATE TABLE RAW.RAW_PATENT (
    RawPatentID bigint IDENTITY(1,1) NOT NULL PRIMARY KEY,
    SourceFileName nvarchar(260) NOT NULL,
    SourceRowNumber int NULL,
    PatentNumber nvarchar(100) NULL,
    DrugName nvarchar(500) NULL,
    AssigneeName nvarchar(500) NULL,
    FilingDate nvarchar(100) NULL,
    GrantDate nvarchar(100) NULL,
    ExpiryDate nvarchar(100) NULL,
    PatentStatus nvarchar(100) NULL,
    Jurisdiction nvarchar(100) NULL,
    PatentTitle nvarchar(1000) NULL,
    LoadedAt datetime2(0) NOT NULL CONSTRAINT DF_RAW_PATENT_LoadedAt DEFAULT SYSUTCDATETIME()
);
GO

CREATE TABLE RAW.RAW_MARKET (
    RawMarketID bigint IDENTITY(1,1) NOT NULL PRIMARY KEY,
    SourceFileName nvarchar(260) NOT NULL,
    SourceRowNumber int NULL,
    TherapeuticArea nvarchar(250) NULL,
    Geography nvarchar(100) NULL,
    MarketYear nvarchar(20) NULL,
    MarketSizeUsdM nvarchar(100) NULL,
    GrowthRatePct nvarchar(100) NULL,
    CompetitiveIntensity nvarchar(100) NULL,
    SourceAreaID nvarchar(100) NULL,
    SourceDateID nvarchar(100) NULL,
    SourceScoreValue nvarchar(100) NULL,
    SourceReference nvarchar(1000) NULL,
    LoadedAt datetime2(0) NOT NULL CONSTRAINT DF_RAW_MARKET_LoadedAt DEFAULT SYSUTCDATETIME()
);
GO
