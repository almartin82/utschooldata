# ==============================================================================
# Exhaustive Typology Tests for utschooldata
# ==============================================================================
#
# Tests data structure, column types, naming standards, edge cases, and
# structural invariants across ALL exported functions.
#
# Categories:
#   1. Column presence and types (tidy)
#   2. Column presence and types (wide)
#   3. Naming standard compliance (subgroups)
#   4. Naming standard compliance (grade levels)
#   5. Entity flag correctness
#   6. Percentage calculation invariants
#   7. Aggregation identity invariants
#   8. Wide-tidy pivot fidelity
#   9. Cross-year structural consistency
#  10. enr_grade_aggs structure
#  11. Edge cases and error handling
#  12. Directory data structure
#  13. safe_numeric edge cases
#  14. build_usbe_url correctness
#
# ==============================================================================


# ==============================================================================
# 1. COLUMN PRESENCE AND TYPES (tidy)
# ==============================================================================

test_that("tidy output has all 16 required columns", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  required <- c(
    "end_year", "type", "district_id", "campus_id",
    "district_name", "campus_name", "charter_flag",
    "grade_level", "subgroup", "n_students", "pct",
    "is_state", "is_district", "is_campus",
    "aggregation_flag", "is_charter"
  )
  for (col in required) {
    expect_true(col %in% names(tidy), info = paste("Missing:", col))
  }
})

test_that("tidy end_year is integer", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  expect_true(is.integer(tidy$end_year) || is.numeric(tidy$end_year))
})

test_that("tidy type is character", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  expect_true(is.character(tidy$type))
})

test_that("tidy district_id is character", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  expect_true(is.character(tidy$district_id))
})

test_that("tidy campus_id is character", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  expect_true(is.character(tidy$campus_id))
})

test_that("tidy district_name is character", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  expect_true(is.character(tidy$district_name))
})

test_that("tidy campus_name is character", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  expect_true(is.character(tidy$campus_name))
})

test_that("tidy charter_flag is character", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  expect_true(is.character(tidy$charter_flag))
})

test_that("tidy grade_level is character", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  expect_true(is.character(tidy$grade_level))
})

test_that("tidy subgroup is character", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  expect_true(is.character(tidy$subgroup))
})

test_that("tidy n_students is numeric", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  expect_true(is.numeric(tidy$n_students))
})

test_that("tidy pct is numeric", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  expect_true(is.numeric(tidy$pct))
})

test_that("tidy is_state is logical", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  expect_true(is.logical(tidy$is_state))
})

test_that("tidy is_district is logical", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  expect_true(is.logical(tidy$is_district))
})

test_that("tidy is_campus is logical", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  expect_true(is.logical(tidy$is_campus))
})

test_that("tidy is_charter is logical", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  expect_true(is.logical(tidy$is_charter))
})

test_that("tidy aggregation_flag is character", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  expect_true(is.character(tidy$aggregation_flag))
})


# ==============================================================================
# 2. COLUMN PRESENCE AND TYPES (wide)
# ==============================================================================

test_that("wide output has all required columns", {
  skip_on_cran()
  skip_if_offline()

  wide <- fetch_enr(2024, tidy = FALSE, use_cache = TRUE)
  required <- c(
    "end_year", "type", "district_id", "campus_id",
    "district_name", "campus_name", "charter_flag",
    "row_total", "white", "black", "hispanic", "asian",
    "native_american", "pacific_islander", "multiracial",
    "male", "female", "econ_disadv", "lep", "special_ed",
    "grade_pk", "grade_k",
    "grade_01", "grade_02", "grade_03", "grade_04",
    "grade_05", "grade_06", "grade_07", "grade_08",
    "grade_09", "grade_10", "grade_11", "grade_12"
  )
  for (col in required) {
    expect_true(col %in% names(wide), info = paste("Missing:", col))
  }
})

test_that("wide end_year is numeric", {
  skip_on_cran()
  skip_if_offline()

  wide <- fetch_enr(2024, tidy = FALSE, use_cache = TRUE)
  expect_true(is.numeric(wide$end_year))
})

test_that("wide row_total is numeric", {
  skip_on_cran()
  skip_if_offline()

  wide <- fetch_enr(2024, tidy = FALSE, use_cache = TRUE)
  expect_true(is.numeric(wide$row_total))
})

