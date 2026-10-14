# SQL runbook

Run scripts in numeric order. Scripts `00` through `06` establish the initial database, schemas, tables, seed data, and basic validation. Later scripts extend the pipeline by source.

## Foundation

| Scripts | Purpose |
|---|---|
| `00` - `01` | Create database and schemas. |
| `02` - `04` | Create RAW, STG, and DWH tables. |
| `05` | Seed reference data for the portfolio. |
| `06` | Execute initial data-quality checks. |

## Clinical trials

| Scripts | Purpose |
|---|---|
| `07` - `10` | Configure raw source columns and clinical import process. |
| `11` - `12` | Load and validate staged clinical trials. |
| `34` | Load clinical events into the fact table. |

## Market data

| Scripts | Purpose |
|---|---|
| `13` - `18` | Configure, load, validate, and stage market events. |
| `35` | Load market events into the fact table. |

## FDA and Orange Book data

| Scripts | Purpose |
|---|---|
| `19` - `23` | Create and load raw FDA source tables and validate raw data. |
| `24` - `29` | Create, load, and validate staged submissions, patents, and exclusivity tables. |
| `31` - `32` | Create and seed drug-alias mapping. |
| `36` - `38` | Load regulatory, patent, and exclusivity events into the fact table. |

## Reporting

| Scripts | Purpose |
|---|---|
| `30` | Load date dimension. |
| `33` | Allow therapeutic-area level market events. |
| `39` | Validate final fact load. |
| `40` - `44` | Run clinical, regulatory, IP-risk, market, and opportunity-ranking KPIs. |

## Before running

1. Confirm the active database context in each script.
2. Update local `BULK INSERT` or file paths to your computer.
3. Verify expected CSV column order and data types.
4. Run validation scripts after each layer before proceeding.
