# ==============================================================================
# Transformation Correctness Tests for Utah School Data
# ==============================================================================
#
# Tests verify the processing pipeline (raw -> wide -> tidy) preserves data
# integrity. All expected values are from real USBE data via fetch_enr()
# with use_cache = TRUE.
#
# Categories:
# 1. Suppression handling
# 2. ID generation
# 3. Grade level normalization
# 4. Subgroup names
# 5. Pivot fidelity (wide <-> tidy)
# 6. Percentage calculations
# 7. Aggregation consistency
# 8. Entity flags
# 9. Per-year known values
# 10. Cross-year consistency
#
# ==============================================================================

# ==============================================================================
# 1. SUPPRESSION HANDLING
# ==============================================================================

test_that("safe_numeric converts suppression markers to NA", {
  # USBE uses several suppression markers

  expect_true(is.na(safe_numeric("*")))
  expect_true(is.na(safe_numeric(".")))
  expect_true(is.na(safe_numeric("-")))
  expect_true(is.na(safe_numeric("-1")))
  expect_true(is.na(safe_numeric("<5")))
  expect_true(is.na(safe_numeric("N<10")))
  expect_true(is.na(safe_numeric("N/A")))
  expect_true(is.na(safe_numeric("NA")))
  expect_true(is.na(safe_numeric("")))
  expect_true(is.na(safe_numeric("N < 10")))
  expect_true(is.na(safe_numeric("n<10")))
  expect_true(is.na(safe_numeric("< 10")))
  expect_true(is.na(safe_numeric("> 0")))
})

test_that("safe_numeric preserves valid numbers", {
  expect_equal(safe_numeric("100"), 100)
  expect_equal(safe_numeric("0"), 0)
  expect_equal(safe_numeric("1234"), 1234)
  expect_equal(safe_numeric("1,234"), 1234)
  expect_equal(safe_numeric("  100  "), 100)
})

test_that("safe_numeric passes through already numeric values", {
  expect_equal(safe_numeric(100), 100)
  expect_equal(safe_numeric(0), 0)
  expect_true(is.na(safe_numeric(NA_real_)))
})

test_that("suppressed values appear as NA in campus-level wide data", {
  skip_on_cran()
  skip_if_offline()

  wide <- fetch_enr(2024, tidy = FALSE, use_cache = TRUE)
  campuses <- wide[wide$type == "Campus", ]

  # Some campuses have suppressed demographics (small counts)
  # At least some NAs should exist in race/ethnicity columns
  na_count_white <- sum(is.na(campuses$white))
  expect_gt(na_count_white, 0)

  # State-level row should have NO suppressed values

  state_row <- wide[wide$type == "State", ]
  expect_false(is.na(state_row$row_total))
  expect_false(is.na(state_row$white))
  expect_false(is.na(state_row$male))
  expect_false(is.na(state_row$female))
})

test_that("suppressed values are excluded from tidy output (no NA n_students)", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)

  # tidy_enr filters out rows where n_students is NA
  expect_equal(sum(is.na(tidy$n_students)), 0)
})


# ==============================================================================
# 2. ID GENERATION
# ==============================================================================

test_that("state-level rows have NA district_id and campus_id", {
  skip_on_cran()
  skip_if_offline()

  wide <- fetch_enr(2024, tidy = FALSE, use_cache = TRUE)
  state_row <- wide[wide$type == "State", ]

  expect_true(is.na(state_row$district_id))
  expect_true(is.na(state_row$campus_id))
  expect_true(is.na(state_row$district_name))
  expect_true(is.na(state_row$campus_name))
})

test_that("district-level rows have district_id but NA campus_id", {
  skip_on_cran()
  skip_if_offline()

  wide <- fetch_enr(2024, tidy = FALSE, use_cache = TRUE)
  districts <- wide[wide$type == "District", ]

  expect_true(all(!is.na(districts$district_id)))
  expect_true(all(is.na(districts$campus_id)))
  expect_true(all(!is.na(districts$district_name)))
  expect_true(all(is.na(districts$campus_name)))
})