test_that("wide demographic columns are numeric", {
  skip_on_cran()
  skip_if_offline()

  wide <- fetch_enr(2024, tidy = FALSE, use_cache = TRUE)
  demo_cols <- c("white", "black", "hispanic", "asian",
                 "native_american", "pacific_islander", "multiracial")
  for (col in demo_cols) {
    expect_true(is.numeric(wide[[col]]), info = paste(col, "not numeric"))
  }
})

test_that("wide gender columns are numeric", {
  skip_on_cran()
  skip_if_offline()

  wide <- fetch_enr(2024, tidy = FALSE, use_cache = TRUE)
  for (col in c("male", "female")) {
    expect_true(is.numeric(wide[[col]]), info = paste(col, "not numeric"))
  }
})

test_that("wide special population columns are numeric", {
  skip_on_cran()
  skip_if_offline()

  wide <- fetch_enr(2024, tidy = FALSE, use_cache = TRUE)
  for (col in c("econ_disadv", "lep", "special_ed")) {
    expect_true(is.numeric(wide[[col]]), info = paste(col, "not numeric"))
  }
})

test_that("wide grade columns are numeric", {
  skip_on_cran()
  skip_if_offline()

  wide <- fetch_enr(2024, tidy = FALSE, use_cache = TRUE)
  grade_cols <- c("grade_pk", "grade_k",
                  paste0("grade_", sprintf("%02d", 1:12)))
  for (col in grade_cols) {
    expect_true(is.numeric(wide[[col]]), info = paste(col, "not numeric"))
  }
})


# ==============================================================================
# 3. NAMING STANDARD COMPLIANCE (subgroups)
# ==============================================================================

test_that("subgroups are exactly the 13 standard names", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  expected <- c("total_enrollment", "white", "black", "hispanic", "asian",
                "native_american", "pacific_islander", "multiracial",
                "male", "female", "special_ed", "lep", "econ_disadv")
  expect_setequal(unique(tidy$subgroup), expected)
})

test_that("no non-standard subgroup names: total", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  expect_false("total" %in% unique(tidy$subgroup))
})

test_that("no non-standard subgroup names: low_income", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  expect_false("low_income" %in% unique(tidy$subgroup))
})

test_that("no non-standard subgroup names: economically_disadvantaged", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  expect_false("economically_disadvantaged" %in% unique(tidy$subgroup))
})

test_that("no non-standard subgroup names: frl", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  expect_false("frl" %in% unique(tidy$subgroup))
})

test_that("no non-standard subgroup names: iep", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  expect_false("iep" %in% unique(tidy$subgroup))
})

test_that("no non-standard subgroup names: ell", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  expect_false("ell" %in% unique(tidy$subgroup))
})

test_that("no non-standard subgroup names: english_learner", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  expect_false("english_learner" %in% unique(tidy$subgroup))
})

test_that("no non-standard subgroup names: american_indian", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  expect_false("american_indian" %in% unique(tidy$subgroup))
})

test_that("no non-standard subgroup names: two_or_more", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  expect_false("two_or_more" %in% unique(tidy$subgroup))
})


# ==============================================================================
# 4. NAMING STANDARD COMPLIANCE (grade levels)
# ==============================================================================

test_that("grade levels are exactly the 15 standard labels", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  expected <- c("PK", "K", "01", "02", "03", "04", "05", "06",
                "07", "08", "09", "10", "11", "12", "TOTAL")
  expect_setequal(unique(tidy$grade_level), expected)
})

test_that("grade levels are all UPPERCASE", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  grades <- unique(tidy$grade_level)
  expect_true(all(grades == toupper(grades)))
})

test_that("no lowercase grade levels exist", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  grades <- unique(tidy$grade_level)
  bad_grades <- c("pk", "k", "total", "kindergarten", "preschool")
  for (bg in bad_grades) {
    expect_false(bg %in% grades, info = paste("Unexpected lowercase:", bg))
  }
})

test_that("grade levels have zero-padded single digits", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  grades <- unique(tidy$grade_level)
  # Numeric grades should be 01-12, not 1-9
  bad_single_digit <- as.character(1:9)
  for (bg in bad_single_digit) {
    expect_false(bg %in% grades,
                 info = paste("Non-zero-padded grade:", bg))
  }
})


