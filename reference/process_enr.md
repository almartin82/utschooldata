# Process raw USBE enrollment data

Transforms raw USBE data into a standardized schema with consistent
column names and types.

## Usage

``` r
process_enr(raw_data, end_year)
```

## Arguments

- raw_data:

  Data frame from get_raw_enr (combined from all sheets)

- end_year:

  School year end

## Value

Processed data frame with standardized columns
