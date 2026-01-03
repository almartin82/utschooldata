# Standardize numeric column types

Converts columns that should be numeric to numeric type, handling
suppression markers. This ensures consistent types when binding data
frames from different sheets.

## Usage

``` r
standardize_numeric_columns(df)
```

## Arguments

- df:

  Data frame with potentially mixed column types

## Value

Data frame with standardized numeric columns
