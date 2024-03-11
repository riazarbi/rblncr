validate_columns <- function(df, expected_column_types) {
purrr::map2_lgl(sapply(df, class), expected_column_types, ~ .y %in% .x )
  }