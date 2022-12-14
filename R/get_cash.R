#' Get cash balance from backend
#'
#' @param connection a trading backend connection
#'
#' @return a data frame cash balance
#' @export
#' @importFrom rlang .data
#' @importFrom dplyr select rename mutate
#'
get_cash <- function(connection) {

  # backend implementations
  if(connection$backend == "alpaca") {
    acct <- alpaca_account(connection)
    acct_cash <- dplyr::select(acct, .data$currency, .data$cash)
    acct_cash <- dplyr::rename(acct_cash, quantity_held = .data$cash)
    acct_cash <- dplyr::mutate(acct_cash,
                               quantity_held = as.numeric(.data$quantity_held))

  } else {
    stop("backend connection failed")
  }

  # generic tests
  test <- identical(colnames(acct_cash), c("currency", "quantity_held"))

  if(!test) {
    stop("data validation failed")
  } else {
    return(acct_cash)
  }
}
