# ADA MicroMasters ML Research Methods

[![License: MIT](https://img.shields.io/github/license/basil-emeokoro/ADA-MicroMasters-ML-Research-Methods)](LICENSE)
![Last Commit](https://img.shields.io/github/last-commit/basil-emeokoro/ADA-MicroMasters-ML-Research-Methods)
![Repository Size](https://img.shields.io/github/repo-size/basil-emeokoro/ADA-MicroMasters-ML-Research-Methods)
![Main Language](https://img.shields.io/github/languages/top/basil-emeokoro/ADA-MicroMasters-ML-Research-Methods)
[![R Check](https://github.com/basil-emeokoro/ADA-MicroMasters-ML-Research-Methods/actions/workflows/r-check.yml/badge.svg)](https://github.com/basil-emeokoro/ADA-MicroMasters-ML-Research-Methods/actions/workflows/r-check.yml)

This repository is Basil Oforbuike Emeokoro's permanent research portfolio for the 12-week ADA Global Academy MicroMasters programme in Data Science, Artificial Intelligence, Machine Learning, and Research Methods.

The objective extends beyond completing weekly assignments. This monorepo documents reproducible analyses, statistical modelling, explainable AI, end-to-end data science workflows, scientific reporting, and clean software engineering practice.

## Portfolio Index

| Week | Topic | Status | Main Output | Code | Report |
| --- | --- | --- | --- | --- | --- |
| Week 1 | Exploratory data analysis of Nigeria DHS child undernutrition | Complete | WAZ/WHZ EDA tables, figures, and PDF report | [R script](week01-eda/assignment/Sprint01_BasilEmeokoro.R) | [PDF](week01-eda/assignment/Sprint01_BasilEmeokoro.pdf) |
| Week 2 | To be added | Planned | TBD | TBD | TBD |
| Week 3 | To be added | Planned | TBD | TBD | TBD |
| Week 4 | To be added | Planned | TBD | TBD | TBD |
| Week 5 | To be added | Planned | TBD | TBD | TBD |
| Week 6 | To be added | Planned | TBD | TBD | TBD |
| Week 7 | To be added | Planned | TBD | TBD | TBD |
| Week 8 | To be added | Planned | TBD | TBD | TBD |
| Week 9 | To be added | Planned | TBD | TBD | TBD |
| Week 10 | To be added | Planned | TBD | TBD | TBD |
| Week 11 | To be added | Planned | TBD | TBD | TBD |
| Week 12 | To be added | Planned | TBD | TBD | TBD |

## Repository Objectives

- Build research-quality data science projects across the full 12-week programme.
- Apply statistical and machine learning techniques to real-world datasets.
- Preserve reproducible scripts, reports, figures, tables, and notes.
- Practice transparent research documentation and version control.
- Maintain a portfolio suitable for academic, research, and industry review.

## Repository Documentation

| Document | Purpose |
| --- | --- |
| [PROJECT_STATUS.md](PROJECT_STATUS.md) | Executive dashboard for weekly progress, repository health, CI, milestones, and release status. |
| [CHANGELOG.md](CHANGELOG.md) | Chronological record of weekly work, major findings, and repository changes. |
| [PROJECT_NOTES.md](PROJECT_NOTES.md) | Operating notes for future coding agents and continuation work. |
| [CITATIONS.md](CITATIONS.md) | Catalogue of datasets, software, packages, standards, and external resources. |
| [LICENSE](LICENSE) | MIT licence for the repository. |
| [CITATION.cff](CITATION.cff) | Citation metadata used by GitHub's "Cite this repository" feature. |

## Topics Covered

- Exploratory data analysis
- Statistical inference
- Data visualization
- Feature engineering
- Machine learning
- Model evaluation
- Explainable AI
- Research methodology
- Predictive analytics
- Model deployment
- Scientific writing
- Reproducible research

## Repository Structure

```text
.
|-- README.md
|-- CHANGELOG.md
|-- CITATIONS.md
|-- CITATION.cff
|-- LICENSE
|-- PROJECT_STATUS.md
|-- PROJECT_NOTES.md
|-- .github/
|   `-- workflows/
|       `-- r-check.yml
|-- docs/
|   `-- releases/
|-- week01-eda/
|   |-- assignment/
|   |-- resources/
|   `-- notes/
|-- week02/ ... week12/
`-- shared/
```

Each weekly folder is intended to contain source code, reports, visualizations, documentation, selected resources, and reproducible workflows. Datasets are included only where redistribution is permitted.

## Technologies Used

- R and RStudio for statistical analysis, data cleaning, visualization, and report generation.
- Python, Jupyter, pandas, NumPy, Matplotlib, Seaborn, and scikit-learn for future weeks.
- GitHub Actions for lightweight reproducibility checks.
- Git and GitHub for version control and portfolio publication.
- PDF, CSV, and image outputs for research reporting.

## Reproducibility Statement

Each week will include the code, report, figures, tables, and notes needed to understand and rerun the work. Large or restricted datasets are not committed unless redistribution is permitted. When a dataset cannot be published, the relevant README explains where it should be placed locally and how the scripts locate it.

For Week 1, the DHS raw CSV is not committed. The full analysis can be reproduced locally by placing `NGKR8BFL.csv` or `NGKR8BFL (1).csv` in `week01-eda/resources/datasets/` and running the assignment script from `week01-eda/assignment/`.

## Software Engineering Practices

- Keep raw data separate from cleaned outputs.
- Preserve reproducible scripts that run from top to bottom.
- Avoid committing temporary files, caches, IDE settings, and private data.
- Use clear folder boundaries for weekly work.
- Record major changes in `CHANGELOG.md`.
- Prefer modular, readable code and explicit assumptions.
- Use feature branches for substantial weekly work before merging to `main`.

## Guiding Principles

- Reproducibility
- Transparency
- Clean code
- Modular design
- Statistical rigor
- Explainability
- Ethical AI
- Research integrity

## Git Workflow

Work for each week is committed as a focused change set using descriptive commit messages, for example:

```text
feat(week01): complete exploratory analysis of Nigeria DHS child undernutrition dataset
```

Future weeks should be added under `week02` through `week12` without restructuring prior completed weeks. Release tags should mark completed milestones, beginning with `v0.1` for Week 1.

## Author

Basil Oforbuike Emeokoro  
Psychometrician | Data Scientist | AI & Machine Learning Researcher | Software Developer  
Email: basil.emeokoro@gmail.com

## Citation

Citation metadata is available in [CITATION.cff](CITATION.cff). GitHub can use this file to display "Cite this repository".

## License

This repository is licensed under the [MIT License](LICENSE).