test_that("campus-level rows have both district_id and campus_id", {
  skip_on_cran()
  skip_if_offline()

  wide <- fetch_enr(2024, tidy = FALSE, use_cache = TRUE)
  campuses <- wide[wide$type == "Campus", ]

  expect_true(all(!is.na(campuses$district_id)))
  expect_true(all(!is.na(campuses$campus_id)))
  expect_true(all(!is.na(campuses$district_name)))
  expect_true(all(!is.na(campuses$campus_name)))
})

test_that("district_id is deterministic for same district name", {
  skip_on_cran()
  skip_if_offline()

  wide <- fetch_enr(2024, tidy = FALSE, use_cache = TRUE)

  # All Alpine District rows should share the same district_id
  alpine_rows <- wide[grepl("Alpine District", wide$district_name), ]
  expect_equal(length(unique(alpine_rows$district_id)), 1)

  # All Granite District rows should share the same district_id
  granite_rows <- wide[grepl("Granite District", wide$district_name), ]
  expect_equal(length(unique(granite_rows$district_id)), 1)
})


# ==============================================================================
# 3. GRADE LEVEL NORMALIZATION
# ==============================================================================

test_that("tidy grade levels use standard labels", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  grade_levels <- unique(tidy$grade_level)

  valid_grades <- c("PK", "K", "01", "02", "03", "04", "05", "06",
                    "07", "08", "09", "10", "11", "12", "TOTAL")
  expect_true(all(grade_levels %in% valid_grades))
})

test_that("all expected grade levels are present", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  grade_levels <- unique(tidy$grade_level)

  # All standard grades should be present
  expected_grades <- c("PK", "K", "01", "02", "03", "04", "05", "06",
                       "07", "08", "09", "10", "11", "12", "TOTAL")
  for (g in expected_grades) {
    expect_true(g %in% grade_levels, label = paste("Grade", g, "present"))
  }
})

test_that("wide grade columns map to correct tidy labels", {
  skip_on_cran()
  skip_if_offline()

  wide <- fetch_enr(2024, tidy = FALSE, use_cache = TRUE)
  state_wide <- wide[wide$type == "State", ]

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  state_tidy <- tidy[tidy$is_state & tidy$subgroup == "total_enrollment", ]

  # PK maps from grade_pk
  tidy_pk <- state_tidy$n_students[state_tidy$grade_level == "PK"]
  expect_equal(tidy_pk, state_wide$grade_pk)

  # K maps from grade_k
  tidy_k <- state_tidy$n_students[state_tidy$grade_level == "K"]
  expect_equal(tidy_k, state_wide$grade_k)

  # 01 maps from grade_01
  tidy_01 <- state_tidy$n_students[state_tidy$grade_level == "01"]
  expect_equal(tidy_01, state_wide$grade_01)

  # 12 maps from grade_12
  tidy_12 <- state_tidy$n_students[state_tidy$grade_level == "12"]
  expect_equal(tidy_12, state_wide$grade_12)
})


# ==============================================================================
# 4. SUBGROUP NAMES
# ==============================================================================

test_that("tidy subgroups use standard naming", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  subgroups <- unique(tidy$subgroup)

  # Standard names per CLAUDE.md
  expected <- c("total_enrollment", "white", "black", "hispanic", "asian",
                "native_american", "pacific_islander", "multiracial",
                "male", "female", "special_ed", "lep", "econ_disadv")
  expect_setequal(subgroups, expected)
})

test_that("no non-standard subgroup names exist", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  subgroups <- unique(tidy$subgroup)

  # Reject non-standard variants
  bad_names <- c("total", "low_income", "economically_disadvantaged", "frl",
                 "iep", "disability", "students_with_disabilities",
                 "el", "ell", "english_learner", "american_indian",
                 "two_or_more", "African_American", "AfAmBlack")
  for (bad in bad_names) {
    expect_false(bad %in% subgroups,
                 label = paste("Non-standard name rejected:", bad))
  }
})

