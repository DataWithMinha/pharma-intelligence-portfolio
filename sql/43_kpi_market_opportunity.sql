USE Pharma_Intelligence;
GO

/*
    KPI 4: Latest Market Opportunity by therapeutic area.
    Uses the most recent market date available for each area.
*/
WITH LatestMarketDate AS (
    SELECT
        f.TherapeuticAreaID,
        MAX(dt.FullDate) AS LatestMarketDate
    FROM DWH.FACT_DRUG_EVENTS f
    JOIN DWH.DIM_EVENT_TYPE et ON et.EventTypeID = f.EventTypeID
    JOIN DWH.DIM_DATE dt ON dt.DateID = f.DateID
    WHERE et.EventTypeName = N'Market'
      AND f.SourceSystem = N'Market data'
    GROUP BY f.TherapeuticAreaID
)
SELECT
    ta.TherapeuticAreaName,
    l.LatestMarketDate,
    MAX(CASE WHEN f.EventName = N'Annual Market Size' THEN f.MetricValue END) AS MarketSizeUsdM,
    MAX(CASE WHEN f.EventName = N'YoY Market Growth Rate' THEN f.MetricValue END) AS YoYGrowthRatePct,
    MAX(CASE WHEN f.EventName = N'Competitive Intensity' THEN f.MetricValue END) AS CompetitiveIntensityIndex,
    MAX(CASE WHEN f.EventName = N'Opportunity Value Score' THEN f.ScoreValue END) AS OpportunityValueScore
FROM LatestMarketDate l
JOIN DWH.DIM_THERAPEUTIC_AREA ta
    ON ta.TherapeuticAreaID = l.TherapeuticAreaID
JOIN DWH.FACT_DRUG_EVENTS f
    ON f.TherapeuticAreaID = l.TherapeuticAreaID
JOIN DWH.DIM_DATE dt
    ON dt.DateID = f.DateID
JOIN DWH.DIM_EVENT_TYPE et
    ON et.EventTypeID = f.EventTypeID
WHERE et.EventTypeName = N'Market'
  AND f.SourceSystem = N'Market data'
  AND dt.FullDate = l.LatestMarketDate
GROUP BY ta.TherapeuticAreaName, l.LatestMarketDate
ORDER BY OpportunityValueScore DESC, MarketSizeUsdM DESC;
GO
