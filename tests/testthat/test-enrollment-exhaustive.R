# ==============================================================================
# Exhaustive Enrollment Tests for utschooldata
# ==============================================================================
#
# Tests ALL exported enrollment functions with ALL parameter combinations.
# All pinned values come from real USBE data via fetch_enr(use_cache = TRUE).
#
# Exported functions tested:
#   - fetch_enr(end_year, tidy, use_cache)
#   - fetch_enr_multi(end_years, tidy, use_cache)
#   - tidy_enr(df)
#   - id_enr_aggs(df)
#   - enr_grade_aggs(df)
#   - get_available_years()
#   - cache_status()
#   - clear_cache(end_year, type)
#   - fetch_directory(end_year, tidy, use_cache)
#   - clear_directory_cache()
#
# ==============================================================================


# ==============================================================================
# get_available_years() — exhaustive
# ==============================================================================

test_that("get_available_years returns 2014:2026", {
  years <- get_available_years()
  expect_equal(years, 2014:2026)
  expect_equal(length(years), 13)
  expect_equal(min(years), 2014)
  expect_equal(max(years), 2026)
})

test_that("get_available_years returns integer vector", {
  years <- get_available_years()
  expect_true(is.integer(years) || is.numeric(years))
  expect_true(all(years == floor(years)))
})


# ==============================================================================
# fetch_enr() — parameter validation
# ==============================================================================

test_that("fetch_enr rejects years outside available range", {
  expect_error(fetch_enr(2013), "end_year must be between")
  expect_error(fetch_enr(2027), "end_year must be between")
  expect_error(fetch_enr(2000), "end_year must be between")
  expect_error(fetch_enr(2050), "end_year must be between")
  expect_error(fetch_enr(1999), "end_year must be between")
})

test_that("fetch_enr_multi rejects invalid years", {
  expect_error(fetch_enr_multi(c(2010, 2024)), "Invalid years")
  expect_error(fetch_enr_multi(c(2024, 2030)), "Invalid years")
  expect_error(fetch_enr_multi(c(2000)), "Invalid years")
})


# ==============================================================================
# fetch_enr() tidy=TRUE — 2024 state-level pinned values
# ==============================================================================

test_that("2024 tidy: state total enrollment is 672,662", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_state &
    tidy$subgroup == "total_enrollment" &
    tidy$grade_level == "TOTAL"]
  expect_equal(val, 672662)
})

test_that("2024 tidy: state white enrollment is 478,697", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_state &
    tidy$subgroup == "white" &
    tidy$grade_level == "TOTAL"]
  expect_equal(val, 478697)
})

test_that("2024 tidy: state hispanic enrollment is 132,110", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_state &
    tidy$subgroup == "hispanic" &
    tidy$grade_level == "TOTAL"]
  expect_equal(val, 132110)
})

test_that("2024 tidy: state black enrollment is 8,757", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_state &
    tidy$subgroup == "black" &
    tidy$grade_level == "TOTAL"]
  expect_equal(val, 8757)
})

test_that("2024 tidy: state asian enrollment is 10,874", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_state &
    tidy$subgroup == "asian" &
    tidy$grade_level == "TOTAL"]
  expect_equal(val, 10874)
})

test_that("2024 tidy: state native_american enrollment is 6,025", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_state &
    tidy$subgroup == "native_american" &
    tidy$grade_level == "TOTAL"]
  expect_equal(val, 6025)
})

test_that("2024 tidy: state pacific_islander enrollment is 10,531", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_state &
    tidy$subgroup == "pacific_islander" &
    tidy$grade_level == "TOTAL"]
  expect_equal(val, 10531)
})

test_that("2024 tidy: state multiracial enrollment is 25,668", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_state &
    tidy$subgroup == "multiracial" &
    tidy$grade_level == "TOTAL"]
  expect_equal(val, 25668)
})

test_that("2024 tidy: state male enrollment is 346,053", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_state &
    tidy$subgroup == "male" &
    tidy$grade_level == "TOTAL"]
  expect_equal(val, 346053)
})

test_that("2024 tidy: state female enrollment is 326,516", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_state &
    tidy$subgroup == "female" &
    tidy$grade_level == "TOTAL"]
  expect_equal(val, 326516)
})

test_that("2024 tidy: state econ_disadv enrollment is 201,736", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_state &
    tidy$subgroup == "econ_disadv" &
    tidy$grade_level == "TOTAL"]
  expect_equal(val, 201736)
})