test_that("demographic subgroups have grade_level TOTAL", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  demo_subgroups <- c("white", "black", "hispanic", "asian",
                      "native_american", "pacific_islander", "multiracial",
                      "male", "female", "special_ed", "lep", "econ_disadv")

  for (sg in demo_subgroups) {
    sg_grades <- unique(tidy$grade_level[tidy$subgroup == sg])
    expect_equal(sg_grades, "TOTAL",
                 label = paste("Subgroup", sg, "has grade_level TOTAL"))
  }
})


# ==============================================================================
# 5. PIVOT FIDELITY (wide <-> tidy)
# ==============================================================================

test_that("state total enrollment matches between wide and tidy", {
  skip_on_cran()
  skip_if_offline()

  wide <- fetch_enr(2024, tidy = FALSE, use_cache = TRUE)
  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)

  wide_total <- wide$row_total[wide$type == "State"]
  tidy_total <- tidy$n_students[tidy$is_state &
                                  tidy$subgroup == "total_enrollment" &
                                  tidy$grade_level == "TOTAL"]

  expect_equal(tidy_total, wide_total)
  expect_equal(tidy_total, 672662)
})

test_that("state demographics match between wide and tidy", {
  skip_on_cran()
  skip_if_offline()

  wide <- fetch_enr(2024, tidy = FALSE, use_cache = TRUE)
  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)

  state_wide <- wide[wide$type == "State", ]
  state_tidy <- tidy[tidy$is_state & tidy$grade_level == "TOTAL", ]

  # White
  tidy_white <- state_tidy$n_students[state_tidy$subgroup == "white"]
  expect_equal(tidy_white, state_wide$white)
  expect_equal(tidy_white, 478697)

  # Hispanic
  tidy_hispanic <- state_tidy$n_students[state_tidy$subgroup == "hispanic"]
  expect_equal(tidy_hispanic, state_wide$hispanic)
  expect_equal(tidy_hispanic, 132110)

  # Black
  tidy_black <- state_tidy$n_students[state_tidy$subgroup == "black"]
  expect_equal(tidy_black, state_wide$black)
  expect_equal(tidy_black, 8757)

  # Asian
  tidy_asian <- state_tidy$n_students[state_tidy$subgroup == "asian"]
  expect_equal(tidy_asian, state_wide$asian)
  expect_equal(tidy_asian, 10874)
})

test_that("state gender counts match between wide and tidy", {
  skip_on_cran()
  skip_if_offline()

  wide <- fetch_enr(2024, tidy = FALSE, use_cache = TRUE)
  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)

  state_wide <- wide[wide$type == "State", ]
  state_tidy <- tidy[tidy$is_state & tidy$grade_level == "TOTAL", ]

  tidy_male <- state_tidy$n_students[state_tidy$subgroup == "male"]
  expect_equal(tidy_male, state_wide$male)
  expect_equal(tidy_male, 346053)

  tidy_female <- state_tidy$n_students[state_tidy$subgroup == "female"]
  expect_equal(tidy_female, state_wide$female)
  expect_equal(tidy_female, 326516)
})

test_that("state special populations match between wide and tidy", {
  skip_on_cran()
  skip_if_offline()

  wide <- fetch_enr(2024, tidy = FALSE, use_cache = TRUE)
  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)

  state_wide <- wide[wide$type == "State", ]
  state_tidy <- tidy[tidy$is_state & tidy$grade_level == "TOTAL", ]

  tidy_econ <- state_tidy$n_students[state_tidy$subgroup == "econ_disadv"]
  expect_equal(tidy_econ, state_wide$econ_disadv)
  expect_equal(tidy_econ, 201736)

  tidy_lep <- state_tidy$n_students[state_tidy$subgroup == "lep"]
  expect_equal(tidy_lep, state_wide$lep)
  expect_equal(tidy_lep, 59147)

  tidy_sped <- state_tidy$n_students[state_tidy$subgroup == "special_ed"]
  expect_equal(tidy_sped, state_wide$special_ed)
  expect_equal(tidy_sped, 87072)
})

