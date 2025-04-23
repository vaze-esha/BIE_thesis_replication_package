## Incentivizing the Green Vote? <br> <small> The Role of California's Cap-and-Trade Investments on Electoral Outcomes

This repository contains the replication package for the ECON 494 Thesis project. 
To replicate all fogures and tables in this project, do the following:
- Clone this repository 
- In `master.do`, set path to `BIE_thesis_replication_package` on your machine


`replication_package_494` stores and calls all data used in this project. Note that all folders except `0_raw_input` are empty. The raw input folder contains all the raw data required to run the do-files in this project. The folders `1_intermediate`, `2_final` and `3_tables` are populated by the do-files as they are sequentially run in `master.do`
  - All outputs used in the paper are stored in `3_tables`
  - All intermediate datasets are stored in `1_intermediate`
  - All final datasets are stored in `2_final`

`replication_package_494_do` contains all do-files for this project

## replication_package_494_do
```
├── 1_import_pre_process.do
├── 2_ballot_imports
│   ├── 2_0_2012_ballot.do
│   ├── 2_0_2014_ballot.do
│   ├── 2_1_2016_ballot.do
│   ├── 2_2_2018_ballot.do
│   ├── 2_3_2020_ballot.do
│   ├── 2_4_2022_ballot.do
│   └── 2_5_voter_particpation.do
├── 3_process_covariates.do
├── 4_merge_covariates_with_outcomes.do
├── 5_FS_2SLS.do
└── master.do
```

Each of the following sections details the contents of the do-files. Note that these do not have to be run individually. Please run `master.do` only to replicate all outputs.

### 1_import_pre_process.do
1. Import and Clean Raw Data

- **CCI Data** (`cci_2024ar_detaileddata.xlsx`):
  - Selects relevant columns, cleans year and CES version fields.
  - Splits into separate datasets by CES version (2, 3, 4) and by year (2015–2023).

- **CES Data** (`ces2results.xlsx`, `ces3results.xlsx`, `ces4results.xlsx`):
  - Imports CES 2.0, 3.0, and 4.0 scores.
  - Retains relevant columns and exports cleaned `.dta` files.

2. Instrument Construction by CES Version

- For **each CES version (2 and 3)**:
  - Merge CCI census tracts with CES scores.
  - De-duplicate to tract-county-year level.
  - Define treatment and control tracts using RD cutoff:
    - Version 2: CES ≥ 32.66 & ≤ 36.52 (bandwidth 3.86) 
    - Version 3: CES ≥ 38.69 & ≤ 42.55 (bandwidth 3.86)
  - Compute:
    - `Treat_Tract`: treated indicator
    - `Control_Tract`: control indicator
    - `instrument`: treated / (treated + control)
  - Collapse to county-year level and save.

3. Export Yearly Instrument Datasets

- For each CES version, export instrument values by year (2015–2023).

4. Merge CCI and Instrument Data

- For each year:
  - Load yearly CCI data.
  - Merge with relevant version(s) of instrument data by county.
  - Fill missing funding as 0 to reflect true zeros.
  - Compute total county funding (`TOT_funding`).

---

**Output:** Cleaned, merged datasets by year (`2015.dta`, ..., `2023.dta`) containing:
- Project-level CCI data
- County-level instrument values
- Total CCI funding per county

### 2_ballot_imports
Ballot Outcome Processing – General Workflow (2012, 2014, 2016, 2018, 2022)

This script processes county-level ballot proposition results from raw Excel files for a given election year. It is used to generate cleaned datasets with vote outcomes for each proposition.

1. Import and Clean Raw Excel Data
- Load Excel files for both **June** and **November** ballots.
- Rename columns for consistency and readability.
- Drop non-county rows (e.g., state totals, percentage rows).
- Remove irrelevant or empty columns.

2. Save Individual Proposition Datasets
- For each proposition:
  - Extract relevant columns (`County`, `Yes`, and `No` votes).
  - Save as a temporary intermediate file.

