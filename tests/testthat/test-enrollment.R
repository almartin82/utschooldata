# Tests for enrollment functions
# Note: Most tests are marked as skip_on_cran since they require network access

test_that("safe_numeric handles various inputs", {
  # Normal numbers
  expect_equal(safe_numeric("100"), 100)
  expect_equal(safe_numeric("1,234"), 1234)

  # Suppressed values
  expect_true(is.na(safe_numeric("*")))
  expect_true(is.na(safe_numeric("-1")))
  expect_true(is.na(safe_numeric("<5")))
  expect_true(is.na(safe_numeric("")))
  expect_true(is.na(safe_numeric("N<10")))
  expect_true(is.na(safe_numeric("N/A")))

  # Whitespace handling
  expect_equal(safe_numeric("  100  "), 100)
})

test_that("get_available_years returns valid range", {
  years <- get_available_years()

  expect_true(is.numeric(years))
  expect_true(length(years) > 0)
  expect_true(min(years) >= 2014)  # Historical data from 2014

  expect_true(max(years) <= 2030)  # Reasonable upper bound
})

test_that("get_full_data_years returns 2019+", {
  full_years <- get_full_data_years()

  expect_true(is.numeric(full_years))
  expect_true(min(full_years) == 2019)
  expect_true(all(full_years >= 2019))
})

test_that("get_state_only_years returns 2014-2018", {
  state_years <- get_state_only_years()

  expect_true(is.numeric(state_years))
  expect_equal(min(state_years), 2014)
  expect_equal(max(state_years), 2018)
  expect_equal(length(state_years), 5)
})

test_that("fetch_enr validates year parameter", {
  expect_error(fetch_enr(2010), "end_year must be between")  # Before data availability
  expect_error(fetch_enr(2013), "end_year must be between")  # Just before 2014
  expect_error(fetch_enr(2050), "end_year must be between")
})

test_that("build_usbe_url constructs valid URLs", {
  url <- build_usbe_url(2024)
  expect_true(grepl("schools.utah.gov", url))
  expect_true(grepl("2024", url))
  expect_true(grepl("FallEnrollmentGradeLevelDemographics.xlsx", url))
})

test_that("get_cache_dir returns valid path", {
  cache_dir <- get_cache_dir()
  expect_true(is.character(cache_dir))
  expect_true(grepl("utschooldata", cache_dir))
})

test_that("cache functions work correctly", {
  # Test cache path generation
  path <- get_cache_path(2024, "tidy")
  expect_true(grepl("enr_tidy_2024.rds", path))

  # Test cache_exists returns FALSE for non-existent cache
  expect_false(cache_exists(9999, "tidy"))
})

# Integration tests (require network access)
test_that("fetch_enr downloads and processes data", {
  skip_on_cran()
  skip_if_offline()

  # Use a recent year
  result <- fetch_enr(2024, tidy = FALSE, use_cache = FALSE)

  # Check structure
  expect_true(is.data.frame(result))
  expect_true("district_id" %in% names(result))
  expect_true("campus_id" %in% names(result))
  expect_true("row_total" %in% names(result))
  expect_true("type" %in% names(result))

  # Check we have all levels
  expect_true("State" %in% result$type)
  expect_true("District" %in% result$type || "Campus" %in% result$type)
})

test_that("tidy_enr produces correct long format", {
  skip_on_cran()
  skip_if_offline()

  # Get wide data
  wide <- fetch_enr(2024, tidy = FALSE, use_cache = TRUE)

  # Tidy it
  tidy_result <- tidy_enr(wide)

  # Check structure
  expect_true("grade_level" %in% names(tidy_result))
  expect_true("subgroup" %in% names(tidy_result))
  expect_true("n_students" %in% names(tidy_result))
  expect_true("pct" %in% names(tidy_result))

  # Check subgroups include expected values
  subgroups <- unique(tidy_result$subgroup)
  expect_true("total_enrollment" %in% subgroups)
})

test_that("id_enr_aggs adds correct flags", {
  skip_on_cran()
  skip_if_offline()

  # Get tidy data with aggregation flags
  result <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)

  # Check flags exist
  expect_true("is_state" %in% names(result))
  expect_true("is_district" %in% names(result))
  expect_true("is_campus" %in% names(result))

  # Check flags are boolean
  expect_true(is.logical(result$is_state))
  expect_true(is.logical(result$is_district))
  expect_true(is.logical(result$is_campus))

  # Check mutual exclusivity (each row is only one type)
  type_sums <- result$is_state + result$is_district + result$is_campus
  expect_true(all(type_sums == 1))
})

test_that("fetch_enr_multi works for multiple years", {
  skip_on_cran()
  skip_if_offline()

  # Get 2 years of data
  result <- fetch_enr_multi(c(2023, 2024), tidy = TRUE, use_cache = TRUE)

  # Check we have both years
  expect_true(all(c(2023, 2024) %in% result$end_year))

  # Check structure
  expect_true(is.data.frame(result))
  expect_true("n_students" %in% names(result))
})

test_that("fetch_enr_multi validates years", {
  expect_error(fetch_enr_multi(c(2010, 2024)), "Invalid years")
})

test_that("state totals are reasonable", {
  skip_on_cran()
  skip_if_offline()

  result <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)

  # Get state total enrollment
  state_total <- result %>%
    dplyr::filter(is_state, subgroup == "total_enrollment", grade_level == "TOTAL") %>%
    dplyr::pull(n_students)

  # Utah has approximately 700,000 K-12 students
  # Allow reasonable range (500k-1M)
  expect_true(state_total > 500000)
  expect_true(state_total < 1000000)
})


# Historical data tests (2014-2018)
test_that("fetch_enr downloads historical state data (2014-2018)", {
  skip_on_cran()
  skip_if_offline()

  # Use 2015 as a test case for historical data
  result <- fetch_enr(2015, tidy = TRUE, use_cache = FALSE)

  # Check structure
  expect_true(is.data.frame(result))
  expect_true("n_students" %in% names(result))
  expect_true("is_state" %in% names(result))

  # Historical data should only have state-level data
  expect_true(all(result$is_state))
  expect_false(any(result$is_district, na.rm = TRUE))
  expect_false(any(result$is_campus, na.rm = TRUE))

  # Get state total enrollment for 2015
  state_total <- result %>%
    dplyr::filter(is_state, subgroup == "total_enrollment", grade_level == "TOTAL") %>%
    dplyr::pull(n_students)

  # Utah had approximately 620,000 K-12 students in 2015
  expect_true(state_total > 500000)
  expect_true(state_total < 800000)
})

test_that("historical and current data can be combined", {
  skip_on_cran()
  skip_if_offline()

  # Get a range spanning historical and current data
  result <- fetch_enr_multi(c(2015, 2024), tidy = TRUE, use_cache = TRUE)

  # Check we have both years
  expect_true(2015 %in% result$end_year)
  expect_true(2024 %in% result$end_year)

  # Check state totals exist for both years
  state_totals <- result %>%
    dplyr::filter(is_state, subgroup == "total_enrollment", grade_level == "TOTAL") %>%
    dplyr::select(end_year, n_students)

  expect_equal(nrow(state_totals), 2)
  expect_true(all(state_totals$n_students > 500000))
})
