USE Pharma_Intelligence;
GO

WITH RegulatoryCandidates AS (
    SELECT
        s.ApplNo,
        s.SubmissionNo,
        s.SubmissionType,
        s.SubmissionStatusCode,
        s.SubmissionStatusDate,
        s.PublicNotes,
        d.DrugID,
        d.TherapeuticAreaID,
        d.PrimaryCompanyID AS CompanyID,
        ROW_NUMBER() OVER (
            PARTITION BY s.ApplNo, s.SubmissionNo, s.SubmissionType,
                         s.SubmissionStatusCode, s.SubmissionStatusDate, d.DrugID
            ORDER BY s.StgFdaSubmissionID
        ) AS DuplicateRank
    FROM STG.STG_FDA_SUBMISSION s
    LEFT JOIN DWH.DIM_DRUG directDrug
        ON UPPER(LTRIM(RTRIM(directDrug.DrugName))) = UPPER(LTRIM(RTRIM(s.TradeName)))
    LEFT JOIN STG.MAP_DRUG_ALIAS alias
        ON alias.SourceSystem = N'FDA'
       AND alias.IsActive = 1
       AND UPPER(LTRIM(RTRIM(alias.SourceDrugName))) = UPPER(LTRIM(RTRIM(s.TradeName)))
    JOIN DWH.DIM_DRUG d
        ON d.DrugID = COALESCE(directDrug.DrugID, alias.DrugID)
    WHERE s.SubmissionStatusDate IS NOT NULL
)
INSERT INTO DWH.FACT_DRUG_EVENTS (
    DrugID, DateID, EventTypeID, TherapeuticAreaID, CompanyID,
    EventStatus, EventName, MetricValue, MetricUnit, ScoreValue,
    Geography, EventDescription, SourceSystem, SourceID
)
SELECT
    c.DrugID,
    dt.DateID,
    et.EventTypeID,
    c.TherapeuticAreaID,
    c.CompanyID,
    CASE c.SubmissionStatusCode
        WHEN N'AP' THEN N'Approved'
        WHEN N'TA' THEN N'Tentative Approval'
        ELSE c.SubmissionStatusCode
    END,
    CONCAT(N'FDA ', COALESCE(c.SubmissionType, N'Submission')),
    NULL,
    NULL,
    NULL,
    N'United States',
    c.PublicNotes,
    N'FDA',
    CONCAT(c.ApplNo, N'|', COALESCE(c.SubmissionNo, N''), N'|',
           COALESCE(c.SubmissionType, N''), N'|', COALESCE(c.SubmissionStatusCode, N''), N'|',
           CONVERT(char(8), c.SubmissionStatusDate, 112))
FROM RegulatoryCandidates c
JOIN DWH.DIM_DATE dt ON dt.FullDate = c.SubmissionStatusDate
JOIN DWH.DIM_EVENT_TYPE et ON et.EventTypeName = N'Regulatory'
WHERE c.DuplicateRank = 1
  AND NOT EXISTS (
      SELECT 1
      FROM DWH.FACT_DRUG_EVENTS f
      WHERE f.SourceSystem = N'FDA'
        AND f.SourceID = CONCAT(c.ApplNo, N'|', COALESCE(c.SubmissionNo, N''), N'|',
           COALESCE(c.SubmissionType, N''), N'|', COALESCE(c.SubmissionStatusCode, N''), N'|',
           CONVERT(char(8), c.SubmissionStatusDate, 112))
        AND f.DrugID = c.DrugID
        AND f.EventTypeID = et.EventTypeID
  );
GO

SELECT EventStatus, COUNT(*) AS RegulatoryFactRows
FROM DWH.FACT_DRUG_EVENTS f
JOIN DWH.DIM_EVENT_TYPE et ON et.EventTypeID = f.EventTypeID
WHERE et.EventTypeName = N'Regulatory'
GROUP BY EventStatus
ORDER BY EventStatus;
GO
