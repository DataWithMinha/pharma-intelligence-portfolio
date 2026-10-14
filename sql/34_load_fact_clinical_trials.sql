USE Pharma_Intelligence;
GO

/*
    Load one fact per mapped ClinicalTrials.gov study and drug.
    StartDate is the event date; CompletionDate is used only when StartDate is missing.
*/
WITH ClinicalCandidates AS (
    SELECT
        s.NCTNumber,
        s.StudyTitle,
        s.OverallStatus,
        s.Phase,
        s.Enrollment,
        COALESCE(s.StartDate, s.CompletionDate) AS EventDate,
        d.DrugID,
        d.TherapeuticAreaID,
        d.PrimaryCompanyID AS CompanyID,
        ROW_NUMBER() OVER (
            PARTITION BY s.NCTNumber, d.DrugID
            ORDER BY COALESCE(s.StartDate, s.CompletionDate), s.StgClinicalTrialID
        ) AS DuplicateRank
    FROM STG.STG_CLINICAL_TRIAL s
    LEFT JOIN DWH.DIM_DRUG directDrug
        ON UPPER(LTRIM(RTRIM(directDrug.DrugName))) =
           UPPER(LTRIM(RTRIM(s.StandardizedDrugName)))
    LEFT JOIN STG.MAP_DRUG_ALIAS alias
        ON alias.SourceSystem = N'ClinicalTrials.gov'
       AND alias.IsActive = 1
       AND UPPER(LTRIM(RTRIM(alias.SourceDrugName))) =
           UPPER(LTRIM(RTRIM(s.StandardizedDrugName)))
    JOIN DWH.DIM_DRUG d
        ON d.DrugID = COALESCE(directDrug.DrugID, alias.DrugID)
    WHERE COALESCE(s.StartDate, s.CompletionDate) IS NOT NULL
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
    c.OverallStatus,
    COALESCE(c.Phase, N'Clinical Trial'),
    c.Enrollment,
    CASE WHEN c.Enrollment IS NOT NULL THEN N'Participants' END,
    NULL,
    NULL,
    c.StudyTitle,
    N'ClinicalTrials.gov',
    c.NCTNumber
FROM ClinicalCandidates c
JOIN DWH.DIM_DATE dt ON dt.FullDate = c.EventDate
JOIN DWH.DIM_EVENT_TYPE et ON et.EventTypeName = N'Clinical Trial'
WHERE c.DuplicateRank = 1
  AND NOT EXISTS (
      SELECT 1
      FROM DWH.FACT_DRUG_EVENTS f
      WHERE f.SourceSystem = N'ClinicalTrials.gov'
        AND f.SourceID = c.NCTNumber
        AND f.DrugID = c.DrugID
        AND f.EventTypeID = et.EventTypeID
  );
GO

SELECT
    COUNT(*) AS ClinicalTrialFactRows
FROM DWH.FACT_DRUG_EVENTS f
JOIN DWH.DIM_EVENT_TYPE et ON et.EventTypeID = f.EventTypeID
WHERE et.EventTypeName = N'Clinical Trial';

SELECT
    d.DrugName,
    COUNT(*) AS TrialEventCount
FROM DWH.FACT_DRUG_EVENTS f
JOIN DWH.DIM_DRUG d ON d.DrugID = f.DrugID
JOIN DWH.DIM_EVENT_TYPE et ON et.EventTypeID = f.EventTypeID
WHERE et.EventTypeName = N'Clinical Trial'
GROUP BY d.DrugName
ORDER BY TrialEventCount DESC;
GO