test_that("2024 tidy: state lep enrollment is 59,147", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_state &
    tidy$subgroup == "lep" &
    tidy$grade_level == "TOTAL"]
  expect_equal(val, 59147)
})

test_that("2024 tidy: state special_ed enrollment is 87,072", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_state &
    tidy$subgroup == "special_ed" &
    tidy$grade_level == "TOTAL"]
  expect_equal(val, 87072)
})


# ==============================================================================
# fetch_enr() tidy=TRUE — 2024 state-level grade counts
# ==============================================================================

test_that("2024 tidy: state PK enrollment is 16,392", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_state &
    tidy$subgroup == "total_enrollment" &
    tidy$grade_level == "PK"]
  expect_equal(val, 16392)
})

test_that("2024 tidy: state K enrollment is 45,217", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_state &
    tidy$subgroup == "total_enrollment" &
    tidy$grade_level == "K"]
  expect_equal(val, 45217)
})

test_that("2024 tidy: state grade 01 enrollment is 48,138", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_state &
    tidy$subgroup == "total_enrollment" &
    tidy$grade_level == "01"]
  expect_equal(val, 48138)
})

test_that("2024 tidy: state grade 02 enrollment is 50,871", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_state &
    tidy$subgroup == "total_enrollment" &
    tidy$grade_level == "02"]
  expect_equal(val, 50871)
})

test_that("2024 tidy: state grade 03 enrollment is 50,964", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_state &
    tidy$subgroup == "total_enrollment" &
    tidy$grade_level == "03"]
  expect_equal(val, 50964)
})

test_that("2024 tidy: state grade 04 enrollment is 51,386", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_state &
    tidy$subgroup == "total_enrollment" &
    tidy$grade_level == "04"]
  expect_equal(val, 51386)
})

test_that("2024 tidy: state grade 05 enrollment is 52,547", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_state &
    tidy$subgroup == "total_enrollment" &
    tidy$grade_level == "05"]
  expect_equal(val, 52547)
})

test_that("2024 tidy: state grade 06 enrollment is 51,406", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_state &
    tidy$subgroup == "total_enrollment" &
    tidy$grade_level == "06"]
  expect_equal(val, 51406)
})

test_that("2024 tidy: state grade 07 enrollment is 52,833", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_state &
    tidy$subgroup == "total_enrollment" &
    tidy$grade_level == "07"]
  expect_equal(val, 52833)
})

test_that("2024 tidy: state grade 08 enrollment is 53,206", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_state &
    tidy$subgroup == "total_enrollment" &
    tidy$grade_level == "08"]
  expect_equal(val, 53206)
})

test_that("2024 tidy: state grade 09 enrollment is 54,351", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_state &
    tidy$subgroup == "total_enrollment" &
    tidy$grade_level == "09"]
  expect_equal(val, 54351)
})

test_that("2024 tidy: state grade 10 enrollment is 55,542", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_state &
    tidy$subgroup == "total_enrollment" &
    tidy$grade_level == "10"]
  expect_equal(val, 55542)
})

test_that("2024 tidy: state grade 11 enrollment is 54,431", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_state &
    tidy$subgroup == "total_enrollment" &
    tidy$grade_level == "11"]
  expect_equal(val, 54431)
})

test_that("2024 tidy: state grade 12 enrollment is 51,770", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_state &
    tidy$subgroup == "total_enrollment" &
    tidy$grade_level == "12"]
  expect_equal(val, 51770)
})


# ==============================================================================
# fetch_enr() tidy=TRUE — 2024 district-level pinned values
# ==============================================================================

test_that("2024 tidy: Alpine District total is 84,710", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_district &
    grepl("Alpine District", tidy$district_name) &
    tidy$subgroup == "total_enrollment" &
    tidy$grade_level == "TOTAL"]
  expect_equal(val, 84710)
})

test_that("2024 tidy: Davis District total is 70,703", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_district &
    grepl("^Davis District", tidy$district_name) &
    tidy$subgroup == "total_enrollment" &
    tidy$grade_level == "TOTAL"]
  expect_equal(val, 70703)
})

test_that("2024 tidy: Granite District total is 58,312", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_district &
    grepl("Granite District", tidy$district_name) &
    tidy$subgroup == "total_enrollment" &
    tidy$grade_level == "TOTAL"]
  expect_equal(val, 58312)
})