test_that("district-level pivot fidelity (Alpine District)", {
  skip_on_cran()
  skip_if_offline()

  wide <- fetch_enr(2024, tidy = FALSE, use_cache = TRUE)
  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)

  alpine_wide <- wide[wide$type == "District" &
                        grepl("Alpine District", wide$district_name), ]
  alpine_tidy <- tidy[tidy$is_district &
                        grepl("Alpine District", tidy$district_name) &
                        tidy$grade_level == "TOTAL", ]

  # Total
  tidy_total <- alpine_tidy$n_students[alpine_tidy$subgroup == "total_enrollment"]
  expect_equal(tidy_total, alpine_wide$row_total)
  expect_equal(tidy_total, 84710)

  # White
  tidy_white <- alpine_tidy$n_students[alpine_tidy$subgroup == "white"]
  expect_equal(tidy_white, alpine_wide$white)
  expect_equal(tidy_white, 64775)

  # Hispanic
  tidy_hisp <- alpine_tidy$n_students[alpine_tidy$subgroup == "hispanic"]
  expect_equal(tidy_hisp, alpine_wide$hispanic)
  expect_equal(tidy_hisp, 13234)
})

test_that("campus-level pivot fidelity (Alpine Online School)", {
  skip_on_cran()
  skip_if_offline()

  wide <- fetch_enr(2024, tidy = FALSE, use_cache = TRUE)
  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)

  # Alpine Online School
  campus_wide <- wide[wide$type == "Campus" &
                        wide$campus_name == "Alpine Online School" &
                        wide$district_name == "Alpine District", ]
  # Use first row if duplicates (data issue)
  campus_wide <- campus_wide[1, ]

  campus_tidy <- tidy[tidy$is_campus &
                        tidy$campus_id == campus_wide$campus_id &
                        tidy$grade_level == "TOTAL", ]

  tidy_total <- campus_tidy$n_students[campus_tidy$subgroup == "total_enrollment"]
  expect_equal(tidy_total[1], campus_wide$row_total)
})

test_that("grade-level counts match between wide and tidy at state level", {
  skip_on_cran()
  skip_if_offline()

  wide <- fetch_enr(2024, tidy = FALSE, use_cache = TRUE)
  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)

  state_wide <- wide[wide$type == "State", ]
  state_grades <- tidy[tidy$is_state & tidy$subgroup == "total_enrollment" &
                         tidy$grade_level != "TOTAL", ]

  # Check each grade
  expect_equal(
    state_grades$n_students[state_grades$grade_level == "PK"],
    state_wide$grade_pk
  )
  expect_equal(
    state_grades$n_students[state_grades$grade_level == "K"],
    state_wide$grade_k
  )
  expect_equal(
    state_grades$n_students[state_grades$grade_level == "01"],
    state_wide$grade_01
  )
  expect_equal(
    state_grades$n_students[state_grades$grade_level == "08"],
    state_wide$grade_08
  )
  expect_equal(
    state_grades$n_students[state_grades$grade_level == "12"],
    state_wide$grade_12
  )
})


# ==============================================================================
# 6. PERCENTAGE CALCULATIONS
# ==============================================================================

test_that("pct = n_students / row_total for subgroups", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  wide <- fetch_enr(2024, tidy = FALSE, use_cache = TRUE)

  state_tidy <- tidy[tidy$is_state & tidy$grade_level == "TOTAL", ]
  state_total <- wide$row_total[wide$type == "State"]

  # White
  white_pct <- state_tidy$pct[state_tidy$subgroup == "white"]
  expected_pct <- 478697 / 672662
  expect_equal(white_pct, expected_pct, tolerance = 1e-6)

  # Hispanic
  hisp_pct <- state_tidy$pct[state_tidy$subgroup == "hispanic"]
  expected_hisp_pct <- 132110 / 672662
  expect_equal(hisp_pct, expected_hisp_pct, tolerance = 1e-6)
})

