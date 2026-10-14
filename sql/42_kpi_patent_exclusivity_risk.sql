USE Pharma_Intelligence;
GO

/*
    KPI 3: Patent and Exclusivity Expiry Risk.
    The as-of date makes the report reproducible when it is rerun.
*/
DECLARE @AsOfDate date = CAST(GETDATE() AS date);

WITH ProtectionEvents AS (
    SELECT
        f.DrugID,
        MIN(CASE
                WHEN f.EventName = N'FDA Patent Expiry'
                 AND f.EventStatus = N'Active'
                 AND dt.FullDate >= @AsOfDate
                THEN dt.FullDate
            END) AS NextPatentExpiry,
        MIN(CASE
                WHEN f.EventName LIKE N'FDA Exclusivity Expiry%'
                 AND dt.FullDate >= @AsOfDate
                THEN dt.FullDate
            END) AS NextExclusivityExpiry,
        COUNT(CASE WHEN f.EventName = N'FDA Patent Expiry' THEN 1 END) AS PatentRecords,
        COUNT(CASE WHEN f.EventName LIKE N'FDA Exclusivity Expiry%' THEN 1 END) AS ExclusivityRecords
    FROM DWH.FACT_DRUG_EVENTS f
    JOIN DWH.DIM_EVENT_TYPE et ON et.EventTypeID = f.EventTypeID
    JOIN DWH.DIM_DATE dt ON dt.DateID = f.DateID
    WHERE et.EventTypeName = N'Patent'
      AND f.SourceSystem = N'FDA Orange Book'
    GROUP BY f.DrugID
), DrugProtection AS (
    SELECT
        d.DrugName,
        ta.TherapeuticAreaName,
        c.CompanyName,
        p.PatentRecords,
        p.ExclusivityRecords,
        p.NextPatentExpiry,
        p.NextExclusivityExpiry,
        CASE
            WHEN p.NextPatentExpiry IS NULL THEN p.NextExclusivityExpiry
            WHEN p.NextExclusivityExpiry IS NULL THEN p.NextPatentExpiry
            WHEN p.NextPatentExpiry <= p.NextExclusivityExpiry THEN p.NextPatentExpiry
            ELSE p.NextExclusivityExpiry
        END AS NextProtectionExpiry
    FROM DWH.DIM_DRUG d
    JOIN DWH.DIM_THERAPEUTIC_AREA ta ON ta.TherapeuticAreaID = d.TherapeuticAreaID
    JOIN DWH.DIM_COMPANY c ON c.CompanyID = d.PrimaryCompanyID
    LEFT JOIN ProtectionEvents p ON p.DrugID = d.DrugID
)
SELECT
    DrugName,
    TherapeuticAreaName,
    CompanyName,
    COALESCE(PatentRecords, 0) AS PatentRecords,
    COALESCE(ExclusivityRecords, 0) AS ExclusivityRecords,
    NextPatentExpiry,
    NextExclusivityExpiry,
    NextProtectionExpiry,
    CASE
        WHEN NextProtectionExpiry IS NULL THEN N'No future protection date loaded'
        WHEN NextProtectionExpiry <= DATEADD(year, 1, @AsOfDate) THEN N'High risk: expiry within 1 year'
        WHEN NextProtectionExpiry <= DATEADD(year, 3, @AsOfDate) THEN N'Medium risk: expiry within 1-3 years'
        ELSE N'Lower risk: protection beyond 3 years'
    END AS ProtectionRiskBand
FROM DrugProtection
ORDER BY
    CASE WHEN NextProtectionExpiry IS NULL THEN 1 ELSE 0 END,
    NextProtectionExpiry,
    DrugName;
GO
