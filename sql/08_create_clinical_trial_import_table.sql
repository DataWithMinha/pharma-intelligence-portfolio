USE Pharma_Intelligence;
GO

-- This table matches the 16 columns in the ClinicalTrials.gov CSV exactly.
-- All fields remain text so the RAW import cannot fail because of source formats.
IF OBJECT_ID(N'RAW.IMPORT_CLINICAL_TRIAL', N'U') IS NULL
BEGIN
    CREATE TABLE RAW.IMPORT_CLINICAL_TRIAL (
        NCTNumber nvarchar(max) NULL,
        StudyTitle nvarchar(max) NULL,
        StudyUrl nvarchar(max) NULL,
        StudyStatus nvarchar(max) NULL,
        BriefSummary nvarchar(max) NULL,
        Conditions nvarchar(max) NULL,
        Interventions nvarchar(max) NULL,
        Sponsor nvarchar(max) NULL,
        Collaborators nvarchar(max) NULL,
        Phases nvarchar(max) NULL,
        Enrollment nvarchar(max) NULL,
        StudyType nvarchar(max) NULL,
        StartDate nvarchar(max) NULL,
        PrimaryCompletionDate nvarchar(max) NULL,
        CompletionDate nvarchar(max) NULL,
        LastUpdatePosted nvarchar(max) NULL
    );
END;
GO
