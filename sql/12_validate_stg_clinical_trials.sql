USE Pharma_Intelligence;
GO

-- RAW and STG counts: STG can be lower only when a RAW row has an invalid NCT number.
SELECT COUNT(*) AS RawRows FROM RAW.RAW_CLINICAL_TRIAL;
SELECT COUNT(*) AS StgRows FROM STG.STG_CLINICAL_TRIAL;
GO

-- No duplicate source record should enter STG.
SELECT RawClinicalTrialID, COUNT(*) AS DuplicateCount
FROM STG.STG_CLINICAL_TRIAL
GROUP BY RawClinicalTrialID
HAVING COUNT(*) > 1;
GO

-- Check remaining invalid NCT numbers.
SELECT COUNT(*) AS InvalidNCTNumbers
FROM STG.STG_CLINICAL_TRIAL
WHERE NCTNumber IS NULL
   OR LTRIM(RTRIM(NCTNumber)) = N''
   OR UPPER(LTRIM(RTRIM(NCTNumber))) IN (N'NA', N'N/A', N'NULL');
GO

-- Check that numeric enrollment and dates converted as expected.
SELECT
    SUM(CASE WHEN Enrollment IS NULL THEN 1 ELSE 0 END) AS NullEnrollment,
    SUM(CASE WHEN StartDate IS NULL THEN 1 ELSE 0 END) AS NullStartDate,
    SUM(CASE WHEN CompletionDate IS NULL THEN 1 ELSE 0 END) AS NullCompletionDate
FROM STG.STG_CLINICAL_TRIAL;
GO

-- Confirm cleaned business labels.
SELECT OverallStatus, COUNT(*) AS Row_Count
FROM STG.STG_CLINICAL_TRIAL
GROUP BY OverallStatus
ORDER BY Row_count DESC;
GO

SELECT
    SUM(CASE
        WHEN r.StartDate IS NULL OR LTRIM(RTRIM(r.StartDate)) = ''
        THEN 1 ELSE 0
    END) AS MissingStartDateInRaw,

    SUM(CASE
        WHEN r.StartDate IS NOT NULL
         AND LTRIM(RTRIM(r.StartDate)) <> ''
         AND s.StartDate IS NULL
        THEN 1 ELSE 0
    END) AS StartDateConversionFailures,

    SUM(CASE
        WHEN r.CompletionDate IS NULL OR LTRIM(RTRIM(r.CompletionDate)) = ''
        THEN 1 ELSE 0
    END) AS MissingCompletionDateInRaw,

    SUM(CASE
        WHEN r.CompletionDate IS NOT NULL
         AND LTRIM(RTRIM(r.CompletionDate)) <> ''
         AND s.CompletionDate IS NULL
        THEN 1 ELSE 0
    END) AS CompletionDateConversionFailures
FROM RAW.RAW_CLINICAL_TRIAL r
JOIN STG.STG_CLINICAL_TRIAL s
    ON s.RawClinicalTrialID = r.RawClinicalTrialID;