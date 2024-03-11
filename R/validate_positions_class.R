validate_positions_class <- function(data) {
  # Check if "symbol" and "qty" columns exist
  if (!("symbol" %in% names(data)) || !("quantity_held" %in% names(data))) {
    stop("Error: Missing 'symbol' or 'qantity_held' column.")
  }
  
  # Check column types
  if (class(data$symbol) != "character" || class(data$quantity_held) != "numeric") {
    stop("Error: Column types are incorrect.")
  }
  
  # Check for NULL values
  if (any(is.na(data$symbol)) || any(is.na(data$quantity_held))) {
    stop("Error: There are NULL values in the data.")
  }
  
  # Check for negative quantity values
  if (any(data$quantity_held < 0)) {
    stop("Error: Quantity values cannot be negative.")
  }
  
  # Return the original object with added class "symbol_qty"
  class(data) <- c("positions", class(data))
  return(data)
}
