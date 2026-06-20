# Build and Reproducibility Guide

This guide explains how to reproduce Week 1 from a clean clone of the repository.

## Requirements

- Git
- R, tested locally with R 4.5.2
- No external CRAN packages are required for Week 1; the assignment script uses base R.
- Approved local access to the Nigeria DHS child recode dataset.

## Dependency Management

`renv` is not initialized for Week 1 because the reproducible assignment script uses base R only and GitHub Actions validates it with the current R release. Introducing `renv` before the programme uses external package dependencies would add lockfile maintenance without improving Week 1 reproducibility. Re-evaluate `renv` when Week 2 or later introduces required CRAN packages for modelling, notebooks, or deployment.

## Clone the Repository

```powershell
git clone https://github.com/basil-emeokoro/ADA-MicroMasters-ML-Research-Methods.git
cd ADA-MicroMasters-ML-Research-Methods
```

## Dataset Placement

The Week 1 raw DHS dataset is restricted and is not committed to the repository. After obtaining approved access from The DHS Program, place the child recode CSV in one of these locations:

```text
week01-eda/resources/datasets/NGKR8BFL.csv
week01-eda/resources/datasets/NGKR8BFL (1).csv
```

For the local course workspace only, the script can also read the legacy task folder:

```text
Tasks/NGKR8BFL.csv
Tasks/NGKR8BFL (1).csv
```

## Repository Layout

```text
week01-eda/
|-- assignment/
|   |-- Sprint01_BasilEmeokoro.R
|   |-- Sprint01_BasilEmeokoro.pdf
|   |-- figures/
|   |-- tables/
|   |-- outputs/
|   `-- report/
`-- resources/
    `-- datasets/
```

## Run Week 1

From the repository root:

```powershell
Rscript week01-eda/assignment/Sprint01_BasilEmeokoro.R
```

From the assignment directory:

```powershell
cd week01-eda/assignment
Rscript Sprint01_BasilEmeokoro.R
```

In RStudio, open `week01-eda/assignment/Sprint01_BasilEmeokoro.R` and use Source. Interactive RStudio sessions display plots in the Plots pane by default while still exporting PNG and PDF outputs.

To suppress plot-pane rendering in an interactive RStudio session:

```r
Sys.setenv(SHOW_PLOTS = "false")
source("week01-eda/assignment/Sprint01_BasilEmeokoro.R")
```

## Expected Outputs

The script regenerates these output groups:

```text
week01-eda/assignment/Sprint01_BasilEmeokoro.pdf
week01-eda/assignment/figures/*.png
week01-eda/assignment/tables/*.csv
week01-eda/assignment/outputs/conclusion.txt
week01-eda/assignment/outputs/sessionInfo.txt
```

## Expected Figures

- `figure_01_waz_histogram.png`
- `figure_02_whz_histogram.png`
- `figure_03_waz_by_region_boxplot.png`
- `figure_04_whz_by_wealth_violin.png`
- `figure_05_waz_by_breastfeeding_violin.png`
- `figure_06_mean_waz_by_religion.png`
- `figure_07_spearman_heatmap.png`
- `figure_08_outlier_boxplot.png`

## Expected Tables

- `table_01_missing_values.csv`
- `table_02_waz_whz_summary.csv`
- `table_03_national_prevalence.csv`
- `table_04_haz_waz_whz_comparison.csv`
- `table_05_underweight_by_group.csv`
- `table_06_spearman_matrix.csv`
- `table_07_ranked_correlation_pairs.csv`
- `table_08_outlier_summary.csv`
- `table_09_outlier_decision.csv`
- `table_10_future_research_questions.csv`

## GitHub Actions

The repository includes `.github/workflows/r-check.yml`. In CI, a small synthetic fixture is generated under `week01-eda/resources/datasets/` so the R script can be validated without committing restricted DHS data.

## Deterministic Output Check

After running the script once, run it again and check:

```powershell
git status --short
git diff --stat
```

Expected result after committed authoritative outputs are up to date:

```text
No differences.
Working tree clean.
```

The script normalizes PDF creation/modification date metadata to reduce binary churn across repeated local builds.

## Troubleshooting

- Missing dataset: confirm the DHS CSV filename and placement match the paths above.
- PDF cannot be overwritten: close any PDF viewer that has `Sprint01_BasilEmeokoro.pdf` open.
- RStudio plots do not appear: confirm the script is running interactively and `SHOW_PLOTS` is not set to `false`.
- GitHub Actions uses different data: CI intentionally uses a synthetic fixture because restricted DHS raw data is not committed.
- Different numerical results: confirm you are using the same DHS child recode file and that raw DHS variables have not been edited.
