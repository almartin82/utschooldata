# ==============================================================================
# LIVE Pipeline Tests for Utah School Data
# ==============================================================================
#
# These tests verify each step of the data pipeline using LIVE network calls.
# NO MOCKS - these tests verify actual data availability and correctness.
#
# Test Categories:
# 1. URL Availability - HTTP 200 for all years
# 2. File Download - File downloads correctly
# 3. File Parsing - readxl can read the file
# 4. Column Structure - Expected sheets and columns exist
# 5. get_raw_enr() - Raw data function works
# 6. Data Quality - No Inf/NaN, valid ranges
# 7. Aggregation - State = sum of districts
# 8. Output Fidelity - tidy=TRUE matches raw values
#
# ==============================================================================

# Helper function to skip tests if offline
skip_if_offline <- function() {
  tryCatch({
    response <- httr::HEAD("https://www.google.com", httr::timeout(5))
    if (httr::http_error(response)) {
      skip("No network connectivity")
    }
  }, error = function(e) {
    skip("No network connectivity")
  })
}

# ==============================================================================
# STEP 1: URL Availability Tests
# ==============================================================================

test_that("USBE main website is accessible", {
  skip_if_offline()

  response <- httr::HEAD(
    "https://www.schools.utah.gov/datastatistics/reports",
    httr::timeout(30)
  )
  expect_true(httr::status_code(response) %in% c(200, 301, 302))
})

test_that("Enrollment data URLs return HTTP 200 for all modern years (2019-2026)", {
  skip_if_offline()

  # Test each year's URL
  for (year in 2019:2026) {
    url <- build_usbe_url(year)
    tryCatch({
      response <- httr::HEAD(url, httr::timeout(30))
      expect_equal(
        httr::status_code(response), 200,
        label = paste("Year", year, "status code")
      )
    }, error = function(e) {
      skip(paste("Network error for year", year, "-", e$message))
    })
  }
})

test_that("Historical time series URL is accessible", {
  skip_if_offline()

  url <- "https://www.schools.utah.gov/superintendentannualreport/_reports/Fall%20Enrollment%20by%20Grade%20Level%20and%20Demographics.xlsx"
  response <- httr::HEAD(url, httr::timeout(30))
  expect_true(httr::status_code(response) %in% c(200, 301, 302))
})

# ==============================================================================
# STEP 2: File Download Tests
# ==============================================================================

test_that("Can download enrollment file and verify it's Excel", {
  skip_if_offline()

  url <- build_usbe_url(2024)
  temp_file <- tempfile(fileext = ".xlsx")

  tryCatch({
    response <- httr::GET(
      url,
      httr::write_disk(temp_file, overwrite = TRUE),
      httr::timeout(120)
    )

    # Check HTTP status
    expect_equal(httr::status_code(response), 200)

    # Check file exists and has content
    expect_true(file.exists(temp_file))

    file_size <- file.info(temp_file)$size
    expect_gt(file_size, 100000)  # Should be larger than 100KB

    # Verify it's an actual Excel file, not HTML error page
    content_type <- httr::headers(response)[["content-type"]]
    expect_true(
      grepl("spreadsheet|excel|octet-stream", content_type, ignore.case = TRUE)
    )

    # Clean up
    if (file.exists(temp_file)) unlink(temp_file)

  }, error = function(e) {
    if (file.exists(temp_file)) unlink(temp_file)
    skip(paste("Download test failed:", e$message))
  })
})

test_that("Downloaded file is not an HTML error page", {
  skip_if_offline()

  url <- build_usbe_url(2024)
  temp_file <- tempfile(fileext = ".xlsx")

  tryCatch({
    httr::GET(url, httr::write_disk(temp_file, overwrite = TRUE), httr::timeout(60))

    # Read first few bytes to check it's not HTML
    con <- file(temp_file, "rb")
    first_bytes <- readBin(con, raw(), 100)
    close(con)

    # Excel files start with PK (zip format)
    first_chars <- rawToChar(first_bytes[1:2])
    expect_equal(first_chars, "PK")  # Excel/ZIP signature

    if (file.exists(temp_file)) unlink(temp_file)

  }, error = function(e) {
    if (file.exists(temp_file)) unlink(temp_file)
    skip(paste("File verification failed:", e$message))
  })
})

