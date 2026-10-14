USE Pharma_Intelligence;
GO

/* Overall fact-table count by intelligence/event type. */
SELECT
    et.EventTypeName,
    COUNT(*) AS FactRows
FROM DWH.FACT_DRUG_EVENTS f
JOIN DWH.DIM_EVENT_TYPE et ON et.EventTypeID = f.EventTypeID
GROUP BY et.EventTypeName
ORDER BY et.EventTypeName;
GO

/* More detailed split for the shared Patent event type. */
SELECT
    CASE
        WHEN f.EventName = N'FDA Patent Expiry' THEN N'FDA Patent Expiry'
        WHEN f.EventName LIKE N'FDA Exclusivity Expiry%' THEN N'FDA Exclusivity Expiry'
        ELSE f.EventName
    END AS PatentEventGroup,
    COUNT(*) AS FactRows
FROM DWH.FACT_DRUG_EVENTS f
JOIN DWH.DIM_EVENT_TYPE et ON et.EventTypeID = f.EventTypeID
WHERE et.EventTypeName = N'Patent'
GROUP BY CASE
        WHEN f.EventName = N'FDA Patent Expiry' THEN N'FDA Patent Expiry'
        WHEN f.EventName LIKE N'FDA Exclusivity Expiry%' THEN N'FDA Exclusivity Expiry'
        ELSE f.EventName
    END
ORDER BY PatentEventGroup;
GO

/* A healthy result is zero for every check below. */
SELECT N'Facts missing a date dimension row' AS ValidationCheck, COUNT(*) AS IssueCount
FROM DWH.FACT_DRUG_EVENTS f
LEFT JOIN DWH.DIM_DATE d ON d.DateID = f.DateID
WHERE d.DateID IS NULL

UNION ALL

SELECT N'Drug-level facts missing a drug', COUNT(*)
FROM DWH.FACT_DRUG_EVENTS f
JOIN DWH.DIM_EVENT_TYPE et ON et.EventTypeID = f.EventTypeID
WHERE et.EventTypeName <> N'Market'
  AND f.DrugID IS NULL

UNION ALL

SELECT N'Market facts incorrectly linked to a drug', COUNT(*)
FROM DWH.FACT_DRUG_EVENTS f
JOIN DWH.DIM_EVENT_TYPE et ON et.EventTypeID = f.EventTypeID
WHERE et.EventTypeName = N'Market'
  AND f.DrugID IS NOT NULL;
GO

SELECT COUNT(*) AS TotalFactRows
FROM DWH.FACT_DRUG_EVENTS;
GO
