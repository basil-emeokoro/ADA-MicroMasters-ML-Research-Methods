# Project Status Dashboard

## Week Status

| Week | Topic | Status | Version | Completion date |
| --- | --- | --- | --- | --- |
| Week 1 | Exploratory Data Analysis | Completed | v0.1 | 2026-06-20 |
| Week 2 | Pending | Planned | TBD | TBD |
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
- CI status: passing for the Week 1 R check workflow
- Reproducibility status: Week 1 script runs from repository root and `week01-eda/assignment/`
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
| CI workflow | Healthy |
| Documentation | Healthy |
| Data governance | Healthy |
| License | MIT present |
| Citation metadata | Present |
| Reproducibility notes | Present |

## Current Milestone

Week 1 repository hardening and reproducibility pass.

## Next Milestone

Begin Week 2 work in the existing monorepo while preserving the Week 1 reproducibility and documentation standards.

## Last Updated

2026-06-20