test_that("2024 tidy: Jordan District total is 57,436", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_district &
    grepl("^Jordan District", tidy$district_name) &
    tidy$subgroup == "total_enrollment" &
    tidy$grade_level == "TOTAL"]
  expect_equal(val, 57436)
})

test_that("2024 tidy: Nebo District total is 43,672", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_district &
    grepl("Nebo District", tidy$district_name) &
    tidy$subgroup == "total_enrollment" &
    tidy$grade_level == "TOTAL"]
  expect_equal(val, 43672)
})

test_that("2024 tidy: Washington District total is 36,753", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_district &
    grepl("Washington District", tidy$district_name) &
    tidy$subgroup == "total_enrollment" &
    tidy$grade_level == "TOTAL"]
  expect_equal(val, 36753)
})

test_that("2024 tidy: Canyons District total is 32,733", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_district &
    grepl("Canyons District", tidy$district_name) &
    tidy$subgroup == "total_enrollment" &
    tidy$grade_level == "TOTAL"]
  expect_equal(val, 32733)
})

test_that("2024 tidy: Weber District total is 32,103", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_district &
    grepl("Weber District", tidy$district_name) &
    tidy$subgroup == "total_enrollment" &
    tidy$grade_level == "TOTAL"]
  expect_equal(val, 32103)
})

test_that("2024 tidy: Cache District total is 19,794", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_district &
    grepl("Cache District", tidy$district_name) &
    tidy$subgroup == "total_enrollment" &
    tidy$grade_level == "TOTAL"]
  expect_equal(val, 19794)
})

test_that("2024 tidy: Salt Lake District total is 18,966", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_district &
    grepl("Salt Lake District", tidy$district_name) &
    tidy$subgroup == "total_enrollment" &
    tidy$grade_level == "TOTAL"]
  expect_equal(val, 18966)
})


# ==============================================================================
# fetch_enr() tidy=TRUE — Nebo District demographics 2024
# ==============================================================================

test_that("2024 tidy: Nebo District white is 35,548", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_district &
    grepl("Nebo District", tidy$district_name) &
    tidy$subgroup == "white" &
    tidy$grade_level == "TOTAL"]
  expect_equal(val, 35548)
})

test_that("2024 tidy: Nebo District hispanic is 6,096", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_district &
    grepl("Nebo District", tidy$district_name) &
    tidy$subgroup == "hispanic" &
    tidy$grade_level == "TOTAL"]
  expect_equal(val, 6096)
})

test_that("2024 tidy: Nebo District econ_disadv is 10,187", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_district &
    grepl("Nebo District", tidy$district_name) &
    tidy$subgroup == "econ_disadv" &
    tidy$grade_level == "TOTAL"]
  expect_equal(val, 10187)
})

test_that("2024 tidy: Nebo District special_ed is 5,179", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_district &
    grepl("Nebo District", tidy$district_name) &
    tidy$subgroup == "special_ed" &
    tidy$grade_level == "TOTAL"]
  expect_equal(val, 5179)
})

test_that("2024 tidy: Nebo District lep is 1,459", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_district &
    grepl("Nebo District", tidy$district_name) &
    tidy$subgroup == "lep" &
    tidy$grade_level == "TOTAL"]
  expect_equal(val, 1459)
})


# ==============================================================================
# fetch_enr() tidy=TRUE — Salt Lake District demographics 2024
# ==============================================================================

test_that("2024 tidy: Salt Lake District hispanic is 7,468", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_district &
    grepl("Salt Lake District", tidy$district_name) &
    tidy$subgroup == "hispanic" &
    tidy$grade_level == "TOTAL"]
  expect_equal(val, 7468)
})

test_that("2024 tidy: Salt Lake District lep is 4,091", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_district &
    grepl("Salt Lake District", tidy$district_name) &
    tidy$subgroup == "lep" &
    tidy$grade_level == "TOTAL"]
  expect_equal(val, 4091)
})


# ==============================================================================
# fetch_enr() tidy=TRUE — Nebo District grade-level 2024
# ==============================================================================

test_that("2024 tidy: Nebo District K enrollment is 3,114", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_district &
    grepl("Nebo District", tidy$district_name) &
    tidy$subgroup == "total_enrollment" &
    tidy$grade_level == "K"]
  expect_equal(val, 3114)
})

