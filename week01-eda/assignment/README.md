# Sprint 01 Assignment - Exploratory Data Analysis (EDA)

This folder contains a complete, self-contained Week 1 assignment developed for the ADA Global Academy MicroMasters in Machine Learning and Research Methods.

The assignment performs exploratory data analysis on child nutrition indicators using Nigeria DHS Child Recode data. It generates cleaned statistical tables, publication-quality figures, reproducibility metadata, and a final PDF report.

The folder is designed to run independently on any compatible computer without requiring the rest of the project repository.

## Dataset Requirements

Before running the analysis, place one of the supported DHS Child Recode CSV files into this folder:

```text
NGKR8BFL.csv
```

or

```text
NGKR8BFL (1).csv
```

The analysis script automatically detects either filename.

Note: The original DHS/Stata distribution files (`.dta`, `.do`, `.dct`, `.frq`, etc.) are not required for this assignment. Only the CSV dataset is used.

## Running the Assignment

### Using RStudio

Open `Sprint01_BasilEmeokoro.R` and click Source.

To preview all figures interactively after execution, run:

```r
preview_all_figures()
```

### Using the Command Line

```powershell
Rscript Sprint01_BasilEmeokoro.R
```

## Generated Outputs

Running the script produces:

- Publication-quality figures in `figures/`
- Statistical tables in `tables/`
- Supporting text outputs in `outputs/`
- R session information in `outputs/sessionInfo.txt`
- Final report: `Sprint01_BasilEmeokoro.pdf`

## Reproducibility Statement

The analysis is deterministic. Given the same input dataset and R environment, repeated executions produce identical analytical results and report outputs.

The raw DHS dataset is not included in this repository because DHS microdata are subject to access and redistribution restrictions.

## Software Requirements

- R, version 4.5 or later recommended
- Base R only; no contributed packages are required

## Author

Basil Oforbuike Emeokoro  
ADA Global Academy - MicroMasters in Machine Learning and Research Methods

## Navigation

- [Repository root](../../README.md)
- [Week 2: Regression Modelling](../../week02-regression-modelling/README.md)

## Complete Research Portfolio

This assignment forms part of a larger 12-week research portfolio developed during the ADA Global Academy MicroMasters in Machine Learning and Research Methods.

The complete repository, including subsequent weekly assignments, reproducibility resources, documentation, and project history, is available at:

https://github.com/basil-emeokoro/ADA-MicroMasters-ML-Research-Methods
