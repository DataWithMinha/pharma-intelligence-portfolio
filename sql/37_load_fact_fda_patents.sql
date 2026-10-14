USE Pharma_Intelligence;
GO

/*
    One patent-expiry event per unique FDA application, product, patent, expiry date,
    and mapped portfolio drug.  Patent dates are the event dates because they show
    when the patent protection is scheduled to end.
*/
WITH PatentCandidates AS (
    SELECT
        s.ApplNo,
        s.ProductNo,
        s.PatentNo,
        s.PatentExpiryDate,
        s.DrugSubstanceFlag,
        s.DrugProductFlag,
        s.PatentUseCode,
        s.DelistFlag,
        s.TradeName,
        s.Ingredient,
        d.DrugID,
        d.TherapeuticAreaID,
        d.PrimaryCompanyID AS CompanyID,
        ROW_NUMBER() OVER (
            PARTITION BY s.ApplNo, s.ProductNo, s.PatentNo,
                         s.PatentExpiryDate, d.DrugID
            ORDER BY s.StgFdaPatentID
        ) AS DuplicateRank
    FROM STG.STG_FDA_PATENT s
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
    CASE WHEN c.DelistFlag = N'Y' THEN N'Delisted' ELSE N'Active' END,
    N'FDA Patent Expiry',
    NULL,
    NULL,
    NULL,
    N'United States',
    CONCAT(N'Patent ', c.PatentNo,
           N'; ingredient: ', COALESCE(c.Ingredient, N'Not supplied'),
           N'; substance flag: ', COALESCE(c.DrugSubstanceFlag, N'Not supplied'),
           N'; product flag: ', COALESCE(c.DrugProductFlag, N'Not supplied'),
           N'; use code: ', COALESCE(c.PatentUseCode, N'Not supplied')),
    N'FDA Orange Book',
    CONCAT(c.ApplNo, N'|', c.ProductNo, N'|', c.PatentNo, N'|',
           CONVERT(char(8), c.PatentExpiryDate, 112))
FROM PatentCandidates c
JOIN DWH.DIM_DATE dt ON dt.FullDate = c.PatentExpiryDate
JOIN DWH.DIM_EVENT_TYPE et ON et.EventTypeName = N'Patent'
WHERE c.DuplicateRank = 1
  AND NOT EXISTS (
      SELECT 1
      FROM DWH.FACT_DRUG_EVENTS f
      WHERE f.SourceSystem = N'FDA Orange Book'
        AND f.SourceID = CONCAT(c.ApplNo, N'|', c.ProductNo, N'|', c.PatentNo, N'|',
            CONVERT(char(8), c.PatentExpiryDate, 112))
        AND f.DrugID = c.DrugID
        AND f.EventTypeID = et.EventTypeID
  );
GO

SELECT
    EventStatus,
    COUNT(*) AS PatentFactRows,
    MIN(d.FullDate) AS EarliestPatentExpiry,
    MAX(d.FullDate) AS LatestPatentExpiry
FROM DWH.FACT_DRUG_EVENTS f
JOIN DWH.DIM_EVENT_TYPE et ON et.EventTypeID = f.EventTypeID
JOIN DWH.DIM_DATE d ON d.DateID = f.DateID
WHERE et.EventTypeName = N'Patent'
  AND f.SourceSystem = N'FDA Orange Book'
GROUP BY EventStatus
ORDER BY EventStatus;
GO
