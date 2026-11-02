USE Pharma_Intelligence;
GO

TRUNCATE TABLE RAW.IMPORT_MARKET;
GO

BULK INSERT RAW.IMPORT_MARKET
-- Update this example path before running the script.
FROM 'C:\SQLImports\Market\fact_market_events_real5areas.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001',
    TABLOCK
);
GO

INSERT INTO RAW.RAW_MARKET (
    SourceFileName, SourceRowNumber, TherapeuticArea, Geography,
    MarketYear, MarketSizeUsdM, GrowthRatePct, CompetitiveIntensity,
    SourceAreaID, SourceDateID, SourceScoreValue, SourceReference
)
SELECT
    N'fact_market_events_real5areas.csv',
    NULL,
    i.AreaName,
    NULL,
    i.MarketYear,
    i.MarketSizeUsdM,
    i.YoYGrowthPct,
    i.CompetitiveIntensityIndex,
    i.AreaID,
    i.DateID,
    i.ScoreValue,
    i.SourceNote
FROM RAW.IMPORT_MARKET i
WHERE NOT EXISTS (
    SELECT 1
    FROM RAW.RAW_MARKET r
    WHERE r.SourceFileName = N'fact_market_events_real5areas.csv'
      AND r.TherapeuticArea = i.AreaName
      AND r.MarketYear = i.MarketYear
);
GO

SELECT COUNT(*) AS ImportedCsvRows FROM RAW.IMPORT_MARKET;

SELECT COUNT(*) AS RawMarketRows
FROM RAW.RAW_MARKET
WHERE SourceFileName = N'fact_market_events_real5areas.csv';
GO

EXEC master.dbo.xp_fileexist
    N'C:\SQLImports\fact_market_events_real5areas.csv';

    USE Pharma_Intelligence;
GO

-- Expected: 25 rows across five therapeutic areas
SELECT
    COUNT(*) AS TotalMarketRows,
    COUNT(DISTINCT TherapeuticArea) AS TherapeuticAreaCount,
    MIN(MarketYear) AS FirstYear,
    MAX(MarketYear) AS LastYear
FROM RAW.RAW_MARKET;
GO

-- Expected: five rows per therapeutic area
SELECT
    TherapeuticArea,
    COUNT(*) AS Row_Count
FROM RAW.RAW_MARKET
GROUP BY TherapeuticArea
ORDER BY TherapeuticArea;
GO

-- Expected: empty
SELECT
    TherapeuticArea,
    MarketYear,
    COUNT(*) AS DuplicateCount
FROM RAW.RAW_MARKET
GROUP BY TherapeuticArea, MarketYear
HAVING COUNT(*) > 1;
GO