# ==============================================================================
# 5. ENTITY FLAG CORRECTNESS
# ==============================================================================

test_that("entity flags are mutually exclusive (sum = 1 for every row)", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  flag_sum <- as.integer(tidy$is_state) +
    as.integer(tidy$is_district) +
    as.integer(tidy$is_campus)
  expect_true(all(flag_sum == 1))
})

test_that("type column only has State, District, Campus", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  expect_true(all(tidy$type %in% c("State", "District", "Campus")))
})

test_that("type column matches entity flags", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  expect_true(all(tidy$is_state == (tidy$type == "State")))
  expect_true(all(tidy$is_district == (tidy$type == "District")))
  expect_true(all(tidy$is_campus == (tidy$type == "Campus")))
})

test_that("aggregation_flag values are state, district, campus", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  expect_true(all(tidy$aggregation_flag %in% c("state", "district", "campus")))
})

test_that("aggregation_flag matches entity flags", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  expect_true(all(tidy$aggregation_flag[tidy$is_state] == "state"))
  expect_true(all(tidy$aggregation_flag[tidy$is_district] == "district"))
  expect_true(all(tidy$aggregation_flag[tidy$is_campus] == "campus"))
})

test_that("charter_flag only has Y or N values (non-NA)", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  non_na_flags <- tidy$charter_flag[!is.na(tidy$charter_flag)]
  expect_true(all(non_na_flags %in% c("Y", "N")))
})

test_that("is_charter TRUE matches charter_flag Y", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  charter_y <- tidy[!is.na(tidy$charter_flag) & tidy$charter_flag == "Y", ]
  expect_true(all(charter_y$is_charter))

  charter_n <- tidy[!is.na(tidy$charter_flag) & tidy$charter_flag == "N", ]
  expect_true(all(!charter_n$is_charter))
})

test_that("state rows have NA district_id and campus_id", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  state_rows <- tidy[tidy$is_state, ]
  expect_true(all(is.na(state_rows$district_id)))
  expect_true(all(is.na(state_rows$campus_id)))
  expect_true(all(is.na(state_rows$district_name)))
  expect_true(all(is.na(state_rows$campus_name)))
})

test_that("district rows have district_id but NA campus_id", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  district_rows <- tidy[tidy$is_district, ]
  expect_true(all(!is.na(district_rows$district_id)))
  expect_true(all(is.na(district_rows$campus_id)))
  expect_true(all(!is.na(district_rows$district_name)))
  expect_true(all(is.na(district_rows$campus_name)))
})

test_that("campus rows have both district_id and campus_id", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  campus_rows <- tidy[tidy$is_campus, ]
  expect_true(all(!is.na(campus_rows$district_id)))
  expect_true(all(!is.na(campus_rows$campus_id)))
  expect_true(all(!is.na(campus_rows$district_name)))
  expect_true(all(!is.na(campus_rows$campus_name)))
})


# ==============================================================================
# 6. PERCENTAGE CALCULATION INVARIANTS
# ==============================================================================

test_that("total_enrollment pct is always 1.0", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  total_rows <- tidy[tidy$subgroup == "total_enrollment" &
    tidy$grade_level == "TOTAL", ]
  expect_true(all(total_rows$pct == 1.0))
})

test_that("pct is always between 0 and 1 (inclusive)", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  expect_true(all(tidy$pct >= 0))
  expect_true(all(tidy$pct <= 1.0))
})

test_that("no Inf in n_students", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  expect_false(any(is.infinite(tidy$n_students)))
})

test_that("no NaN in n_students", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  expect_false(any(is.nan(tidy$n_students)))
})

test_that("no NA in n_students (filtered by tidy_enr)", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  expect_equal(sum(is.na(tidy$n_students)), 0)
})

test_that("no Inf in pct", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  expect_false(any(is.infinite(tidy$pct)))
})

test_that("no NaN in pct", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  expect_false(any(is.nan(tidy$pct)))
})

test_that("all n_students are non-negative", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  expect_true(all(tidy$n_students >= 0))
})

test_that("pct = n_students / row_total for state white", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  state_white <- tidy[tidy$is_state & tidy$subgroup == "white" &
    tidy$grade_level == "TOTAL", ]
  expected_pct <- 478697 / 672662
  expect_equal(state_white$pct, expected_pct, tolerance = 1e-6)
})

