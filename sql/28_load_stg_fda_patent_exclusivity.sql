USE Pharma_Intelligence;
GO

/* FDA patent rows use ApplNo + ProductNo, which prevents product-variant ambiguity. */
WITH PatentCandidates AS (
    SELECT
        NULLIF(LTRIM(RTRIM(p.Appl_Type)), N'') AS ApplType,
        LTRIM(RTRIM(p.Appl_No)) AS ApplNo,
        LTRIM(RTRIM(p.Product_No)) AS ProductNo,
        LTRIM(RTRIM(p.Patent_No)) AS PatentNo,
        TRY_CONVERT(date, LTRIM(RTRIM(p.Patent_Expire_Date_Text))) AS PatentExpiryDate,
        NULLIF(UPPER(LTRIM(RTRIM(p.Drug_Substance_Flag))), N'') AS DrugSubstanceFlag,
        NULLIF(UPPER(LTRIM(RTRIM(p.Drug_Product_Flag))), N'') AS DrugProductFlag,
        NULLIF(LTRIM(RTRIM(p.Patent_Use_Code)), N'') AS PatentUseCode,
        NULLIF(UPPER(LTRIM(RTRIM(p.Delist_Flag))), N'') AS DelistFlag,
        TRY_CONVERT(date, LTRIM(RTRIM(p.Submission_Date))) AS SubmissionDate,
        NULLIF(LTRIM(RTRIM(pr.TradeName)), N'') AS TradeName,
        NULLIF(LTRIM(RTRIM(pr.Ingredient)), N'') AS Ingredient,
        NULLIF(LTRIM(RTRIM(pr.ApplicantFullName)), N'') AS ApplicantName,
        ROW_NUMBER() OVER (
            PARTITION BY LTRIM(RTRIM(p.Appl_No)), LTRIM(RTRIM(p.Product_No)),
                         LTRIM(RTRIM(p.Patent_No)), TRY_CONVERT(date, LTRIM(RTRIM(p.Patent_Expire_Date_Text)))
            ORDER BY TRY_CONVERT(date, LTRIM(RTRIM(p.Submission_Date))) DESC
        ) AS DuplicateRank
    FROM RAW.RAW_FDA_PATENT p
    JOIN RAW.RAW_FDA_PRODUCTS pr
        ON LTRIM(RTRIM(pr.ApplNo)) = LTRIM(RTRIM(p.Appl_No))
       AND TRY_CONVERT(int, LTRIM(RTRIM(pr.ProductNo))) =
           TRY_CONVERT(int, LTRIM(RTRIM(p.Product_No)))
    WHERE p.Appl_No IS NOT NULL
      AND p.Product_No IS NOT NULL
      AND p.Patent_No IS NOT NULL
      AND TRY_CONVERT(date, LTRIM(RTRIM(p.Patent_Expire_Date_Text))) IS NOT NULL
)
INSERT INTO STG.STG_FDA_PATENT (
    ApplType, ApplNo, ProductNo, PatentNo, PatentExpiryDate,
    DrugSubstanceFlag, DrugProductFlag, PatentUseCode, DelistFlag, SubmissionDate,
    TradeName, Ingredient, ApplicantName
)
SELECT
    c.ApplType, c.ApplNo, c.ProductNo, c.PatentNo, c.PatentExpiryDate,
    c.DrugSubstanceFlag, c.DrugProductFlag, c.PatentUseCode, c.DelistFlag,
    c.SubmissionDate, c.TradeName, c.Ingredient, c.ApplicantName
FROM PatentCandidates c
WHERE c.DuplicateRank = 1
  AND NOT EXISTS (
      SELECT 1 FROM STG.STG_FDA_PATENT s
      WHERE s.ApplNo = c.ApplNo
        AND s.ProductNo = c.ProductNo
        AND s.PatentNo = c.PatentNo
        AND s.PatentExpiryDate = c.PatentExpiryDate
  );
GO

WITH ExclusivityCandidates AS (
    SELECT
        NULLIF(LTRIM(RTRIM(e.Appl_Type)), N'') AS ApplType,
        LTRIM(RTRIM(e.Appl_No)) AS ApplNo,
        LTRIM(RTRIM(e.Product_No)) AS ProductNo,
        LTRIM(RTRIM(e.Exclusivity_Code)) AS ExclusivityCode,
        TRY_CONVERT(date, LTRIM(RTRIM(e.Exclusivity_Date))) AS ExclusivityDate,
        NULLIF(LTRIM(RTRIM(pr.TradeName)), N'') AS TradeName,
        NULLIF(LTRIM(RTRIM(pr.Ingredient)), N'') AS Ingredient,
        pr.ApplicantName,
        ROW_NUMBER() OVER (
            PARTITION BY LTRIM(RTRIM(e.Appl_No)), LTRIM(RTRIM(e.Product_No)),
                         LTRIM(RTRIM(e.Exclusivity_Code)), TRY_CONVERT(date, LTRIM(RTRIM(e.Exclusivity_Date)))
            ORDER BY (SELECT 0)
        ) AS DuplicateRank
    FROM RAW.RAW_FDA_EXCLUSIVITY e
    JOIN (
        SELECT
            LTRIM(RTRIM(ApplNo)) AS ApplNo,
            MIN(NULLIF(LTRIM(RTRIM(TradeName)), N'')) AS TradeName,
            MIN(NULLIF(LTRIM(RTRIM(Ingredient)), N'')) AS Ingredient,
            MIN(NULLIF(LTRIM(RTRIM(ApplicantFullName)), N'')) AS ApplicantName
        FROM RAW.RAW_FDA_PRODUCTS
        WHERE ApplNo IS NOT NULL
          AND LTRIM(RTRIM(ApplNo)) <> N''
        GROUP BY LTRIM(RTRIM(ApplNo))
        HAVING COUNT(DISTINCT NULLIF(LTRIM(RTRIM(TradeName)), N'')) = 1
    ) pr
        ON pr.ApplNo = LTRIM(RTRIM(e.Appl_No))
    WHERE e.Appl_No IS NOT NULL
      AND e.Product_No IS NOT NULL
      AND e.Exclusivity_Code IS NOT NULL
      AND TRY_CONVERT(date, LTRIM(RTRIM(e.Exclusivity_Date))) IS NOT NULL
)
INSERT INTO STG.STG_FDA_EXCLUSIVITY (
    ApplType, ApplNo, ProductNo, ExclusivityCode, ExclusivityDate,
    TradeName, Ingredient, ApplicantName
)
SELECT
    c.ApplType, c.ApplNo, c.ProductNo, c.ExclusivityCode, c.ExclusivityDate,
    c.TradeName, c.Ingredient, c.ApplicantName
FROM ExclusivityCandidates c
WHERE c.DuplicateRank = 1
  AND NOT EXISTS (
      SELECT 1 FROM STG.STG_FDA_EXCLUSIVITY s
      WHERE s.ApplNo = c.ApplNo
        AND s.ProductNo = c.ProductNo
        AND s.ExclusivityCode = c.ExclusivityCode
        AND s.ExclusivityDate = c.ExclusivityDate
  );
GO
