USE Pharma_Intelligence;
GO

/*
    RAW -> STG clinical-trial transformation.
    RAW is never changed. This script copies and standardizes valid records.
*/
INSERT INTO STG.STG_CLINICAL_TRIAL (
    RawClinicalTrialID,
    NCTNumber,
    StudyTitle,
    OverallStatus,
    Phase,
    Enrollment,
    StartDate,
    CompletionDate,
    SponsorName,
    Conditions,
    Interventions,
    Geography,
    StandardizedDrugName
)
SELECT
    r.RawClinicalTrialID,
    NULLIF(LTRIM(RTRIM(r.NCTNumber)), N''),
    NULLIF(LTRIM(RTRIM(r.StudyTitle)), N''),
    CASE UPPER(LTRIM(RTRIM(r.OverallStatus)))
        WHEN N'COMPLETED' THEN N'Completed'
        WHEN N'UNKNOWN' THEN N'Unknown'
        WHEN N'RECRUITING' THEN N'Recruiting'
        WHEN N'TERMINATED' THEN N'Terminated'
        WHEN N'ACTIVE_NOT_RECRUITING' THEN N'Active Not Recruiting'
        WHEN N'NOT_YET_RECRUITING' THEN N'Not Yet Recruiting'
        WHEN N'WITHDRAWN' THEN N'Withdrawn'
        WHEN N'ENROLLING_BY_INVITATION' THEN N'Enrolling By Invitation'
        WHEN N'NO_LONGER_AVAILABLE' THEN N'No Longer Available'
        WHEN N'SUSPENDED' THEN N'Suspended'
        WHEN N'APPROVED_FOR_MARKETING' THEN N'Approved For Marketing'
        WHEN N'AVAILABLE' THEN N'Available'
        WHEN N'TEMPORARILY_NOT_AVAILABLE' THEN N'Temporarily Not Available'
        WHEN N'NA' THEN NULL
        WHEN N'N/A' THEN NULL
        ELSE NULLIF(LTRIM(RTRIM(r.OverallStatus)), N'')
    END,
    CASE
        WHEN r.Phase IS NULL OR UPPER(LTRIM(RTRIM(r.Phase))) IN (N'NA', N'N/A', N'NULL') THEN NULL
        ELSE REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(UPPER(LTRIM(RTRIM(r.Phase))), N'|', N' | '),
             N'EARLY_PHASE1', N'Early Phase 1'),
             N'PHASE1', N'Phase 1'),
             N'PHASE2', N'Phase 2'),
             N'PHASE3', N'Phase 3'),
             N'PHASE4', N'Phase 4')
    END,
    TRY_CONVERT(int, REPLACE(LTRIM(RTRIM(r.Enrollment)), N',', N'')),
    CASE
        WHEN LTRIM(RTRIM(r.StartDate)) LIKE N'[0-9][0-9][0-9][0-9]-[0-9][0-9]'
            THEN TRY_CONVERT(date, LTRIM(RTRIM(r.StartDate)) + N'-01')
        ELSE TRY_CONVERT(date, LTRIM(RTRIM(r.StartDate)))
    END,
    CASE
        WHEN LTRIM(RTRIM(r.CompletionDate)) LIKE N'[0-9][0-9][0-9][0-9]-[0-9][0-9]'
            THEN EOMONTH(TRY_CONVERT(date, LTRIM(RTRIM(r.CompletionDate)) + N'-01'))
        ELSE TRY_CONVERT(date, LTRIM(RTRIM(r.CompletionDate)))
    END,
    NULLIF(LTRIM(RTRIM(r.Sponsor)), N''),
    NULLIF(LTRIM(RTRIM(r.Conditions)), N''),
    NULLIF(LTRIM(RTRIM(r.Interventions)), N''),
    NULL,
    REPLACE(REPLACE(REPLACE(r.SourceFileName,
        N'clinical_trials_', N''),
        N'clinical_studies_', N''),
        N'.csv', N'')
FROM RAW.RAW_CLINICAL_TRIAL r
WHERE r.NCTNumber IS NOT NULL
  AND LTRIM(RTRIM(r.NCTNumber)) <> N''
  AND UPPER(LTRIM(RTRIM(r.NCTNumber))) NOT IN (N'NA', N'N/A', N'NULL')
  AND NOT EXISTS (
      SELECT 1
      FROM STG.STG_CLINICAL_TRIAL s
      WHERE s.RawClinicalTrialID = r.RawClinicalTrialID
  );
GO
