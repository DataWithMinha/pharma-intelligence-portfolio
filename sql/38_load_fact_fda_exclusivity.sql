USE Pharma_Intelligence;
GO

/*
    Load FDA exclusivity-expiry events.  Patent and exclusivity records share the
    Patent event type, but EventName keeps them distinct for reporting.
*/
WITH ExclusivityCandidates AS (
    SELECT
        s.ApplNo,
        s.ProductNo,
        s.ExclusivityCode,
        s.ExclusivityDate,
        s.TradeName,
        s.Ingredient,
        d.DrugID,
        d.TherapeuticAreaID,
        d.PrimaryCompanyID AS CompanyID,
        ROW_NUMBER() OVER (
            PARTITION BY s.ApplNo, s.ProductNo, s.ExclusivityCode,
                         s.ExclusivityDate, d.DrugID
            ORDER BY s.StgFdaExclusivityID
        ) AS DuplicateRank
    FROM STG.STG_FDA_EXCLUSIVITY s
    LEFT JOIN DWH.DIM_DRUG directDrug
        ON UPPER(LTRIM(RTRIM(directDrug.DrugName))) = UPPER(LTRIM(RTRIM(s.TradeName)))
    LEFT JOIN STG.MAP_DRUG_ALIAS alias
        ON alias.SourceSystem = N'FDA'
       AND alias.IsActive = 1
       AND UPPER(LTRIM(RTRIM(alias.SourceDrugName))) = UPPER(LTRIM(RTRIM(s.TradeName)))
    JOIN DWH.DIM_DRUG d
        ON d.DrugID = COALESCE(directDrug.DrugID, alias.DrugID)
)
INSERT INTO DWH.FACT_DRUG_EVENTS (
    DrugID, DateID, EventTypeID, TherapeuticAreaID, CompanyID,
    EventStatus, EventName, MetricValue, MetricUnit, ScoreValue,
    Geography, EventDescription, SourceSystem, SourceID
)
SELECT
    c.DrugID,
    dt.DateID,
    et.EventTypeID,
    c.TherapeuticAreaID,
    c.CompanyID,
    N'Active',
    CONCAT(N'FDA Exclusivity Expiry - ', c.ExclusivityCode),
    NULL,
    NULL,
    NULL,
    N'United States',
    CONCAT(N'FDA exclusivity code ', c.ExclusivityCode,
           N'; ingredient: ', COALESCE(c.Ingredient, N'Not supplied')),
    N'FDA Orange Book',
    CONCAT(N'EXCL|', c.ApplNo, N'|', c.ProductNo, N'|', c.ExclusivityCode, N'|',
           CONVERT(char(8), c.ExclusivityDate, 112))
FROM ExclusivityCandidates c
JOIN DWH.DIM_DATE dt ON dt.FullDate = c.ExclusivityDate
JOIN DWH.DIM_EVENT_TYPE et ON et.EventTypeName = N'Patent'
WHERE c.DuplicateRank = 1
  AND NOT EXISTS (
      SELECT 1
      FROM DWH.FACT_DRUG_EVENTS f
      WHERE f.SourceSystem = N'FDA Orange Book'
        AND f.SourceID = CONCAT(N'EXCL|', c.ApplNo, N'|', c.ProductNo, N'|',
            c.ExclusivityCode, N'|', CONVERT(char(8), c.ExclusivityDate, 112))
        AND f.DrugID = c.DrugID
        AND f.EventTypeID = et.EventTypeID
  );
GO

SELECT
    COUNT(*) AS ExclusivityFactRows,
    MIN(d.FullDate) AS EarliestExclusivityExpiry,
    MAX(d.FullDate) AS LatestExclusivityExpiry
FROM DWH.FACT_DRUG_EVENTS f
JOIN DWH.DIM_EVENT_TYPE et ON et.EventTypeID = f.EventTypeID
JOIN DWH.DIM_DATE d ON d.DateID = f.DateID
WHERE et.EventTypeName = N'Patent'
  AND f.SourceSystem = N'FDA Orange Book'
  AND f.EventName LIKE N'FDA Exclusivity Expiry%';
GO
