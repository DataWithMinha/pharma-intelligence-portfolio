USE Pharma_Intelligence;
GO

/*
    KPI 1: Clinical Pipeline Overview by drug.
    Counts trials and separates currently active trials from completed trials.
*/
SELECT
    d.DrugName,
    ta.TherapeuticAreaName,
    c.CompanyName,
    COUNT(*) AS TotalClinicalTrials,
    SUM(CASE
            WHEN f.EventStatus IN (N'Recruiting', N'Active not recruiting',
                                   N'Not yet recruiting', N'Enrolling by invitation')
            THEN 1 ELSE 0
        END) AS ActiveClinicalTrials,
    SUM(CASE WHEN f.EventStatus = N'Completed' THEN 1 ELSE 0 END) AS CompletedClinicalTrials,
    SUM(CASE WHEN f.EventName IN (N'Phase 3', N'Phase 2|Phase 3') THEN 1 ELSE 0 END) AS LateStageTrials,
    SUM(COALESCE(f.MetricValue, 0)) AS TotalKnownEnrollment
FROM DWH.FACT_DRUG_EVENTS f
JOIN DWH.DIM_EVENT_TYPE et ON et.EventTypeID = f.EventTypeID
JOIN DWH.DIM_DRUG d ON d.DrugID = f.DrugID
JOIN DWH.DIM_THERAPEUTIC_AREA ta ON ta.TherapeuticAreaID = f.TherapeuticAreaID
LEFT JOIN DWH.DIM_COMPANY c ON c.CompanyID = f.CompanyID
WHERE et.EventTypeName = N'Clinical Trial'
GROUP BY d.DrugName, ta.TherapeuticAreaName, c.CompanyName
ORDER BY ActiveClinicalTrials DESC, LateStageTrials DESC, TotalClinicalTrials DESC;
GO