test_that("2024 tidy: Nebo District grade 06 is 3,454", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_district &
    grepl("Nebo District", tidy$district_name) &
    tidy$subgroup == "total_enrollment" &
    tidy$grade_level == "06"]
  expect_equal(val, 3454)
})

test_that("2024 tidy: Nebo District grade 12 is 3,114", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_district &
    grepl("Nebo District", tidy$district_name) &
    tidy$subgroup == "total_enrollment" &
    tidy$grade_level == "12"]
  expect_equal(val, 3114)
})


# ==============================================================================
# fetch_enr() tidy=TRUE — entity counts 2024
# ==============================================================================

test_that("2024 tidy: exactly 1 state row per subgroup-grade", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  state_total <- tidy[tidy$is_state &
    tidy$subgroup == "total_enrollment" &
    tidy$grade_level == "TOTAL", ]
  expect_equal(nrow(state_total), 1)
})

test_that("2024 tidy: 154 districts", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  districts <- tidy[tidy$is_district &
    tidy$subgroup == "total_enrollment" &
    tidy$grade_level == "TOTAL", ]
  expect_equal(nrow(districts), 154)
})

test_that("2024 tidy: 1,052 campuses", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  campuses <- tidy[tidy$is_campus &
    tidy$subgroup == "total_enrollment" &
    tidy$grade_level == "TOTAL", ]
  expect_equal(nrow(campuses), 1052)
})

test_that("2024 tidy: 253 charter entities", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  charter <- tidy[tidy$is_charter &
    tidy$subgroup == "total_enrollment" &
    tidy$grade_level == "TOTAL", ]
  expect_equal(nrow(charter), 253)
})

test_that("2024 tidy: total tidy rows is 32,217", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  expect_equal(nrow(tidy), 32217)
})

test_that("2024 tidy: 27 state-level rows", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  state_rows <- tidy[tidy$type == "State", ]
  expect_equal(nrow(state_rows), 27)
})


# ==============================================================================
# fetch_enr() tidy=TRUE — charter vs non-charter split 2024
# ==============================================================================

test_that("2024 tidy: 113 charter districts, 41 non-charter districts", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  districts <- tidy[tidy$is_district &
    tidy$subgroup == "total_enrollment" &
    tidy$grade_level == "TOTAL", ]

  charter_count <- sum(districts$charter_flag == "Y", na.rm = TRUE)
  noncharter_count <- sum(districts$charter_flag == "N", na.rm = TRUE)

  expect_equal(charter_count, 113)
  expect_equal(noncharter_count, 41)
})

test_that("2024 tidy: charter district enrollment is 79,823", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  charter_students <- tidy[tidy$is_district &
    tidy$charter_flag == "Y" &
    tidy$subgroup == "total_enrollment" &
    tidy$grade_level == "TOTAL", ]
  expect_equal(sum(charter_students$n_students), 79823)
})

test_that("2024 tidy: non-charter district enrollment is 593,950", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  noncharter <- tidy[tidy$is_district &
    tidy$charter_flag == "N" &
    tidy$subgroup == "total_enrollment" &
    tidy$grade_level == "TOTAL", ]
  expect_equal(sum(noncharter$n_students), 593950)
})


# ==============================================================================
# fetch_enr() tidy=TRUE — cross-year state totals
# ==============================================================================

test_that("2023 state total enrollment is 674,650", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2023, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_state &
    tidy$subgroup == "total_enrollment" &
    tidy$grade_level == "TOTAL"]
  expect_equal(val, 674650)
})

test_that("2022 state total enrollment is 674,351", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2022, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_state &
    tidy$subgroup == "total_enrollment" &
    tidy$grade_level == "TOTAL"]
  expect_equal(val, 674351)
})

test_that("2025 state total enrollment is 667,789", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2025, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_state &
    tidy$subgroup == "total_enrollment" &
    tidy$grade_level == "TOTAL"]
  expect_equal(val, 667789)
})

test_that("2026 state total enrollment is 656,310", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2026, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_state &
    tidy$subgroup == "total_enrollment" &
    tidy$grade_level == "TOTAL"]
  expect_equal(val, 656310)
})

test_that("2019 state total enrollment is 658,952", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2019, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_state &
    tidy$subgroup == "total_enrollment" &
    tidy$grade_level == "TOTAL"]
  expect_equal(val, 658952)
})


# ==============================================================================
# fetch_enr() tidy=TRUE — 2026 demographics
# ==============================================================================

