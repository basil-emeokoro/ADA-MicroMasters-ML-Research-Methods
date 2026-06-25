# Project Status Dashboard

## Week Status

| Week | Topic | Status | Version | Completion date |
| --- | --- | --- | --- | --- |
| Week 1 | Exploratory Data Analysis | Completed | v0.1 | 2026-06-20 |
| Week 2 | Regression Modelling | Completed | v0.2 | 2026-06-25 |
| Week 3 | Pending | Planned | TBD | TBD |
| Week 4 | Pending | Planned | TBD | TBD |
| Week 5 | Pending | Planned | TBD | TBD |
| Week 6 | Pending | Planned | TBD | TBD |
| Week 7 | Pending | Planned | TBD | TBD |
| Week 8 | Pending | Planned | TBD | TBD |
| Week 9 | Pending | Planned | TBD | TBD |
| Week 10 | Pending | Planned | TBD | TBD |
| Week 11 | Pending | Planned | TBD | TBD |
| Week 12 | Pending | Planned | TBD | TBD |

## Current State

- Current branch: main
- Latest tag: v0.1
- Latest release notes: `docs/releases/v0.1_release_notes.md`
- Latest stable Week 1 assignment commit: current `main` HEAD after the final hardening pass; run `git log -1 --oneline` for the exact hash
- Dataset used for Week 1: Nigeria DHS child recode microdata (`NGKR8BFL`)
- Dataset policy: restricted raw DHS data is not committed
- CI status: passing for Week 1 and Week 2 R check workflows after synthetic fixture validation
- Reproducibility status: Week 1 and Week 2 scripts run from their assignment folders; Week 2 also runs from the local Project folder
- Documentation status: README, BUILD guide, changelog, project notes, citation metadata, citation catalogue, and release notes are present

## Known Issues

- GitHub CLI is not installed locally, so the `v0.1` GitHub Release must be created manually from `docs/releases/v0.1_release_notes.md`.
- GitHub PDF preview may be less reliable than downloading the PDF locally; the PDF itself is the authoritative report artifact.
- Full DHS reproduction requires approved access to the restricted raw dataset.

## Repository Health Checklist

| Area | Status |
| --- | --- |
| Monorepo structure | Healthy |
| Week 1 outputs | Complete |
| Week 2 outputs | Complete |
| CI workflow | Healthy |
| Documentation | Healthy |
| Data governance | Healthy |
| License | MIT present |
| Citation metadata | Present |
| Reproducibility notes | Present |

## Current Milestone

Week 2 regression modelling assignment completed.

## Next Milestone

Begin Week 3 work while preserving the Week 1 and Week 2 reproducibility and documentation standards.

## Last Updated

2026-06-25