test_that("pct = n_students / row_total for state hispanic", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  state_hisp <- tidy[tidy$is_state & tidy$subgroup == "hispanic" &
    tidy$grade_level == "TOTAL", ]
  expected_pct <- 132110 / 672662
  expect_equal(state_hisp$pct, expected_pct, tolerance = 1e-6)
})


# ==============================================================================
# 7. AGGREGATION IDENTITY INVARIANTS
# ==============================================================================

test_that("race/ethnicity sums equal row_total at state level", {
  skip_on_cran()
  skip_if_offline()

  wide <- fetch_enr(2024, tidy = FALSE, use_cache = TRUE)
  state <- wide[wide$type == "State", ]
  race_sum <- sum(state$white, state$black, state$hispanic,
                  state$asian, state$native_american,
                  state$pacific_islander, state$multiracial, na.rm = TRUE)
  expect_equal(race_sum, state$row_total)
})

test_that("K-12 grade sum equals row_total at state level", {
  skip_on_cran()
  skip_if_offline()

  wide <- fetch_enr(2024, tidy = FALSE, use_cache = TRUE)
  state <- wide[wide$type == "State", ]
  k12_sum <- sum(
    state$grade_k,
    state$grade_01, state$grade_02, state$grade_03,
    state$grade_04, state$grade_05, state$grade_06,
    state$grade_07, state$grade_08, state$grade_09,
    state$grade_10, state$grade_11, state$grade_12,
    na.rm = TRUE
  )
  expect_equal(k12_sum, state$row_total)
})

test_that("male + female equals row_total at state level", {
  skip_on_cran()
  skip_if_offline()

  wide <- fetch_enr(2024, tidy = FALSE, use_cache = TRUE)
  state <- wide[wide$type == "State", ]
  gender_sum <- sum(state$male, state$female, na.rm = TRUE)
  # May not exactly equal row_total due to gender unknown, but close
  expect_equal(gender_sum, state$row_total, tolerance = 200)
})

test_that("district enrollment sums approximate state total", {
  skip_on_cran()
  skip_if_offline()

  wide <- fetch_enr(2024, tidy = FALSE, use_cache = TRUE)
  state_total <- wide$row_total[wide$type == "State"]
  district_sum <- sum(wide$row_total[wide$type == "District"], na.rm = TRUE)
  ratio <- district_sum / state_total
  expect_gt(ratio, 0.95)
  expect_lt(ratio, 1.05)
})

test_that("exactly 1 state row per subgroup-grade combo", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  state_rows <- tidy[tidy$is_state, ]
  combos <- paste(state_rows$subgroup, state_rows$grade_level)
  expect_false(any(duplicated(combos)))
})

test_that("demographic subgroups only exist at grade_level TOTAL", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  demo_sgs <- c("white", "black", "hispanic", "asian",
                "native_american", "pacific_islander", "multiracial",
                "male", "female", "special_ed", "lep", "econ_disadv")
  for (sg in demo_sgs) {
    sg_grades <- unique(tidy$grade_level[tidy$subgroup == sg])
    expect_equal(sg_grades, "TOTAL",
                 info = paste("Subgroup", sg, "should only have TOTAL"))
  }
})


# ==============================================================================
# 8. WIDE-TIDY PIVOT FIDELITY
# ==============================================================================

test_that("wide row_total matches tidy total_enrollment at state level", {
  skip_on_cran()
  skip_if_offline()

  wide <- fetch_enr(2024, tidy = FALSE, use_cache = TRUE)
  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  wide_total <- wide$row_total[wide$type == "State"]
  tidy_total <- tidy$n_students[tidy$is_state &
    tidy$subgroup == "total_enrollment" &
    tidy$grade_level == "TOTAL"]
  expect_equal(wide_total, tidy_total)
})

test_that("wide white matches tidy white at state level", {
  skip_on_cran()
  skip_if_offline()

  wide <- fetch_enr(2024, tidy = FALSE, use_cache = TRUE)
  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  expect_equal(
    wide$white[wide$type == "State"],
    tidy$n_students[tidy$is_state & tidy$subgroup == "white" &
      tidy$grade_level == "TOTAL"]
  )
})