test_that("total_enrollment has pct = 1.0", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  total_rows <- tidy[tidy$subgroup == "total_enrollment" &
                       tidy$grade_level == "TOTAL", ]

  expect_true(all(total_rows$pct == 1.0))
})

test_that("pct is capped at 1.0 (no values > 1)", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  expect_equal(sum(tidy$pct > 1.0), 0)
})

test_that("pct is non-negative", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  expect_equal(sum(tidy$pct < 0), 0)
})

test_that("grade-level pct is fraction of row_total", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)

  # State-level K grade pct
  state_k <- tidy[tidy$is_state & tidy$subgroup == "total_enrollment" &
                     tidy$grade_level == "K", ]
  expected_k_pct <- 45217 / 672662
  expect_equal(state_k$pct, expected_k_pct, tolerance = 1e-6)
})


# ==============================================================================
# 7. AGGREGATION CONSISTENCY
# ==============================================================================

test_that("race/ethnicity sum equals row_total at state level", {
  skip_on_cran()
  skip_if_offline()

  wide <- fetch_enr(2024, tidy = FALSE, use_cache = TRUE)
  state <- wide[wide$type == "State", ]

  race_sum <- sum(state$white, state$black, state$hispanic,
                  state$asian, state$native_american,
                  state$pacific_islander, state$multiracial, na.rm = TRUE)
  expect_equal(race_sum, state$row_total)
  expect_equal(race_sum, 672662)
})

test_that("K-12 grade sum equals row_total (excludes PK)", {
  skip_on_cran()
  skip_if_offline()

  wide <- fetch_enr(2024, tidy = FALSE, use_cache = TRUE)
  state <- wide[wide$type == "State", ]

  k12_sum <- sum(state$grade_k,
                 state$grade_01, state$grade_02, state$grade_03,
                 state$grade_04, state$grade_05, state$grade_06,
                 state$grade_07, state$grade_08, state$grade_09,
                 state$grade_10, state$grade_11, state$grade_12,
                 na.rm = TRUE)
  expect_equal(k12_sum, state$row_total)
  expect_equal(k12_sum, 672662)
})

test_that("enr_grade_aggs K8 + HS = K12", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  aggs <- enr_grade_aggs(tidy)

  state_aggs <- aggs[aggs$is_state, ]
  k8 <- state_aggs$n_students[state_aggs$grade_level == "K8"]
  hs <- state_aggs$n_students[state_aggs$grade_level == "HS"]
  k12 <- state_aggs$n_students[state_aggs$grade_level == "K12"]

  expect_equal(k8 + hs, k12)
  expect_equal(k8, 456568)
  expect_equal(hs, 216094)
  expect_equal(k12, 672662)
})

test_that("district totals approximately equal state total", {
  skip_on_cran()
  skip_if_offline()

  wide <- fetch_enr(2024, tidy = FALSE, use_cache = TRUE)

  state_total <- wide$row_total[wide$type == "State"]
  district_total <- sum(wide$row_total[wide$type == "District"], na.rm = TRUE)

  # Districts should account for ~100% of state (charter LEAs included)
  ratio <- district_total / state_total
  expect_gt(ratio, 0.95)
  expect_lt(ratio, 1.05)
})

test_that("no Inf or NaN in tidy numeric columns", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)

  expect_false(any(is.infinite(tidy$n_students)))
  expect_false(any(is.nan(tidy$n_students)))
  expect_false(any(is.infinite(tidy$pct)))
  expect_false(any(is.nan(tidy$pct)))
})

