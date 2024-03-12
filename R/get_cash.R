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

   } else {
     stop("backend connection failed")
   }
   
  acct_cash <- dplyr::select(acct, "currency", "cash")
  acct_cash <- dplyr::rename(acct_cash, quantity_held = "cash")
   
  # generic tests
  test <- identical(colnames(acct_cash), c("currency", "quantity_held"))
  if(!test) {
    stop("data validation failed")
  } else {
    return(acct_cash)
  }
}
