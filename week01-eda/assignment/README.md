# Sprint 01 Assignment - Basil Emeokoro

This is the authoritative Week 1 assignment folder for the GitHub monorepo. Use this folder for professor submission.

The root-level `Assignment/` folder is a legacy local folder from earlier work. The local `Tasks/` folder is a reference/data folder and is not required when submitting this assignment folder.

## Independent Submission Use

To send or run this folder by itself, place one approved DHS child recode CSV directly inside this folder before running:

```text
NGKR8BFL.csv
NGKR8BFL (1).csv
```

Do not include the `NGKR8BDT/` Stata folder unless the professor explicitly requests Stata files. The current R script reads CSV only.

## Run

From this folder:

```r
source("Sprint01_BasilEmeokoro.R")
```

or from a terminal:

```powershell
Rscript Sprint01_BasilEmeokoro.R
```

The script creates cleaned tables in `tables/`, figures in `figures/`, text outputs in `outputs/`, session information in `outputs/sessionInfo.txt`, and the final PDF report at `Sprint01_BasilEmeokoro.pdf`.

No contributed R packages are required; the script is written in base R.