test_that("all enrollment counts are non-negative", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  expect_true(all(tidy$n_students >= 0))

  wide <- fetch_enr(2024, tidy = FALSE, use_cache = TRUE)
  expect_true(all(wide$row_total >= 0, na.rm = TRUE))
})


# ==============================================================================
# 8. ENTITY FLAGS
# ==============================================================================

test_that("entity flags are mutually exclusive", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)

  flag_sum <- as.integer(tidy$is_state) +
    as.integer(tidy$is_district) +
    as.integer(tidy$is_campus)
  expect_true(all(flag_sum == 1))
})

test_that("entity flags are logical type", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  expect_true(is.logical(tidy$is_state))
  expect_true(is.logical(tidy$is_district))
  expect_true(is.logical(tidy$is_campus))
  expect_true(is.logical(tidy$is_charter))
})

test_that("exactly one state row per subgroup-grade combination", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  state_rows <- tidy[tidy$is_state, ]

  dupes <- as.data.frame(table(state_rows$subgroup, state_rows$grade_level))
  expect_true(all(dupes$Freq <= 1))
})

test_that("state row counts match expected values", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  total_rows <- tidy[tidy$subgroup == "total_enrollment" &
                       tidy$grade_level == "TOTAL", ]

  # Exactly 1 state, 154 districts, 1052 campuses
  expect_equal(sum(total_rows$is_state), 1)
  expect_equal(sum(total_rows$is_district), 154)
  expect_equal(sum(total_rows$is_campus), 1052)
})

test_that("charter flag correctly identifies charter LEAs", {
  skip_on_cran()
  skip_if_offline()

  wide <- fetch_enr(2024, tidy = FALSE, use_cache = TRUE)
  districts <- wide[wide$type == "District", ]

  charter_count <- sum(districts$charter_flag == "Y", na.rm = TRUE)
  noncharter_count <- sum(districts$charter_flag == "N", na.rm = TRUE)

  expect_equal(charter_count, 113)
  expect_equal(noncharter_count, 41)
  expect_equal(charter_count + noncharter_count, nrow(districts))
})

test_that("is_charter flag matches charter_flag column", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)

  # All rows with charter_flag == "Y" should have is_charter == TRUE
  charter_y <- tidy[!is.na(tidy$charter_flag) & tidy$charter_flag == "Y", ]
  expect_true(all(charter_y$is_charter))

  # All rows with charter_flag == "N" should have is_charter == FALSE
  charter_n <- tidy[!is.na(tidy$charter_flag) & tidy$charter_flag == "N", ]
  expect_true(all(!charter_n$is_charter))
})

test_that("aggregation_flag column is consistent with entity flags", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)

  # State rows should have aggregation_flag == "state"
  state_agg <- unique(tidy$aggregation_flag[tidy$is_state])
  expect_equal(state_agg, "state")

  # District rows should have aggregation_flag == "district"
  district_agg <- unique(tidy$aggregation_flag[tidy$is_district])
  expect_equal(district_agg, "district")

  # Campus rows should have aggregation_flag == "campus"
  campus_agg <- unique(tidy$aggregation_flag[tidy$is_campus])
  expect_equal(campus_agg, "campus")
})


# ==============================================================================
# 9. PER-YEAR KNOWN VALUES
# ==============================================================================

test_that("2024 state total enrollment is 672,662", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  state_total <- tidy$n_students[tidy$is_state &
                                   tidy$subgroup == "total_enrollment" &
                                   tidy$grade_level == "TOTAL"]
  expect_equal(state_total, 672662)
})

test_that("2024 Alpine District total is 84,710", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  alpine <- tidy$n_students[tidy$is_district &
                              grepl("Alpine District", tidy$district_name) &
                              tidy$subgroup == "total_enrollment" &
                              tidy$grade_level == "TOTAL"]
  expect_equal(alpine, 84710)
})