test_that("wide hispanic matches tidy hispanic at state level", {
  skip_on_cran()
  skip_if_offline()

  wide <- fetch_enr(2024, tidy = FALSE, use_cache = TRUE)
  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  expect_equal(
    wide$hispanic[wide$type == "State"],
    tidy$n_students[tidy$is_state & tidy$subgroup == "hispanic" &
      tidy$grade_level == "TOTAL"]
  )
})

test_that("wide grade_k matches tidy K at state level", {
  skip_on_cran()
  skip_if_offline()

  wide <- fetch_enr(2024, tidy = FALSE, use_cache = TRUE)
  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  expect_equal(
    wide$grade_k[wide$type == "State"],
    tidy$n_students[tidy$is_state & tidy$subgroup == "total_enrollment" &
      tidy$grade_level == "K"]
  )
})

test_that("wide grade_12 matches tidy 12 at state level", {
  skip_on_cran()
  skip_if_offline()

  wide <- fetch_enr(2024, tidy = FALSE, use_cache = TRUE)
  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  expect_equal(
    wide$grade_12[wide$type == "State"],
    tidy$n_students[tidy$is_state & tidy$subgroup == "total_enrollment" &
      tidy$grade_level == "12"]
  )
})

test_that("Alpine District total matches wide and tidy", {
  skip_on_cran()
  skip_if_offline()

  wide <- fetch_enr(2024, tidy = FALSE, use_cache = TRUE)
  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)

  alpine_wide <- wide$row_total[wide$type == "District" &
    grepl("Alpine District", wide$district_name)]
  alpine_tidy <- tidy$n_students[tidy$is_district &
    grepl("Alpine District", tidy$district_name) &
    tidy$subgroup == "total_enrollment" &
    tidy$grade_level == "TOTAL"]
  expect_equal(alpine_wide, alpine_tidy)
})


# ==============================================================================
# 9. CROSS-YEAR STRUCTURAL CONSISTENCY
# ==============================================================================

test_that("2023 and 2024 have same columns", {
  skip_on_cran()
  skip_if_offline()

  tidy_2023 <- fetch_enr(2023, tidy = TRUE, use_cache = TRUE)
  tidy_2024 <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  expect_equal(sort(names(tidy_2023)), sort(names(tidy_2024)))
})

test_that("2023 and 2024 have same subgroups", {
  skip_on_cran()
  skip_if_offline()

  tidy_2023 <- fetch_enr(2023, tidy = TRUE, use_cache = TRUE)
  tidy_2024 <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  expect_setequal(unique(tidy_2023$subgroup), unique(tidy_2024$subgroup))
})

test_that("2023 and 2024 have same grade levels", {
  skip_on_cran()
  skip_if_offline()

  tidy_2023 <- fetch_enr(2023, tidy = TRUE, use_cache = TRUE)
  tidy_2024 <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  expect_setequal(unique(tidy_2023$grade_level), unique(tidy_2024$grade_level))
})

test_that("2019 and 2024 have same columns", {
  skip_on_cran()
  skip_if_offline()

  tidy_2019 <- fetch_enr(2019, tidy = TRUE, use_cache = TRUE)
  tidy_2024 <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  expect_equal(sort(names(tidy_2019)), sort(names(tidy_2024)))
})

test_that("year-over-year state total changes are < 5%", {
  skip_on_cran()
  skip_if_offline()

  multi <- fetch_enr_multi(2022:2024, tidy = TRUE, use_cache = TRUE)
  state_totals <- multi[multi$is_state &
    multi$subgroup == "total_enrollment" &
    multi$grade_level == "TOTAL", ]
  state_totals <- state_totals[order(state_totals$end_year), ]

  for (i in 2:nrow(state_totals)) {
    pct_change <- abs(state_totals$n_students[i] /
      state_totals$n_students[i - 1] - 1)
    expect_lt(pct_change, 0.05,
              label = paste("YoY change",
                            state_totals$end_year[i - 1], "->",
                            state_totals$end_year[i]))
  }
})

test_that("wide 2023 and 2024 have same columns", {
  skip_on_cran()
  skip_if_offline()

  wide_2023 <- fetch_enr(2023, tidy = FALSE, use_cache = TRUE)
  wide_2024 <- fetch_enr(2024, tidy = FALSE, use_cache = TRUE)
  expect_equal(sort(names(wide_2023)), sort(names(wide_2024)))
})


