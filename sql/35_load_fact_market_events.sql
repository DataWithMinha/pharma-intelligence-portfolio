USE Pharma_Intelligence;
GO

/* One market row creates separate fact events so unlike measures are never aggregated together. */
WITH MarketMetrics AS (
    SELECT s.TherapeuticAreaName, s.MarketDate, s.SourceReference,
           N'Annual Market Size' AS EventName,
           s.MarketSizeUsdM AS MetricValue,
           N'USD Million' AS MetricUnit,
           CAST(NULL AS decimal(9,4)) AS ScoreValue,
           N'MarketSize' AS MetricCode
    FROM STG.STG_MARKET s
    WHERE s.MarketSizeUsdM IS NOT NULL

    UNION ALL

    SELECT s.TherapeuticAreaName, s.MarketDate, s.SourceReference,
           N'YoY Market Growth Rate', s.GrowthRatePct, N'Percent',
           CAST(NULL AS decimal(9,4)), N'YoYGrowth'
    FROM STG.STG_MARKET s
    WHERE s.GrowthRatePct IS NOT NULL

    UNION ALL

    SELECT s.TherapeuticAreaName, s.MarketDate, s.SourceReference,
           N'Competitive Intensity', s.CompetitiveIntensity, N'Index',
           CAST(NULL AS decimal(9,4)), N'CompetitiveIntensity'
    FROM STG.STG_MARKET s
    WHERE s.CompetitiveIntensity IS NOT NULL

    UNION ALL

    SELECT s.TherapeuticAreaName, s.MarketDate, s.SourceReference,
           N'Opportunity Value Score', CAST(NULL AS decimal(19,4)), N'Points',
           s.SourceScoreValue, N'OpportunityScore'
    FROM STG.STG_MARKET s
    WHERE s.SourceScoreValue IS NOT NULL
)
INSERT INTO DWH.FACT_DRUG_EVENTS (
    DrugID, DateID, EventTypeID, TherapeuticAreaID, CompanyID,
    EventStatus, EventName, MetricValue, MetricUnit, ScoreValue,
    Geography, EventDescription, SourceSystem, SourceID
)
SELECT
    NULL,
    dt.DateID,
    et.EventTypeID,
    ta.TherapeuticAreaID,
    NULL,
    N'Active',
    m.EventName,
    m.MetricValue,
    m.MetricUnit,
    m.ScoreValue,
    N'Global',
    m.SourceReference,
    N'Market data',
    CONCAT(ta.TherapeuticAreaName, N'|', CONVERT(char(8), m.MarketDate, 112), N'|', m.MetricCode)
FROM MarketMetrics m
JOIN DWH.DIM_THERAPEUTIC_AREA ta
    ON ta.TherapeuticAreaName = m.TherapeuticAreaName
JOIN DWH.DIM_DATE dt
    ON dt.FullDate = m.MarketDate
JOIN DWH.DIM_EVENT_TYPE et
    ON et.EventTypeName = N'Market'
WHERE NOT EXISTS (
    SELECT 1
    FROM DWH.FACT_DRUG_EVENTS f
    WHERE f.SourceSystem = N'Market data'
      AND f.SourceID = CONCAT(ta.TherapeuticAreaName, N'|', CONVERT(char(8), m.MarketDate, 112), N'|', m.MetricCode)
      AND f.EventTypeID = et.EventTypeID
      AND f.DrugID IS NULL
);
GO

SELECT EventName, COUNT(*) AS MarketFactRows
FROM DWH.FACT_DRUG_EVENTS f
JOIN DWH.DIM_EVENT_TYPE et ON et.EventTypeID = f.EventTypeID
WHERE et.EventTypeName = N'Market'
GROUP BY EventName
ORDER BY EventName;
GO
