# ==============================================================================
# Tests for fetch_directory()
# ==============================================================================

test_that("fetch_directory returns data", {
  skip_on_cran()
  skip_if_offline()

  dir_data <- fetch_directory(use_cache = FALSE)

  expect_s3_class(dir_data, "tbl_df")
  expect_gt(nrow(dir_data), 50)
  expect_true("district_name" %in% names(dir_data))
  expect_true("school_name" %in% names(dir_data))
  expect_true("principal_name" %in% names(dir_data))
  expect_true("superintendent_name" %in% names(dir_data))
  expect_true("address" %in% names(dir_data))
  expect_true("city" %in% names(dir_data))
  expect_true("state" %in% names(dir_data))
  expect_true("zip" %in% names(dir_data))
  expect_true("phone" %in% names(dir_data))
  expect_true("is_charter" %in% names(dir_data))
  expect_true("grades_served" %in% names(dir_data))
})

test_that("fetch_directory raw format works", {
  skip_on_cran()
  skip_if_offline()

  dir_raw <- fetch_directory(tidy = FALSE, use_cache = FALSE)

  expect_s3_class(dir_raw, "tbl_df")
  expect_gt(nrow(dir_raw), 50)
})

test_that("directory tidy schema has standard columns", {
  skip_on_cran()
  skip_if_offline()

  dir_data <- fetch_directory(use_cache = TRUE)

  # Standard columns from task specification
  expected_cols <- c(
    "state_district_id", "state_school_id",
    "district_name", "school_name",
    "entity_type",
    "address", "city", "state", "zip", "phone",
    "principal_name", "principal_email",
    "superintendent_name", "superintendent_email",
    "website"
  )

  for (col in expected_cols) {
    expect_true(col %in% names(dir_data), info = paste("Missing column:", col))
  }
})

test_that("directory has charter schools flagged", {
  skip_on_cran()
  skip_if_offline()

  dir_data <- fetch_directory(use_cache = TRUE)

  expect_true(is.logical(dir_data$is_charter))
  # Utah has many charter schools
  n_charter <- sum(dir_data$is_charter, na.rm = TRUE)
  expect_gt(n_charter, 10)
})

test_that("directory cache works", {
  skip_on_cran()
  skip_if_offline()

  dir1 <- fetch_directory(use_cache = TRUE)
  dir2 <- fetch_directory(use_cache = TRUE)

  expect_equal(nrow(dir1), nrow(dir2))

  clear_directory_cache()
})

test_that("superintendent data is joined for known districts", {
  skip_on_cran()
  skip_if_offline()

  dir_data <- fetch_directory(use_cache = TRUE)

  # Alpine is a major district that should always have a superintendent
  alpine <- dir_data |>
    dplyr::filter(grepl("Alpine", district_name, ignore.case = TRUE))

  expect_gt(nrow(alpine), 0)

  # At least some Alpine schools should have superintendent info
  has_supt <- sum(!is.na(alpine$superintendent_name))
  expect_gt(has_supt, 0)
})
