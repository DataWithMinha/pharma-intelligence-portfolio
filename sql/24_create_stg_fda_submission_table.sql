USE Pharma_Intelligence;
GO

IF OBJECT_ID(N'STG.STG_FDA_SUBMISSION', N'U') IS NULL
BEGIN
    CREATE TABLE STG.STG_FDA_SUBMISSION (
        StgFdaSubmissionID bigint IDENTITY(1,1) NOT NULL PRIMARY KEY,
        ApplNo nvarchar(100) NOT NULL,
        SubmissionNo nvarchar(100) NULL,
        SubmissionType nvarchar(100) NULL,
        SubmissionClassCodeID nvarchar(100) NULL,
        SubmissionStatusCode nvarchar(20) NULL,
        SubmissionStatusDate date NULL,
        ReviewPriority nvarchar(100) NULL,
        PublicNotes nvarchar(max) NULL,
        TradeName nvarchar(500) NOT NULL,
        Ingredient nvarchar(max) NULL,
        ApplicantName nvarchar(500) NULL,
        LoadedAt datetime2(0) NOT NULL CONSTRAINT DF_STG_FDA_SUBMISSION_LoadedAt DEFAULT SYSUTCDATETIME(),
        CONSTRAINT UQ_STG_FDA_SUBMISSION UNIQUE (ApplNo, SubmissionNo, SubmissionType, SubmissionStatusCode, SubmissionStatusDate)
    );
END;
GO
