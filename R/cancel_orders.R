

cancel_orders <- function(connection) {
  
  # backend implementations
  if(connection$backend == "alpaca") {
    cancel <- alpaca_cancel_orders(connection)
    
  } else {
    stop("backend connection failed")
  }
  
  # generic tests
  test <- is.logical(cancel)
  
  if(!test) {
    stop("Response validation failed. Your backend function isn't working correctly. Unclear whether your orders have cancelled or not.")
  } else {
    return(cancel)
  }
  
}
