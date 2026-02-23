# utschooldata

Fetch and analyze Utah school enrollment data from
[USBE](https://schools.utah.gov/datastatistics/reports) in R or Python.

## Why This Package?

Utah is one of the fastest-growing states with the youngest population
in America, yet school enrollment patterns defy simple narratives. While
total enrollment grew 7% since 2014, it has fallen three of the last
four years. Kindergarten enrollment has dropped 14%. Suburban districts
along the Wasatch Front are holding steady while Salt Lake City schools
have lost 21% of students since 2019. Hispanic enrollment is up 46%, and
the English learner population grew 70%.

This package provides direct access to Utah State Board of Education
enrollment data–no manual downloads, no web scraping fragility, just
clean data ready for analysis.

Part of the [state schooldata
project](https://github.com/almartin82/njschooldata), extending the
original [njschooldata](https://github.com/almartin82/njschooldata)
package to all 50 states.

## R Quick Start

``` r
# install.packages("devtools")
devtools::install_github("almartin82/utschooldata")

library(utschooldata)
library(dplyr)

# Get 2026 enrollment data
enr <- fetch_enr(2026, use_cache = TRUE)

# View state totals
enr |>
  filter(is_state, subgroup == "total_enrollment", grade_level == "TOTAL") |>
  select(end_year, n_students)
#> # A tibble: 1 x 2
#>   end_year n_students
#>      <dbl>      <dbl>
#> 1     2026     656310
```

## Python Quick Start

``` python
import pyutschooldata as ut

# Fetch 2026 data
enr = ut.fetch_enr(2026)

# Statewide total
total = enr[(enr['is_state']) &
            (enr['grade_level'] == 'TOTAL') &
            (enr['subgroup'] == 'total_enrollment')]['n_students'].sum()
print(f"{total:,} students")
# 656,310 students

# Check available years
years = ut.get_available_years()
print(f"Data available: {min(years)}-{max(years)}")
# Data available: 2014-2026
```

------------------------------------------------------------------------

## 15 Insights from Utah School Enrollment Data

### 1. Utah grew 7% since 2014 but is now declining

Utah added over 44,000 students from 2014 to its 2022 peak, but
enrollment has fallen three of the last four years, dropping below
660,000 in 2026.

``` r
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

stopifnot(nrow(state_totals) > 0)
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
#> 13     2026     656310 -11479      -1.72
```

![Statewide
enrollment](https://almartin82.github.io/utschooldata/articles/enrollment_hooks_files/figure-html/statewide-chart-1.png)

Statewide enrollment

------------------------------------------------------------------------

### 2. Granite and Alpine are Utah’s enrollment giants

Utah’s two largest districts–Alpine and Granite–anchor the Wasatch
Front, but their trajectories differ. Salt Lake District has seen steep
declines while suburban districts hold steady.

``` r
large_districts <- enr |>
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL",
         district_name %in% c("Granite District", "Alpine District", "Davis District",
                              "Jordan District", "Canyons District", "Salt Lake District")) |>
  select(end_year, district_name, n_students)

stopifnot(nrow(large_districts) > 0)

large_districts |>
  filter(end_year == max(end_year)) |>
  arrange(desc(n_students))
#> # A tibble: 6 x 3
#>   end_year district_name      n_students
#>      <dbl> <chr>                   <dbl>
#> 1     2026 Alpine District         84215
#> 2     2026 Davis District          67466
#> 3     2026 Jordan District         55820
#> 4     2026 Granite District        54467
#> 5     2026 Canyons District        31499
#> 6     2026 Salt Lake District      17649
```

![Top
districts](https://almartin82.github.io/utschooldata/articles/enrollment_hooks_files/figure-html/top-districts-chart-1.png)

Top districts

------------------------------------------------------------------------

### 3. Utah’s student body is diversifying

While Utah remains less diverse than national averages, Hispanic
enrollment has grown substantially over the past decade, now
representing nearly 22% of students.

``` r
enr_latest <- fetch_enr(max_year, use_cache = TRUE)

demographics <- enr_latest |>
  filter(is_state, grade_level == "TOTAL",
         subgroup %in% c("hispanic", "white", "black", "asian", "native_american", "pacific_islander", "multiracial")) |>
  mutate(pct = round(pct * 100, 1)) |>
  select(subgroup, n_students, pct) |>
  arrange(desc(n_students))

stopifnot(nrow(demographics) > 0)
demographics
#> # A tibble: 7 x 3
#>   subgroup         n_students   pct
#>   <chr>                 <dbl> <dbl>
#> 1 white                451812  68.8
#> 2 hispanic             142284  21.7
#> 3 multiracial           25385   3.9
#> 4 asian                 11385   1.7
#> 5 pacific_islander      10973   1.7
#> 6 black                  8806   1.3
#> 7 native_american        5665   0.9
```

![Demographics](https://almartin82.github.io/utschooldata/articles/enrollment_hooks_files/figure-html/demographics-chart-1.png)

Demographics

------------------------------------------------------------------------

### 4. Pacific Islander students are a unique Utah story

Utah has one of the highest concentrations of Pacific Islander students
in the nation, reflecting the state’s significant Polynesian community,
particularly in Salt Lake County.

``` r
pi_districts <- enr_latest |>
  filter(is_district, grade_level == "TOTAL", subgroup == "pacific_islander") |>
  filter(n_students > 100) |>
  mutate(pct = round(pct * 100, 2)) |>
  select(district_name, n_students, pct) |>
  arrange(desc(pct)) |>
  head(10)

stopifnot(nrow(pi_districts) > 0)
pi_districts
#> # A tibble: 10 x 3
#>    district_name                  n_students   pct
#>    <chr>                               <dbl> <dbl>
#>  1 Mana Academy Charter School           193 64.12
#>  2 Wallace Stegner Academy               145  5.09
#>  3 Salt Lake District                    886  5.02
#>  4 Granite District                     2146  3.94
#>  5 Logan City District                   160  3.15
#>  6 Provo District                        388  2.98
#>  7 Jordan District                      1275  2.28
#>  8 Tooele District                       340  2.16
#>  9 Alpine District                      1331  1.58
#> 10 Davis District                       1023  1.52
```

![Pacific
Islander](https://almartin82.github.io/utschooldata/articles/enrollment_hooks_files/figure-html/pacific-islander-chart-1.png)

Pacific Islander

------------------------------------------------------------------------

### 5. Nebo District is the Utah County growth leader

Provo, Alpine, and Nebo districts in Utah County show diverging paths
since 2019. Nebo grew 26% while Provo lost nearly 20% of students as
young families settle further south along the I-15 corridor.

``` r
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
#> 1 Nebo District        33117     41675       25.8
#> 2 Alpine District      79748     84215        5.6
#> 3 Provo District       16165     13010      -19.5
```

![Growth
chart](https://almartin82.github.io/utschooldata/articles/enrollment_hooks_files/figure-html/growth-chart-1.png)

Growth chart

------------------------------------------------------------------------

### 6. Rural districts face decline

While the Wasatch Front booms, rural districts in southern and eastern
Utah face enrollment pressure as families move to urban centers for jobs
and services.

``` r
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
#> 1 Emery District          2181      1907      -12.6
#> 2 Carbon District         3484      3135      -10.0
#> 3 Grand District          1520      1376       -9.5
#> 4 San Juan District       2876      2725       -5.3
#> 5 Millard District        2916      2997        2.8
```

![Regional
chart](https://almartin82.github.io/utschooldata/articles/enrollment_hooks_files/figure-html/regional-chart-1.png)

Regional chart

------------------------------------------------------------------------

### 7. Washington County is Utah’s fastest-growing region

The St. George area (Washington County School District) has exploded
with growth as retirees and remote workers flock to southern Utah,
though growth has slowed since 2023.

``` r
washington <- enr |>
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL",
         district_name == "Washington District") |>
  select(end_year, district_name, n_students) |>
  mutate(change = n_students - lag(n_students),
         pct_change = round(change / lag(n_students) * 100, 1))

stopifnot(nrow(washington) > 0)
washington
#> # A tibble: 8 x 5
#>   end_year district_name       n_students change pct_change
#>      <dbl> <chr>                    <dbl>  <dbl>      <dbl>
#> 1     2019 Washington District      31074     NA       NA
#> 2     2020 Washington District      33884   2810        9.0
#> 3     2021 Washington District      35346   1462        4.3
#> 4     2022 Washington District      36453   1107        3.1
#> 5     2023 Washington District      36623    170        0.5
#> 6     2024 Washington District      36753    130        0.4
#> 7     2025 Washington District      36006   -747       -2.0
#> 8     2026 Washington District      34396  -1610       -4.5
```

![Washington
County](https://almartin82.github.io/utschooldata/articles/enrollment_hooks_files/figure-html/washington-chart-1.png)

Washington County

------------------------------------------------------------------------

### 8. Charter schools serve over a quarter of Utah students

Utah has a robust charter school sector, with over 26% of public school
students attending charter schools–one of the highest rates in the
nation.

``` r
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

stopifnot(nrow(charter_summary) > 0)
charter_summary
#> # A tibble: 2 x 3
#>   sector             enrollment   pct
#>   <chr>                   <dbl> <dbl>
#> 1 All Public Schools     656310 100
#> 2 Charter Schools        170536  26
```

![Charters](https://almartin82.github.io/utschooldata/articles/enrollment_hooks_files/figure-html/charters-chart-1.png)

Charters

------------------------------------------------------------------------

### 9. Kindergarten enrollment dipped during COVID and keeps falling

Unlike many states that saw a COVID bounce-back, Utah kindergarten
enrollment has continued to decline, dropping from 50,363 in 2014 to
43,519 in 2026.

``` r
covid_grades <- enr |>
  filter(is_state, subgroup == "total_enrollment",
         grade_level %in% c("K", "01", "05", "09")) |>
  select(end_year, grade_level, n_students) |>
  pivot_wider(names_from = grade_level, values_from = n_students)

stopifnot(nrow(covid_grades) > 0)
covid_grades
#> # A tibble: 13 x 5
#>    end_year     K    01    05    09
#>       <dbl> <dbl> <dbl> <dbl> <dbl>
#>  1     2014 50363 51424 48499 45721
#>  2     2015 48859 51431 49181 46699
#>  3     2016 48327 50322 49563 47616
#>  4     2017 48242 49981 51455 48522
#>  5     2018 47605 49812 53389 50125
#>  6     2019 49081 49081 53465 51044
#>  7     2020 48789 50699 52766 51908
#>  8     2021 46874 49242 51542 53340
#>  9     2022 48744 49624 51764 55245
#> 10     2023 46655 50346 50921 55330
#> 11     2024 45217 48138 52547 54351
#> 12     2025 44776 46313 51677 53658
#> 13     2026 43519 45232 51133 53318
```

![COVID
grades](https://almartin82.github.io/utschooldata/articles/enrollment_hooks_files/figure-html/covid-chart-1.png)

COVID grades

------------------------------------------------------------------------

### 10. High school enrollment surged 24% since 2014

As larger elementary cohorts from the 2010s moved through the system,
Utah high schools saw significant enrollment growth–though 2026 marks
the first decline.

``` r
hs_trend <- enr |>
  filter(is_state, subgroup == "total_enrollment",
         grade_level %in% c("09", "10", "11", "12")) |>
  group_by(end_year) |>
  summarize(hs_total = sum(n_students, na.rm = TRUE), .groups = "drop") |>
  mutate(change = hs_total - lag(hs_total),
         pct_change = round(change / lag(hs_total) * 100, 1))

stopifnot(nrow(hs_trend) > 0)
hs_trend
#> # A tibble: 13 x 4
#>    end_year hs_total change pct_change
#>       <dbl>    <dbl>  <dbl>      <dbl>
#>  1     2014   173049     NA       NA
#>  2     2015   178071   5022        2.9
#>  3     2016   183492   5421        3.0
#>  4     2017   187727   4235        2.3
#>  5     2018   192340   4613        2.5
#>  6     2019   196008   3668        1.9
#>  7     2020   200437   4429        2.3
#>  8     2021   205808   5371        2.7
#>  9     2022   210817   5009        2.4
#> 10     2023   214148   3331        1.6
#> 11     2024   216094   1946        0.9
#> 12     2025   216526    432        0.2
#> 13     2026   214601  -1925       -0.9
```

![High
school](https://almartin82.github.io/utschooldata/articles/enrollment_hooks_files/figure-html/high-school-chart-1.png)

High school

------------------------------------------------------------------------

### 11. Hispanic enrollment grew 46% since 2014

Utah’s Hispanic student population has grown significantly faster than
overall enrollment, adding nearly 45,000 students in just over a decade.

``` r
hispanic <- enr |>
  filter(is_state, grade_level == "TOTAL", subgroup == "hispanic") |>
  select(end_year, n_students) |>
  mutate(change = n_students - lag(n_students),
         pct_change = round(change / lag(n_students) * 100, 1))

stopifnot(nrow(hispanic) > 0)
hispanic
#> # A tibble: 13 x 4
#>    end_year n_students change pct_change
#>       <dbl>      <dbl>  <dbl>      <dbl>
#>  1     2014      97388     NA       NA
#>  2     2015     101390   4002        4.1
#>  3     2016     104457   3067        3.0
#>  4     2017     108074   3617        3.5
#>  5     2018     110931   2857        2.6
#>  6     2019     113945   3014        2.7
#>  7     2020     117486   3541        3.1
#>  8     2021     119393   1907        1.6
#>  9     2022     126467   7074        5.9
#> 10     2023     131954   5487        4.3
#> 11     2024     132110    156        0.1
#> 12     2025     142267  10157        7.7
#> 13     2026     142284     17        0.0
```

![Hispanic
growth](https://almartin82.github.io/utschooldata/articles/enrollment_hooks_files/figure-html/hispanic-chart-1.png)

Hispanic growth

------------------------------------------------------------------------

### 12. English learner population grew 70% since 2014

The number of English learners (ELL/LEP) in Utah schools has grown from
34,000 to over 58,000 since 2014–a 70% increase that outpaces overall
enrollment growth by nearly 10x.

``` r
ell_trend <- enr |>
  filter(is_state, grade_level == "TOTAL", subgroup == "lep") |>
  select(end_year, n_students, pct) |>
  mutate(pct = round(pct * 100, 1),
         change = n_students - lag(n_students),
         pct_change = round(change / lag(n_students) * 100, 1))

stopifnot(nrow(ell_trend) > 0)
ell_trend
#> # A tibble: 13 x 5
#>    end_year n_students   pct change pct_change
#>       <dbl>      <dbl> <dbl>  <dbl>      <dbl>
#>  1     2014      34394   5.6     NA       NA
#>  2     2015      37033   6.0   2639        7.7
#>  3     2016      38414   6.1   1381        3.7
#>  4     2017      39662   6.2   1248        3.2
#>  5     2018      43763   6.7   4101       10.3
#>  6     2019      49374   7.5   5611       12.8
#>  7     2020      53234   8.0   3860        7.8
#>  8     2021      52788   7.9   -446       -0.8
#>  9     2022      55546   8.2   2758        5.2
#> 10     2023      59176   8.8   3630        6.5
#> 11     2024      59147   8.8    -29        0.0
#> 12     2025      61481   9.2   2334        3.9
#> 13     2026      58419   8.9  -3062       -5.0
```

![ELL
growth](https://almartin82.github.io/utschooldata/articles/enrollment_hooks_files/figure-html/ell-chart-1.png)

ELL growth

------------------------------------------------------------------------

### 13. Nearly 1 in 3 students are economically disadvantaged

About 28% of Utah students qualify as economically disadvantaged–lower
than the national average but still representing over 186,000 students.

``` r
special_pops <- enr_latest |>
  filter(is_state, grade_level == "TOTAL",
         subgroup %in% c("econ_disadv", "lep", "special_ed")) |>
  mutate(pct = round(pct * 100, 1)) |>
  select(subgroup, n_students, pct) |>
  arrange(desc(n_students))

stopifnot(nrow(special_pops) > 0)
special_pops
#> # A tibble: 3 x 3
#>   subgroup    n_students   pct
#>   <chr>            <dbl> <dbl>
#> 1 econ_disadv     186361  28.4
#> 2 special_ed       89893  13.7
#> 3 lep              58419   8.9
```

![Special
populations](https://almartin82.github.io/utschooldata/articles/enrollment_hooks_files/figure-html/special-pops-chart-1.png)

Special populations

------------------------------------------------------------------------

### 14. Kindergarten enrollment dropped 14% since 2014

Utah kindergarten enrollment has fallen from 50,363 in 2014 to 43,519 in
2026–a 14% decline–even as high school grades hit record levels. This
signals future total enrollment declines.

``` r
grades <- enr_latest |>
  filter(is_state, subgroup == "total_enrollment") |>
  filter(!grade_level %in% c("TOTAL")) |>
  select(grade_level, n_students) |>
  arrange(desc(n_students))

stopifnot(nrow(grades) > 0)
grades
#> # A tibble: 14 x 2
#>    grade_level n_students
#>    <chr>            <dbl>
#>  1 12               53982
#>  2 11               53721
#>  3 10               53580
#>  4 09               53318
#>  5 07               52826
#>  6 08               51752
#>  7 06               51547
#>  8 05               51133
#>  9 04               50931
#> 10 03               48524
#> 11 02               46245
#> 12 01               45232
#> 13 K                43519
#> 14 PK               14869
```

![Grade
distribution](https://almartin82.github.io/utschooldata/articles/enrollment_hooks_files/figure-html/grade-distribution-chart-1.png)

Grade distribution

------------------------------------------------------------------------

### 15. Salt Lake City district lost 21% of students since 2019

While suburban districts hold steady, Salt Lake City School District has
declined from over 22,000 to under 18,000 students–a loss driven by
housing costs and demographic shifts in the urban core.

``` r
salt_lake <- enr |>
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL",
         district_name == "Salt Lake District") |>
  select(end_year, district_name, n_students) |>
  mutate(change = n_students - lag(n_students),
         pct_change = round(change / lag(n_students) * 100, 1))

stopifnot(nrow(salt_lake) > 0)
salt_lake
#> # A tibble: 8 x 5
#>   end_year district_name      n_students change pct_change
#>      <dbl> <chr>                   <dbl>  <dbl>      <dbl>
#> 1     2019 Salt Lake District      22401     NA       NA
#> 2     2020 Salt Lake District      22017   -384       -1.7
#> 3     2021 Salt Lake District      20536  -1481       -6.7
#> 4     2022 Salt Lake District      19833   -703       -3.4
#> 5     2023 Salt Lake District      19449   -384       -1.9
#> 6     2024 Salt Lake District      18966   -483       -2.5
#> 7     2025 Salt Lake District      18535   -431       -2.3
#> 8     2026 Salt Lake District      17649   -886       -4.8
```

![Salt Lake
decline](https://almartin82.github.io/utschooldata/articles/enrollment_hooks_files/figure-html/salt-lake-chart-1.png)

Salt Lake decline

------------------------------------------------------------------------

## Summary

Utah’s school enrollment data reveals:

- **Recent decline**: After years of growth, Utah enrollment peaked in
  2022 and has fallen since
- **Wasatch Front dominance**: The Salt Lake-Provo corridor holds most
  students
- **Southern boom**: Washington County (St. George) grew fastest but is
  now slowing
- **Rural challenges**: Eastern Utah districts losing students to urban
  areas
- **Diversifying demographics**: Hispanic and Pacific Islander
  populations growing
- **Charter expansion**: Charter schools serve over 26% of students
- **Grade-level shift**: Kindergarten declining 14% while high school
  grew 24%

These patterns reflect Utah’s unique demographics–the youngest state in
the nation–and rapid population growth along the Wasatch Front and in
southwestern Utah.

------------------------------------------------------------------------

## Data Notes

### Data Source

Data is downloaded from the Utah State Board of Education (USBE) Data
and Statistics portal:

- **Primary URL**: <https://schools.utah.gov/datastatistics/reports>
- **File Pattern**: `{YEAR}FallEnrollmentGradeLevelDemographics.xlsx`
- **Collection Date**: October 1 of each school year (Fall Enrollment
  count)

### Years Available

| Era     | Years     | Format        | Notes                                           |
|---------|-----------|---------------|-------------------------------------------------|
| Current | 2014-2026 | Excel (.xlsx) | Fall Enrollment by Grade Level and Demographics |

**Earliest available year**: 2014 **Most recent available year**: 2026
**Total years of data**: 13 years

### Aggregation Levels

- **State**: Total Utah enrollment
- **District (LEA)**: Local Education Agency totals (aggregated from
  schools)
- **Campus (School)**: Individual school enrollment

### Demographics Available

| Category            | Fields                                                                        |
|---------------------|-------------------------------------------------------------------------------|
| Race/Ethnicity      | White, Black, Hispanic, Asian, Native American, Pacific Islander, Multiracial |
| Gender              | Male, Female                                                                  |
| Special Populations | Economically Disadvantaged, English Learners (ELL/LEP), Special Education     |
| Grade Levels        | Pre-K, K, 1-12                                                                |

### Known Caveats

1.  **Data Suppression**: Small cell sizes may be suppressed for privacy
    (typically N \< 10)
2.  **Charter Schools**: Charter schools are included and can be
    identified where the charter_flag column is available
3.  **Historical Changes**: District boundaries and school
    configurations may change year to year
4.  **October 1 Count**: All enrollment figures represent the official
    October 1 count date

------------------------------------------------------------------------

## Output Schema

### Tidy Format (`tidy = TRUE`, default)

| Column        | Type      | Description                                |
|---------------|-----------|--------------------------------------------|
| end_year      | integer   | School year end                            |
| type          | character | Aggregation level                          |
| district_id   | character | LEA identifier                             |
| campus_id     | character | School identifier                          |
| district_name | character | LEA name                                   |
| campus_name   | character | School name                                |
| grade_level   | character | “TOTAL”, “PK”, “K”, “01”-“12”              |
| subgroup      | character | “total_enrollment”, “white”, “black”, etc. |
| n_students    | integer   | Student count                              |
| pct           | numeric   | Percentage of total (0-1 scale)            |
| is_state      | logical   | TRUE for state-level rows                  |
| is_district   | logical   | TRUE for district-level rows               |
| is_campus     | logical   | TRUE for school-level rows                 |
| is_charter    | logical   | TRUE for charter schools                   |

### Wide Format (`tidy = FALSE`)

| Column                                                                        | Type      | Description                                  |
|-------------------------------------------------------------------------------|-----------|----------------------------------------------|
| end_year                                                                      | integer   | School year end (2024 = 2023-24 school year) |
| type                                                                          | character | “State”, “District”, or “Campus”             |
| district_id                                                                   | character | LEA identifier                               |
| campus_id                                                                     | character | School identifier                            |
| district_name                                                                 | character | LEA name                                     |
| campus_name                                                                   | character | School name                                  |
| row_total                                                                     | integer   | Total enrollment                             |
| white, black, hispanic, asian, native_american, pacific_islander, multiracial | integer   | Race/ethnicity counts                        |
| male, female                                                                  | integer   | Gender counts                                |
| econ_disadv, lep, special_ed                                                  | integer   | Special population counts                    |
| grade_pk, grade_k, grade_01 - grade_12                                        | integer   | Grade-level enrollment                       |

------------------------------------------------------------------------

## Caching

The package caches downloaded data locally to avoid repeated downloads:

``` r
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

------------------------------------------------------------------------

## Functions

### User-facing (exported)

- `fetch_enr(end_year, tidy = TRUE, use_cache = TRUE)` - Fetch
  enrollment data for a single year
- `fetch_enr_multi(end_years, tidy = TRUE, use_cache = TRUE)` - Fetch
  data for multiple years
- `tidy_enr(df)` - Transform wide format to tidy format
- [`get_available_years()`](https://almartin82.github.io/utschooldata/reference/get_available_years.md) -
  List available data years
- `id_enr_aggs(df)` - Add aggregation level flags
- `enr_grade_aggs(df)` - Create K-8, HS, K-12 grade aggregates
- [`cache_status()`](https://almartin82.github.io/utschooldata/reference/cache_status.md) -
  Show cached data status
- `clear_cache(end_year, type)` - Clear cached data

------------------------------------------------------------------------

## Part of the State Schooldata Project

A simple, consistent interface for accessing state-published school data
in Python and R.

**All 50 state packages:**
[github.com/almartin82](https://github.com/almartin82?tab=repositories&q=schooldata)

**Original package:**
[njschooldata](https://github.com/almartin82/njschooldata) - New Jersey
school data (the mothership)

------------------------------------------------------------------------

## License

MIT
