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

# Get available years dynamically
available_years <- get_available_years()
min_year <- min(available_years)
max_year <- max(available_years)

## ----statewide-trend----------------------------------------------------------
enr <- fetch_enr_multi(available_years)

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
    title = paste0("Utah Public School Enrollment (", min_year, "-", max_year, ")"),
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
enr_latest <- fetch_enr(max_year)

demographics <- enr_latest |>
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
    title = paste0("Utah Student Demographics (", max_year, ")"),
    subtitle = "White students remain the majority, but diversity is increasing",
    x = "Number of Students",
    y = NULL
  )

## ----pacific-islander---------------------------------------------------------
pi_districts <- enr_latest |>
  filter(is_district, grade_level == "TOTAL", subgroup == "pacific_islander") |>
  filter(n_students > 100) |>
  mutate(pct = round(pct * 100, 2)) |>
  select(district_name, n_students, pct) |>
  arrange(desc(pct)) |>
  head(10)

pi_districts

## ----pacific-islander-chart---------------------------------------------------
pi_districts |>
  mutate(district_name = forcats::fct_reorder(district_name, pct)) |>
  ggplot(aes(x = pct, y = district_name, fill = n_students)) +
  geom_col() +
  scale_fill_viridis_c(option = "plasma", labels = scales::comma) +
  labs(
    title = "Pacific Islander Students as % of District Enrollment",
    subtitle = "Utah has one of the highest PI student populations nationally",
    x = "Percent of District",
    y = NULL,
    fill = "Students"
  )

## ----utah-county--------------------------------------------------------------
utah_county <- enr |>
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL",
         grepl("Alpine|Provo|Nebo", district_name, ignore.case = TRUE)) |>
  group_by(district_name) |>
  summarize(
    first_year = n_students[end_year == min_year],
    last_year = n_students[end_year == max_year],
    pct_change = round((last_year / first_year - 1) * 100, 1),
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
    first_year = n_students[end_year == min_year],
    last_year = n_students[end_year == max_year],
    pct_change = round((last_year / first_year - 1) * 100, 1),
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

## ----washington-chart---------------------------------------------------------
washington |>
  ggplot(aes(x = end_year, y = n_students)) +
  geom_area(fill = "#E65100", alpha = 0.3) +
  geom_line(color = "#E65100", linewidth = 1.2) +
  geom_point(color = "#E65100", size = 3) +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title = "Washington County School District Enrollment",
    subtitle = "St. George area leads Utah in enrollment growth",
    x = "School Year",
    y = "Total Enrollment"
  )

## ----charters-----------------------------------------------------------------
state_total <- enr_latest |>
  filter(is_state, subgroup == "total_enrollment", grade_level == "TOTAL") |>
  pull(n_students)

charter_total <- enr_latest |>
  filter(is_charter, subgroup == "total_enrollment", grade_level == "TOTAL") |>
  summarize(charter_total = sum(n_students, na.rm = TRUE)) |>
  pull(charter_total)

charter_summary <- tibble(
  sector = c("All Public Schools", "Charter Schools"),
  enrollment = c(state_total, charter_total),
  pct = c(100, round(charter_total / state_total * 100, 1))
)

charter_summary

## ----charters-chart-----------------------------------------------------------
tibble(
  sector = c("Traditional Districts", "Charter Schools"),
  enrollment = c(state_total - charter_total, charter_total)
) |>
  mutate(pct = enrollment / sum(enrollment) * 100,
         label = paste0(round(pct, 1), "%")) |>
  ggplot(aes(x = "", y = enrollment, fill = sector)) +
  geom_col(width = 1) +
  coord_polar(theta = "y") +
  geom_text(aes(label = label), position = position_stack(vjust = 0.5), color = "white", size = 5) +
  scale_fill_manual(values = c("Traditional Districts" = "#1976D2", "Charter Schools" = "#43A047")) +
  labs(
    title = paste0("Utah Public School Enrollment by Sector (", max_year, ")"),
    subtitle = "Charter schools serve a growing share of students",
    fill = NULL
  ) +
  theme_void() +
  theme(legend.position = "bottom", plot.title = element_text(hjust = 0.5), plot.subtitle = element_text(hjust = 0.5))

## ----covid-k------------------------------------------------------------------
covid_grades <- enr |>
  filter(is_state, subgroup == "total_enrollment",
         grade_level %in% c("K", "01", "05", "09")) |>
  select(end_year, grade_level, n_students) |>
  pivot_wider(names_from = grade_level, values_from = n_students)

covid_grades

## ----covid-chart--------------------------------------------------------------
enr |>
  filter(is_state, subgroup == "total_enrollment",
         grade_level %in% c("K", "01", "05", "09")) |>
  mutate(grade_level = factor(grade_level, levels = c("K", "01", "05", "09"),
                               labels = c("Kindergarten", "1st Grade", "5th Grade", "9th Grade"))) |>
  ggplot(aes(x = end_year, y = n_students, color = grade_level)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 2) +
  geom_vline(xintercept = 2021, linetype = "dashed", alpha = 0.5) +
  annotate("text", x = 2021, y = max(covid_grades$K) * 1.05, label = "COVID", hjust = -0.1, size = 3) +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title = "Utah Grade-Level Enrollment Over Time",
    subtitle = "Kindergarten recovered quickly after the 2020-21 dip",
    x = "School Year",
    y = "Enrollment",
    color = "Grade"
  )

## ----high-school--------------------------------------------------------------
hs_trend <- enr |>
  filter(is_state, subgroup == "total_enrollment",
         grade_level %in% c("09", "10", "11", "12")) |>
  group_by(end_year) |>
  summarize(hs_total = sum(n_students, na.rm = TRUE), .groups = "drop") |>
  mutate(change = hs_total - lag(hs_total),
         pct_change = round(change / lag(hs_total) * 100, 1))

hs_trend

## ----high-school-chart--------------------------------------------------------
hs_trend |>
  ggplot(aes(x = end_year, y = hs_total)) +
  geom_area(fill = "#7B1FA2", alpha = 0.3) +
  geom_line(color = "#7B1FA2", linewidth = 1.2) +
  geom_point(color = "#7B1FA2", size = 3) +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title = "Utah High School Enrollment (Grades 9-12)",
    subtitle = "Steady growth as larger cohorts reach high school",
    x = "School Year",
    y = "Total HS Enrollment"
  )

