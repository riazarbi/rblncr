validate_clock_class <- function(data) {
  # Check number of rows
  if (nrow(data) != 1) {
    stop("Error: Number of rows is not 1.")
  }
  
  # Check if all columns are present
  expected_columns <- c("timestamp", "is_open", "next_open", "next_close")
  if (!all(expected_columns %in% names(data))) {
    stop("Error: Missing one or more columns.")
  }
  
  # Check column types
  expected_column_types <- c("POSIXt", "logical", "POSIXt", "POSIXt")
  if (!all(validate_columns(data, expected_column_types))) {
    stop("Error: Column types are incorrect.")
  }
  
  purrr::map2(sapply(data, class), expected_column_types, ~ .y %in% .x )
  
  # Check for NULL values
  if (any(is.na(data))) {
    stop("Error: There are NULL values in the data.")
  }
  
  # Return the original object with added class "clock"
  class(data) <- c("clock", class(data))
  return(data)
}