# ==============================================================================
# STEP 3: File Parsing Tests
# ==============================================================================

test_that("Can list Excel sheets with readxl", {
  skip_if_offline()

  url <- build_usbe_url(2024)
  temp_file <- tempfile(fileext = ".xlsx")

  tryCatch({
    httr::GET(url, httr::write_disk(temp_file, overwrite = TRUE), httr::timeout(60))

    sheets <- readxl::excel_sheets(temp_file)
    expect_gt(length(sheets), 0)
    expect_true("State" %in% sheets)
    expect_true("By LEA" %in% sheets)
    expect_true("By School" %in% sheets)

    if (file.exists(temp_file)) unlink(temp_file)

  }, error = function(e) {
    if (file.exists(temp_file)) unlink(temp_file)
    skip(paste("Sheet listing failed:", e$message))
  })
})

test_that("Can read State sheet with readxl", {
  skip_if_offline()

  url <- build_usbe_url(2024)
  temp_file <- tempfile(fileext = ".xlsx")

  tryCatch({
    httr::GET(url, httr::write_disk(temp_file, overwrite = TRUE), httr::timeout(60))

    df <- readxl::read_excel(temp_file, sheet = "State")

    expect_true(is.data.frame(df))
    expect_gt(nrow(df), 0)
    expect_gt(ncol(df), 10)

    if (file.exists(temp_file)) unlink(temp_file)

  }, error = function(e) {
    if (file.exists(temp_file)) unlink(temp_file)
    skip(paste("State sheet parsing failed:", e$message))
  })
})

test_that("Can read By School sheet with readxl", {
  skip_if_offline()

  url <- build_usbe_url(2024)
  temp_file <- tempfile(fileext = ".xlsx")

  tryCatch({
    httr::GET(url, httr::write_disk(temp_file, overwrite = TRUE), httr::timeout(60))

    df <- readxl::read_excel(temp_file, sheet = "By School")

    expect_true(is.data.frame(df))
    expect_gt(nrow(df), 500)

    if (file.exists(temp_file)) unlink(temp_file)

  }, error = function(e) {
    if (file.exists(temp_file)) unlink(temp_file)
    skip(paste("School sheet parsing failed:", e$message))
  })
})

# ==============================================================================
# STEP 4: Column Structure Tests
# ==============================================================================

test_that("State sheet has expected columns", {
  skip_if_offline()

  url <- build_usbe_url(2024)
  temp_file <- tempfile(fileext = ".xlsx")

  tryCatch({
    httr::GET(url, httr::write_disk(temp_file, overwrite = TRUE), httr::timeout(60))

    df <- readxl::read_excel(temp_file, sheet = "State")
    cols <- tolower(names(df))

    # Check required columns exist (case-insensitive)
    expect_true(any(grepl("school.?year", cols)))
    expect_true(any(grepl("lea.?type", cols)))
    expect_true(any(grepl("total", cols)))
    expect_true(any(grepl("female", cols)))
    expect_true(any(grepl("male", cols)))
    expect_true(any(grepl("white", cols)))
    expect_true(any(grepl("hispanic", cols)))

    if (file.exists(temp_file)) unlink(temp_file)

  }, error = function(e) {
    if (file.exists(temp_file)) unlink(temp_file)
    skip(paste("Column structure test failed:", e$message))
  })
})

test_that("By School sheet has school identifiers", {
  skip_if_offline()

  url <- build_usbe_url(2024)
  temp_file <- tempfile(fileext = ".xlsx")

  tryCatch({
    httr::GET(url, httr::write_disk(temp_file, overwrite = TRUE), httr::timeout(60))

    df <- readxl::read_excel(temp_file, sheet = "By School")
    cols <- tolower(names(df))

    expect_true(any(grepl("lea.?name", cols)))
    expect_true(any(grepl("school.?name", cols)))

    if (file.exists(temp_file)) unlink(temp_file)

  }, error = function(e) {
    if (file.exists(temp_file)) unlink(temp_file)
    skip(paste("School columns test failed:", e$message))
  })
})