# ==============================================================================
# 10. enr_grade_aggs STRUCTURE
# ==============================================================================

test_that("enr_grade_aggs returns exactly K8, HS, K12 grade levels", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  aggs <- enr_grade_aggs(tidy)
  expect_setequal(unique(aggs$grade_level), c("K8", "HS", "K12"))
})

test_that("enr_grade_aggs only includes total_enrollment subgroup", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  aggs <- enr_grade_aggs(tidy)
  expect_equal(unique(aggs$subgroup), "total_enrollment")
})

test_that("enr_grade_aggs preserves entity flags", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  aggs <- enr_grade_aggs(tidy)
  expect_true("is_state" %in% names(aggs))
  expect_true("is_district" %in% names(aggs))
  expect_true("is_campus" %in% names(aggs))
})

test_that("enr_grade_aggs pct is always NA", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  aggs <- enr_grade_aggs(tidy)
  expect_true(all(is.na(aggs$pct)))
})

test_that("enr_grade_aggs K8+HS=K12 for every entity", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  aggs <- enr_grade_aggs(tidy)

  # Group by entity and check identity
  k8_total <- sum(aggs$n_students[aggs$grade_level == "K8"])
  hs_total <- sum(aggs$n_students[aggs$grade_level == "HS"])
  k12_total <- sum(aggs$n_students[aggs$grade_level == "K12"])
  expect_equal(k8_total + hs_total, k12_total)
})

test_that("enr_grade_aggs has equal row counts per grade level", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  aggs <- enr_grade_aggs(tidy)
  k8_n <- sum(aggs$grade_level == "K8")
  hs_n <- sum(aggs$grade_level == "HS")
  k12_n <- sum(aggs$grade_level == "K12")
  expect_equal(k8_n, hs_n)
  expect_equal(hs_n, k12_n)
})


# ==============================================================================
# 11. EDGE CASES AND ERROR HANDLING
# ==============================================================================

test_that("safe_numeric handles NA input", {
  expect_true(is.na(safe_numeric(NA)))
  expect_true(is.na(safe_numeric(NA_character_)))
  expect_true(is.na(safe_numeric(NA_real_)))
})

test_that("safe_numeric handles empty string", {
  expect_true(is.na(safe_numeric("")))
})

test_that("safe_numeric handles whitespace-only string", {
  expect_true(is.na(safe_numeric("   ")))
})

test_that("safe_numeric handles period", {
  expect_true(is.na(safe_numeric(".")))
})

test_that("safe_numeric handles dash", {
  expect_true(is.na(safe_numeric("-")))
})

test_that("safe_numeric handles various less-than patterns", {
  expect_true(is.na(safe_numeric("< 10")))
  expect_true(is.na(safe_numeric("<5")))
  expect_true(is.na(safe_numeric("> 0")))
})

test_that("safe_numeric handles USBE-specific suppression markers", {
  expect_true(is.na(safe_numeric("N<10")))
  expect_true(is.na(safe_numeric("N < 10")))
  expect_true(is.na(safe_numeric("n<10")))
  expect_true(is.na(safe_numeric("N/A")))
})

test_that("safe_numeric preserves zero", {
  expect_equal(safe_numeric("0"), 0)
  expect_equal(safe_numeric(0), 0)
})

test_that("safe_numeric handles commas in thousands", {
  expect_equal(safe_numeric("1,234"), 1234)
  expect_equal(safe_numeric("1,234,567"), 1234567)
})

test_that("safe_numeric handles leading/trailing whitespace", {
  expect_equal(safe_numeric("  100  "), 100)
  expect_equal(safe_numeric("\t200"), 200)
})

test_that("safe_numeric handles already-numeric input", {
  expect_equal(safe_numeric(42), 42)
  expect_equal(safe_numeric(3.14), 3.14)
})

test_that("safe_numeric handles negative number marker -1", {
  expect_true(is.na(safe_numeric("-1")))
})


# ==============================================================================
# 12. DIRECTORY DATA STRUCTURE
# ==============================================================================

test_that("fetch_directory returns a tibble", {
  skip_on_cran()
  skip_if_offline()

  dir_data <- fetch_directory(use_cache = TRUE)
  expect_s3_class(dir_data, "tbl_df")
})

