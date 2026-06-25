###############################################################################
# ADA Global Academy MicroMasters
# Week 2 - Regression Modelling
# Housing price linear regression and diabetes readmission logistic regression
# Version: 0.1
# Last Updated: 2026-06-25
# Author: Basil Oforbuike Emeokoro
###############################################################################

options(stringsAsFactors = FALSE)
set.seed(20260625)

show_plots_env <- tolower(trimws(Sys.getenv("SHOW_PLOTS", unset = "")))
rstudio_session <- identical(Sys.getenv("RSTUDIO"), "1")
SHOW_PLOTS <- show_plots_env %in% c("true", "1", "yes") ||
  ((show_plots_env == "" || show_plots_env == "auto") && interactive())
SHOW_PLOTS <- SHOW_PLOTS && (interactive() || rstudio_session)
cat("SHOW_PLOTS:", SHOW_PLOTS, "\n")
cat("Interactive session:", interactive(), "\n")

`%||%` <- function(x, y) if (is.null(x)) y else x
normalize_dir <- function(path) normalizePath(path, winslash = "/", mustWork = FALSE)

get_script_path <- function() {
  script_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(script_arg) > 0) return(normalize_dir(sub("^--file=", "", script_arg[1])))
  frame_files <- vapply(sys.frames(), function(frame) frame$ofile %||% NA_character_, character(1))
  frame_files <- frame_files[!is.na(frame_files)]
  if (length(frame_files) > 0) return(normalize_dir(frame_files[length(frame_files)]))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    context <- tryCatch(rstudioapi::getSourceEditorContext(), error = function(e) NULL)
    if (!is.null(context$path) && nzchar(context$path)) return(normalize_dir(context$path))
  }
  NULL
}

script_path <- get_script_path()
assignment_dir <- if (!is.null(script_path)) dirname(script_path) else normalize_dir(getwd())
if (!file.exists(file.path(assignment_dir, "Sprint02_BasilEmeokoro.R")) && basename(getwd()) == "assignment") {
  assignment_dir <- normalize_dir(getwd())
}
project_dir <- assignment_dir
repo_dir <- normalize_dir(file.path(assignment_dir, "..", ".."))

