# Data dictionary

## Core dimensions

| Table | Key | Purpose |
|---|---|---|
| `DWH.DIM_DATE` | `DateID` | Calendar date attributes for reporting. |
| `DWH.DIM_DRUG` | `DrugID` | Portfolio drug, generic name, primary company, and therapeutic area. |
| `DWH.DIM_COMPANY` | `CompanyID` | Company reference data. |
| `DWH.DIM_THERAPEUTIC_AREA` | `TherapeuticAreaID` | Oncology, Immunology, Cardiology, Endocrinology, and Neurology classifications. |
| `DWH.DIM_EVENT_TYPE` | `EventTypeID` | Event category such as Clinical Trial, Market, Regulatory, or Patent. |

## Event fact

| Column | Meaning |
|---|---|
| `EventID` | Surrogate key for the stored event. |
| `DrugID` | Drug associated with the event. It is null only for therapeutic-area-level market events. |
| `DateID` | Reporting date for the event. |
| `EventTypeID` | Event category. |
| `EventStatus` | Status such as Completed, Recruiting, Approved, or Active. |
| `EventName` | Event-specific label, such as Phase 3 or FDA Patent Expiry. |
| `MetricValue` | Numeric measure; interpret only with event type and unit. |
| `MetricUnit` | Unit for the numeric measure. |
| `ScoreValue` | 0-100 score used for market events where applicable. |
| `SourceSystem` | Source domain, such as ClinicalTrials.gov, FDA, FDA Orange Book, or Market data. |
| `SourceID` | Source-record identifier for traceability. |
| `LoadedAt` | UTC warehouse load timestamp. |
