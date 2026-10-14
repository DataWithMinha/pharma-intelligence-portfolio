USE Pharma_Intelligence;
GO

/*
    RAW -> STG market transformation.
    Geography is set to Global because this source has no geography field and
    represents therapeutic-area market estimates at the portfolio level.
*/
INSERT INTO STG.STG_MARKET (
    RawMarketID,
    TherapeuticAreaName,
    Geography,
    MarketDate,
    MarketSizeUsdM,
    GrowthRatePct,
    CompetitiveIntensity,
    SourceScoreValue,
    SourceReference
)
SELECT
    r.RawMarketID,
    NULLIF(LTRIM(RTRIM(r.TherapeuticArea)), N''),
    N'Global',
    TRY_CONVERT(date, r.SourceDateID, 112),
    TRY_CONVERT(decimal(19,2), REPLACE(LTRIM(RTRIM(r.MarketSizeUsdM)), N',', N'')),
    TRY_CONVERT(decimal(9,4), REPLACE(LTRIM(RTRIM(r.GrowthRatePct)), N'%', N'')),
    TRY_CONVERT(decimal(9,4), LTRIM(RTRIM(r.CompetitiveIntensity))),
    TRY_CONVERT(decimal(9,4), LTRIM(RTRIM(r.SourceScoreValue))),
    NULLIF(LTRIM(RTRIM(r.SourceReference)), N'')
FROM RAW.RAW_MARKET r
WHERE r.TherapeuticArea IS NOT NULL
  AND LTRIM(RTRIM(r.TherapeuticArea)) <> N''
  AND TRY_CONVERT(date, r.SourceDateID, 112) IS NOT NULL
  AND NOT EXISTS (
      SELECT 1
      FROM STG.STG_MARKET s
      WHERE s.RawMarketID = r.RawMarketID
  );
GO

SELECT * FROM STG.STG_MARKET;