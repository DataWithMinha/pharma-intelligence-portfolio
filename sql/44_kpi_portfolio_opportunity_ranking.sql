USE Pharma_Intelligence;
GO

/*
    KPI 5: Portfolio Opportunity Ranking.
    Transparent illustrative weighting:
      40% market opportunity, 25% clinical pipeline, 20% regulatory activity,
      15% future protection position.
    This is a prioritisation aid, not a legal, clinical, or investment recommendation.
*/
DECLARE @AsOfDate date = CAST(GETDATE() AS date);

WITH LatestMarketDate AS (
    SELECT f.TherapeuticAreaID, MAX(dt.FullDate) AS LatestMarketDate
    FROM DWH.FACT_DRUG_EVENTS f
    JOIN DWH.DIM_EVENT_TYPE et ON et.EventTypeID = f.EventTypeID
    JOIN DWH.DIM_DATE dt ON dt.DateID = f.DateID
    WHERE et.EventTypeName = N'Market'
      AND f.SourceSystem = N'Market data'
    GROUP BY f.TherapeuticAreaID
),
MarketScore AS (
    SELECT f.TherapeuticAreaID,
           MAX(CASE WHEN f.EventName = N'Opportunity Value Score' THEN f.ScoreValue END) AS OpportunityValueScore
    FROM DWH.FACT_DRUG_EVENTS f
    JOIN LatestMarketDate l
        ON l.TherapeuticAreaID = f.TherapeuticAreaID
    JOIN DWH.DIM_DATE dt ON dt.DateID = f.DateID
    WHERE f.SourceSystem = N'Market data'
      AND dt.FullDate = l.LatestMarketDate
    GROUP BY f.TherapeuticAreaID
),
ClinicalScore AS (
    SELECT
        f.DrugID,
        SUM(CASE WHEN f.EventStatus IN (N'Recruiting', N'Active not recruiting',
                                        N'Not yet recruiting', N'Enrolling by invitation')
                 THEN 1 ELSE 0 END) AS ActiveTrials,
        SUM(CASE WHEN f.EventName IN (N'Phase 3', N'Phase 2|Phase 3')
                 THEN 1 ELSE 0 END) AS LateStageTrials
    FROM DWH.FACT_DRUG_EVENTS f
    JOIN DWH.DIM_EVENT_TYPE et ON et.EventTypeID = f.EventTypeID
    WHERE et.EventTypeName = N'Clinical Trial'
    GROUP BY f.DrugID
),
RegulatoryScore AS (
    SELECT
        f.DrugID,
        SUM(CASE WHEN f.EventStatus = N'Approved' THEN 1 ELSE 0 END) AS ApprovedEvents
    FROM DWH.FACT_DRUG_EVENTS f
    JOIN DWH.DIM_EVENT_TYPE et ON et.EventTypeID = f.EventTypeID
    WHERE et.EventTypeName = N'Regulatory'
      AND f.SourceSystem = N'FDA'
    GROUP BY f.DrugID
),
ProtectionScore AS (
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
            END) AS NextExclusivityExpiry
    FROM DWH.FACT_DRUG_EVENTS f
    JOIN DWH.DIM_EVENT_TYPE et ON et.EventTypeID = f.EventTypeID
    JOIN DWH.DIM_DATE dt ON dt.DateID = f.DateID
    WHERE et.EventTypeName = N'Patent'
      AND f.SourceSystem = N'FDA Orange Book'
    GROUP BY f.DrugID
),
BaseScores AS (
    SELECT
        d.DrugID,
        d.DrugName,
        ta.TherapeuticAreaName,
        c.CompanyName,
        COALESCE(m.OpportunityValueScore, 0) AS MarketOpportunityScore,
        COALESCE(cl.ActiveTrials, 0) AS ActiveTrials,
        COALESCE(cl.LateStageTrials, 0) AS LateStageTrials,
        COALESCE(r.ApprovedEvents, 0) AS ApprovedEvents,
        CASE
            WHEN p.NextPatentExpiry IS NULL THEN p.NextExclusivityExpiry
            WHEN p.NextExclusivityExpiry IS NULL THEN p.NextPatentExpiry
            WHEN p.NextPatentExpiry <= p.NextExclusivityExpiry THEN p.NextPatentExpiry
            ELSE p.NextExclusivityExpiry
        END AS NextProtectionExpiry
    FROM DWH.DIM_DRUG d
    JOIN DWH.DIM_THERAPEUTIC_AREA ta ON ta.TherapeuticAreaID = d.TherapeuticAreaID
    JOIN DWH.DIM_COMPANY c ON c.CompanyID = d.PrimaryCompanyID
    LEFT JOIN MarketScore m ON m.TherapeuticAreaID = d.TherapeuticAreaID
    LEFT JOIN ClinicalScore cl ON cl.DrugID = d.DrugID
    LEFT JOIN RegulatoryScore r ON r.DrugID = d.DrugID
    LEFT JOIN ProtectionScore p ON p.DrugID = d.DrugID
),
NormalisedScores AS (
    SELECT *,
        MAX(ActiveTrials) OVER () AS MaxActiveTrials,
        MAX(LateStageTrials) OVER () AS MaxLateStageTrials,
        MAX(ApprovedEvents) OVER () AS MaxApprovedEvents
    FROM BaseScores
)
SELECT
    ROW_NUMBER() OVER (ORDER BY
        (0.40 * MarketOpportunityScore)
        + (0.25 * ((0.60 * 100.0 * ActiveTrials / NULLIF(MaxActiveTrials, 0))
                 + (0.40 * 100.0 * LateStageTrials / NULLIF(MaxLateStageTrials, 0))))
        + (0.20 * 100.0 * ApprovedEvents / NULLIF(MaxApprovedEvents, 0))
        + (0.15 * CASE
                WHEN NextProtectionExpiry IS NULL THEN 0
                WHEN NextProtectionExpiry <= DATEADD(year, 1, @AsOfDate) THEN 25
                WHEN NextProtectionExpiry <= DATEADD(year, 3, @AsOfDate) THEN 50
                ELSE 100
            END) DESC,
        DrugName
    ) AS PortfolioRank,
    DrugName,
    TherapeuticAreaName,
    CompanyName,
    MarketOpportunityScore,
    ActiveTrials,
    LateStageTrials,
    ApprovedEvents,
    NextProtectionExpiry,
    CAST(
        (0.40 * MarketOpportunityScore)
        + (0.25 * ((0.60 * 100.0 * ActiveTrials / NULLIF(MaxActiveTrials, 0))
                 + (0.40 * 100.0 * LateStageTrials / NULLIF(MaxLateStageTrials, 0))))
        + (0.20 * 100.0 * ApprovedEvents / NULLIF(MaxApprovedEvents, 0))
        + (0.15 * CASE
                WHEN NextProtectionExpiry IS NULL THEN 0
                WHEN NextProtectionExpiry <= DATEADD(year, 1, @AsOfDate) THEN 25
                WHEN NextProtectionExpiry <= DATEADD(year, 3, @AsOfDate) THEN 50
                ELSE 100
            END)
        AS decimal(9,2)
    ) AS PortfolioOpportunityScore
FROM NormalisedScores
ORDER BY PortfolioRank;
GO
