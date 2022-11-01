

get_orders <- function(connection) {
  
  # backend implementations
  if(connection$backend == "alpaca") {
    order_status <- alpaca_get_orders(connection, status = "all")
    order_status <- dplyr::select(order_status, submitted_at, id, status, side, qty, limit_price, filled_qty, filled_avg_price)
    order_status <- dplyr::mutate(order_status, 
                                  timestamp = lubridate::as_datetime(submitted_at),
                                  order = ifelse(side == "sell", -as.numeric(qty), as.numeric(qty)),
                                  filled = ifelse(side == "sell", -as.numeric(filled_qty), as.numeric(filled_qty)),
                                  limit = as.numeric(limit_price))
    order_status <- dplyr::select(order_status, timestamp, order, filled, limit, filled_avg_price, status, id)
    
      } else {
    stop("backend connection failed")
  }
  
  # generic tests
  test <- identical(colnames(order_status), c("timestamp", "order", "filled", "limit",  "filled_avg_price", "status", "id"))
  
  if(!test) {
    stop("data validation failed. submission probable succeeded, so you need to fix your backend function AND cancel any open orders.")
  } else {
    return(order_status)
  }
  
}