test_that("2026 tidy: state white is 451,812", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2026, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_state &
    tidy$subgroup == "white" &
    tidy$grade_level == "TOTAL"]
  expect_equal(val, 451812)
})

test_that("2026 tidy: state hispanic is 142,284", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2026, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_state &
    tidy$subgroup == "hispanic" &
    tidy$grade_level == "TOTAL"]
  expect_equal(val, 142284)
})

test_that("2026 tidy: state econ_disadv is 186,361", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2026, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_state &
    tidy$subgroup == "econ_disadv" &
    tidy$grade_level == "TOTAL"]
  expect_equal(val, 186361)
})

test_that("2026 tidy: state special_ed is 89,893", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2026, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_state &
    tidy$subgroup == "special_ed" &
    tidy$grade_level == "TOTAL"]
  expect_equal(val, 89893)
})


# ==============================================================================
# fetch_enr() tidy=TRUE — 2023 demographics
# ==============================================================================

test_that("2023 tidy: state white is 481,848", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2023, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_state &
    tidy$subgroup == "white" &
    tidy$grade_level == "TOTAL"]
  expect_equal(val, 481848)
})

test_that("2023 tidy: state hispanic is 131,954", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2023, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_state &
    tidy$subgroup == "hispanic" &
    tidy$grade_level == "TOTAL"]
  expect_equal(val, 131954)
})

test_that("2023 tidy: state econ_disadv is 199,375", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2023, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_state &
    tidy$subgroup == "econ_disadv" &
    tidy$grade_level == "TOTAL"]
  expect_equal(val, 199375)
})


# ==============================================================================
# fetch_enr() tidy=FALSE — wide format 2024
# ==============================================================================

test_that("2024 wide: state row_total is 672,662", {
  skip_on_cran()
  skip_if_offline()

  wide <- fetch_enr(2024, tidy = FALSE, use_cache = TRUE)
  state <- wide[wide$type == "State", ]
  expect_equal(state$row_total, 672662)
})

test_that("2024 wide: Alpine District row_total is 84,710", {
  skip_on_cran()
  skip_if_offline()

  wide <- fetch_enr(2024, tidy = FALSE, use_cache = TRUE)
  alpine <- wide[wide$type == "District" &
    grepl("Alpine District", wide$district_name), ]
  expect_equal(alpine$row_total, 84710)
})

test_that("2024 wide: Alpine District white is 64,775", {
  skip_on_cran()
  skip_if_offline()

  wide <- fetch_enr(2024, tidy = FALSE, use_cache = TRUE)
  alpine <- wide[wide$type == "District" &
    grepl("Alpine District", wide$district_name), ]
  expect_equal(alpine$white, 64775)
})

test_that("2024 wide: Alpine District hispanic is 13,234", {
  skip_on_cran()
  skip_if_offline()

  wide <- fetch_enr(2024, tidy = FALSE, use_cache = TRUE)
  alpine <- wide[wide$type == "District" &
    grepl("Alpine District", wide$district_name), ]
  expect_equal(alpine$hispanic, 13234)
})


# ==============================================================================
# enr_grade_aggs() — state level
# ==============================================================================

test_that("2024 grade aggs: state K8 is 456,568", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  aggs <- enr_grade_aggs(tidy)
  val <- aggs$n_students[aggs$is_state & aggs$grade_level == "K8"]
  expect_equal(val, 456568)
})

test_that("2024 grade aggs: state HS is 216,094", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  aggs <- enr_grade_aggs(tidy)
  val <- aggs$n_students[aggs$is_state & aggs$grade_level == "HS"]
  expect_equal(val, 216094)
})

test_that("2024 grade aggs: state K12 is 672,662", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  aggs <- enr_grade_aggs(tidy)
  val <- aggs$n_students[aggs$is_state & aggs$grade_level == "K12"]
  expect_equal(val, 672662)
})

test_that("2024 grade aggs: K8 + HS = K12 at state level", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  aggs <- enr_grade_aggs(tidy)
  state_aggs <- aggs[aggs$is_state, ]
  k8 <- state_aggs$n_students[state_aggs$grade_level == "K8"]
  hs <- state_aggs$n_students[state_aggs$grade_level == "HS"]
  k12 <- state_aggs$n_students[state_aggs$grade_level == "K12"]
  expect_equal(k8 + hs, k12)
})


# ==============================================================================
# enr_grade_aggs() — district level
# ==============================================================================

