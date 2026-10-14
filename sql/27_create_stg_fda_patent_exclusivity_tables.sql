USE Pharma_Intelligence;
GO

IF OBJECT_ID(N'STG.STG_FDA_PATENT', N'U') IS NULL
BEGIN
    CREATE TABLE STG.STG_FDA_PATENT (
        StgFdaPatentID bigint IDENTITY(1,1) NOT NULL PRIMARY KEY,
        ApplType nvarchar(50) NULL,
        ApplNo nvarchar(100) NOT NULL,
        ProductNo nvarchar(100) NOT NULL,
        PatentNo nvarchar(100) NOT NULL,
        PatentExpiryDate date NOT NULL,
        DrugSubstanceFlag nvarchar(20) NULL,
        DrugProductFlag nvarchar(20) NULL,
        PatentUseCode nvarchar(100) NULL,
        DelistFlag nvarchar(20) NULL,
        SubmissionDate date NULL,
        TradeName nvarchar(500) NOT NULL,
        Ingredient nvarchar(max) NULL,
        ApplicantName nvarchar(500) NULL,
        LoadedAt datetime2(0) NOT NULL CONSTRAINT DF_STG_FDA_PATENT_LoadedAt DEFAULT SYSUTCDATETIME(),
        CONSTRAINT UQ_STG_FDA_PATENT UNIQUE (ApplNo, ProductNo, PatentNo, PatentExpiryDate)
    );
END;
GO

IF OBJECT_ID(N'STG.STG_FDA_EXCLUSIVITY', N'U') IS NULL
BEGIN
    CREATE TABLE STG.STG_FDA_EXCLUSIVITY (
        StgFdaExclusivityID bigint IDENTITY(1,1) NOT NULL PRIMARY KEY,
        ApplType nvarchar(50) NULL,
        ApplNo nvarchar(100) NOT NULL,
        ProductNo nvarchar(100) NOT NULL,
        ExclusivityCode nvarchar(100) NOT NULL,
        ExclusivityDate date NOT NULL,
        TradeName nvarchar(500) NOT NULL,
        Ingredient nvarchar(max) NULL,
        ApplicantName nvarchar(500) NULL,
        LoadedAt datetime2(0) NOT NULL CONSTRAINT DF_STG_FDA_EXCLUSIVITY_LoadedAt DEFAULT SYSUTCDATETIME(),
        CONSTRAINT UQ_STG_FDA_EXCLUSIVITY UNIQUE (ApplNo, ProductNo, ExclusivityCode, ExclusivityDate)
    );
END;
GO
