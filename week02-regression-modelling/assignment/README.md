# Sprint 02 Assignment - Regression Modelling

This folder contains the Week 2 regression modelling assignment for the ADA Global Academy MicroMasters in Machine Learning and Research Methods.

The assignment applies two regression workflows:

- Multiple linear regression using the USA Housing dataset, with `Price` as the outcome.
- Logistic regression using the diabetes dataset, with `readmitted_binary` as the outcome.

## Dataset Requirements

Place these CSV files in this folder or in `data/` before running the script:

```text
USA_Housing.csv
clean_diabetes.csv
```

The script also supports `resources/datasets/` when used inside the full monorepo.

## Running the Assignment

Using RStudio, open `Sprint02_BasilEmeokoro.R` and click Source.

From a terminal:

```powershell
Rscript Sprint02_BasilEmeokoro.R
```

To preview all figures interactively after sourcing:

```r
preview_all_figures()
```

## Generated Outputs

- Final PDF report: `Sprint02_BasilEmeokoro.pdf`
- Figures: `figures/`
- Tables: `tables/`
- Supporting outputs and session metadata: `outputs/`

## Reproducibility

The workflow uses base R only and sets a fixed random seed for the train/test split. PDF metadata is normalized to reduce repeated-build churn.

## Author

Basil Oforbuike Emeokoro  
ADA Global Academy - MicroMasters in Machine Learning and Research Methods

## Navigation

- [Repository root](../../README.md)
- [Week 2 overview](../README.md)
- [Week 1: Exploratory Data Analysis](../../week01-eda/assignment/README.md)
