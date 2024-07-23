ib_positions <- function(ib_connection) {
  endpoint <-  paste0("/v1/api/portfolio/",ib_connection$account_id,"/positions")
  result <- ib_query(endpoint, ib_connection)
  positions <- jsonlite::fromJSON(result, flatten = TRUE)
  if((length(colnames(positions))) == 0) {
    positions <- data.frame(symbol = character(), qty = character())
  }
  
  positions <- dplyr::select(positions, "conid", "position")
  positions <- dplyr::rename(positions, quantity_held = "position")
  positions <- dplyr::rename(positions, symbol = "conid")
  positions <- dplyr::mutate(positions, quantity_held = as.numeric(.data$quantity_held))
  positions <- dplyr::mutate(positions, symbol = as.character(.data$symbol))
  positions <- validate_positions_class(positions)
  return(positions)
}