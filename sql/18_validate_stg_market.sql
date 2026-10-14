USE Pharma_Intelligence;
GO

SELECT COUNT(*) AS RawMarketRows FROM RAW.RAW_MARKET;
SELECT COUNT(*) AS StgMarketRows FROM STG.STG_MARKET;
GO

SELECT
    SUM(CASE WHEN MarketSizeUsdM IS NULL THEN 1 ELSE 0 END) AS NullMarketSize,
    SUM(CASE WHEN CompetitiveIntensity IS NULL THEN 1 ELSE 0 END) AS NullCompetitiveIntensity,
    SUM(CASE WHEN GrowthRatePct IS NULL THEN 1 ELSE 0 END) AS NullGrowthRate,
    SUM(CASE WHEN SourceScoreValue IS NULL THEN 1 ELSE 0 END) AS NullSourceScore
FROM STG.STG_MARKET;
GO

SELECT TherapeuticAreaName, COUNT(*) AS Row_Count,
       MIN(MarketDate) AS FirstMarketDate,
       MAX(MarketDate) AS LastMarketDate
FROM STG.STG_MARKET
GROUP BY TherapeuticAreaName
ORDER BY TherapeuticAreaName;
GO

SELECT TherapeuticAreaName, MarketDate, COUNT(*) AS DuplicateCount
FROM STG.STG_MARKET
GROUP BY TherapeuticAreaName, MarketDate
HAVING COUNT(*) > 1;
GO
