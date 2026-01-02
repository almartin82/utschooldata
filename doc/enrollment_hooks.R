## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  message = FALSE,
  warning = FALSE,
  fig.width = 8,
  fig.height = 5
)

## ----load-packages------------------------------------------------------------
library(utschooldata)
library(dplyr)
library(tidyr)
library(ggplot2)

theme_set(theme_minimal(base_size = 14))

## ----statewide-trend----------------------------------------------------------
enr <- fetch_enr_multi(2019:2026)

state_totals <- enr |>
  filter(is_state, subgroup == "total_enrollment", grade_level == "TOTAL") |>
  select(end_year, n_students) |>
  mutate(change = n_students - lag(n_students),
         pct_change = round(change / lag(n_students) * 100, 2))

state_totals

## ----statewide-chart----------------------------------------------------------
ggplot(state_totals, aes(x = end_year, y = n_students)) +
  geom_line(linewidth = 1.2, color = "#CC0000") +
  geom_point(size = 3, color = "#CC0000") +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title = "Utah Public School Enrollment (2019-2026)",
    subtitle = "Steady growth continues in the Beehive State",
    x = "School Year (ending)",
    y = "Total Enrollment"
  )

## ----largest-districts--------------------------------------------------------
large_districts <- enr |>
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL",
         grepl("Granite|Alpine|Davis|Jordan|Canyons|Salt Lake City", district_name, ignore.case = TRUE)) |>
  select(end_year, district_name, n_students)

large_districts |>
  filter(end_year == max(end_year)) |>
  arrange(desc(n_students))

## ----top-districts-chart------------------------------------------------------
enr |>
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL",
         grepl("Granite|Alpine|Davis|Jordan", district_name, ignore.case = TRUE)) |>
  ggplot(aes(x = end_year, y = n_students, color = district_name)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 2) +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title = "Utah's Largest Districts: Enrollment Trends",
    subtitle = "The Big Four along the Wasatch Front",
    x = "School Year",
    y = "Enrollment",
    color = "District"
  )

## ----demographics-------------------------------------------------------------
enr_2026 <- fetch_enr(2026)

demographics <- enr_2026 |>
  filter(is_state, grade_level == "TOTAL",
         subgroup %in% c("hispanic", "white", "black", "asian", "native_american", "pacific_islander", "multiracial")) |>
  mutate(pct = round(pct * 100, 1)) |>
  select(subgroup, n_students, pct) |>
  arrange(desc(n_students))

demographics

## ----demographics-chart-------------------------------------------------------
demographics |>
  mutate(subgroup = forcats::fct_reorder(subgroup, n_students)) |>
  ggplot(aes(x = n_students, y = subgroup, fill = subgroup)) +
  geom_col(show.legend = FALSE) +
  geom_text(aes(label = paste0(pct, "%")), hjust = -0.1) +
  scale_x_continuous(labels = scales::comma, expand = expansion(mult = c(0, 0.15))) +
  scale_fill_brewer(palette = "Set2") +
  labs(
    title = "Utah Student Demographics (2026)",
    subtitle = "White students remain the majority, but diversity is increasing",
    x = "Number of Students",
    y = NULL
  )

## ----pacific-islander---------------------------------------------------------
pi_districts <- enr_2026 |>
  filter(is_district, grade_level == "TOTAL", subgroup == "pacific_islander") |>
  filter(n_students > 100) |>
  mutate(pct = round(pct * 100, 2)) |>
  select(district_name, n_students, pct) |>
  arrange(desc(pct)) |>
  head(10)

pi_districts

## ----utah-county--------------------------------------------------------------
utah_county <- enr |>
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL",
         grepl("Alpine|Provo|Nebo", district_name, ignore.case = TRUE)) |>
  group_by(district_name) |>
  summarize(
    y2019 = n_students[end_year == 2019],
    y2026 = n_students[end_year == 2026],
    pct_change = round((y2026 / y2019 - 1) * 100, 1),
    .groups = "drop"
  ) |>
  arrange(desc(pct_change))

utah_county

## ----growth-chart-------------------------------------------------------------
enr |>
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL",
         grepl("Alpine|Provo|Nebo|Washington", district_name, ignore.case = TRUE)) |>
  ggplot(aes(x = end_year, y = n_students, color = district_name)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 2) +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title = "Utah's Growing Districts",
    subtitle = "Utah County and St. George area lead growth",
    x = "School Year",
    y = "Enrollment",
    color = "District"
  )

## ----rural-decline------------------------------------------------------------
rural <- enr |>
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL",
         grepl("Carbon|Emery|Grand|San Juan|Millard", district_name, ignore.case = TRUE)) |>
  group_by(district_name) |>
  filter(n() >= 5) |>
  summarize(
    y2019 = n_students[end_year == 2019],
    y2026 = n_students[end_year == 2026],
    pct_change = round((y2026 / y2019 - 1) * 100, 1),
    .groups = "drop"
  ) |>
  arrange(pct_change)

rural

## ----regional-chart-----------------------------------------------------------
enr |>
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL",
         grepl("Carbon|Emery|Grand|San Juan", district_name, ignore.case = TRUE)) |>
  ggplot(aes(x = end_year, y = n_students, color = district_name)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 2) +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title = "Rural Utah Districts: Enrollment Challenges",
    subtitle = "Eastern Utah districts losing students",
    x = "School Year",
    y = "Enrollment",
    color = "District"
  )

## ----washington-county--------------------------------------------------------
washington <- enr |>
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL",
         grepl("Washington", district_name, ignore.case = TRUE)) |>
  select(end_year, district_name, n_students) |>
  mutate(change = n_students - lag(n_students),
         pct_change = round(change / lag(n_students) * 100, 1))

washington

## ----charters-----------------------------------------------------------------
state_total <- enr_2026 |>
  filter(is_state, subgroup == "total_enrollment", grade_level == "TOTAL") |>
  pull(n_students)

charter_total <- enr_2026 |>
  filter(is_charter, subgroup == "total_enrollment", grade_level == "TOTAL") |>
  summarize(charter_total = sum(n_students, na.rm = TRUE)) |>
  pull(charter_total)

tibble(
  sector = c("All Public Schools", "Charter Schools"),
  enrollment = c(state_total, charter_total),
  pct = c(100, round(charter_total / state_total * 100, 1))
)

## ----covid-k------------------------------------------------------------------
covid_grades <- enr |>
  filter(is_state, subgroup == "total_enrollment",
         grade_level %in% c("K", "01", "05", "09")) |>
  select(end_year, grade_level, n_students) |>
  pivot_wider(names_from = grade_level, values_from = n_students)

covid_grades

## ----high-school--------------------------------------------------------------
hs_trend <- enr |>
  filter(is_state, subgroup == "total_enrollment",
         grade_level %in% c("09", "10", "11", "12")) |>
  group_by(end_year) |>
  summarize(hs_total = sum(n_students, na.rm = TRUE), .groups = "drop") |>
  mutate(change = hs_total - lag(hs_total),
         pct_change = round(change / lag(hs_total) * 100, 1))

hs_trend

