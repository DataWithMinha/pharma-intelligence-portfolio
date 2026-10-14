USE Pharma_Intelligence;
GO

-- Each table mirrors one FDA source file. Values remain text in RAW.
IF OBJECT_ID(N'RAW.RAW_FDA_APPLICATION_DOCS', N'U') IS NULL
BEGIN
    CREATE TABLE RAW.RAW_FDA_APPLICATION_DOCS (
        ApplicationDocsID nvarchar(max) NULL,
        ApplicationDocsTypeID nvarchar(max) NULL,
        ApplNo nvarchar(max) NULL,
        SubmissionType nvarchar(max) NULL,
        SubmissionNo nvarchar(max) NULL,
        ApplicationDocsTitle nvarchar(max) NULL,
        ApplicationDocsURL nvarchar(max) NULL,
        ApplicationDocsDate nvarchar(max) NULL
    );
END;
GO

IF OBJECT_ID(N'RAW.RAW_FDA_APPLICATIONS', N'U') IS NULL
BEGIN
    CREATE TABLE RAW.RAW_FDA_APPLICATIONS (
        ApplNo nvarchar(max) NULL,
        ApplType nvarchar(max) NULL,
        ApplPublicNotes nvarchar(max) NULL,
        SponsorName nvarchar(max) NULL
    );
END;
GO

IF OBJECT_ID(N'RAW.RAW_FDA_EXCLUSIVITY', N'U') IS NULL
BEGIN
    CREATE TABLE RAW.RAW_FDA_EXCLUSIVITY (
        Appl_Type nvarchar(max) NULL,
        Appl_No nvarchar(max) NULL,
        Product_No nvarchar(max) NULL,
        Exclusivity_Code nvarchar(max) NULL,
        Exclusivity_Date nvarchar(max) NULL
    );
END;
GO

IF OBJECT_ID(N'RAW.RAW_FDA_MARKETING_STATUS', N'U') IS NULL
BEGIN
    CREATE TABLE RAW.RAW_FDA_MARKETING_STATUS (
        MarketingStatusID nvarchar(max) NULL,
        ApplNo nvarchar(max) NULL,
        ProductNo nvarchar(max) NULL
    );
END;
GO

IF OBJECT_ID(N'RAW.RAW_FDA_PATENT', N'U') IS NULL
BEGIN
    CREATE TABLE RAW.RAW_FDA_PATENT (
        Appl_Type nvarchar(max) NULL,
        Appl_No nvarchar(max) NULL,
        Product_No nvarchar(max) NULL,
        Patent_No nvarchar(max) NULL,
        Patent_Expire_Date_Text nvarchar(max) NULL,
        Drug_Substance_Flag nvarchar(max) NULL,
        Drug_Product_Flag nvarchar(max) NULL,
        Patent_Use_Code nvarchar(max) NULL,
        Delist_Flag nvarchar(max) NULL,
        Submission_Date nvarchar(max) NULL
    );
END;
GO

IF OBJECT_ID(N'RAW.RAW_FDA_SUBMISSIONS', N'U') IS NULL
BEGIN
    CREATE TABLE RAW.RAW_FDA_SUBMISSIONS (
        ApplNo nvarchar(max) NULL,
        SubmissionClassCodeID nvarchar(max) NULL,
        SubmissionType nvarchar(max) NULL,
        SubmissionNo nvarchar(max) NULL,
        SubmissionStatus nvarchar(max) NULL,
        SubmissionStatusDate nvarchar(max) NULL,
        SubmissionsPublicNotes nvarchar(max) NULL,
        ReviewPriority nvarchar(max) NULL
    );
END;
GO