test_that("2024 Davis District total is 70,703", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  davis <- tidy$n_students[tidy$is_district &
                             grepl("^Davis District", tidy$district_name) &
                             tidy$subgroup == "total_enrollment" &
                             tidy$grade_level == "TOTAL"]
  expect_equal(davis, 70703)
})

test_that("2024 Granite District total is 58,312", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  granite <- tidy$n_students[tidy$is_district &
                               grepl("Granite District", tidy$district_name) &
                               tidy$subgroup == "total_enrollment" &
                               tidy$grade_level == "TOTAL"]
  expect_equal(granite, 58312)
})

test_that("2024 Jordan District total is 57,436", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  jordan <- tidy$n_students[tidy$is_district &
                              grepl("^Jordan District", tidy$district_name) &
                              tidy$subgroup == "total_enrollment" &
                              tidy$grade_level == "TOTAL"]
  expect_equal(jordan, 57436)
})

test_that("2024 state-level grade counts are correct", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  state_grades <- tidy[tidy$is_state & tidy$subgroup == "total_enrollment" &
                         tidy$grade_level != "TOTAL", ]

  # Check specific grade counts from USBE data
  expect_equal(
    state_grades$n_students[state_grades$grade_level == "PK"], 16392
  )
  expect_equal(
    state_grades$n_students[state_grades$grade_level == "K"], 45217
  )
  expect_equal(
    state_grades$n_students[state_grades$grade_level == "01"], 48138
  )
  expect_equal(
    state_grades$n_students[state_grades$grade_level == "12"], 51770
  )
})

test_that("2024 state demographics known values", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  state <- tidy[tidy$is_state & tidy$grade_level == "TOTAL", ]

  expect_equal(state$n_students[state$subgroup == "white"], 478697)
  expect_equal(state$n_students[state$subgroup == "hispanic"], 132110)
  expect_equal(state$n_students[state$subgroup == "black"], 8757)
  expect_equal(state$n_students[state$subgroup == "asian"], 10874)
  expect_equal(state$n_students[state$subgroup == "native_american"], 6025)
  expect_equal(state$n_students[state$subgroup == "pacific_islander"], 10531)
  expect_equal(state$n_students[state$subgroup == "multiracial"], 25668)
  expect_equal(state$n_students[state$subgroup == "male"], 346053)
  expect_equal(state$n_students[state$subgroup == "female"], 326516)
  expect_equal(state$n_students[state$subgroup == "econ_disadv"], 201736)
  expect_equal(state$n_students[state$subgroup == "lep"], 59147)
  expect_equal(state$n_students[state$subgroup == "special_ed"], 87072)
})

test_that("2023 state total enrollment is 674,650", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2023, tidy = TRUE, use_cache = TRUE)
  state_total <- tidy$n_students[tidy$is_state &
                                   tidy$subgroup == "total_enrollment" &
                                   tidy$grade_level == "TOTAL"]
  expect_equal(state_total, 674650)
})


# ==============================================================================
# 10. CROSS-YEAR CONSISTENCY
# ==============================================================================

test_that("year-over-year state total changes are plausible", {
  skip_on_cran()
  skip_if_offline()

  tidy_multi <- fetch_enr_multi(2023:2024, tidy = TRUE, use_cache = TRUE)

  state_totals <- tidy_multi[tidy_multi$is_state &
                               tidy_multi$subgroup == "total_enrollment" &
                               tidy_multi$grade_level == "TOTAL",
                             c("end_year", "n_students")]
  state_totals <- state_totals[order(state_totals$end_year), ]

  # Year-over-year change should be < 5%
  for (i in 2:nrow(state_totals)) {
    pct_change <- abs(state_totals$n_students[i] / state_totals$n_students[i - 1] - 1)
    expect_lt(pct_change, 0.05,
              label = paste("YoY change",
                            state_totals$end_year[i - 1], "->",
                            state_totals$end_year[i]))
  }
})