3. Process Proposition Outcomes
- For each saved proposition dataset:
  - Clean county names and drop header rows again if necessary.
  - Convert vote counts from string to numeric.
  - Compute the proportion of `Yes` votes:
    ```
    prop_yes = Yes_votes / (Yes_votes + No_votes)
    ```
  - Generate a binary indicator for whether the proposition **passed**:
    - `1` if `Yes` votes > 50%
    - `0` otherwise

4. Save Final Cleaned Datasets
- Save each proposition file with the final cleaned version containing:
  - `County`
  - `Yes` and `No` vote counts
  - `prop_yes` share
  - `pass_binary` (whether it passed)

---
This process is repeated for each election year, with the appropriate propositions and file names substituted accordingly.

### 3_process_covariates.do

1. Import and Clean Raw Data

- **Household Income & Transit Data** (`ACSDP1Y{year}.DP03-Data.csv`):
  - Imports data for years 2014–2019, 2021–2023.
  - Keeps commuting mode estimates (carpooled, drive alone, transit, walk, work from home, other) and median household income.
  - Cleans:
    - Drops first two rows.
    - Removes `" County, California"` from `County` names.
    - Converts relevant variables from string to numeric.

- **Population Data** (`population_estimates.csv`):
  - Drops metadata and unnecessary columns (`v6`, `date_code`).
  - Extracts `Year` from `date_desc` and removes census/base years.
  - Converts `Year` and `Population` to numeric.
  - Saves one `.dta` file per year (e.g., `population_data_2014.dta`).

- **Education Data** (`ACSST5Y{year}.S1501-Data.csv`):
  - Imports data for 2014–2023.
  - Retains educational attainment columns and renames for clarity (e.g., `BACHELORS_OR_HIGHER`).
  - Drops first two rows and cleans county names.
  - Converts columns to numeric and saves per year (e.g., `pop_education_2015.dta`).

- **Race Data** (`ACSSE{year}.K200201-Data.csv`):
  - Imports race distribution data for 2014–2019, 2021–2023.
  - Keeps race population estimates and renames variables.
  - Drops first two rows and cleans county names.
  - Saves per year (e.g., `race_2021.dta`).

- **Housing Tenure Data** (`ACSDT5Y{year}.B25003-Data.csv`):
  - Imports homeowner and renter counts for 2014–2023.
  - Renames columns (`total_homeowners`, `total_renters`, etc.).
  - Cleans county names and drops first two rows.
  - Saves per year (e.g., `renter_homeowner_2016.dta`).

---

2. Save Yearly Processed Datasets

- Each dataset type (income & transit, population, education, race, tenure) is saved individually by year as a `.dta` file in `$intermediate_data`.

---

3. Merge All Covariates

- **For each year** in 2014–2019, 2021–2023:
  - Loads income & transit data.
  - Merges in race, education, and housing tenure data by county.
  - Drops `_merge` variables after each merge.
  - Saves the merged dataset as `covariates/covariates_{year}.dta`.

---

### 4_merge_covariates.do

- Merge socioeconomic and demographic covariates into yearly datasets.
- Generate derived variables and labels for each year.
- Append all years into a single panel.
- Merge with county-level ballot proposition outcomes.

---


1. **Year: 2015**

- Load data for 2015.
- Drop duplicates by `County TOT_funding instrument`.
- Merge with 2015 covariates.
- Clean and destring relevant variables.
- Construct:
  - `prop_nonwhite` = share of nonwhite population (excluding Asians)
  - `prop_less_educated` = population with less than a college degree
  - `prop_high_educated` = complement of above
  - `prop_transit_carpool` = share using transit or carpool to work
  - `log_funding` = log of total GGRF funding
- Label key variables.
- Save cleaned data.

---

2. **Years: 2016–2018 (CES Version 2)**