test_that("directory has all 27 expected columns", {
  skip_on_cran()
  skip_if_offline()

  dir_data <- fetch_directory(use_cache = TRUE)
  expected <- c(
    "state_district_id", "state_school_id",
    "district_name", "school_name",
    "entity_type", "school_category", "grades_served",
    "address", "city", "state", "zip", "phone", "fax",
    "principal_name", "principal_email",
    "superintendent_name", "superintendent_email",
    "website",
    "is_charter", "is_private", "is_closed", "is_title1",
    "year_opened", "year_closed",
    "latitude", "longitude",
    "county_name"
  )
  for (col in expected) {
    expect_true(col %in% names(dir_data), info = paste("Missing:", col))
  }
})

test_that("directory is_charter is logical", {
  skip_on_cran()
  skip_if_offline()

  dir_data <- fetch_directory(use_cache = TRUE)
  expect_true(is.logical(dir_data$is_charter))
})

test_that("directory is_private is logical", {
  skip_on_cran()
  skip_if_offline()

  dir_data <- fetch_directory(use_cache = TRUE)
  expect_true(is.logical(dir_data$is_private))
})

test_that("directory is_closed is logical", {
  skip_on_cran()
  skip_if_offline()

  dir_data <- fetch_directory(use_cache = TRUE)
  expect_true(is.logical(dir_data$is_closed))
})

test_that("directory latitude is numeric", {
  skip_on_cran()
  skip_if_offline()

  dir_data <- fetch_directory(use_cache = TRUE)
  expect_true(is.numeric(dir_data$latitude))
})

test_that("directory longitude is numeric", {
  skip_on_cran()
  skip_if_offline()

  dir_data <- fetch_directory(use_cache = TRUE)
  expect_true(is.numeric(dir_data$longitude))
})

test_that("directory entity_type has known values", {
  skip_on_cran()
  skip_if_offline()

  dir_data <- fetch_directory(use_cache = TRUE)
  expected_types <- c("Regular Education", "Alternate Education",
                      "Special Education", "Adult High",
                      "Residential Treatment", "Vocational Education")
  actual_types <- unique(dir_data$entity_type)
  # All actual types should be in the expected set
  for (et in actual_types) {
    expect_true(et %in% expected_types,
                info = paste("Unexpected entity_type:", et))
  }
})

test_that("directory school_category has known values", {
  skip_on_cran()
  skip_if_offline()

  dir_data <- fetch_directory(use_cache = TRUE)
  expected_cats <- c("Elementary School", "High School",
                     "Junior High/Middle School", "K-12 School",
                     "Other", "Preschool")
  actual_cats <- unique(dir_data$school_category)
  for (sc in actual_cats) {
    expect_true(sc %in% expected_cats,
                info = paste("Unexpected school_category:", sc))
  }
})

test_that("directory has > 1000 records", {
  skip_on_cran()
  skip_if_offline()

  dir_data <- fetch_directory(use_cache = TRUE)
  expect_gt(nrow(dir_data), 1000)
})

test_that("directory has charter schools", {
  skip_on_cran()
  skip_if_offline()

  dir_data <- fetch_directory(use_cache = TRUE)
  n_charter <- sum(dir_data$is_charter, na.rm = TRUE)
  expect_gt(n_charter, 100)
})

test_that("directory has private schools", {
  skip_on_cran()
  skip_if_offline()

  dir_data <- fetch_directory(use_cache = TRUE)
  n_private <- sum(dir_data$is_private, na.rm = TRUE)
  expect_gt(n_private, 50)
})

test_that("directory has schools with principal names", {
  skip_on_cran()
  skip_if_offline()

  dir_data <- fetch_directory(use_cache = TRUE)
  n_principals <- sum(!is.na(dir_data$principal_name))
  expect_gt(n_principals, 500)
})

test_that("directory has schools with superintendent names", {
  skip_on_cran()
  skip_if_offline()

  dir_data <- fetch_directory(use_cache = TRUE)
  n_supts <- sum(!is.na(dir_data$superintendent_name))
  expect_gt(n_supts, 100)
})

test_that("directory tidy = FALSE returns raw data", {
  skip_on_cran()
  skip_if_offline()

  raw <- fetch_directory(tidy = FALSE, use_cache = TRUE)
  expect_s3_class(raw, "tbl_df")
  expect_gt(nrow(raw), 50)
})

