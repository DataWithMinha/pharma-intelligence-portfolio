USE Pharma_Intelligence;
GO

-- Expected starter counts: 4 event types, 5 therapeutic areas, 16 companies, 25 drugs.
SELECT N'DIM_EVENT_TYPE' AS TableName, COUNT(*) AS RowCount FROM DWH.DIM_EVENT_TYPE
UNION ALL SELECT N'DIM_THERAPEUTIC_AREA', COUNT(*) FROM DWH.DIM_THERAPEUTIC_AREA
UNION ALL SELECT N'DIM_COMPANY', COUNT(*) FROM DWH.DIM_COMPANY
UNION ALL SELECT N'DIM_DRUG', COUNT(*) FROM DWH.DIM_DRUG
UNION ALL SELECT N'FACT_DRUG_EVENTS', COUNT(*) FROM DWH.FACT_DRUG_EVENTS;
GO

-- Drug names must be unique.
SELECT DrugName, COUNT(*) AS DuplicateCount
FROM DWH.DIM_DRUG
GROUP BY DrugName
HAVING COUNT(*) > 1;
GO

-- Fact rows must agree with the drug's assigned therapeutic area.
SELECT f.EventID, d.DrugName, f.TherapeuticAreaID AS FactAreaID, d.TherapeuticAreaID AS DrugAreaID
FROM DWH.FACT_DRUG_EVENTS f
JOIN DWH.DIM_DRUG d ON d.DrugID = f.DrugID
WHERE f.TherapeuticAreaID <> d.TherapeuticAreaID;
GO

-- Metric values are only comparable within event type and unit.
SELECT et.EventTypeName, f.MetricUnit, COUNT(*) AS EventCount,
       MIN(f.MetricValue) AS MinimumMetricValue, MAX(f.MetricValue) AS MaximumMetricValue
FROM DWH.FACT_DRUG_EVENTS f
JOIN DWH.DIM_EVENT_TYPE et ON et.EventTypeID = f.EventTypeID
WHERE f.MetricValue IS NOT NULL
GROUP BY et.EventTypeName, f.MetricUnit;
GO
