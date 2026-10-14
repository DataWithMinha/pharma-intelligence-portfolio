USE Pharma_Intelligence;
GO

/*
    Reusable RAW loader for one ClinicalTrials.gov CSV file.
    Change only the two values below before each run.
*/

DECLARE @FilePath nvarchar(4000) =
    N'C:\Users\minha\Downloads\PHARMA INTEL\clinical_trials_imbruvica.csv';

DECLARE @SourceFileName nvarchar(260) =
    N'clinical_trials_imbruvica.csv';
/* The import table is temporary. Permanent data is already in RAW.RAW_CLINICAL_TRIAL. */
TRUNCATE TABLE RAW.IMPORT_CLINICAL_TRIAL;

DECLARE @BulkSql nvarchar(max) =
    N'BULK INSERT RAW.IMPORT_CLINICAL_TRIAL
      FROM ''' + REPLACE(@FilePath, N'''', N'''''') + N'''
      WITH (
          FORMAT = ''CSV'',
          FIRSTROW = 2,
          FIELDQUOTE = ''"'',
          FIELDTERMINATOR = '','',
          ROWTERMINATOR = ''0x0a'',
          CODEPAGE = ''65001'',
          TABLOCK
      );';

EXEC sys.sp_executesql @BulkSql;

INSERT INTO RAW.RAW_CLINICAL_TRIAL (
    SourceFileName, SourceRowNumber, NCTNumber, StudyTitle, StudyUrl,
    OverallStatus, Phase, StudyType, Enrollment, StartDate,
    PrimaryCompletionDate, CompletionDate, Sponsor, Collaborators,
    Conditions, Interventions, BriefSummary, LastUpdatePosted
)
SELECT
    @SourceFileName, NULL, i.NCTNumber, i.StudyTitle, i.StudyUrl,
    i.StudyStatus, i.Phases, i.StudyType, i.Enrollment, i.StartDate,
    i.PrimaryCompletionDate, i.CompletionDate, i.Sponsor, i.Collaborators,
    i.Conditions, i.Interventions, i.BriefSummary, i.LastUpdatePosted
FROM RAW.IMPORT_CLINICAL_TRIAL i
WHERE NOT EXISTS (
    SELECT 1
    FROM RAW.RAW_CLINICAL_TRIAL r
    WHERE r.SourceFileName = @SourceFileName
      AND r.NCTNumber = i.NCTNumber
);

SELECT @SourceFileName AS SourceFileName,
       COUNT(*) AS RawRowsLoaded
FROM RAW.RAW_CLINICAL_TRIAL
WHERE SourceFileName = @SourceFileName;
GO

SELECT COUNT(*) FROM RAW.RAW_CLINICAL_TRIAL;

USE Pharma_Intelligence;
GO

-- 1. Total rows and number of source files loaded
SELECT
    COUNT(*) AS TotalClinicalRawRows,
    COUNT(DISTINCT SourceFileName) AS SourceFilesLoaded
FROM RAW.RAW_CLINICAL_TRIAL;
GO

-- 2. Row count for each CSV file
SELECT
    SourceFileName,
    COUNT(*) AS Row_Count
FROM RAW.RAW_CLINICAL_TRIAL
GROUP BY SourceFileName
ORDER BY SourceFileName;
GO

-- 3. Duplicate NCT numbers inside the same source file
SELECT
    SourceFileName,
    NCTNumber,
    COUNT(*) AS DuplicateCount
FROM RAW.RAW_CLINICAL_TRIAL
WHERE NCTNumber IS NOT NULL
GROUP BY SourceFileName, NCTNumber
HAVING COUNT(*) > 1;
GO

-- 4. Missing or invalid NCT numbers
SELECT
    SourceFileName,
    COUNT(*) AS InvalidNCTCount
FROM RAW.RAW_CLINICAL_TRIAL
WHERE NCTNumber IS NULL
   OR LTRIM(RTRIM(NCTNumber)) = ''
   OR UPPER(LTRIM(RTRIM(NCTNumber))) IN ('N/A', 'NA', 'NULL')
GROUP BY SourceFileName;
GO

USE Pharma_Intelligence;
GO

-- Clinical-study statuses
SELECT
    OverallStatus,
    COUNT(*) AS Row_Count
FROM RAW.RAW_CLINICAL_TRIAL
GROUP BY OverallStatus
ORDER BY Row_Count DESC;
GO

-- Trial phases
SELECT
    Phase,
    COUNT(*) AS Row_Count
FROM RAW.RAW_CLINICAL_TRIAL
GROUP BY Phase
ORDER BY Row_Count DESC;
GO

-- Check enrollment formats
SELECT TOP 30
    Enrollment
FROM RAW.RAW_CLINICAL_TRIAL
WHERE Enrollment IS NOT NULL
ORDER BY Enrollment;
GO

-- Check date formats
SELECT TOP 30
    StartDate,
    PrimaryCompletionDate,
    CompletionDate
FROM RAW.RAW_CLINICAL_TRIAL
WHERE StartDate IS NOT NULL;
GO

SELECT
    COUNT(*) AS TotalRows,
    SUM(CASE WHEN Enrollment IS NULL
              OR LTRIM(RTRIM(Enrollment)) = ''
              OR UPPER(LTRIM(RTRIM(Enrollment))) IN ('NA', 'N/A', 'NULL')
             THEN 1 ELSE 0 END) AS MissingEnrollment,

    SUM(CASE WHEN LTRIM(RTRIM(Enrollment)) = '0'
             THEN 1 ELSE 0 END) AS ZeroEnrollment,

    SUM(CASE WHEN TRY_CONVERT(int,
             REPLACE(LTRIM(RTRIM(Enrollment)), ',', '')) IS NOT NULL
             THEN 1 ELSE 0 END) AS ValidNumericEnrollment,

    SUM(CASE WHEN Enrollment IS NOT NULL
              AND LTRIM(RTRIM(Enrollment)) <> ''
              AND UPPER(LTRIM(RTRIM(Enrollment))) NOT IN ('NA', 'N/A', 'NULL')
              AND TRY_CONVERT(int,
                  REPLACE(LTRIM(RTRIM(Enrollment)), ',', '')) IS NULL
             THEN 1 ELSE 0 END) AS InvalidEnrollment
FROM RAW.RAW_CLINICAL_TRIAL;