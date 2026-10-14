USE Pharma_Intelligence;
GO

/*
    KPI 2: FDA Regulatory Approval Activity by drug.
    Each row represents a recorded FDA submission decision, not a unique drug approval.
*/
SELECT
    d.DrugName,
    ta.TherapeuticAreaName,
    c.CompanyName,
    SUM(CASE WHEN f.EventStatus = N'Approved' THEN 1 ELSE 0 END) AS ApprovedSubmissionEvents,
    SUM(CASE WHEN f.EventStatus = N'Tentative Approval' THEN 1 ELSE 0 END) AS TentativeApprovalEvents,
    COUNT(*) AS TotalRegulatoryEvents,
    MIN(dt.FullDate) AS FirstRegulatoryDecisionDate,
    MAX(dt.FullDate) AS LatestRegulatoryDecisionDate
FROM DWH.FACT_DRUG_EVENTS f
JOIN DWH.DIM_EVENT_TYPE et ON et.EventTypeID = f.EventTypeID
JOIN DWH.DIM_DRUG d ON d.DrugID = f.DrugID
JOIN DWH.DIM_THERAPEUTIC_AREA ta ON ta.TherapeuticAreaID = f.TherapeuticAreaID
LEFT JOIN DWH.DIM_COMPANY c ON c.CompanyID = f.CompanyID
JOIN DWH.DIM_DATE dt ON dt.DateID = f.DateID
WHERE et.EventTypeName = N'Regulatory'
  AND f.SourceSystem = N'FDA'
GROUP BY d.DrugName, ta.TherapeuticAreaName, c.CompanyName
ORDER BY ApprovedSubmissionEvents DESC, LatestRegulatoryDecisionDate DESC;
GO