test_that("end_year column is correct for each year", {
  skip_on_cran()
  skip_if_offline()

  tidy_multi <- fetch_enr_multi(2023:2024, tidy = TRUE, use_cache = TRUE)

  years_present <- sort(unique(tidy_multi$end_year))
  expect_equal(years_present, c(2023, 2024))

  # Each year's data should only have that year in end_year
  for (yr in 2023:2024) {
    yr_data <- tidy_multi[tidy_multi$end_year == yr, ]
    expect_true(all(yr_data$end_year == yr))
    expect_gt(nrow(yr_data), 0)
  }
})

test_that("same columns exist across years", {
  skip_on_cran()
  skip_if_offline()

  tidy_2023 <- fetch_enr(2023, tidy = TRUE, use_cache = TRUE)
  tidy_2024 <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)

  expect_equal(sort(names(tidy_2023)), sort(names(tidy_2024)))
})

test_that("same subgroups exist across years", {
  skip_on_cran()
  skip_if_offline()

  tidy_2023 <- fetch_enr(2023, tidy = TRUE, use_cache = TRUE)
  tidy_2024 <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)

  expect_setequal(unique(tidy_2023$subgroup), unique(tidy_2024$subgroup))
})

test_that("same grade levels exist across years", {
  skip_on_cran()
  skip_if_offline()

  tidy_2023 <- fetch_enr(2023, tidy = TRUE, use_cache = TRUE)
  tidy_2024 <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)

  expect_setequal(unique(tidy_2023$grade_level), unique(tidy_2024$grade_level))
})

test_that("Granite District demographics are stable across years", {
  skip_on_cran()
  skip_if_offline()

  tidy_multi <- fetch_enr_multi(2023:2024, tidy = TRUE, use_cache = TRUE)

  granite <- tidy_multi[tidy_multi$is_district &
                          grepl("Granite District", tidy_multi$district_name) &
                          tidy_multi$subgroup == "total_enrollment" &
                          tidy_multi$grade_level == "TOTAL", ]

  expect_equal(nrow(granite), 2)
  expect_true(all(granite$end_year %in% c(2023, 2024)))

  # Granite should have 50k-70k students in both years
  expect_true(all(granite$n_students > 50000))
  expect_true(all(granite$n_students < 70000))
})


# ==============================================================================
# STRUCTURAL INTEGRITY
# ==============================================================================

test_that("tidy output has all required columns", {
  skip_on_cran()
  skip_if_offline()

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)

  required_cols <- c("end_year", "type", "district_id", "campus_id",
                     "district_name", "campus_name", "charter_flag",
                     "grade_level", "subgroup", "n_students", "pct",
                     "is_state", "is_district", "is_campus",
                     "aggregation_flag", "is_charter")
  for (col in required_cols) {
    expect_true(col %in% names(tidy),
                label = paste("Required column:", col))
  }
})

test_that("wide output has all required columns", {
  skip_on_cran()
  skip_if_offline()

  wide <- fetch_enr(2024, tidy = FALSE, use_cache = TRUE)

  required_cols <- c("end_year", "type", "district_id", "campus_id",
                     "district_name", "campus_name", "charter_flag",
                     "row_total", "white", "black", "hispanic", "asian",
                     "native_american", "pacific_islander", "multiracial",
                     "male", "female", "econ_disadv", "lep", "special_ed",
                     "grade_pk", "grade_k",
                     "grade_01", "grade_02", "grade_03", "grade_04",
                     "grade_05", "grade_06", "grade_07", "grade_08",
                     "grade_09", "grade_10", "grade_11", "grade_12")
  for (col in required_cols) {
    expect_true(col %in% names(wide),
                label = paste("Required column:", col))
  }
})

test_that("type column only contains valid values", {
  skip_on_cran()
  skip_if_offline()

  wide <- fetch_enr(2024, tidy = FALSE, use_cache = TRUE)
  expect_true(all(wide$type %in% c("State", "District", "Campus")))

  tidy <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)
  expect_true(all(tidy$type %in% c("State", "District", "Campus")))
})
