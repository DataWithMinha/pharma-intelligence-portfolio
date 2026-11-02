# Architecture and modelling decisions

## Why RAW, STG, and DWH?

| Layer | Purpose | Design choice |
|---|---|---|
| `RAW` | Preserve source-shaped extracts | Keeps source values and lineage intact for auditability. |
| `STG` | Clean and standardise records | Applies typing, date parsing, deduplication, and alias mapping. |
| `DWH` | Support analytical reporting | Provides a star-schema model for consistent KPI analysis. |

## Fact grain

`DWH.FACT_DRUG_EVENTS` stores one source-recorded event for one drug on one date. `EventTypeID` distinguishes clinical-trial, market, regulatory, patent, and exclusivity events.

## Key decisions

- **Single event fact:** supports cross-domain reporting without creating isolated marts for every source.
- **Drug alias mapping:** resolves source variation such as generic names, brand names, and formulation variants before fact loading.
- **Source lineage:** `SourceSystem` and `SourceID` preserve traceability back to a source record.
- **Date dimension:** makes trend and period analysis consistent.
- **Company on fact:** supports direct company-level portfolio analysis even when an event is linked to a drug.

## Known limitations

- The opportunity score is a transparent business-ranking heuristic, not a prediction model.
- FDA application and approval data can include ANDA and NDA records; application type must be considered when interpreting generic competition.
- Public clinical-trial data can contain incomplete enrolment, status, and date fields.
- Patent/exclusivity information supports monitoring only and should not be used as legal advice.