- Load data for each year.
- Drop duplicates and filter for CES Version 2.
- Merge with same-year covariates.
- Clean numeric fields: regex + destring.
- Create and label key variables (same as 2015).
- Save each cleaned file.

---

3. **Years: 2018–2023 (CES Version 3)**

- Repeat same procedure as above, but filter for CES Version 3.
- Years include 2018, 2019, 2021, 2022, 2023.
- Note: 2018 included in both CES Version 2 and 3 loops, likely due to split coverage.

---

4. **Year: 2020 (Special Case)**

- Use CES Version 3.
- Merge with *lagged* 2019 covariates.
- Clean and construct the same key variables.
- Save cleaned file.

---

5. **Append Panel Data (2015–2023)**

- Combine all yearly files into a single dataset using `append`.
- Save as `panel_2015_2023.dta`.

---

6. **Merge with Ballot Outcomes**

- Load the final panel.
- Loop over proposition datasets (from 2012–2022).
- Merge on `County` for each proposition.
- Drop non-matching observations.
- Save the final dataset with ballot outcomes merged.

---

- All numeric conversions are safeguarded by removing non-numeric characters before `destring`.
- Care taken to avoid duplication and ensure clean merges.
- `CESVersion` filters help address survey version inconsistencies.
- All constructed proportions and log values are labeled for readability in output tables.
- `total_asians` are excluded from `prop_nonwhite` variable by design.

### 5_FS_2SLS.do
- Run first-stage, reduced-form, and 2SLS regressions to estimate the impact of GGRF funding.
- Address endogenous policy timing by isolating exogenous variation in the instrument.
- Generate summary statistics, regression outputs, and county-level maps across years.

---
1. **First Stage Regressions**

- Load panel data for 2015–2023.
- Encode `County` to numeric `county_id` for panel setup.
- For 2018, keep only observations with the **maximum instrument** per county (due to two CES versions).
- Define panel with `xtset county_id Year`.
- Construct variables:
  - `cumulative_funding` = sum of `TOT_funding` per county across years
  - `log_cumulative_funding` = log of the cumulative funding
  - `avg_instrument` = average of instrument per `County-Year`
- Label key variables.
- Save updated panel data.

- Run and store:
  - OLS: `log_cumulative_funding` on `instrument`
  - OLS + control: add `prop_nonwhite`
- Export to LaTeX via `outreg2`.

---

2. **Reduced Form Regressions**

- Load full panel.
- Define local environmental propositions by year:
  - 2016: 65, 67
  - 2018: 3, 6, 68, 72
  - 2022: 30
- For each year:
  - Regress `prop_yes_<num>` on `instrument`, clustered at county level.
  - Output all results for the year to `rf_<year>.tex`.

---

3. **2SLS (IV) Regressions**

- Load full panel again.
- Define propositions for:
  - Environmental years: 2016, 2018, 2022
  - Placebo years: 2012, 2014
- For each year and proposition:
  - Run OLS: outcome on `log_cumulative_funding`
  - Run 2SLS: instrument `instrument` for `log_cumulative_funding`
  - Output OLS and 2SLS to `ols_2sls_<year>.tex`
  - Generate `coefplot` per year for 2SLS estimates
  - Export plot as PNG

---

4. **Figures and Summary Statistics**

- Load panel data.
- Set graphing scheme and font.
- Generate:
  - Histogram of `log_cumulative_funding`
  - Line + scatter plot of `avg_instrument` by county and year
- Export plots to PNG.

---

5. **Funding Maps by Year**

- Load and clean shapefile for CA counties.
- Merge panel data with shapefile by `County`.
- For each year from 2015–2023:
  - Plot `TOT_funding` using `spmap`
  - Save funding map for each year as PNG.

---

- 2018 instrument values filtered for version consistency.
- Uses `outreg2` and `coefplot` to streamline reporting.
- Panel structure enables consistent comparison across years.
- `spmap` visualizations highlight funding distribution by geography and time.
- Placebo years (2012, 2014) included to test for pre-trends.
