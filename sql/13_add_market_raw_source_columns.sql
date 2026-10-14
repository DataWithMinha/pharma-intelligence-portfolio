USE Pharma_Intelligence;
GO

-- Run once only if RAW.RAW_MARKET already exists.
IF COL_LENGTH(N'RAW.RAW_MARKET', N'SourceAreaID') IS NULL
    ALTER TABLE RAW.RAW_MARKET ADD SourceAreaID nvarchar(100) NULL;
GO

IF COL_LENGTH(N'RAW.RAW_MARKET', N'SourceDateID') IS NULL
    ALTER TABLE RAW.RAW_MARKET ADD SourceDateID nvarchar(100) NULL;
GO

IF COL_LENGTH(N'RAW.RAW_MARKET', N'SourceScoreValue') IS NULL
    ALTER TABLE RAW.RAW_MARKET ADD SourceScoreValue nvarchar(100) NULL;
GO
