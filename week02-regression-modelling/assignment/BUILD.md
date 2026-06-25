# Build Guide - Week 2 Regression Modelling

## Requirements

- R 4.5 or later recommended
- Base R only
- `USA_Housing.csv`
- `clean_diabetes.csv`

## Dataset Placement

Place both datasets in one of these supported locations:

```text
week02-regression-modelling/assignment/
week02-regression-modelling/assignment/data/
week02-regression-modelling/resources/datasets/
```

For the standalone local Week 2 project, the script also reads datasets from the Project folder.

## Run

From the assignment folder:

```powershell
Rscript Sprint02_BasilEmeokoro.R
```

The script creates:

- `Sprint02_BasilEmeokoro.pdf`
- `figures/*.png`
- `tables/*.csv`
- `outputs/conclusion.txt`
- `outputs/sessionInfo.txt`

## Reproducibility Check

Run the script twice and check:

```powershell
git status --short
git diff --stat
```

If committed outputs are current and the same datasets are used, no tracked output differences should appear.
