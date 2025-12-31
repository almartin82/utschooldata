# Tests for caching functions

test_that("get_cache_dir creates directory if needed", {
  cache_dir <- get_cache_dir()

  expect_true(is.character(cache_dir))
  expect_true(dir.exists(cache_dir))
  expect_true(grepl("utschooldata", cache_dir))
})

test_that("get_cache_path constructs correct paths", {
  path_tidy <- get_cache_path(2024, "tidy")
  path_wide <- get_cache_path(2024, "wide")

  expect_true(grepl("enr_tidy_2024\\.rds$", path_tidy))
  expect_true(grepl("enr_wide_2024\\.rds$", path_wide))

  # Different years produce different paths
  path_2023 <- get_cache_path(2023, "tidy")
  expect_false(path_tidy == path_2023)
})

test_that("cache_exists returns FALSE for non-existent data", {
  # Use a year that definitely won't be cached
  expect_false(cache_exists(1900, "tidy"))
  expect_false(cache_exists(9999, "wide"))
})

test_that("write_cache and read_cache roundtrip works", {
  # Create test data
  test_df <- data.frame(
    end_year = 9998,
    district_id = "TEST001",
    n_students = 100,
    stringsAsFactors = FALSE
  )

  # Write to cache
  cache_path <- write_cache(test_df, 9998, "test")
  expect_true(file.exists(cache_path))

  # Read back
  result <- read_cache(9998, "test")
  expect_equal(result$end_year, 9998)
  expect_equal(result$district_id, "TEST001")
  expect_equal(result$n_students, 100)

  # Clean up
  file.remove(cache_path)
})

test_that("clear_cache removes files", {
  # Create test data
  test_df <- data.frame(x = 1:3)

  # Write test cache files
  write_cache(test_df, 9997, "tidy")
  write_cache(test_df, 9997, "wide")

  # Verify they exist
  expect_true(file.exists(get_cache_path(9997, "tidy")))
  expect_true(file.exists(get_cache_path(9997, "wide")))

  # Clear specific year
  clear_cache(9997)

  # Verify they're gone
  expect_false(file.exists(get_cache_path(9997, "tidy")))
  expect_false(file.exists(get_cache_path(9997, "wide")))
})

test_that("cache_status runs without error", {
  # Should work even with empty cache (may produce messages)
  result <- suppressMessages(cache_status())
  expect_true(is.data.frame(result))
})