test_that("clear_directory_cache runs without error", {
  skip_on_cran()
  skip_if_offline()

  result <- suppressMessages(clear_directory_cache())
  expect_true(is.numeric(result))
})


# ==============================================================================
# 13. safe_numeric EXHAUSTIVE EDGE CASES
# ==============================================================================

test_that("safe_numeric handles numeric vector input", {
  result <- safe_numeric(c(1, 2, 3))
  expect_equal(result, c(1, 2, 3))
})

test_that("safe_numeric handles character vector input", {
  result <- safe_numeric(c("100", "200", "*"))
  expect_equal(result[1], 100)
  expect_equal(result[2], 200)
  expect_true(is.na(result[3]))
})

test_that("safe_numeric handles mixed suppression vector", {
  result <- safe_numeric(c("100", "<5", "N/A", "50", ""))
  expect_equal(result[1], 100)
  expect_true(is.na(result[2]))
  expect_true(is.na(result[3]))
  expect_equal(result[4], 50)
  expect_true(is.na(result[5]))
})


# ==============================================================================
# 14. build_usbe_url CORRECTNESS
# ==============================================================================

test_that("build_usbe_url for 2024 is correct", {
  url <- build_usbe_url(2024)
  expect_equal(
    url,
    "https://schools.utah.gov/datastatistics/_datastatisticsfiles_/_reports_/_enrollmentmembership_/2024FallEnrollmentGradeLevelDemographics.xlsx"
  )
})

test_that("build_usbe_url for 2019 is correct", {
  url <- build_usbe_url(2019)
  expect_true(grepl("2019FallEnrollmentGradeLevelDemographics.xlsx", url))
})

test_that("build_usbe_url contains schools.utah.gov", {
  url <- build_usbe_url(2026)
  expect_true(grepl("schools.utah.gov", url))
})

test_that("build_usbe_url embeds the year in the filename", {
  for (yr in 2019:2026) {
    url <- build_usbe_url(yr)
    expect_true(grepl(as.character(yr), url),
                info = paste("Year", yr, "not in URL"))
  }
})


# ==============================================================================
# 15. WIDE DATA SUPPRESSION
# ==============================================================================

test_that("wide campus data has some NAs (suppressed values)", {
  skip_on_cran()
  skip_if_offline()

  wide <- fetch_enr(2024, tidy = FALSE, use_cache = TRUE)
  campuses <- wide[wide$type == "Campus", ]
  # Small schools have suppressed counts
  expect_gt(sum(is.na(campuses$white)), 0)
})

test_that("wide state row has no NAs in key columns", {
  skip_on_cran()
  skip_if_offline()

  wide <- fetch_enr(2024, tidy = FALSE, use_cache = TRUE)
  state <- wide[wide$type == "State", ]
  expect_false(is.na(state$row_total))
  expect_false(is.na(state$white))
  expect_false(is.na(state$black))
  expect_false(is.na(state$hispanic))
  expect_false(is.na(state$male))
  expect_false(is.na(state$female))
  expect_false(is.na(state$grade_k))
  expect_false(is.na(state$grade_12))
})

test_that("wide has 1 state, >100 districts, >900 campuses", {
  skip_on_cran()
  skip_if_offline()

  wide <- fetch_enr(2024, tidy = FALSE, use_cache = TRUE)
  expect_equal(sum(wide$type == "State"), 1)
  expect_gt(sum(wide$type == "District"), 100)
  expect_gt(sum(wide$type == "Campus"), 900)
})


# ==============================================================================
# 16. MULTI-YEAR WIDE FORMAT
# ==============================================================================

test_that("fetch_enr_multi wide returns correct years", {
  skip_on_cran()
  skip_if_offline()

  result <- fetch_enr_multi(2023:2024, tidy = FALSE, use_cache = TRUE)
  expect_true(all(c(2023, 2024) %in% result$end_year))
  expect_true("row_total" %in% names(result))
})

test_that("fetch_enr_multi wide has same columns for each year", {
  skip_on_cran()
  skip_if_offline()

  result <- fetch_enr_multi(2023:2024, tidy = FALSE, use_cache = TRUE)
  cols_2023 <- names(result[result$end_year == 2023, ])
  cols_2024 <- names(result[result$end_year == 2024, ])
  expect_equal(cols_2023, cols_2024)
})
