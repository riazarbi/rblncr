get_cash <- function(connection) {
  
  # backend implementations
  if(connection$backend == "alpaca") {
    acct <- alpaca_account(connection)
    acct_cash <- dplyr::select(acct, currency, cash)
    acct_cash <- dplyr::rename(acct_cash, quantity = cash)

  } else {
    stop("backend connection failed")
  }
  
  # generic tests
  test <- identical(colnames(acct_cash), c("currency", "quantity"))
  
  if(!test) {
    stop("data validation failed")
  } else {
    return(acct_cash)
  }
}