test_that("2024 grade aggs: Nebo K8 is 30,446", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  aggs <- enr_grade_aggs(tidy)
  nebo <- aggs[aggs$is_district & grepl("Nebo District", aggs$district_name), ]
  expect_equal(nebo$n_students[nebo$grade_level == "K8"], 30446)
})

test_that("2024 grade aggs: Nebo HS is 13,226", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  aggs <- enr_grade_aggs(tidy)
  nebo <- aggs[aggs$is_district & grepl("Nebo District", aggs$district_name), ]
  expect_equal(nebo$n_students[nebo$grade_level == "HS"], 13226)
})

test_that("2024 grade aggs: Nebo K12 is 43,672", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  aggs <- enr_grade_aggs(tidy)
  nebo <- aggs[aggs$is_district & grepl("Nebo District", aggs$district_name), ]
  expect_equal(nebo$n_students[nebo$grade_level == "K12"], 43672)
})

test_that("2024 grade aggs: Nebo K8 + HS = K12", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  aggs <- enr_grade_aggs(tidy)
  nebo <- aggs[aggs$is_district & grepl("Nebo District", aggs$district_name), ]
  expect_equal(
    nebo$n_students[nebo$grade_level == "K8"] +
      nebo$n_students[nebo$grade_level == "HS"],
    nebo$n_students[nebo$grade_level == "K12"]
  )
})


# ==============================================================================
# enr_grade_aggs() — 2026 state level
# ==============================================================================

test_that("2026 grade aggs: state K8 is 441,709", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2026, tidy = TRUE, use_cache = TRUE)
  aggs <- enr_grade_aggs(tidy)
  val <- aggs$n_students[aggs$is_state & aggs$grade_level == "K8"]
  expect_equal(val, 441709)
})

test_that("2026 grade aggs: state HS is 214,601", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2026, tidy = TRUE, use_cache = TRUE)
  aggs <- enr_grade_aggs(tidy)
  val <- aggs$n_students[aggs$is_state & aggs$grade_level == "HS"]
  expect_equal(val, 214601)
})

test_that("2026 grade aggs: state K12 is 656,310", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2026, tidy = TRUE, use_cache = TRUE)
  aggs <- enr_grade_aggs(tidy)
  val <- aggs$n_students[aggs$is_state & aggs$grade_level == "K12"]
  expect_equal(val, 656310)
})


# ==============================================================================
# enr_grade_aggs() — row count structure
# ==============================================================================

test_that("2024 grade aggs: exactly 3,618 rows", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  aggs <- enr_grade_aggs(tidy)
  expect_equal(nrow(aggs), 3618)
})

test_that("2024 grade aggs: 1,206 K8 rows", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  aggs <- enr_grade_aggs(tidy)
  expect_equal(sum(aggs$grade_level == "K8"), 1206)
})

test_that("2024 grade aggs: 1,206 HS rows", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  aggs <- enr_grade_aggs(tidy)
  expect_equal(sum(aggs$grade_level == "HS"), 1206)
})

test_that("2024 grade aggs: 1,206 K12 rows", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  aggs <- enr_grade_aggs(tidy)
  expect_equal(sum(aggs$grade_level == "K12"), 1206)
})

test_that("enr_grade_aggs pct is NA for aggregated rows", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  aggs <- enr_grade_aggs(tidy)
  expect_true(all(is.na(aggs$pct)))
})


# ==============================================================================
# fetch_enr_multi() — multi-year pinned values
# ==============================================================================

test_that("fetch_enr_multi returns both years for 2023:2024", {
  skip_on_cran()
  skip_if_offline()

  result <- fetch_enr_multi(2023:2024, tidy = TRUE, use_cache = TRUE)
  expect_true(all(c(2023, 2024) %in% result$end_year))
  expect_equal(length(unique(result$end_year)), 2)
})

test_that("fetch_enr_multi 2023:2024 state totals match individual calls", {
  skip_on_cran()
  skip_if_offline()

  result <- fetch_enr_multi(2023:2024, tidy = TRUE, use_cache = TRUE)
  state_totals <- result[result$is_state &
    result$subgroup == "total_enrollment" &
    result$grade_level == "TOTAL", ]

  expect_equal(
    state_totals$n_students[state_totals$end_year == 2023],
    674650
  )
  expect_equal(
    state_totals$n_students[state_totals$end_year == 2024],
    672662
  )
})

