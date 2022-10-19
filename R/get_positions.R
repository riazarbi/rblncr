get_positions <- function(connection) {
  
  # backend implementations
  if(connection$backend == "alpaca") {
    positions <- alpaca_positions(connection)
    positions <- dplyr::select(positions, symbol, qty)
    positions <- dplyr::rename(positions, quantity = qty)
    
  } else {
    stop("backend connection failed")
  }
  
  # generic tests
  test <- identical(colnames(positions), c("symbol", "quantity"))
  
  if(!test) {
    stop("data validation failed")
  } else {
    return(positions)
  }
}
