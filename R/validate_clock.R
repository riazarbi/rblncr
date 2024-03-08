validate_clock <- function(clock) {
  if (!inherits(clock, "data.frame")) {
    print("Error: 'clock' is not a data frame.")
    return(FALSE)
  }
  
  expected_vars <- c("timestamp", "is_open", "next_open", "next_close")
  if (!all(expected_vars %in% names(clock))) {
    print("Error: Missing variables in 'clock' object.")
    return(FALSE)
  }
  
  expected_types <- list(
    timestamp = "character",
    is_open = "logical",
    next_open = "character",
    next_close = "character"
  )
  
  for (var in expected_vars) {
    if (class(clock[[var]]) != expected_types[[var]]) {
      print(paste("Error: Variable '", var, "' has incorrect data type. Expected type:", expected_types[[var]]))
      return(FALSE)
    }
  }
  
  print("Validation successful: 'clock' object has the expected structure and data types.")
  return(TRUE)
}
