USE Pharma_Intelligence;
GO

SELECT COUNT(*) AS StagedFdaSubmissionRows
FROM STG.STG_FDA_SUBMISSION;
GO

SELECT SubmissionStatusCode, COUNT(*) AS Row_Count
FROM STG.STG_FDA_SUBMISSION
GROUP BY SubmissionStatusCode
ORDER BY Row_Count DESC;
GO

SELECT
    SUM(CASE WHEN SubmissionStatusDate IS NULL THEN 1 ELSE 0 END) AS NullSubmissionDates,
    SUM(CASE WHEN TradeName IS NULL OR LTRIM(RTRIM(TradeName)) = N'' THEN 1 ELSE 0 END) AS MissingTradeNames
FROM STG.STG_FDA_SUBMISSION;
GO

SELECT ApplNo, SubmissionNo, SubmissionType, SubmissionStatusCode, SubmissionStatusDate,
       COUNT(*) AS DuplicateCount
FROM STG.STG_FDA_SUBMISSION
GROUP BY ApplNo, SubmissionNo, SubmissionType, SubmissionStatusCode, SubmissionStatusDate
HAVING COUNT(*) > 1;
GO


SELECT TOP 20
    Patent_Expire_Date_Text,
    Submission_Date
FROM RAW.RAW_FDA_PATENT
WHERE Patent_Expire_Date_Text IS NOT NULL;
GO

SELECT
    COUNT(*) AS TotalPatentRows,
    SUM(CASE WHEN Patent_Expire_Date_Text IS NULL
              OR LTRIM(RTRIM(Patent_Expire_Date_Text)) = ''
             THEN 1 ELSE 0 END) AS MissingExpiryDates,
    SUM(CASE WHEN Patent_Expire_Date_Text IS NOT NULL
              AND LTRIM(RTRIM(Patent_Expire_Date_Text)) <> ''
              AND TRY_CONVERT(date, Patent_Expire_Date_Text) IS NULL
             THEN 1 ELSE 0 END) AS InvalidExpiryDates
FROM RAW.RAW_FDA_PATENT;
GO

SELECT
    COUNT(*) AS TotalExclusivityRows,
    SUM(CASE WHEN Exclusivity_Date IS NULL
              OR LTRIM(RTRIM(Exclusivity_Date)) = ''
             THEN 1 ELSE 0 END) AS MissingExclusivityDates,
    SUM(CASE WHEN Exclusivity_Date IS NOT NULL
              AND LTRIM(RTRIM(Exclusivity_Date)) <> ''
              AND TRY_CONVERT(date, Exclusivity_Date) IS NULL
             THEN 1 ELSE 0 END) AS InvalidExclusivityDates
FROM RAW.RAW_FDA_EXCLUSIVITY;
GO