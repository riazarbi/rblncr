#' Get positions from backend
#'
#' @param connection a trading backend connection
#'
#' @return a data frame of stock positions
#' @export
#' @importFrom rlang .data
#' @importFrom dplyr select rename mutate
#'
get_positions <- function(connection) {

  # backend implementations
  if(connection$backend == "alpaca") {
    positions <- alpaca_positions(connection)
  } else {
    stop("backend connection failed")
  }

  if(!test) {
    stop("data validation failed")
  } else {
    return(positions)
  }
}