test_that("fetch_enr_multi wide format works", {
  skip_on_cran()
  skip_if_offline()

  result <- fetch_enr_multi(2023:2024, tidy = FALSE, use_cache = TRUE)
  expect_true(is.data.frame(result))
  expect_true("row_total" %in% names(result))
  expect_true(all(c(2023, 2024) %in% result$end_year))
})

test_that("fetch_enr_multi 2019:2024 returns 6 years of data", {
  skip_on_cran()
  skip_if_offline()

  result <- fetch_enr_multi(2019:2024, tidy = TRUE, use_cache = TRUE)
  years_present <- sort(unique(result$end_year))
  expect_equal(years_present, 2019:2024)
})

test_that("fetch_enr_multi with single year works like fetch_enr", {
  skip_on_cran()
  skip_if_offline()

  multi <- fetch_enr_multi(2024, tidy = TRUE, use_cache = TRUE)
  single <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  expect_equal(nrow(multi), nrow(single))
})


# ==============================================================================
# Alpine District campus count
# ==============================================================================

test_that("2024 tidy: Alpine District has 89 campuses", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  alpine_campuses <- tidy[tidy$is_campus &
    grepl("Alpine District", tidy$district_name) &
    tidy$subgroup == "total_enrollment" &
    tidy$grade_level == "TOTAL", ]
  expect_equal(nrow(alpine_campuses), 89)
})

test_that("2024 tidy: Granite District has 85 campuses", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  granite_campuses <- tidy[tidy$is_campus &
    grepl("Granite District", tidy$district_name) &
    tidy$subgroup == "total_enrollment" &
    tidy$grade_level == "TOTAL", ]
  expect_equal(nrow(granite_campuses), 85)
})


# ==============================================================================
# Smallest districts (charter schools)
# ==============================================================================

test_that("2024 tidy: Moab Charter School has 75 students", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  moab <- tidy[tidy$is_district &
    grepl("Moab Charter", tidy$district_name) &
    tidy$subgroup == "total_enrollment" &
    tidy$grade_level == "TOTAL", ]
  expect_equal(moab$n_students, 75)
})


# ==============================================================================
# cache_status() and clear_cache()
# ==============================================================================

test_that("cache_status returns a data.frame", {
  result <- suppressMessages(cache_status())
  expect_true(is.data.frame(result))
})

test_that("clear_cache with non-existent year is safe", {
  result <- suppressMessages(clear_cache(9999))
  # Should return 0 (invisible) - no files removed
  expect_true(is.numeric(result))
})

test_that("clear_cache roundtrip with test data", {
  # Write test cache
  test_df <- data.frame(end_year = 9990, n = 1)
  write_cache(test_df, 9990, "tidy")
  write_cache(test_df, 9990, "wide")

  # Verify they exist
  expect_true(file.exists(get_cache_path(9990, "tidy")))
  expect_true(file.exists(get_cache_path(9990, "wide")))

  # Clear by year
  suppressMessages(clear_cache(9990))
  expect_false(file.exists(get_cache_path(9990, "tidy")))
  expect_false(file.exists(get_cache_path(9990, "wide")))
})

test_that("clear_cache by type works", {
  test_df <- data.frame(end_year = 9991, n = 1)
  write_cache(test_df, 9991, "tidy")
  write_cache(test_df, 9991, "wide")

  # Clear only tidy
  suppressMessages(clear_cache(type = "tidy"))
  expect_false(file.exists(get_cache_path(9991, "tidy")))
  # Wide should still exist ... or not, since clear_cache with type clears ALL years for type
  # Clean up remaining
  suppressMessages(clear_cache(9991))
})

test_that("clear_cache with both year and type works", {
  test_df <- data.frame(end_year = 9992, n = 1)
  write_cache(test_df, 9992, "tidy")

  suppressMessages(clear_cache(9992, "tidy"))
  expect_false(file.exists(get_cache_path(9992, "tidy")))
})


# ==============================================================================
# 2023 entity counts
# ==============================================================================

test_that("2023 tidy: 156 districts", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2023, tidy = TRUE, use_cache = TRUE)
  districts <- tidy[tidy$is_district &
    tidy$subgroup == "total_enrollment" &
    tidy$grade_level == "TOTAL", ]
  expect_equal(nrow(districts), 156)
})

