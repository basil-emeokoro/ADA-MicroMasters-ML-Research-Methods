# Citation and Resource Catalogue

This catalogue records the datasets, software, and standards used in the ADA MicroMasters portfolio. It should be updated each week when new external resources are introduced.

## Datasets

### Nigeria Demographic and Health Survey Child Recode Data

- Name: Nigeria Demographic and Health Survey child recode microdata (`NGKR8BFL`)
- Source: The DHS Program / ICF
- URL: https://dhsprogram.com/
- Weeks used: Week 1
- Usage restrictions: DHS microdata require approved access through The DHS Program. Raw restricted data must not be committed to this repository.
- Repository handling: Week 1 scripts expect the approved local CSV at `week01-eda/resources/datasets/NGKR8BFL.csv`, `week01-eda/resources/datasets/NGKR8BFL (1).csv`, or the documented local legacy task folder.
- Citation format: Use the official DHS Program dataset/report citation supplied with the approved download and the final Nigeria DHS report.

### The DHS Program

- Source: ICF
- URL: https://dhsprogram.com/
- Weeks used: Week 1 and future DHS-based work
- Usage restrictions: Follow DHS Program terms of use, dataset-specific permissions, and attribution requirements.
- Citation format: Cite The DHS Program and the relevant country survey report or dataset file used in the analysis.

### ADA Global Academy

- Name: ADA Global Academy MicroMasters programme materials
- Source: ADA Global Academy
- Weeks used: Week 1 and future weekly assignments
- Usage restrictions: Course materials should be used according to programme rules and should not be redistributed if restricted.
- Citation format: Attribute assignment prompts, rubrics, and class-provided materials to ADA Global Academy where required.

## Software

### R

- Role: Week 1 data cleaning, statistical summaries, figure generation, report generation, and reproducibility metadata.
- URL: https://www.r-project.org/
- Tested locally with: R 4.5.2
- CI environment: GitHub Actions R release
- Citation format: Use `citation()` in R for the version-specific R citation.

## Packages

Week 1 is intentionally implemented with base R and does not require external CRAN packages. Future weeks should add major package citations here when they become part of the reproducible workflow.

## Standards and Practices

- Reproducible research principles: scripts, outputs, assumptions, and dataset-access instructions are preserved.
- Semantic versioning, adapted: weekly release tags use `v0.1`, `v0.2`, and onward.
- Conventional Commit messages: commit history uses structured messages such as `fix(week01): ...` and `docs(repo): ...`.
- Data governance: restricted, private, or unnecessarily large raw datasets are excluded from version control.

## Maintenance

- Add only resources actually used by the portfolio.
- Keep entries concise and verifiable.
- Record dataset restrictions before committing outputs derived from restricted sources.