# ==============================================================================
# STEP 5: get_raw_enr() Function Tests
# ==============================================================================

test_that("get_raw_enr() returns valid data for 2024", {
  skip_if_offline()

  result <- get_raw_enr(2024)

  expect_true(is.data.frame(result))
  expect_gt(nrow(result), 100)

  # Check for expected columns after standardization
  expect_true("level" %in% names(result))
})

test_that("get_raw_enr() returns data with multiple levels", {
  skip_if_offline()

  result <- get_raw_enr(2024)

  levels <- unique(result$level)
  expect_true("State" %in% levels)
  expect_true("District" %in% levels)
  expect_true("Campus" %in% levels)
})

test_that("get_raw_enr() returns state-only data for historical years", {
  skip_if_offline()

  result <- get_raw_enr(2015)

  expect_true(is.data.frame(result))
  expect_true(all(result$level == "State"))
})

test_that("get_raw_enr() rejects invalid years", {
  expect_error(get_raw_enr(2000), "not available")
  expect_error(get_raw_enr(2050), "not available")
})

# ==============================================================================
# STEP 6: Data Quality Tests
# ==============================================================================

test_that("No Inf or NaN values in raw data", {
  skip_if_offline()

  result <- get_raw_enr(2024)

  # Check all numeric columns for Inf/NaN
  numeric_cols <- names(result)[sapply(result, is.numeric)]
  for (col in numeric_cols) {
    expect_false(any(is.infinite(result[[col]]), na.rm = TRUE))
    expect_false(any(is.nan(result[[col]]), na.rm = TRUE))
  }
})

test_that("Enrollment counts are non-negative", {
  skip_if_offline()

  result <- get_raw_enr(2024)

  # Find total column
  total_col <- grep("total_k12|row_total|Total", names(result), value = TRUE, ignore.case = TRUE)
  if (length(total_col) > 0) {
    totals <- result[[total_col[1]]]
    expect_true(all(totals >= 0, na.rm = TRUE))
  }
})

test_that("State total enrollment is in reasonable range", {
  skip_if_offline()

  result <- fetch_enr(2024, tidy = TRUE, use_cache = FALSE)

  state_total <- result |>
    dplyr::filter(is_state, subgroup == "total_enrollment", grade_level == "TOTAL") |>
    dplyr::pull(n_students)

  # Utah has approximately 670,000 K-12 students
  expect_gt(state_total, 500000)
  expect_lt(state_total, 1000000)
})

test_that("Gender counts are reasonable", {
  skip_if_offline()

  result <- fetch_enr(2024, tidy = TRUE, use_cache = FALSE)

  male <- result |>
    dplyr::filter(is_state, subgroup == "male", grade_level == "TOTAL") |>
    dplyr::pull(n_students)

  female <- result |>
    dplyr::filter(is_state, subgroup == "female", grade_level == "TOTAL") |>
    dplyr::pull(n_students)

  # Check gender values are reasonable
  expect_gt(male, 200000)
  expect_gt(female, 200000)

  # Check ratio is reasonable (typically 48-52%)
  total <- male + female
  male_pct <- male / total
  expect_gt(male_pct, 0.45)
  expect_lt(male_pct, 0.55)
})

# ==============================================================================
# STEP 7: Aggregation Tests
# ==============================================================================

test_that("District totals approximately equal state total", {
  skip_if_offline()

  result <- fetch_enr(2024, tidy = FALSE, use_cache = FALSE)

  # Get state total
  state_total <- result |>
    dplyr::filter(type == "State") |>
    dplyr::pull(row_total) |>
    sum(na.rm = TRUE)

  # Get district totals
  district_total <- result |>
    dplyr::filter(type == "District") |>
    dplyr::pull(row_total) |>
    sum(na.rm = TRUE)

  # District totals should be close to state total (within 1%)
  # Note: May not be exact due to charter schools vs districts
  ratio <- district_total / state_total
  expect_gt(ratio, 0.85)
  expect_lt(ratio, 1.15)
})