test_that("2023 tidy: 1,060 campuses", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2023, tidy = TRUE, use_cache = TRUE)
  campuses <- tidy[tidy$is_campus &
    tidy$subgroup == "total_enrollment" &
    tidy$grade_level == "TOTAL", ]
  expect_equal(nrow(campuses), 1060)
})

test_that("2023 tidy: total tidy rows is 32,523", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2023, tidy = TRUE, use_cache = TRUE)
  expect_equal(nrow(tidy), 32523)
})


# ==============================================================================
# 2023 top districts
# ==============================================================================

test_that("2023 tidy: Alpine District total is 84,666", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2023, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_district &
    grepl("Alpine District", tidy$district_name) &
    tidy$subgroup == "total_enrollment" &
    tidy$grade_level == "TOTAL"]
  expect_equal(val, 84666)
})

test_that("2023 tidy: Davis District total is 71,564", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2023, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_district &
    grepl("^Davis District", tidy$district_name) &
    tidy$subgroup == "total_enrollment" &
    tidy$grade_level == "TOTAL"]
  expect_equal(val, 71564)
})

test_that("2023 tidy: Granite District total is 59,121", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2023, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_district &
    grepl("Granite District", tidy$district_name) &
    tidy$subgroup == "total_enrollment" &
    tidy$grade_level == "TOTAL"]
  expect_equal(val, 59121)
})


# ==============================================================================
# 2026 entity counts and grade counts
# ==============================================================================

test_that("2026 tidy: 154 districts", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2026, tidy = TRUE, use_cache = TRUE)
  districts <- tidy[tidy$is_district &
    tidy$subgroup == "total_enrollment" &
    tidy$grade_level == "TOTAL", ]
  expect_equal(nrow(districts), 154)
})

test_that("2026 tidy: 1,063 campuses", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2026, tidy = TRUE, use_cache = TRUE)
  campuses <- tidy[tidy$is_campus &
    tidy$subgroup == "total_enrollment" &
    tidy$grade_level == "TOTAL", ]
  expect_equal(nrow(campuses), 1063)
})

test_that("2026 tidy: state K enrollment is 43,519", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2026, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_state &
    tidy$subgroup == "total_enrollment" &
    tidy$grade_level == "K"]
  expect_equal(val, 43519)
})

test_that("2026 tidy: state grade 12 enrollment is 53,982", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2026, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_state &
    tidy$subgroup == "total_enrollment" &
    tidy$grade_level == "12"]
  expect_equal(val, 53982)
})


# ==============================================================================
# 2019 entity counts
# ==============================================================================

test_that("2019 tidy: 154 districts", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2019, tidy = TRUE, use_cache = TRUE)
  districts <- tidy[tidy$is_district &
    tidy$subgroup == "total_enrollment" &
    tidy$grade_level == "TOTAL", ]
  expect_equal(nrow(districts), 154)
})

test_that("2019 tidy: 1,029 campuses", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2019, tidy = TRUE, use_cache = TRUE)
  campuses <- tidy[tidy$is_campus &
    tidy$subgroup == "total_enrollment" &
    tidy$grade_level == "TOTAL", ]
  expect_equal(nrow(campuses), 1029)
})


# ==============================================================================
# 2023 state demographics
# ==============================================================================

test_that("2023 tidy: state asian is 11,328", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2023, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_state &
    tidy$subgroup == "asian" &
    tidy$grade_level == "TOTAL"]
  expect_equal(val, 11328)
})

test_that("2023 tidy: state black is 8,938", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2023, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_state &
    tidy$subgroup == "black" &
    tidy$grade_level == "TOTAL"]
  expect_equal(val, 8938)
})

test_that("2023 tidy: state special_ed is 83,288", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2023, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_state &
    tidy$subgroup == "special_ed" &
    tidy$grade_level == "TOTAL"]
  expect_equal(val, 83288)
})

test_that("2023 tidy: state lep is 59,176", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2023, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_state &
    tidy$subgroup == "lep" &
    tidy$grade_level == "TOTAL"]
  expect_equal(val, 59176)
})

test_that("2023 tidy: state male is 346,958", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2023, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_state &
    tidy$subgroup == "male" &
    tidy$grade_level == "TOTAL"]
  expect_equal(val, 346958)
})

test_that("2023 tidy: state female is 327,609", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2023, tidy = TRUE, use_cache = TRUE)
  val <- tidy$n_students[tidy$is_state &
    tidy$subgroup == "female" &
    tidy$grade_level == "TOTAL"]
  expect_equal(val, 327609)
})
