# Data guidance

This repository intentionally does not include raw data files. The project uses public extracts from:

- ClinicalTrials.gov clinical-study data
- FDA Drugs@FDA / FDA regulatory data
- FDA Orange Book patent and exclusivity data
- Therapeutic-area market data used for the portfolio scoring exercise

## Safe use

- Store downloaded files in `data/raw/` locally. That folder is excluded by `.gitignore`.
- Do not commit credentials, internal client data, patient data, personally identifiable information, or licensed data.
- Update local paths in the import scripts before execution.
- Record source date and file version when downloading a new extract.
