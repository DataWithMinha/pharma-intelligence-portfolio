USE Pharma_Intelligence;
GO

-- Run once only if STG.STG_MARKET already exists.
IF COL_LENGTH(N'STG.STG_MARKET', N'SourceScoreValue') IS NULL
    ALTER TABLE STG.STG_MARKET ADD SourceScoreValue decimal(9,4) NULL;
GO
