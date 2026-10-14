# Power BI dashboard guide

Connect Power BI Desktop to the SQL Server `Pharma_Intelligence` database and import these DWH tables:

- `DWH.DIM_DATE`
- `DWH.DIM_DRUG`
- `DWH.DIM_COMPANY`
- `DWH.DIM_THERAPEUTIC_AREA`
- `DWH.DIM_EVENT_TYPE`
- `DWH.FACT_DRUG_EVENTS`

## Relationships

Create one-to-many, single-direction relationships from each dimension to `FACT_DRUG_EVENTS`:

- `DIM_DATE[DateID]` -> `FACT_DRUG_EVENTS[DateID]`
- `DIM_DRUG[DrugID]` -> `FACT_DRUG_EVENTS[DrugID]`
- `DIM_COMPANY[CompanyID]` -> `FACT_DRUG_EVENTS[CompanyID]`
- `DIM_THERAPEUTIC_AREA[TherapeuticAreaID]` -> `FACT_DRUG_EVENTS[TherapeuticAreaID]`
- `DIM_EVENT_TYPE[EventTypeID]` -> `FACT_DRUG_EVENTS[EventTypeID]`

## Suggested report pages

1. **Executive Overview** - total events, active clinical trials, clinical events, patent-expiry events, active trials by drug, and market opportunity by therapeutic area.
2. **Market and IP Risk** - latest market opportunity score, patent/exclusivity timing, and portfolio opportunity ranking.
3. **Clinical and Regulatory Detail** - trial pipeline, phase distribution, status breakdown, and approval activity.

## Important modelling note

`MetricValue` has different meanings by event type and unit. Do not sum it across all event types. Always filter by `DIM_EVENT_TYPE[EventTypeName]` and use `MetricUnit` where applicable.
