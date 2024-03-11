validate_account_class <- function(data) {
  
  if ("account" %in% class(data)) {
    # If "account" class is already present, return the object as is
    return(data)
  }
  
  # Check number of rows
  if (nrow(data) != 1) {
    stop("Error: Number of rows is not 1.")
  }
  
  # Check number of columns
  if (ncol(data) != 6) {
    stop("Error: Number of columns is not 6.")
  }
  
  # Check column names
  expected_column_names <- c("account_number", "status", "currency", "cash", "equity", "portfolio_value")
  if (!all(validate_columns(data, expected_column_types))) {
    stop("Error: Column types are incorrect.")
  }
  
  
  # Check column types
  expected_column_types <- c("character", "character", "character", "numeric", "numeric", "numeric")
  if (!all(sapply(data, class) == expected_column_types)) {
    stop("Error: Column types are incorrect.")
  }
  
  # Check for NULL values
  if (any(is.null(data))) {
    stop("Error: There are NULL values in the data.")
  }
  
  # Add class "account"
  class(data) <- c("account", class(data))
  
  # If all checks passed, return the original object
  return(data)
}
