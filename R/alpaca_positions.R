alpaca_positions <- function(alpaca_connection) {
  result <- alpaca_query("/v2/positions", alpaca_connection)
  positions <- jsonlite::fromJSON(result, flatten = TRUE)
  if((length(colnames(positions))) == 0) {
    positions <- data.frame(symbol = character(), qty = character())
  }
  
  positions <- dplyr::select(positions, "symbol", "qty")
  positions <- dplyr::rename(positions, quantity_held = "qty")
  positions <- dplyr::mutate(positions, quantity_held = as.numeric(.data$quantity_held))
  positions <- validate_positions_class(positions)
}
