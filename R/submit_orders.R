

submit_orders <- function(orders, connection) {
  
  # backend implementations
  if(connection$backend == "alpaca") {
    submissions <- alpaca_submit_orders(orders, connection)

  } else {
    stop("backend connection failed")
  }
  
  # generic tests
  test <- identical(colnames(submissions), c("symbol", "order", "limit", "value", "status", "id"))
  
  if(!test) {
    stop("data validation failed. submission probable succeeded, so you need to fix your backend function AND cancel any open orders.")
  } else {
    return(submissions)
  }
  
}
