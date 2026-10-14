USE Pharma_Intelligence;
GO

/*
    Use one product mapping only when an ApplNo has one distinct trade name.
    This prevents an application-level submission from multiplying across
    dosage forms or brand variants.
*/
WITH ProductApplicationMap AS (
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
)
INSERT INTO STG.STG_FDA_SUBMISSION (
    ApplNo, SubmissionNo, SubmissionType, SubmissionClassCodeID,
    SubmissionStatusCode, SubmissionStatusDate, ReviewPriority, PublicNotes,
    TradeName, Ingredient, ApplicantName
)
SELECT
    LTRIM(RTRIM(s.ApplNo)),
    NULLIF(LTRIM(RTRIM(s.SubmissionNo)), N''),
    NULLIF(LTRIM(RTRIM(s.SubmissionType)), N''),
    NULLIF(LTRIM(RTRIM(s.SubmissionClassCodeID)), N''),
    NULLIF(UPPER(LTRIM(RTRIM(s.SubmissionStatus))), N''),
    TRY_CONVERT(date, LTRIM(RTRIM(s.SubmissionStatusDate))),
    NULLIF(UPPER(LTRIM(RTRIM(s.ReviewPriority))), N''),
    NULLIF(LTRIM(RTRIM(s.SubmissionsPublicNotes)), N''),
    p.TradeName,
    p.Ingredient,
    p.ApplicantName
FROM RAW.RAW_FDA_SUBMISSIONS s
JOIN ProductApplicationMap p
    ON p.ApplNo = LTRIM(RTRIM(s.ApplNo))
WHERE s.ApplNo IS NOT NULL
  AND LTRIM(RTRIM(s.ApplNo)) <> N''
  AND NOT EXISTS (
      SELECT 1
      FROM STG.STG_FDA_SUBMISSION t
      WHERE t.ApplNo = LTRIM(RTRIM(s.ApplNo))
        AND ISNULL(t.SubmissionNo, N'') = ISNULL(NULLIF(LTRIM(RTRIM(s.SubmissionNo)), N''), N'')
        AND ISNULL(t.SubmissionType, N'') = ISNULL(NULLIF(LTRIM(RTRIM(s.SubmissionType)), N''), N'')
        AND ISNULL(t.SubmissionStatusCode, N'') = ISNULL(NULLIF(UPPER(LTRIM(RTRIM(s.SubmissionStatus))), N''), N'')
        AND ISNULL(t.SubmissionStatusDate, CONVERT(date, '19000101')) =
            ISNULL(TRY_CONVERT(date, LTRIM(RTRIM(s.SubmissionStatusDate))), CONVERT(date, '19000101'))
  );
GO
