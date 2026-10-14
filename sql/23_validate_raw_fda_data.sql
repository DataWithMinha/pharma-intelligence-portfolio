USE Pharma_Intelligence;
GO

-- Confirm every FDA source table contains data.
SELECT N'Application documents' AS SourceName, COUNT(*) AS Row_Count FROM RAW.RAW_FDA_APPLICATION_DOCS
UNION ALL SELECT N'Applications', COUNT(*) FROM RAW.RAW_FDA_APPLICATIONS
UNION ALL SELECT N'Exclusivity', COUNT(*) FROM RAW.RAW_FDA_EXCLUSIVITY
UNION ALL SELECT N'Marketing status', COUNT(*) FROM RAW.RAW_FDA_MARKETING_STATUS
UNION ALL SELECT N'Patents', COUNT(*) FROM RAW.RAW_FDA_PATENT
UNION ALL SELECT N'Products', COUNT(*) FROM RAW.RAW_FDA_PRODUCTS
UNION ALL SELECT N'Submissions', COUNT(*) FROM RAW.RAW_FDA_SUBMISSIONS;
GO

-- Product coverage: most FDA application numbers should resolve to a product record.
SELECT
    COUNT(DISTINCT a.ApplNo) AS ApplicationNumbers,
    COUNT(DISTINCT CASE WHEN p.ApplNo IS NOT NULL THEN a.ApplNo END) AS ApplicationsWithProductMatch,
    COUNT(DISTINCT CASE WHEN p.ApplNo IS NULL THEN a.ApplNo END) AS ApplicationsWithoutProductMatch
FROM RAW.RAW_FDA_APPLICATIONS a
LEFT JOIN (
    SELECT DISTINCT LTRIM(RTRIM(ApplNo)) AS ApplNo
    FROM RAW.RAW_FDA_PRODUCTS
) p ON p.ApplNo = LTRIM(RTRIM(a.ApplNo));
GO

-- Verify FDA submission dates can convert to proper SQL dates.
SELECT
    COUNT(*) AS TotalSubmissions,
    SUM(CASE WHEN SubmissionStatusDate IS NULL
                  OR LTRIM(RTRIM(SubmissionStatusDate)) = N''
             THEN 1 ELSE 0 END) AS MissingSubmissionDates,
    SUM(CASE WHEN SubmissionStatusDate IS NOT NULL
                  AND LTRIM(RTRIM(SubmissionStatusDate)) <> N''
                  AND TRY_CONVERT(date, SubmissionStatusDate) IS NULL
             THEN 1 ELSE 0 END) AS InvalidSubmissionDates
FROM RAW.RAW_FDA_SUBMISSIONS;
GO

-- See the actual regulatory statuses that will be standardized in STG.
SELECT SubmissionStatus, COUNT(*) AS Row_Count
FROM RAW.RAW_FDA_SUBMISSIONS
GROUP BY SubmissionStatus
ORDER BY Row_Count DESC;
GO


SELECT
    ApplNo,
    COUNT(DISTINCT TradeName) AS DistinctTradeNames
FROM RAW.RAW_FDA_PRODUCTS
GROUP BY ApplNo
HAVING COUNT(DISTINCT TradeName) > 1
ORDER BY DistinctTradeNames DESC;

SELECT
    ApplNo,
    ProductNo,
    TradeName,
    Ingredient,
    Applicant,
    ApprovalDate
FROM RAW.RAW_FDA_PRODUCTS
WHERE ApplNo IN ('215256', '215866', '217806', '213051')
ORDER BY ApplNo, ProductNo;