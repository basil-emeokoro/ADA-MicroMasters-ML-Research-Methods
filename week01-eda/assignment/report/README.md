# Week 1 Report Generation

The final assignment report is generated directly by `../Sprint01_BasilEmeokoro.R` using base R's PDF graphics device.

No RMarkdown or Quarto source file is used for Week 1 because the project environment does not require contributed R packages and the assignment script is intentionally self-contained. The script writes:

- `../Sprint01_BasilEmeokoro.pdf`
- `../figures/*.png`
- `../tables/*.csv`
- `../outputs/conclusion.txt`

To regenerate the report, place the DHS CSV in `week01-eda/resources/datasets/` and run the assignment script from either the repository root or `week01-eda/assignment/`.

The script defines reusable publication helpers, including `theme_publication()`, `publication_margins()`, and `plot_header_caption()`. Future Week 2-12 reports should reuse or extend these helpers so plots retain consistent typography, margins, captions, legends, and 300 dpi export settings.
