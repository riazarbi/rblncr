get_positions <- function(connection) {
  
  # backend implementations
  if(connection$backend == "alpaca") {
    positions <- alpaca_positions(connection)
    if((length(colnames(positions))) == 0) {
      positions <- data.frame(symbol = character(), qty = character())
    }
    positions <- dplyr::select(positions, symbol, qty)
    positions <- dplyr::rename(positions, quantity_held = qty)
    positions <- dplyr::mutate(positions, quantity_held = as.numeric(quantity_held))
    
  } else {
    stop("backend connection failed")
  }
  
  # generic tests
  test <- identical(colnames(positions), c("symbol", "quantity_held"))
  
  if(!test) {
    stop("data validation failed")
  } else {
    return(positions)
  }
}
