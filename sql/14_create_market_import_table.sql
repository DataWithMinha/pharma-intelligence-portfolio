USE Pharma_Intelligence;
GO

-- This table matches the nine source CSV columns exactly. All remain text in RAW.
IF OBJECT_ID(N'RAW.IMPORT_MARKET', N'U') IS NULL
BEGIN
    CREATE TABLE RAW.IMPORT_MARKET (
        AreaID nvarchar(max) NULL,
        AreaName nvarchar(max) NULL,
        MarketYear nvarchar(max) NULL,
        MarketSizeUsdM nvarchar(max) NULL,
        YoYGrowthPct nvarchar(max) NULL,
        CompetitiveIntensityIndex nvarchar(max) NULL,
        DateID nvarchar(max) NULL,
        SourceNote nvarchar(max) NULL,
        ScoreValue nvarchar(max) NULL
    );
END;
GO
