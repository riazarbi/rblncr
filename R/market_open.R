#' Determine if the market is open
#'
#' @param connection a trading backend connection
#'
#' @return TRUE or FALSE
#' @export
#'
market_open <- function(connection) {
  
  # backend implementations
  if(connection$backend == "alpaca") {
    clock <- alpaca_clock(connection)
    is_open <- any(clock$is_open)
  } else {
    stop("backend connection failed")
  }
  
  return(is_open)
  
}
