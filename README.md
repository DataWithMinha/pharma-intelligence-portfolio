# Pharma Intelligence Portfolio and Market Opportunity Analysis

An end-to-end SQL Server portfolio analytics project that combines public clinical-trial, FDA regulatory, Orange Book patent/exclusivity, and therapeutic-area market data. The solution turns source records into a validated analytics warehouse and SQL KPI layer for portfolio, market, clinical, regulatory, and IP-risk review.

> This is a portfolio project built from public data. It is a prioritisation aid, not legal, clinical, investment, or commercial advice.

## Business questions

- Which drugs have the most active or late-stage clinical-trial activity?
- Which therapeutic areas have the strongest market opportunity?
- Which drugs face upcoming patent or exclusivity expiry exposure?
- How many regulatory approval events are recorded for each portfolio drug?
- Which drugs rank highest using a transparent multi-factor opportunity score?

## Solution architecture

```text
Public sources
ClinicalTrials.gov | FDA datasets | FDA Orange Book | Market data
        |
        v
RAW schema        Source-shaped landing tables and import lineage
        |
        v
STG schema        Typed, cleaned, standardised, deduplicated records
        |
        v
DWH schema        Star-schema analytics model
        |
        v
SQL KPI queries and analytical outputs
```

The warehouse uses one central event fact table:

```text
DIM_DATE -------------------|
DIM_DRUG -------------------|
DIM_COMPANY ----------------|--- FACT_DRUG_EVENTS
DIM_EVENT_TYPE -------------|
DIM_THERAPEUTIC_AREA -------|
```

## Project highlights

- Models a 25-drug portfolio across five therapeutic areas and sixteen companies.
- Separates raw ingestion, cleansing, and analytics using `RAW`, `STG`, and `DWH` schemas.
- Uses drug alias mapping to reconcile brand, generic, and formulation names across sources.
- Includes data-quality validation for missing values, duplicates, date validity, and source-to-product matching.
- Produces KPI queries for clinical pipeline, FDA regulatory activity, patent/exclusivity risk, market opportunity, and portfolio prioritisation.
- Includes KPI queries for portfolio prioritisation and downstream reporting.

## Technology

- SQL Server / T-SQL
- SQL Server Management Studio
- Excel / CSV source extracts
- Python and Beautiful Soup for public HTML data extraction where applicable

## Repository structure

```text
pharma-intelligence-portfolio/
├── sql/                 SQL Server build, load, validation, and KPI scripts
├── docs/                Architecture, data dictionary, and runbook
├── data/                Dataset guidance; raw files are deliberately excluded
├── README.md
└── .gitignore
```

## Run the project

1. Install SQL Server Express or SQL Server Developer Edition and open SSMS.
2. Run `sql/00_create_database.sql` while connected to `master`.
3. Run the remaining scripts in numeric order.
4. Before running import/load scripts, update the local CSV paths to match your computer.
5. Load only public source data into `RAW` tables.
6. Run the STG, DWH, validation, and KPI scripts in order.

The complete order is documented in [docs/runbook.md](docs/runbook.md).

## Opportunity score

The portfolio opportunity score is intentionally transparent:

| Factor | Weight | Rationale |
|---|---:|---|
| Therapeutic-area market opportunity | 40% | Commercial attractiveness is the main prioritisation signal. |
| Clinical activity and late-stage trials | 25% | Indicates pipeline maturity and activity. |
| FDA approved-event activity | 20% | Captures regulatory movement in the available dataset. |
| Future patent/exclusivity protection | 15% | Flags near-term protection exposure; it is not a legal freedom-to-operate assessment. |

Weights are business assumptions and can be adjusted with stakeholder input.

## Data and privacy

Raw source files, local import paths, credentials, and any non-public data are excluded from this repository. Use only public datasets and comply with each source's terms of use.

## Author

Minha Khan  
Data Analyst | Pharma Market Intelligence  
[LinkedIn](https://www.linkedin.com/in/minha-khann)
