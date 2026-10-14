USE Pharma_Intelligence;
GO

SELECT N'FDA patents' AS Dataset, COUNT(*) AS StagedRows FROM STG.STG_FDA_PATENT
UNION ALL
SELECT N'FDA exclusivity', COUNT(*) FROM STG.STG_FDA_EXCLUSIVITY;
GO

SELECT COUNT(*) AS MissingPatentTradeNames
FROM STG.STG_FDA_PATENT
WHERE TradeName IS NULL OR LTRIM(RTRIM(TradeName)) = N'';

SELECT COUNT(*) AS MissingExclusivityTradeNames
FROM STG.STG_FDA_EXCLUSIVITY
WHERE TradeName IS NULL OR LTRIM(RTRIM(TradeName)) = N'';
GO

SELECT ApplNo, ProductNo, PatentNo, PatentExpiryDate, COUNT(*) AS DuplicateCount
FROM STG.STG_FDA_PATENT
GROUP BY ApplNo, ProductNo, PatentNo, PatentExpiryDate
HAVING COUNT(*) > 1;

SELECT ApplNo, ProductNo, ExclusivityCode, ExclusivityDate, COUNT(*) AS DuplicateCount
FROM STG.STG_FDA_EXCLUSIVITY
GROUP BY ApplNo, ProductNo, ExclusivityCode, ExclusivityDate
HAVING COUNT(*) > 1;
GO
