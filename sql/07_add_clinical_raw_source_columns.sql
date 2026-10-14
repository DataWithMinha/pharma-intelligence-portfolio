USE Pharma_Intelligence;
GO

-- Run this once only if RAW.RAW_CLINICAL_TRIAL was created before the
-- ClinicalTrials.gov source-column update.
IF COL_LENGTH(N'RAW.RAW_CLINICAL_TRIAL', N'StudyUrl') IS NULL
    ALTER TABLE RAW.RAW_CLINICAL_TRIAL ADD StudyUrl nvarchar(1000) NULL;
GO

IF COL_LENGTH(N'RAW.RAW_CLINICAL_TRIAL', N'Collaborators') IS NULL
    ALTER TABLE RAW.RAW_CLINICAL_TRIAL ADD Collaborators nvarchar(max) NULL;
GO

IF COL_LENGTH(N'RAW.RAW_CLINICAL_TRIAL', N'LastUpdatePosted') IS NULL
    ALTER TABLE RAW.RAW_CLINICAL_TRIAL ADD LastUpdatePosted nvarchar(100) NULL;
GO