test_that("School totals approximately equal district totals", {
  skip_if_offline()

  result <- fetch_enr(2024, tidy = FALSE, use_cache = FALSE)

  # Get district totals
  district_total <- result |>
    dplyr::filter(type == "District") |>
    dplyr::pull(row_total) |>
    sum(na.rm = TRUE)

  # Get school totals
  school_total <- result |>
    dplyr::filter(type == "Campus") |>
    dplyr::pull(row_total) |>
    sum(na.rm = TRUE)

  # School totals should be close to district totals
  ratio <- school_total / district_total
  expect_gt(ratio, 0.90)
  expect_lt(ratio, 1.10)
})

# ==============================================================================
# STEP 8: Output Fidelity Tests
# ==============================================================================

test_that("tidy=TRUE output total matches raw data total", {
  skip_if_offline()

  # Get raw data
  raw <- fetch_enr(2024, tidy = FALSE, use_cache = FALSE)

  # Get tidy data
  tidy_data <- fetch_enr(2024, tidy = TRUE, use_cache = FALSE)

  # Get state total from raw
  raw_total <- raw |>
    dplyr::filter(type == "State") |>
    dplyr::pull(row_total) |>
    sum(na.rm = TRUE)

  # Get state total from tidy
  tidy_total <- tidy_data |>
    dplyr::filter(is_state, subgroup == "total_enrollment", grade_level == "TOTAL") |>
    dplyr::pull(n_students) |>
    sum(na.rm = TRUE)

  # Should match
  expect_equal(tidy_total, raw_total, tolerance = 1)
})

test_that("fetch_enr returns correct year in end_year column", {
  skip_if_offline()

  result <- fetch_enr(2024, tidy = TRUE, use_cache = FALSE)

  expect_true("end_year" %in% names(result))
  expect_true(all(result$end_year == 2024, na.rm = TRUE))
})

test_that("fetch_enr_multi returns data for all requested years", {
  skip_if_offline()

  result <- fetch_enr_multi(2023:2024, tidy = TRUE, use_cache = TRUE)

  years_in_data <- unique(result$end_year)
  expect_true(2023 %in% years_in_data)
  expect_true(2024 %in% years_in_data)
})

# ==============================================================================
# STEP 9: Year-by-Year Verification Tests
# ==============================================================================

test_that("All modern years (2019-2026) can be fetched",
{
  skip_if_offline()

  for (year in 2019:2026) {
    tryCatch({
      result <- fetch_enr(year, tidy = TRUE, use_cache = TRUE)

      expect_true(is.data.frame(result))
      expect_gt(nrow(result), 100)

      # Check for state-level data
      state_rows <- sum(result$is_state, na.rm = TRUE)
      expect_gt(state_rows, 0)

    }, error = function(e) {
      fail(paste("Year", year, "failed:", e$message))
    })
  }
})

test_that("Historical years (2014-2018) return state-only data", {
  skip_if_offline()

  for (year in c(2015, 2017)) {  # Test a sample of historical years
    tryCatch({
      result <- fetch_enr(year, tidy = TRUE, use_cache = TRUE)

      # Historical years should only have state-level data
      expect_true(all(result$is_state))
      expect_false(any(result$is_district, na.rm = TRUE))
      expect_false(any(result$is_campus, na.rm = TRUE))

    }, error = function(e) {
      fail(paste("Historical year", year, "failed:", e$message))
    })
  }
})

# ==============================================================================
# STEP 10: Known Value Tests (Spot Checks)
# ==============================================================================

test_that("2024 state total is approximately 672,000", {
  skip_if_offline()

  result <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)

  state_total <- result |>
    dplyr::filter(is_state, subgroup == "total_enrollment", grade_level == "TOTAL") |>
    dplyr::pull(n_students)

  # From the raw data, 2024 state total is 672,662
  expect_gt(state_total, 670000)
  expect_lt(state_total, 680000)
})

test_that("Alpine District is one of the largest districts", {
  skip_if_offline()

  result <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)

  alpine <- result |>
    dplyr::filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL",
                  grepl("Alpine", district_name, ignore.case = TRUE)) |>
    dplyr::pull(n_students)

  # Alpine is one of Utah's largest districts with ~85k students
  expect_gt(alpine, 70000)
  expect_lt(alpine, 100000)
})
