USE Pharma_Intelligence;
GO

-- Step 1: Load the untouched CSV into the source-shaped RAW import table.
-- Run this on the same computer where SQL Server can read the file path.
BULK INSERT RAW.IMPORT_CLINICAL_TRIAL
FROM 'C:\Users\minha\Downloads\PHARMA INTEL\clinical_trials_tagrisso.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001',
    TABLOCK
);
GO

-- Step 2: Map the source columns into the project's permanent RAW table.
-- No cleaning happens here; values are copied as supplied by the source.
INSERT INTO RAW.RAW_CLINICAL_TRIAL (
    SourceFileName,
    SourceRowNumber,
    NCTNumber,
    StudyTitle,
    StudyUrl,
    OverallStatus,
    Phase,
    StudyType,
    Enrollment,
    StartDate,
    PrimaryCompletionDate,
    CompletionDate,
    Sponsor,
    Collaborators,
    Conditions,
    Interventions,
    BriefSummary,
    LastUpdatePosted
)
SELECT
    N'clinical_trials_tagrisso.csv',
    NULL,
    i.NCTNumber,
    i.StudyTitle,
    i.StudyUrl,
    i.StudyStatus,
    i.Phases,
    i.StudyType,
    i.Enrollment,
    i.StartDate,
    i.PrimaryCompletionDate,
    i.CompletionDate,
    i.Sponsor,
    i.Collaborators,
    i.Conditions,
    i.Interventions,
    i.BriefSummary,
    i.LastUpdatePosted
FROM RAW.IMPORT_CLINICAL_TRIAL i
WHERE NOT EXISTS (
    SELECT 1
    FROM RAW.RAW_CLINICAL_TRIAL r
    WHERE r.SourceFileName = N'clinical_trials_tagrisso.csv'
      AND r.NCTNumber = i.NCTNumber
);
GO

-- Step 3: Confirm that the import and permanent RAW load agree.
SELECT COUNT(*) AS ImportedCsvRows
FROM RAW.IMPORT_CLINICAL_TRIAL;

SELECT COUNT(*) AS RawTagrissoRows
FROM RAW.RAW_CLINICAL_TRIAL
WHERE SourceFileName = N'clinical_trials_tagrisso.csv';
GO


USE Pharma_Intelligence;
GO

SELECT COUNT(*) AS TagrissoRawRows
FROM RAW.RAW_CLINICAL_TRIAL
WHERE SourceFileName = 'clinical_trials_tagrisso.csv';

SELECT TOP 5
    RawClinicalTrialID,
    NCTNumber,
    StudyTitle,
    OverallStatus,
    Phase,
    Enrollment,
    Sponsor,
    LoadedAt
FROM RAW.RAW_CLINICAL_TRIAL
WHERE SourceFileName = 'clinical_trials_tagrisso.csv';

SELECT NCTNumber, COUNT(*) AS DuplicateCount
FROM RAW.RAW_CLINICAL_TRIAL
WHERE SourceFileName = 'clinical_trials_tagrisso.csv'
GROUP BY NCTNumber
HAVING COUNT(*) > 1;