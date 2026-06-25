# Changelog

## Week 1

- Dataset: Nigeria DHS 2024 Children's Recode dataset (`NGKR8BFL`), used locally for child anthropometry analysis.
- Objective: exploratory analysis of child undernutrition in Nigeria using WAZ and WHZ, with HAZ included for stunting comparison.
- Portfolio hardening:
  - Added MIT license metadata.
  - Added `CITATION.cff` for GitHub citation support.
  - Added GitHub Actions workflow to run the Week 1 R script against a synthetic reproducibility fixture.
  - Added portfolio index, README badges, agent notes, and project notes for future weekly work.
- Analyses completed:
  - Cleaned WAZ and WHZ by converting DHS invalid codes `9996+` to missing and scaling valid scores by 100.
  - Recoded region, residence, wealth, mother education, father education, breastfeeding, and religion.
  - Produced missingness, summary-statistics, national-prevalence, HAZ/WAZ/WHZ comparison, subgroup-prevalence, correlation, outlier, decision, and research-question tables.
  - Generated 8 assignment figures, including histograms, box plots, violin plots, mean comparison, Spearman heatmap, and outlier plot.
- Major findings:
  - Valid WAZ observations: 9,513; valid WHZ observations: 9,464.
  - Weighted underweight prevalence: 26.41%; severe underweight: 8.27%.
  - Weighted wasting prevalence: 8.44%; severe wasting: 1.87%.
  - HAZ/stunting prevalence for comparison: 39.14%.
  - The poorest wealth quintile had the highest underweight prevalence among reported subgroups.
- Files created:
  - `week01-eda/assignment/Sprint01_BasilEmeokoro.R`
  - `week01-eda/assignment/Sprint01_BasilEmeokoro.pdf`
  - `week01-eda/assignment/figures/`
  - `week01-eda/assignment/tables/`
  - `week01-eda/assignment/outputs/`
  - `week01-eda/assignment/README.md`
  - `.github/workflows/r-check.yml`
  - `LICENSE`
  - `CITATION.cff`
  - `PROJECT_NOTES.md`

## Repository documentation updates

- Added `PROJECT_STATUS.md` as the executive dashboard for programme progress, repository health, CI, documentation, reproducibility, and milestones.
- Added `CITATIONS.md` as the living catalogue of datasets, software, packages, standards, and external resources.
- Added `docs/releases/v0.1_release_notes.md` for manual creation of the Week 1 GitHub Release when GitHub CLI is unavailable.
- Updated the root README with a repository documentation index.

## Week 1 hardening pass

- Added an interactive plotting switch so RStudio sessions can show plots while automated `Rscript` and CI runs remain headless.
- Exported `sessionInfo()` to `week01-eda/assignment/outputs/sessionInfo.txt`.
- Normalized PDF creation/modification date metadata to reduce binary churn across repeated builds.
- Added `BUILD.md` with clean-clone reproduction steps for Week 1.
- Tightened `CITATIONS.md` and `PROJECT_STATUS.md` to keep repository documentation concise and operational.

## Week 2

- Dataset: USA Housing dataset and clean diabetes readmission dataset, used locally for regression modelling.
- Objective: complete one multiple linear regression model for house price and one logistic regression model for diabetes readmission.
- Analyses completed:
  - Documented dataset dimensions, variable types, missing values, duplicate rows, target variables, predictors, and excluded variables.
  - Built a multiple linear regression model for `Price` using area income, house age, rooms, bedrooms, and population.
  - Built a logistic regression model for `readmitted_binary` using hospital-stay, utilization, diagnosis, race, gender, and age predictors.
  - Produced EDA figures, regression result tables, diagnostics, confusion matrix, AUC, prediction interval, and predicted probability example.
- Major findings:
  - Housing model R-squared: approximately 0.918.
  - Diabetes test accuracy: approximately 0.618.
  - Diabetes manual AUC: approximately 0.651.
- Files created:
  - `week02-regression-modelling/assignment/Sprint02_BasilEmeokoro.R`
  - `week02-regression-modelling/assignment/Sprint02_BasilEmeokoro.pdf`
  - `week02-regression-modelling/assignment/figures/`
  - `week02-regression-modelling/assignment/tables/`
  - `week02-regression-modelling/assignment/outputs/`
  - `week02-regression-modelling/assignment/README.md`
  - `week02-regression-modelling/assignment/BUILD.md`

## Week 3

- Planned.

## Week 4

- Planned.

## Week 5

- Planned.

## Week 6

- Planned.

## Week 7

- Planned.

## Week 8

- Planned.

## Week 9

- Planned.

## Week 10

- Planned.

## Week 11

- Planned.

## Week 12

- Planned.
