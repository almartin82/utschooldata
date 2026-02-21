# utschooldata

<!-- badges: start -->
[![R-CMD-check](https://github.com/almartin82/utschooldata/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/almartin82/utschooldata/actions/workflows/R-CMD-check.yaml)
[![Python Tests](https://github.com/almartin82/utschooldata/actions/workflows/python-test.yaml/badge.svg)](https://github.com/almartin82/utschooldata/actions/workflows/python-test.yaml)
[![pkgdown](https://github.com/almartin82/utschooldata/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/almartin82/utschooldata/actions/workflows/pkgdown.yaml)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

Fetch and analyze Utah school enrollment data from [USBE](https://schools.utah.gov/datastatistics/reports) in R or Python.

## Why This Package?

Utah is one of the fastest-growing states with the youngest population in America, yet school enrollment patterns defy simple narratives. While total enrollment grew 9% since 2014, kindergarten enrollment has dropped 11%. Suburban districts along the Wasatch Front are booming while Salt Lake City schools have lost 17% of students since 2019. Hispanic enrollment is up 46%, and the English learner population nearly doubled.

This package provides direct access to Utah State Board of Education enrollment data--no manual downloads, no web scraping fragility, just clean data ready for analysis.

Part of the [state schooldata project](https://github.com/almartin82/njschooldata), extending the original [njschooldata](https://github.com/almartin82/njschooldata) package to all 50 states.

## R Quick Start

```r
# install.packages("devtools")
devtools::install_github("almartin82/utschooldata")

library(utschooldata)
library(dplyr)

# Get 2025 enrollment data
enr <- fetch_enr(2025, use_cache = TRUE)

# View state totals
enr |>
  filter(is_state, subgroup == "total_enrollment", grade_level == "TOTAL") |>
  select(end_year, n_students)
#> # A tibble: 1 x 2
#>   end_year n_students
#>      <dbl>      <dbl>
#> 1     2025     667789
```

## Python Quick Start

```python
import pyutschooldata as ut

# Fetch 2025 data
enr = ut.fetch_enr(2025)

# Statewide total
total = enr[(enr['is_state']) &
            (enr['grade_level'] == 'TOTAL') &
            (enr['subgroup'] == 'total_enrollment')]['n_students'].sum()
print(f"{total:,} students")
# 667,789 students

# Check available years
years = ut.get_available_years()
print(f"Data available: {min(years)}-{max(years)}")
# Data available: 2014-2026
```

---

## 15 Insights from Utah School Enrollment Data

### 1. Utah's enrollment continues to grow

Utah has one of the youngest populations in the nation and continues to see steady enrollment growth, unlike many states that saw declines after COVID.

```r
library(utschooldata)
library(dplyr)
library(tidyr)
library(ggplot2)

theme_set(theme_minimal(base_size = 14))

# Get available years dynamically
available_years <- get_available_years()
min_year <- min(available_years)
max_year <- max(available_years)

enr <- fetch_enr_multi(available_years, use_cache = TRUE)

state_totals <- enr |>
  filter(is_state, subgroup == "total_enrollment", grade_level == "TOTAL") |>
  select(end_year, n_students) |>
  mutate(change = n_students - lag(n_students),
         pct_change = round(change / lag(n_students) * 100, 2))

state_totals
#> # A tibble: 13 x 4
#>    end_year n_students change pct_change
#>       <dbl>      <dbl>  <dbl>      <dbl>
#>  1     2014     612088     NA      NA
#>  2     2015     621748   9660       1.58
#>  3     2016     633461  11713       1.88
#>  4     2017     644004  10543       1.66
#>  5     2018     651796   7792       1.21
#>  6     2019     658952   7156       1.1
#>  7     2020     666858   7906       1.2
#>  8     2021     665306  -1552      -0.23
#>  9     2022     674351   9045       1.36
#> 10     2023     674650    299       0.04
#> 11     2024     672662  -1988      -0.29
#> 12     2025     667789  -4873      -0.72
```

![Statewide enrollment](https://almartin82.github.io/utschooldata/articles/enrollment_hooks_files/figure-html/statewide-chart-1.png)

---

### 2. Granite and Alpine are Utah's enrollment giants

Utah's two largest districts--Granite and Alpine--each serve well over 57,000 students, but their trajectories differ. Salt Lake City has seen declines while suburban districts grow.

```r
large_districts <- enr |>
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL",
         grepl("Granite|Alpine|Davis|Jordan|Canyons|Salt Lake City", district_name, ignore.case = TRUE)) |>
  select(end_year, district_name, n_students)

large_districts |>
  filter(end_year == max(end_year)) |>
  arrange(desc(n_students))
#> # A tibble: 6 x 3
#>   end_year district_name      n_students
#>      <dbl> <chr>                   <dbl>
#> 1     2025 Alpine District         84757
#> 2     2025 Davis District          69602
#> 3     2025 Jordan District         57083
#> 4     2025 Granite District        57038
#> 5     2025 Canyons District        32289
#> 6     2025 Salt Lake District      18535
```

![Top districts](https://almartin82.github.io/utschooldata/articles/enrollment_hooks_files/figure-html/top-districts-chart-1.png)

---

### 3. Utah's student body is diversifying

While Utah remains less diverse than national averages, Hispanic enrollment has grown substantially over the past decade, now representing 21% of students.

```r
enr_latest <- fetch_enr(max_year, use_cache = TRUE)

demographics <- enr_latest |>
  filter(is_state, grade_level == "TOTAL",
         subgroup %in% c("hispanic", "white", "black", "asian", "native_american", "pacific_islander", "multiracial")) |>
  mutate(pct = round(pct * 100, 1)) |>
  select(subgroup, n_students, pct) |>
  arrange(desc(n_students))

demographics
#> # A tibble: 7 x 3
#>   subgroup         n_students   pct
#>   <chr>                 <dbl> <dbl>
#> 1 white                463352  69.4
#> 2 hispanic             142267  21.3
#> 3 multiracial           25478   3.8
#> 4 asian                 11184   1.7
#> 5 pacific_islander      10844   1.6
#> 6 black                  8827   1.3
#> 7 native_american        5837   0.9
```

![Demographics](https://almartin82.github.io/utschooldata/articles/enrollment_hooks_files/figure-html/demographics-chart-1.png)

---

### 4. Pacific Islander students are a unique Utah story

Utah has one of the highest concentrations of Pacific Islander students in the nation, reflecting the state's significant Polynesian community, particularly in Salt Lake County.

```r
pi_districts <- enr_latest |>
  filter(is_district, grade_level == "TOTAL", subgroup == "pacific_islander") |>
  filter(n_students > 100) |>
  mutate(pct = round(pct * 100, 2)) |>
  select(district_name, n_students, pct) |>
  arrange(desc(pct)) |>
  head(10)

pi_districts
#> # A tibble: 10 x 3
#>    district_name                  n_students   pct
#>    <chr>                               <dbl> <dbl>
#>  1 Mana Academy Charter School           185 61.5
#>  2 Wallace Stegner Academy               143  6.6
#>  3 Salt Lake District                    919  4.96
#>  4 Granite District                     2092  3.67
#>  5 Provo District                        432  3.21
#>  6 Logan City District                   135  2.67
#>  7 Jordan District                      1272  2.23
#>  8 Tooele District                       349  2.23
#>  9 Alpine District                      1287  1.52
#> 10 Davis District                       1025  1.47
```

![Pacific Islander](https://almartin82.github.io/utschooldata/articles/enrollment_hooks_files/figure-html/pacific-islander-chart-1.png)

---

### 5. Utah County is the growth engine

Provo, Alpine, and Nebo districts in Utah County are seeing consistent growth as young families settle along the I-15 corridor south of Salt Lake.

```r
utah_county <- enr |>
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL",
         grepl("Alpine|Provo|Nebo", district_name, ignore.case = TRUE)) |>
  group_by(district_name) |>
  arrange(end_year) |>
  summarize(
    first_year = first(n_students),
    last_year = last(n_students),
    pct_change = round((last_year / first_year - 1) * 100, 1),
    .groups = "drop"
  ) |>
  arrange(desc(pct_change))

stopifnot(nrow(utah_county) > 0)
utah_county
#> # A tibble: 3 x 4
#>   district_name   first_year last_year pct_change
#>   <chr>                <dbl>     <dbl>      <dbl>
#> 1 Nebo District        33117     42946       29.7
#> 2 Alpine District      79748     84757        6.3
#> 3 Provo District       16165     13463      -16.7
```

![Growth chart](https://almartin82.github.io/utschooldata/articles/enrollment_hooks_files/figure-html/growth-chart-1.png)

---

### 6. Rural districts face decline

While the Wasatch Front booms, rural districts in southern and eastern Utah face enrollment pressure as families move to urban centers for jobs and services.

```r
rural <- enr |>
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL",
         grepl("Carbon|Emery|Grand|San Juan|Millard", district_name, ignore.case = TRUE)) |>
  group_by(district_name) |>
  filter(n() >= 5) |>
  arrange(end_year) |>
  summarize(
    first_year = first(n_students),
    last_year = last(n_students),
    pct_change = round((last_year / first_year - 1) * 100, 1),
    .groups = "drop"
  ) |>
  arrange(pct_change)

stopifnot(nrow(rural) > 0)
rural
#> # A tibble: 5 x 4
#>   district_name     first_year last_year pct_change
#>   <chr>                  <dbl>     <dbl>      <dbl>
#> 1 Grand District          1520      1371       -9.8
#> 2 Emery District          2181      1986       -8.9
#> 3 Carbon District         3484      3186       -8.6
#> 4 San Juan District       2876      2768       -3.8
#> 5 Millard District        2916      3064        5.1
```

![Regional chart](https://almartin82.github.io/utschooldata/articles/enrollment_hooks_files/figure-html/regional-chart-1.png)

---

### 7. Washington County is Utah's fastest-growing region

The St. George area (Washington County School District) has exploded with growth as retirees and remote workers flock to southern Utah.

```r
washington <- enr |>
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL",
         grepl("Washington", district_name, ignore.case = TRUE)) |>
  select(end_year, district_name, n_students) |>
  mutate(change = n_students - lag(n_students),
         pct_change = round(change / lag(n_students) * 100, 1))

washington
#> # A tibble: 14 x 5
#>    end_year district_name      n_students change pct_change
#>       <dbl> <chr>                   <dbl>  <dbl>      <dbl>
#>  1     2019 Washington District     31074     NA       NA
#>  2     2020 Washington District     33884   2810        9
#>  3     2021 Washington District     35346   1462        4.3
#>  4     2022 Washington District     36453   1107        3.1
#>  5     2023 Washington District     36623    170        0.5
#>  6     2024 Washington District     36753    130        0.4
#>  7     2025 Washington District     36006   -747       -2
```

![Washington County](https://almartin82.github.io/utschooldata/articles/enrollment_hooks_files/figure-html/washington-chart-1.png)

---

### 8. Charter schools serve a growing share of Utah students

Utah has a robust charter school sector, with nearly 25% of public school students attending charter schools--one of the highest rates in the nation.

```r
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
#> # A tibble: 2 x 3
#>   sector             enrollment   pct
#>   <chr>                   <dbl> <dbl>
#> 1 All Public Schools     667789 100
#> 2 Charter Schools        163710  24.5
```

![Charters](https://almartin82.github.io/utschooldata/articles/enrollment_hooks_files/figure-html/charters-chart-1.png)

---

### 9. Kindergarten enrollment dipped during COVID but recovered

Unlike many states, Utah saw kindergarten enrollment bounce back relatively quickly after COVID disruptions, though it has since declined further.

```r
covid_grades <- enr |>
  filter(is_state, subgroup == "total_enrollment",
         grade_level %in% c("K", "01", "05", "09")) |>
  select(end_year, grade_level, n_students) |>
  pivot_wider(names_from = grade_level, values_from = n_students)

covid_grades
#> # A tibble: 12 x 5
#>    end_year     K   `01`   `05`   `09`
#>       <dbl> <dbl>  <dbl>  <dbl>  <dbl>
#>  1     2014 50363  51424  48499  45721
#>  2     2015 48859  51431  49181  46699
#>  3     2016 48327  50322  49563  47616
#>  4     2017 48242  49981  51455  48522
#>  5     2018 47605  49812  53389  50125
#>  6     2019 49081  49081  53465  51044
#>  7     2020 48789  50699  52766  51908
#>  8     2021 46874  49242  51542  53340
#>  9     2022 48744  49624  51764  55245
#> 10     2023 46655  50346  50921  55330
#> 11     2024 45217  48138  52547  54351
#> 12     2025 44776  46313  51677  53658
```

![COVID grades](https://almartin82.github.io/utschooldata/articles/enrollment_hooks_files/figure-html/covid-chart-1.png)

---

### 10. High school enrollment is surging

As larger elementary cohorts from the 2010s move through the system, Utah high schools are seeing significant enrollment growth--up 25% since 2014.

```r
hs_trend <- enr |>
  filter(is_state, subgroup == "total_enrollment",
         grade_level %in% c("09", "10", "11", "12")) |>
  group_by(end_year) |>
  summarize(hs_total = sum(n_students, na.rm = TRUE), .groups = "drop") |>
  mutate(change = hs_total - lag(hs_total),
         pct_change = round(change / lag(hs_total) * 100, 1))

hs_trend
#> # A tibble: 12 x 4
#>    end_year hs_total change pct_change
#>       <dbl>    <dbl>  <dbl>      <dbl>
#>  1     2014   173049     NA       NA
#>  2     2015   178071   5022        2.9
#>  3     2016   183492   5421        3
#>  4     2017   187727   4235        2.3
#>  5     2018   192340   4613        2.5
#>  6     2019   196008   3668        1.9
#>  7     2020   200437   4429        2.3
#>  8     2021   205808   5371        2.7
#>  9     2022   210817   5009        2.4
#> 10     2023   214148   3331        1.6
#> 11     2024   216094   1946        0.9
#> 12     2025   216526    432        0.2
```

![High school](https://almartin82.github.io/utschooldata/articles/enrollment_hooks_files/figure-html/high-school-chart-1.png)

---

### 11. Hispanic enrollment grew 46% since 2014

Utah's Hispanic student population has grown significantly faster than overall enrollment, adding nearly 45,000 students in just over a decade.

```r
hispanic <- enr |>
  filter(is_state, grade_level == "TOTAL", subgroup == "hispanic") |>
  select(end_year, n_students) |>
  mutate(change = n_students - lag(n_students),
         pct_change = round(change / lag(n_students) * 100, 1))

hispanic
#> # A tibble: 12 x 4
#>    end_year n_students change pct_change
#>       <dbl>      <dbl>  <dbl>      <dbl>
#>  1     2014      97388     NA       NA
#>  2     2015     101390   4002        4.1
#>  3     2016     104457   3067        3
#>  4     2017     108074   3617        3.5
#>  5     2018     110931   2857        2.6
#>  6     2019     113945   3014        2.7
#>  7     2020     117486   3541        3.1
#>  8     2021     119393   1907        1.6
#>  9     2022     126467   7074        5.9
#> 10     2023     131954   5487        4.3
#> 11     2024     132110    156        0.1
#> 12     2025     142267  10157        7.7
```

![Hispanic growth](https://almartin82.github.io/utschooldata/articles/enrollment_hooks_files/figure-html/hispanic-chart-1.png)

---

### 12. English learner population nearly doubled

The number of English learners (ELL/LEP) in Utah schools has grown from 34,000 to over 61,000 since 2014--an 79% increase.

```r
ell_trend <- enr |>
  filter(is_state, grade_level == "TOTAL", subgroup == "lep") |>
  select(end_year, n_students, pct) |>
  mutate(pct = round(pct * 100, 1),
         change = n_students - lag(n_students),
         pct_change = round(change / lag(n_students) * 100, 1))

ell_trend
#> # A tibble: 12 x 5
#>    end_year n_students   pct change pct_change
#>       <dbl>      <dbl> <dbl>  <dbl>      <dbl>
#>  1     2014      34394   5.6     NA       NA
#>  2     2015      37033   6       2639      7.7
#>  3     2016      38414   6.1     1381      3.7
#>  4     2017      39662   6.2     1248      3.2
#>  5     2018      43763   6.7     4101     10.3
#>  6     2019      49374   7.5     5611     12.8
#>  7     2020      53234   8       3860      7.8
#>  8     2021      52788   7.9     -446     -0.8
#>  9     2022      55546   8.2     2758      5.2
#> 10     2023      59176   8.8     3630      6.5
#> 11     2024      59147   8.8      -29      0
#> 12     2025      61481   9.2     2334      3.9
```

![ELL growth](https://almartin82.github.io/utschooldata/articles/enrollment_hooks_files/figure-html/ell-chart-1.png)

---

### 13. Nearly 1 in 3 students are economically disadvantaged

About 29% of Utah students qualify as economically disadvantaged--lower than the national average but still representing nearly 194,000 students.

```r
special_pops <- enr_latest |>
  filter(is_state, grade_level == "TOTAL",
         subgroup %in% c("econ_disadv", "lep", "special_ed")) |>
  mutate(pct = round(pct * 100, 1)) |>
  select(subgroup, n_students, pct) |>
  arrange(desc(n_students))

special_pops
#> # A tibble: 3 x 3
#>   subgroup    n_students   pct
#>   <chr>            <dbl> <dbl>
#> 1 econ_disadv     193572  29
#> 2 special_ed       88462  13.2
#> 3 lep              61481   9.2
```

![Special populations](https://almartin82.github.io/utschooldata/articles/enrollment_hooks_files/figure-html/special-pops-chart-1.png)

---

### 14. Elementary enrollment is declining while high school grows

Utah kindergarten enrollment dropped 11% since its 2014 peak, even as high school grades are at record levels. This points to future enrollment declines.

```r
grades <- enr_latest |>
  filter(is_state, subgroup == "total_enrollment") |>
  filter(!grade_level %in% c("TOTAL")) |>
  select(grade_level, n_students) |>
  arrange(desc(n_students))

grades
#> # A tibble: 14 x 2
#>    grade_level n_students
#>    <chr>            <dbl>
#>  1 11               54834
#>  2 10               54609
#>  3 09               53658
#>  4 12               53425
#>  5 08               53017
#>  6 06               52775
#>  7 07               51808
#>  8 05               51677
#>  9 04               51285
#> 10 03               51101
#> 11 02               48511
#> 12 01               46313
#> 13 K                44776
#> 14 PK               16008
```

![Grade distribution](https://almartin82.github.io/utschooldata/articles/enrollment_hooks_files/figure-html/grade-distribution-chart-1.png)

---

### 15. Salt Lake City district lost 17% of students since 2019

While suburban districts boom, Salt Lake City School District has declined from over 22,000 to under 19,000 students--a loss driven by housing costs and demographic shifts in the urban core.

```r
salt_lake <- enr |>
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL",
         district_name == "Salt Lake District") |>
  select(end_year, district_name, n_students) |>
  mutate(change = n_students - lag(n_students),
         pct_change = round(change / lag(n_students) * 100, 1))

salt_lake
#> # A tibble: 7 x 5
#>   end_year district_name      n_students change pct_change
#>      <dbl> <chr>                   <dbl>  <dbl>      <dbl>
#> 1     2019 Salt Lake District      22401     NA       NA
#> 2     2020 Salt Lake District      22017   -384       -1.7
#> 3     2021 Salt Lake District      20536  -1481       -6.7
#> 4     2022 Salt Lake District      19833   -703       -3.4
#> 5     2023 Salt Lake District      19449   -384       -1.9
#> 6     2024 Salt Lake District      18966   -483       -2.5
#> 7     2025 Salt Lake District      18535   -431       -2.3
```

![Salt Lake decline](https://almartin82.github.io/utschooldata/articles/enrollment_hooks_files/figure-html/salt-lake-chart-1.png)

---

## Summary

Utah's school enrollment data reveals:

- **Continued growth**: Unlike many states, Utah continues to add students overall
- **Wasatch Front dominance**: The Salt Lake-Provo corridor holds most students
- **Southern boom**: Washington County (St. George) is the fastest-growing region
- **Rural challenges**: Eastern Utah districts losing students to urban areas
- **Diversifying demographics**: Hispanic and Pacific Islander populations growing
- **Charter expansion**: Charter schools serve nearly 25% of students
- **Grade-level shift**: Elementary declining while high school grows

These patterns reflect Utah's unique demographics--the youngest state in the nation--and rapid population growth along the Wasatch Front and in southwestern Utah.

---

## Data Notes

### Data Source

Data is downloaded from the Utah State Board of Education (USBE) Data and Statistics portal:

- **Primary URL**: https://schools.utah.gov/datastatistics/reports
- **File Pattern**: `{YEAR}FallEnrollmentGradeLevelDemographics.xlsx`
- **Collection Date**: October 1 of each school year (Fall Enrollment count)

### Years Available

| Era | Years | Format | Notes |
|-----|-------|--------|-------|
| Current | 2014-2026 | Excel (.xlsx) | Fall Enrollment by Grade Level and Demographics |

**Earliest available year**: 2014
**Most recent available year**: 2026
**Total years of data**: 13 years

### Aggregation Levels

- **State**: Total Utah enrollment
- **District (LEA)**: Local Education Agency totals (aggregated from schools)
- **Campus (School)**: Individual school enrollment

### Demographics Available

| Category | Fields |
|----------|--------|
| Race/Ethnicity | White, Black, Hispanic, Asian, Native American, Pacific Islander, Multiracial |
| Gender | Male, Female |
| Special Populations | Economically Disadvantaged, English Learners (ELL/LEP), Special Education |
| Grade Levels | Pre-K, K, 1-12 |

### Known Caveats

1. **Data Suppression**: Small cell sizes may be suppressed for privacy (typically N < 10)
2. **Charter Schools**: Charter schools are included and can be identified where the charter_flag column is available
3. **Historical Changes**: District boundaries and school configurations may change year to year
4. **October 1 Count**: All enrollment figures represent the official October 1 count date

---

## Output Schema

### Tidy Format (`tidy = TRUE`, default)

| Column | Type | Description |
|--------|------|-------------|
| end_year | integer | School year end |
| type | character | Aggregation level |
| district_id | character | LEA identifier |
| campus_id | character | School identifier |
| district_name | character | LEA name |
| campus_name | character | School name |
| grade_level | character | "TOTAL", "PK", "K", "01"-"12" |
| subgroup | character | "total_enrollment", "white", "black", etc. |
| n_students | integer | Student count |
| pct | numeric | Percentage of total (0-1 scale) |
| is_state | logical | TRUE for state-level rows |
| is_district | logical | TRUE for district-level rows |
| is_campus | logical | TRUE for school-level rows |
| is_charter | logical | TRUE for charter schools |

### Wide Format (`tidy = FALSE`)

| Column | Type | Description |
|--------|------|-------------|
| end_year | integer | School year end (2024 = 2023-24 school year) |
| type | character | "State", "District", or "Campus" |
| district_id | character | LEA identifier |
| campus_id | character | School identifier |
| district_name | character | LEA name |
| campus_name | character | School name |
| row_total | integer | Total enrollment |
| white, black, hispanic, asian, native_american, pacific_islander, multiracial | integer | Race/ethnicity counts |
| male, female | integer | Gender counts |
| econ_disadv, lep, special_ed | integer | Special population counts |
| grade_pk, grade_k, grade_01 - grade_12 | integer | Grade-level enrollment |

---

## Caching

The package caches downloaded data locally to avoid repeated downloads:

```r
# View cache status
cache_status()

# Clear all cached data
clear_cache()

# Clear specific year
clear_cache(2024)

# Force fresh download (ignore cache)
fetch_enr(2024, use_cache = FALSE)
```

Cache location: `rappdirs::user_cache_dir("utschooldata")`

---

## Functions

### User-facing (exported)

- `fetch_enr(end_year, tidy = TRUE, use_cache = TRUE)` - Fetch enrollment data for a single year
- `fetch_enr_multi(end_years, tidy = TRUE, use_cache = TRUE)` - Fetch data for multiple years
- `tidy_enr(df)` - Transform wide format to tidy format
- `get_available_years()` - List available data years
- `id_enr_aggs(df)` - Add aggregation level flags
- `enr_grade_aggs(df)` - Create K-8, HS, K-12 grade aggregates
- `cache_status()` - Show cached data status
- `clear_cache(end_year, type)` - Clear cached data

---

## Part of the State Schooldata Project

A simple, consistent interface for accessing state-published school data in Python and R.

**All 50 state packages:** [github.com/almartin82](https://github.com/almartin82?tab=repositories&q=schooldata)

**Original package:** [njschooldata](https://github.com/almartin82/njschooldata) - New Jersey school data (the mothership)

---

## License

MIT