figures_dir <- file.path(project_dir, "figures")
tables_dir <- file.path(project_dir, "tables")
outputs_dir <- file.path(project_dir, "outputs")
report_dir <- file.path(project_dir, "report")
data_dir <- file.path(project_dir, "data")
dir.create(figures_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(tables_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(outputs_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(report_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)

cat("Assignment directory:", assignment_dir, "\n")
cat("Figures directory:", figures_dir, "\n")
cat("Tables directory:", tables_dir, "\n")
cat("Outputs directory:", outputs_dir, "\n")
cat("Report directory:", report_dir, "\n")

find_dataset <- function(filename) {
  candidates <- c(
    file.path(project_dir, filename),
    file.path(data_dir, filename),
    file.path(project_dir, "resources", "datasets", filename),
    file.path(repo_dir, "week02-regression-modelling", "resources", "datasets", filename),
    file.path(repo_dir, "week02-regression-modelling", "assignment", "data", filename),
    file.path(normalize_dir(file.path(project_dir, "..")), filename),
    file.path(getwd(), filename)
  )
  found <- candidates[file.exists(candidates)][1]
  if (is.na(found)) {
    stop(
      "Could not find required dataset: ", filename, "\n",
      "Place it in the Week 2 Project folder, assignment/data/, or week02-regression-modelling/resources/datasets/."
    )
  }
  normalize_dir(found)
}

housing_file <- find_dataset("USA_Housing.csv")
diabetes_file <- find_dataset("clean_diabetes.csv")
cat("Housing dataset:", housing_file, "\n")
cat("Diabetes dataset:", diabetes_file, "\n")

housing_raw <- read.csv(housing_file, check.names = FALSE)
diabetes_raw <- read.csv(diabetes_file, check.names = FALSE)

clean_names <- function(x) {
  out <- gsub("[^A-Za-z0-9]+", "_", x)
  out <- gsub("^_|_$", "", out)
  make.names(out, unique = TRUE)
}

housing <- housing_raw
names(housing) <- clean_names(names(housing))
diabetes <- diabetes_raw
names(diabetes) <- clean_names(names(diabetes))
diabetes[] <- lapply(diabetes, function(x) if (is.character(x)) trimws(x) else x)

fmt <- function(x, digits = 3) {
  ifelse(is.na(x), "NA", formatC(x, format = "f", digits = digits, big.mark = ","))
}
pct <- function(x, digits = 1) round(100 * x, digits)
write_table <- function(tbl, name, row.names = FALSE) write.csv(tbl, file.path(tables_dir, name), row.names = row.names)

dataset_overview <- data.frame(
  Dataset = c("USA Housing", "Diabetes readmission"),
  Rows = c(nrow(housing), nrow(diabetes)),
  Columns = c(ncol(housing), ncol(diabetes)),
  Target = c("Price", "readmitted_binary"),
  Task = c("Multiple linear regression", "Binary logistic regression"),
  stringsAsFactors = FALSE
)

var_profile <- function(df, dataset) {
  data.frame(
    Dataset = dataset,
    Variable = names(df),
    Type = vapply(df, function(x) class(x)[1], character(1)),
    Missing_N = vapply(df, function(x) sum(is.na(x) | (is.character(x) & x == "")), integer(1)),
    Unique_N = vapply(df, function(x) length(unique(x)), integer(1)),
    stringsAsFactors = FALSE
  )
}

variable_descriptions <- rbind(
  data.frame(
    Dataset = "USA Housing",
    Variable = names(housing_raw),
    Description = c(
      "Average income in the area.",
      "Average house age in the area.",
      "Average number of rooms in houses in the area.",
      "Average number of bedrooms in houses in the area.",
      "Area population.",
      "House price; continuous target variable.",
      "Text address; excluded because it is non-predictive text for this assignment model."
    ),
    stringsAsFactors = FALSE
  ),
  data.frame(
    Dataset = "Diabetes readmission",
    Variable = names(diabetes_raw),
    Description = c(
      "Length of hospital stay.",
      "Number of laboratory procedures.",
      "Number of non-laboratory procedures.",
      "Number of medications.",
      "Number of outpatient visits before encounter.",
      "Number of emergency visits before encounter.",
      "Number of inpatient visits before encounter.",
      "Number of diagnoses.",
      "Patient race category.",
      "Patient gender.",
      "Patient age band.",
      "Admission type code; administrative coded variable.",
      "Discharge disposition code; administrative coded variable.",
      "Admission source code; administrative coded variable.",
      "Medical specialty associated with encounter.",
      "Binary readmission target."
    ),
    stringsAsFactors = FALSE
  )
)

missing_duplicate_table <- data.frame(
  Dataset = c("USA Housing", "Diabetes readmission"),
  Missing_Cells = c(sum(is.na(housing)), sum(is.na(diabetes))),
  Duplicate_Rows = c(sum(duplicated(housing)), sum(duplicated(diabetes))),
  stringsAsFactors = FALSE
)

housing_predictors <- c("Avg_Area_Income", "Avg_Area_House_Age", "Avg_Area_Number_of_Rooms",
                        "Avg_Area_Number_of_Bedrooms", "Area_Population")
housing_model_df <- housing[, c("Price", housing_predictors)]
housing_model_df <- housing_model_df[complete.cases(housing_model_df), ]

diabetes$readmitted_binary <- ifelse(diabetes$readmitted_binary %in% c(1, "1", "Yes", "yes", "TRUE", TRUE), 1, 0)
diabetes$readmitted_factor <- factor(diabetes$readmitted_binary, levels = c(0, 1), labels = c("Not readmitted", "Readmitted"))
factor_cols <- intersect(c("race", "gender", "age"), names(diabetes))
for (col in factor_cols) diabetes[[col]] <- factor(diabetes[[col]])
if ("medical_specialty" %in% names(diabetes)) diabetes$medical_specialty <- factor(diabetes$medical_specialty)

diabetes_predictors <- c("time_in_hospital", "num_lab_procedures", "num_procedures",
                         "num_medications", "number_outpatient", "number_emergency",
                         "number_inpatient", "number_diagnoses", "race", "gender", "age")
diabetes_model_df <- diabetes[, c("readmitted_binary", "readmitted_factor", diabetes_predictors)]
diabetes_model_df <- diabetes_model_df[complete.cases(diabetes_model_df), ]

numeric_summary <- function(df, vars, dataset) {
  do.call(rbind, lapply(vars, function(v) {
    x <- df[[v]]
    data.frame(
      Dataset = dataset, Variable = v, N = sum(!is.na(x)),
      Mean = mean(x, na.rm = TRUE), SD = stats::sd(x, na.rm = TRUE),
      Min = min(x, na.rm = TRUE), Median = stats::median(x, na.rm = TRUE),
      Max = max(x, na.rm = TRUE), stringsAsFactors = FALSE
    )
  }))
}

housing_summary <- numeric_summary(housing_model_df, c("Price", housing_predictors), "USA Housing")
diabetes_numeric <- diabetes_predictors[sapply(diabetes_model_df[diabetes_predictors], is.numeric)]
diabetes_summary <- numeric_summary(diabetes_model_df, diabetes_numeric, "Diabetes readmission")

readmission_distribution <- data.frame(
  Outcome = names(table(diabetes_model_df$readmitted_factor)),
  N = as.integer(table(diabetes_model_df$readmitted_factor)),
  Percent = pct(as.numeric(prop.table(table(diabetes_model_df$readmitted_factor))), 2),
  stringsAsFactors = FALSE
)

cor_matrix <- stats::cor(housing_model_df[, c("Price", housing_predictors)], use = "complete.obs")
write_table(dataset_overview, "table_01_dataset_overview.csv")
write_table(variable_descriptions, "table_02_variable_descriptions.csv")
write_table(rbind(var_profile(housing, "USA Housing"), var_profile(diabetes, "Diabetes readmission")),
            "table_03_variable_profile.csv")
write_table(missing_duplicate_table, "table_04_missing_duplicates.csv")
write_table(housing_summary, "table_05_housing_descriptive_statistics.csv")
write_table(diabetes_summary, "table_06_diabetes_descriptive_statistics.csv")
write_table(round(cor_matrix, 3), "table_07_housing_correlation_matrix.csv", row.names = TRUE)
write_table(readmission_distribution, "table_08_readmission_distribution.csv")

publication_style <- list(dpi = 300, title_cex = 1.12, subtitle_cex = 0.88, caption_cex = 0.78,
                          text_col = "#202020", accent = "#2b6cb0", accent2 = "#c05621")

theme_publication <- function(type = "default") {
  mar <- switch(type,
                heatmap = c(8, 8, 5, 2),
                diagnostics = c(5, 5, 4, 2),
                c(5.8, 5.5, 4.8, 2))
  par(bg = "white", fg = publication_style$text_col, col.axis = publication_style$text_col,
      col.lab = publication_style$text_col, col.main = publication_style$text_col,
      family = "sans", mar = mar, mgp = c(3, 0.8, 0), tcl = -0.3)
}

plot_header_caption <- function(main, subtitle, caption, caption_line = 4.2) {
  title(main = main, line = 2.0, cex.main = publication_style$title_cex)
  mtext(subtitle, side = 3, line = 0.55, cex = publication_style$subtitle_cex)
  mtext(caption, side = 1, line = caption_line, cex = publication_style$caption_cex)
}

can_preview_plots <- function() interactive() || rstudio_session
preview_figure <- function(plot_fun, force = FALSE) {
  if (!force && !SHOW_PLOTS) return(invisible(FALSE))
  if (!can_preview_plots()) return(invisible(FALSE))
  plot_fun()
  invisible(TRUE)
}
save_figure <- function(filename, plot_fun, width = 10, height = 7, dpi = publication_style$dpi) {
  grDevices::png(filename, width = width, height = height, units = "in", res = dpi)
  tryCatch(plot_fun(), error = function(e) {
    if (grDevices::dev.cur() > 1) grDevices::dev.off()
    stop(e)
  })
  if (grDevices::dev.cur() > 1) grDevices::dev.off()
  preview_figure(plot_fun)
  invisible(filename)
}

plot_price_dist <- function() {
  op <- par(no.readonly = TRUE); on.exit(par(op), add = TRUE); theme_publication()
  hist(housing_model_df$Price, breaks = 35, col = "#9ecae1", border = "white",
       xlab = "House price", ylab = "Frequency", main = "")
  plot_header_caption("Figure 1. USA Housing price distribution", "Continuous target variable for linear regression",
                      "Caption: Price is approximately bell-shaped with high-value upper-tail observations.")
}
plot_price_income <- function() {
  op <- par(no.readonly = TRUE); on.exit(par(op), add = TRUE); theme_publication()
  plot(housing_model_df$Avg_Area_Income, housing_model_df$Price, pch = 16, cex = 0.45,
       col = rgb(0.1, 0.35, 0.65, 0.35), xlab = "Average area income", ylab = "Price", main = "")
  abline(stats::lm(Price ~ Avg_Area_Income, data = housing_model_df), col = publication_style$accent2, lwd = 2)
  plot_header_caption("Figure 2. Price vs average area income", "Higher-income areas tend to have higher house prices",
                      "Caption: The fitted line shows a strong positive bivariate relationship.")
}
plot_price_age <- function() {
  op <- par(no.readonly = TRUE); on.exit(par(op), add = TRUE); theme_publication()
  plot(housing_model_df$Avg_Area_House_Age, housing_model_df$Price, pch = 16, cex = 0.45,
       col = rgb(0.2, 0.45, 0.2, 0.35), xlab = "Average area house age", ylab = "Price", main = "")
  abline(stats::lm(Price ~ Avg_Area_House_Age, data = housing_model_df), col = publication_style$accent2, lwd = 2)
  plot_header_caption("Figure 3. Price vs house age", "Older average housing stock is associated with higher prices",
                      "Caption: Relationship is positive in the assignment dataset.")
}
plot_price_rooms <- function() {
  op <- par(no.readonly = TRUE); on.exit(par(op), add = TRUE); theme_publication()
  plot(housing_model_df$Avg_Area_Number_of_Rooms, housing_model_df$Price, pch = 16, cex = 0.45,
       col = rgb(0.45, 0.2, 0.55, 0.35), xlab = "Average number of rooms", ylab = "Price", main = "")
  abline(stats::lm(Price ~ Avg_Area_Number_of_Rooms, data = housing_model_df), col = publication_style$accent2, lwd = 2)
  plot_header_caption("Figure 4. Price vs average rooms", "More rooms are associated with higher prices",
                      "Caption: Room count has a positive association with price.")
}
plot_housing_corr <- function() {
  op <- par(no.readonly = TRUE); on.exit(par(op), add = TRUE); theme_publication("heatmap")
  m <- cor_matrix[nrow(cor_matrix):1, ]
  image(seq_len(ncol(m)), seq_len(nrow(m)), t(m), axes = FALSE,
        col = grDevices::colorRampPalette(c("#2166ac", "white", "#b2182b"))(101),
        zlim = c(-1, 1), xlab = "", ylab = "", main = "")
  labels <- c("Price", "Income", "House age", "Rooms", "Bedrooms", "Population")
  axis(1, seq_len(ncol(m)), labels, las = 2, cex.axis = 0.78)
  axis(2, seq_len(nrow(m)), rev(labels), las = 1, cex.axis = 0.78)
  for (i in seq_len(ncol(m))) for (j in seq_len(nrow(m))) text(i, j, fmt(m[j, i], 2), cex = 0.78)
  plot_header_caption("Figure 5. Housing correlation heatmap", "Red indicates positive association; blue indicates negative",
                      "Caption: Income and room-related predictors show the clearest links with price.", caption_line = 7.4)
}
plot_readmission_dist <- function() {
  op <- par(no.readonly = TRUE); on.exit(par(op), add = TRUE); theme_publication()
  barplot(readmission_distribution$Percent, names.arg = readmission_distribution$Outcome,
          col = c("#a1d99b", "#fc9272"), ylab = "Percent", main = "", ylim = c(0, 100))
  plot_header_caption("Figure 6. Readmission distribution", "Binary target for logistic regression",
                      "Caption: Class balance affects how accuracy should be interpreted.")
}
plot_readmission_age <- function() {
  op <- par(no.readonly = TRUE); on.exit(par(op), add = TRUE); theme_publication()
  tab <- prop.table(table(diabetes_model_df$age, diabetes_model_df$readmitted_factor), 1)[, "Readmitted"] * 100
  barplot(tab, las = 2, col = "#9ecae1", ylab = "Readmitted (%)", main = "", ylim = c(0, max(tab, na.rm = TRUE) * 1.25))
  plot_header_caption("Figure 7. Readmission by age group", "Older age bands generally have higher readmission percentages",
                      "Caption: Percent readmitted is calculated within each age group.", caption_line = 5.2)
}
plot_readmission_time <- function() {
  op <- par(no.readonly = TRUE); on.exit(par(op), add = TRUE); theme_publication()
  boxplot(time_in_hospital ~ readmitted_factor, data = diabetes_model_df, col = c("#c7e9c0", "#fdd0a2"),
          xlab = "Readmission status", ylab = "Time in hospital", main = "")
  plot_header_caption("Figure 8. Readmission by time in hospital", "Readmitted patients have slightly longer stays",
                      "Caption: Box plots compare hospital stay length by outcome.")
}
plot_readmission_inpatient <- function() {
  op <- par(no.readonly = TRUE); on.exit(par(op), add = TRUE); theme_publication()
  capped <- pmin(diabetes_model_df$number_inpatient, 5)
  tab <- prop.table(table(capped, diabetes_model_df$readmitted_factor), 1)[, "Readmitted"] * 100
  names(tab)[names(tab) == "5"] <- "5+"
  barplot(tab, col = "#bcbddc", ylab = "Readmitted (%)", xlab = "Prior inpatient visits", main = "")
  plot_header_caption("Figure 9. Readmission by inpatient visits", "Prior inpatient use is strongly associated with readmission",
                      "Caption: Counts of 5 or more prior inpatient visits are grouped as 5+.")
}
plot_readmission_specialty <- function() {
  op <- par(no.readonly = TRUE); on.exit(par(op), add = TRUE); theme_publication()
  specialty <- as.character(diabetes$medical_specialty)
  specialty[is.na(specialty) | specialty == ""] <- "Unknown"
  top <- names(sort(table(specialty), decreasing = TRUE))[1:min(8, length(unique(specialty)))]
  specialty_group <- ifelse(specialty %in% top, specialty, "Other")
  temp <- data.frame(specialty = factor(specialty_group), readmit = diabetes$readmitted_factor)
  tab <- prop.table(table(temp$specialty, temp$readmit), 1)[, "Readmitted"] * 100
  tab <- sort(tab)
  barplot(tab, horiz = TRUE, las = 1, col = "#fdae6b", xlab = "Readmitted (%)", main = "")
  plot_header_caption("Figure 10. Readmission by medical specialty", "Healthcare specialty captures patient and care-context differences",
                      "Caption: Smaller specialties are grouped as Other.", caption_line = 4.8)
}

housing_model <- stats::lm(
  Price ~ Avg_Area_Income + Avg_Area_House_Age + Avg_Area_Number_of_Rooms +
    Avg_Area_Number_of_Bedrooms + Area_Population,
  data = housing_model_df
)
housing_summary_model <- summary(housing_model)
housing_coef <- data.frame(
  Term = rownames(coef(housing_summary_model)),
  Estimate = coef(housing_summary_model)[, 1],
  Std_Error = coef(housing_summary_model)[, 2],
  t_value = coef(housing_summary_model)[, 3],
  p_value = coef(housing_summary_model)[, 4],
  check.names = FALSE
)
housing_ci <- data.frame(Term = rownames(confint(housing_model)), confint(housing_model), check.names = FALSE)
names(housing_ci)[2:3] <- c("CI_2.5", "CI_97.5")
housing_coef <- merge(housing_coef, housing_ci, by = "Term", all.x = TRUE)
housing_fit_metrics <- data.frame(
  Metric = c("R-squared", "Adjusted R-squared", "Residual standard error", "Model N"),
  Value = c(housing_summary_model$r.squared, housing_summary_model$adj.r.squared,
            housing_summary_model$sigma, nrow(housing_model_df))
)
new_house <- as.data.frame(as.list(vapply(housing_model_df[housing_predictors], median, numeric(1))))
housing_prediction <- data.frame(stats::predict(housing_model, newdata = new_house, interval = "prediction"))
housing_prediction <- cbind(new_house, housing_prediction)

vif_manual <- function(model, predictors) {
  df <- model$model
  out <- sapply(predictors, function(v) {
    others <- setdiff(predictors, v)
    f <- as.formula(paste(v, "~", paste(others, collapse = " + ")))
    r2 <- summary(lm(f, data = df))$r.squared
    1 / (1 - r2)
  })
  data.frame(Variable = names(out), VIF = as.numeric(out), row.names = NULL)
}
housing_vif <- vif_manual(housing_model, housing_predictors)

train_idx <- sample(seq_len(nrow(diabetes_model_df)), size = floor(0.70 * nrow(diabetes_model_df)))
diabetes_train <- diabetes_model_df[train_idx, ]
diabetes_test <- diabetes_model_df[-train_idx, ]
logistic_formula <- as.formula(
  "readmitted_binary ~ time_in_hospital + num_lab_procedures + num_procedures + num_medications + number_outpatient + number_emergency + number_inpatient + number_diagnoses + race + gender + age"
)
diabetes_model <- stats::glm(logistic_formula, data = diabetes_train, family = stats::binomial())
diabetes_summary_model <- summary(diabetes_model)
logit_coef <- data.frame(
  Term = rownames(coef(diabetes_summary_model)),
  Estimate = coef(diabetes_summary_model)[, 1],
  Std_Error = coef(diabetes_summary_model)[, 2],
  z_value = coef(diabetes_summary_model)[, 3],
  p_value = coef(diabetes_summary_model)[, 4],
  check.names = FALSE
)
logit_ci <- suppressMessages(confint.default(diabetes_model))
logit_or <- data.frame(Term = rownames(logit_ci), Odds_Ratio = exp(coef(diabetes_model)),
                       OR_CI_2.5 = exp(logit_ci[, 1]), OR_CI_97.5 = exp(logit_ci[, 2]), row.names = NULL)
logit_coef <- merge(logit_coef, logit_or, by = "Term", all.x = TRUE)

test_prob <- as.numeric(stats::predict(diabetes_model, newdata = diabetes_test, type = "response"))
test_pred <- ifelse(test_prob >= 0.5, 1, 0)
actual <- diabetes_test$readmitted_binary
tp <- sum(test_pred == 1 & actual == 1)
tn <- sum(test_pred == 0 & actual == 0)
fp <- sum(test_pred == 1 & actual == 0)
fn <- sum(test_pred == 0 & actual == 1)
auc_manual <- function(actual, score) {
  ok <- !is.na(actual) & !is.na(score)
  actual <- actual[ok]; score <- score[ok]
  n_pos <- sum(actual == 1); n_neg <- sum(actual == 0)
  if (n_pos == 0 || n_neg == 0) return(NA_real_)
  ranks <- rank(score, ties.method = "average")
  (sum(ranks[actual == 1]) - n_pos * (n_pos + 1) / 2) / (n_pos * n_neg)
}
logistic_metrics <- data.frame(
  Metric = c("Train N", "Test N", "Threshold", "Accuracy", "Sensitivity", "Specificity", "AUC", "Readmitted test prevalence"),
  Value = c(nrow(diabetes_train), nrow(diabetes_test), 0.5, (tp + tn) / length(actual),
            ifelse((tp + fn) == 0, NA, tp / (tp + fn)),
            ifelse((tn + fp) == 0, NA, tn / (tn + fp)),
            auc_manual(actual, test_prob), mean(actual == 1))
)
confusion_table <- data.frame(
  Predicted = c("Not readmitted", "Not readmitted", "Readmitted", "Readmitted"),
  Actual = c("Not readmitted", "Readmitted", "Not readmitted", "Readmitted"),
  N = c(tn, fn, fp, tp)
)
new_patient <- diabetes_test[1, diabetes_predictors, drop = FALSE]
new_patient_probability <- data.frame(new_patient, Predicted_Probability = as.numeric(predict(diabetes_model, newdata = new_patient, type = "response")))

write_table(housing_coef, "table_09_housing_linear_coefficients.csv")
write_table(housing_fit_metrics, "table_10_housing_fit_metrics.csv")
write_table(housing_prediction, "table_11_housing_prediction_interval.csv")
write_table(housing_vif, "table_12_housing_vif.csv")
write_table(logit_coef, "table_13_diabetes_logistic_coefficients.csv")
write_table(logistic_metrics, "table_14_diabetes_evaluation_metrics.csv")
write_table(confusion_table, "table_15_diabetes_confusion_matrix.csv")
write_table(new_patient_probability, "table_16_diabetes_predicted_probability.csv")

plot_resid_fitted <- function() {
  op <- par(no.readonly = TRUE); on.exit(par(op), add = TRUE); theme_publication("diagnostics")
  plot(fitted(housing_model), resid(housing_model), pch = 16, cex = 0.45,
       col = rgb(0.2, 0.2, 0.2, 0.35), xlab = "Fitted values", ylab = "Residuals", main = "")
  abline(h = 0, col = "#d7301f", lwd = 2, lty = 2)
  plot_header_caption("Figure 11. Residuals vs fitted values", "Linear regression diagnostic",
                      "Caption: Residual spread is used to assess linearity and constant variance.")
}
plot_qq <- function() {
  op <- par(no.readonly = TRUE); on.exit(par(op), add = TRUE); theme_publication("diagnostics")
  qqnorm(resid(housing_model), pch = 16, cex = 0.45, main = "", xlab = "Theoretical quantiles", ylab = "Sample quantiles")
  qqline(resid(housing_model), col = "#d7301f", lwd = 2)
  plot_header_caption("Figure 12. Normal Q-Q plot", "Linear regression diagnostic",
                      "Caption: Points close to the line indicate approximately normal residuals.")
}
plot_scale_location <- function() {
  op <- par(no.readonly = TRUE); on.exit(par(op), add = TRUE); theme_publication("diagnostics")
  plot(fitted(housing_model), sqrt(abs(rstandard(housing_model))), pch = 16, cex = 0.45,
       col = rgb(0.2, 0.2, 0.2, 0.35), xlab = "Fitted values", ylab = "Sqrt(|standardized residuals|)", main = "")
  plot_header_caption("Figure 13. Scale-location plot", "Linear regression diagnostic",
                      "Caption: A flat spread suggests more stable residual variance.")
}
plot_resid_hist <- function() {
  op <- par(no.readonly = TRUE); on.exit(par(op), add = TRUE); theme_publication("diagnostics")
  hist(resid(housing_model), breaks = 35, col = "#bdbdbd", border = "white", main = "",
       xlab = "Residual", ylab = "Frequency")
  plot_header_caption("Figure 14. Residual histogram", "Distribution of linear regression residuals",
                      "Caption: Histogram supports the Q-Q plot assessment.")
}
plot_cooks <- function() {
  op <- par(no.readonly = TRUE); on.exit(par(op), add = TRUE); theme_publication("diagnostics")
  cd <- cooks.distance(housing_model)
  plot(cd, type = "h", col = "#636363", xlab = "Observation", ylab = "Cook's distance", main = "")
  abline(h = 4 / length(cd), col = "#d7301f", lty = 2, lwd = 2)
  plot_header_caption("Figure 15. Cook's distance", "Influential-observation screening",
                      "Caption: Dashed line shows the common 4/n screening threshold.")
}
plot_roc <- function() {
  op <- par(no.readonly = TRUE); on.exit(par(op), add = TRUE); theme_publication("diagnostics")
  thresholds <- seq(1, 0, length.out = 201)
  tpr <- fpr <- numeric(length(thresholds))
  for (i in seq_along(thresholds)) {
    pred <- ifelse(test_prob >= thresholds[i], 1, 0)
    tpr[i] <- sum(pred == 1 & actual == 1) / sum(actual == 1)
    fpr[i] <- sum(pred == 1 & actual == 0) / sum(actual == 0)
  }
  plot(c(0, fpr, 1), c(0, tpr, 1), type = "l", lwd = 2, col = publication_style$accent,
       xlab = "False positive rate", ylab = "True positive rate", main = "")
  abline(0, 1, lty = 2, col = "#999999")
  plot_header_caption("Figure 16. Logistic ROC curve", paste0("Manual AUC = ", fmt(logistic_metrics$Value[logistic_metrics$Metric == "AUC"], 3)),
                      "Caption: ROC curve summarizes ranking performance across thresholds.")
}

figure_files <- list(
  list(name = "figure_01_housing_price_distribution.png", fun = plot_price_dist, width = 10, height = 7),
  list(name = "figure_02_housing_price_income.png", fun = plot_price_income, width = 10, height = 7),
  list(name = "figure_03_housing_price_age.png", fun = plot_price_age, width = 10, height = 7),
  list(name = "figure_04_housing_price_rooms.png", fun = plot_price_rooms, width = 10, height = 7),
  list(name = "figure_05_housing_correlation_heatmap.png", fun = plot_housing_corr, width = 11, height = 8),
  list(name = "figure_06_diabetes_readmission_distribution.png", fun = plot_readmission_dist, width = 9, height = 7),
  list(name = "figure_07_diabetes_readmission_age.png", fun = plot_readmission_age, width = 10, height = 7.5),
  list(name = "figure_08_diabetes_readmission_time.png", fun = plot_readmission_time, width = 9, height = 7),
  list(name = "figure_09_diabetes_readmission_inpatient.png", fun = plot_readmission_inpatient, width = 9, height = 7),
  list(name = "figure_10_diabetes_readmission_specialty.png", fun = plot_readmission_specialty, width = 10, height = 7),
  list(name = "figure_11_housing_residuals_fitted.png", fun = plot_resid_fitted, width = 9, height = 7),
  list(name = "figure_12_housing_qq.png", fun = plot_qq, width = 9, height = 7),
  list(name = "figure_13_housing_scale_location.png", fun = plot_scale_location, width = 9, height = 7),
  list(name = "figure_14_housing_residual_histogram.png", fun = plot_resid_hist, width = 9, height = 7),
  list(name = "figure_15_housing_cooks_distance.png", fun = plot_cooks, width = 9, height = 7),
  list(name = "figure_16_diabetes_roc.png", fun = plot_roc, width = 9, height = 7)
)
preview_all_figures <- function() invisible(lapply(figure_files, function(fig) preview_figure(fig$fun, force = TRUE)))
for (fig in figure_files) save_figure(file.path(figures_dir, fig$name), fig$fun, fig$width, fig$height)

strong_housing <- housing_coef[housing_coef$Term != "(Intercept)", ]
strong_housing <- strong_housing[order(-abs(strong_housing$Estimate)), ][1, ]
sig_housing <- paste(housing_coef$Term[housing_coef$p_value < 0.05 & housing_coef$Term != "(Intercept)"], collapse = ", ")
if (!nzchar(sig_housing)) sig_housing <- "none at p < 0.05"

logit_non_intercept <- logit_coef[logit_coef$Term != "(Intercept)", ]
logit_non_intercept <- logit_non_intercept[order(-abs(log(logit_non_intercept$Odds_Ratio))), ]
top_logit <- head(logit_non_intercept, 5)
sig_logit <- paste(logit_coef$Term[logit_coef$p_value < 0.05 & logit_coef$Term != "(Intercept)"], collapse = ", ")
if (!nzchar(sig_logit)) sig_logit <- "none at p < 0.05"

interpret_housing <- paste0(
  "The multiple linear regression explains ", fmt(housing_summary_model$r.squared * 100, 1),
  "% of variation in Price (adjusted R-squared ", fmt(housing_summary_model$adj.r.squared, 3),
  "). Holding the other model variables constant, positive coefficients indicate higher expected price. ",
  "The largest coefficient by scale is ", strong_housing$Term, ", but variable units differ, so practical importance should be judged with context. ",
  "Statistically significant predictors at p < 0.05 are: ", sig_housing, "."
)
interpret_diabetes <- paste0(
  "The logistic model estimates the probability of readmission. Odds ratios above 1 indicate higher odds of readmission, while odds ratios below 1 indicate lower odds. ",
  "At threshold 0.5, test accuracy is ", fmt(logistic_metrics$Value[logistic_metrics$Metric == "Accuracy"] * 100, 1),
  "%, sensitivity is ", fmt(logistic_metrics$Value[logistic_metrics$Metric == "Sensitivity"] * 100, 1),
  "%, specificity is ", fmt(logistic_metrics$Value[logistic_metrics$Metric == "Specificity"] * 100, 1),
  "%, and manual AUC is ", fmt(logistic_metrics$Value[logistic_metrics$Metric == "AUC"], 3),
  ". Statistically significant predictors at p < 0.05 include: ", sig_logit, "."
)
limitations <- paste(
  "Both analyses are observational and should not be interpreted causally.",
  "The housing dataset uses area-level variables, not full property-level appraisal data.",
  "The diabetes model uses coded administrative fields selectively; high-cardinality specialty and *_id variables can create unstable or hard-to-interpret coefficients.",
  "Classification at a 0.5 threshold may not be optimal for clinical readmission screening."
)
next_steps <- paste(
  "Next steps include validating models on external data, testing nonlinear effects and interactions, evaluating alternative probability thresholds for readmission,",
  "and comparing base regression with regularized or tree-based models after documenting package dependencies."
)
conclusion <- paste(
  "USA Housing findings:", interpret_housing,
  "Diabetes readmission findings:", interpret_diabetes,
  "Limitations:", limitations,
  "Recommended next analytical steps:", next_steps
)
writeLines(strwrap(conclusion, width = 100), file.path(outputs_dir, "conclusion.txt"))
writeLines(capture.output(sessionInfo()), file.path(outputs_dir, "sessionInfo.txt"))

table_text <- function(tbl, max_rows = 16, digits = 4) {
  if (nrow(tbl) > max_rows) tbl <- tbl[seq_len(max_rows), , drop = FALSE]
  capture.output(print(format(tbl, digits = digits), row.names = FALSE, right = FALSE))
}
wrap_lines <- function(text, width = 110) unlist(strwrap(text, width = width))

report_page_counter <- 0
add_page_number <- function() {
  report_page_counter <<- report_page_counter + 1
  mtext(sprintf("Page %d", report_page_counter), side = 3, adj = 1, line = 3.7, cex = 0.65, col = "#666666")
}
add_text_page <- function(title, body_lines, cex = 0.69) {
  plot.new()
  text(0.02, 0.97, title, adj = c(0, 1), cex = 1.12, font = 2)
  add_page_number()
  y <- 0.91
  for (line in body_lines) {
    if (line == "") {
      y <- y - 0.024
    } else {
      text(0.02, y, line, adj = c(0, 1), cex = cex, family = "mono")
      y <- y - 0.027
    }
    if (y < 0.04) {
      plot.new()
      add_page_number()
      y <- 0.96
    }
  }
}
add_plot_page <- function(plot_fun) {
  plot_fun()
  add_page_number()
}
scrub_pdf_metadata <- function(filename) {
  bytes <- readBin(filename, what = "raw", n = file.info(filename)$size)
  find_raw <- function(x, pattern) {
    if (length(x) < length(pattern)) return(integer(0))
    candidates <- which(x[seq_len(length(x) - length(pattern) + 1)] == pattern[1])
    candidates[vapply(candidates, function(i) identical(x[i:(i + length(pattern) - 1)], pattern), logical(1))]
  }
  replace_pdf_date <- function(x, field, replacement = "D:20260625000000") {
    prefix <- charToRaw(paste0("/", field, " ("))
    pos <- find_raw(x, prefix)
    if (length(pos) == 0) return(x)
    start <- pos[1] + length(prefix)
    end_candidates <- which(x[start:length(x)] == charToRaw(")"))
    if (length(end_candidates) == 0) return(x)
    end <- start + end_candidates[1] - 2
    replacement_raw <- charToRaw(replacement)
    target_length <- end - start + 1
    if (length(replacement_raw) > target_length) replacement_raw <- replacement_raw[seq_len(target_length)]
    if (length(replacement_raw) < target_length) replacement_raw <- c(replacement_raw, rep(charToRaw("0"), target_length - length(replacement_raw)))
    x[start:end] <- replacement_raw
    x
  }
  bytes <- replace_pdf_date(bytes, "CreationDate")
  bytes <- replace_pdf_date(bytes, "ModDate")
  writeBin(bytes, filename)
  invisible(filename)
}

report_pdf <- file.path(project_dir, "Sprint02_BasilEmeokoro.pdf")
grDevices::pdf(report_pdf, width = 11, height = 8.5, onefile = TRUE)
add_text_page("Sprint 02 Assignment: Regression Modelling",
              c("Basil Oforbuike Emeokoro",
                "ADA Global Academy MicroMasters in Machine Learning and Research Methods",
                "",
                "Research Question 1: What area-level economic and housing characteristics are associated with house price?",
                "Research Question 2: What patient and hospital-stay characteristics are associated with diabetes readmission?",
                "",
                table_text(dataset_overview)))
add_text_page("Dataset Documentation and Preparation",
              c("Table 1. Dataset overview", table_text(dataset_overview),
                "", "Table 2. Missing and duplicate checks", table_text(missing_duplicate_table),
                "", "Decisions:",
                wrap_lines("USA Housing uses Price as the continuous outcome. Address is excluded because it is a text identifier rather than a stable numeric predictor for the assignment model."),
                wrap_lines("Diabetes readmitted_binary is converted to 0/1. Race, gender, and age are treated as factors. Medical specialty and *_id administrative codes are documented but excluded from the core model to preserve interpretability and stability.")))
add_text_page("Variable Descriptions",
              c("Table 3. Variable descriptions", table_text(variable_descriptions, 30)))
add_text_page("Exploratory Data Analysis Tables",
              c("Table 4. Housing descriptive statistics", table_text(housing_summary, 12),
                "", "Table 5. Diabetes descriptive statistics", table_text(diabetes_summary, 12),
                "", "Table 6. Readmission distribution", table_text(readmission_distribution),
                "", wrap_lines("Housing price is most visibly related to average area income, house age, and rooms. Diabetes readmission appears higher among patients with more prior inpatient visits and somewhat longer hospital stays.")))
for (i in 1:10) add_plot_page(figure_files[[i]]$fun)
add_text_page("Linear Regression Results",
              c("Model formula:",
                "Price ~ Avg. Area Income + Avg. Area House Age + Avg. Area Number of Rooms +",
                "        Avg. Area Number of Bedrooms + Area Population",
                "", "Table 7. Linear regression coefficients", table_text(housing_coef, 12),
                "", "Table 8. Fit metrics", table_text(housing_fit_metrics),
                "", "Table 9. Prediction interval for median-profile house", table_text(housing_prediction),
                "", wrap_lines(interpret_housing)))
for (i in 11:15) add_plot_page(figure_files[[i]]$fun)
add_text_page("Linear Regression Diagnostics",
              c("Table 10. Manual VIF values", table_text(housing_vif),
                "", wrap_lines("Residual plots are used to assess linearity, variance stability, residual normality, and influential observations. VIF values summarize multicollinearity among the numeric housing predictors. None of these checks proves causality; they indicate whether the linear model is a reasonable descriptive approximation.")))
add_text_page("Logistic Regression Results",
              c("Model formula:",
                "readmitted_binary ~ time_in_hospital + num_lab_procedures + num_procedures +",
                "                    num_medications + number_outpatient + number_emergency +",
                "                    number_inpatient + number_diagnoses + race + gender + age",
                "", "Table 11. Logistic coefficients and odds ratios", table_text(logit_coef, 18),
                "", "Top odds-ratio effects by absolute log odds ratio:", table_text(top_logit, 8),
                "", wrap_lines(interpret_diabetes)))
add_text_page("Logistic Evaluation",
              c("Table 12. Evaluation metrics", table_text(logistic_metrics),
                "", "Table 13. Confusion matrix", table_text(confusion_table),
                "", "Table 14. Predicted probability example", table_text(new_patient_probability),
                "", wrap_lines("The default 0.5 threshold is transparent but may under-detect readmissions if the positive class is less common. Clinical screening would normally compare thresholds using costs of false positives and false negatives.")))
add_plot_page(plot_roc)
add_text_page("Final Interpretation and Conclusion",
              c("USA Housing findings", wrap_lines(interpret_housing),
                "", "Diabetes readmission findings", wrap_lines(interpret_diabetes),
                "", "Limitations", wrap_lines(limitations),
                "", "Recommended next analytical steps", wrap_lines(next_steps)))
grDevices::dev.off()
scrub_pdf_metadata(report_pdf)

cat("Created report:", report_pdf, "\n")
cat("Created figures in:", figures_dir, "\n")
cat("Created tables in:", tables_dir, "\n")
cat("Created session info:", file.path(outputs_dir, "sessionInfo.txt"), "\n")
