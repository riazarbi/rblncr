

alpaca_submit_orders <- function(orders, alpaca_connection) {
  test <- is.data.frame(orders) &
    identical(sort(colnames(orders)), c("limit", "order", "symbol", "value")) 
  if(!test) {
    stop("Order data validation failed. Ensure order dataframe structure is correct.")
  }
  
  orders_alpaca <- orders
  orders_alpaca <- dplyr::rename(orders_alpaca, qty = order, limit_price = limit)
  orders_alpaca <- dplyr::select(orders_alpaca, symbol, qty, limit_price)
  orders_alpaca <- dplyr::mutate(orders_alpaca, side = ifelse(qty < 0, 'sell','buy'))
  orders_alpaca <- dplyr::mutate(orders_alpaca, 
                          qty = as.character(abs(qty)), 
                          limit_price = as.character(limit_price))
  orders_alpaca$type <- 'limit'
  orders_alpaca$time_in_force <- 'day'
  
  orders_alpaca <- dplyr::mutate(orders_alpaca, status = ifelse(is.na(limit_price), "no_limit", NA))
  orders_alpaca <- dplyr::mutate(orders_alpaca, status = ifelse(qty == 0, "no_volume", status))
  orders_for_submission <- dplyr::filter(orders_alpaca, is.na(status))
  
  if(nrow(orders_for_submission) > 0) {
    order_list <- split(orders_for_submission, 1:nrow(orders_for_submission))
    submissions <- purrr::map(order_list, 
                              function(order) 
                              {
                                # try be gentle to the API
                                #Sys.sleep(runif(1, min = 1, max = length(order_list)));
                                
                                httr::POST("https://paper-api.alpaca.markets/v2/orders", 
                                           body = as.list(order),
                                           encode = "json",
                                           alpaca_connection$headers)
                              }
    )
    submission_status <- purrr::map_dbl(submissions, ~ .x$status)
    orders_for_submission$status <- submission_status
    orders_for_submission$status <- ifelse(orders_for_submission$status ==200, "submitted", "rejected")
    orders_for_submission
    submissions_df <- purrr::map_df(submissions, httr::content)
    submissions_short <- dplyr::select(submissions_df, symbol, id, status)
    
    orders_status <- dplyr::bind_rows(orders_alpaca, orders_for_submission)
    orders_status <- dplyr::filter(orders_status, !is.na(status))
    
    # overlay client status with alpaca status and add id
    orders_status <- dplyr::left_join(orders_status, submissions_short, by = "symbol")
    orders_status <- dplyr::mutate(orders_status, 
                                   status = ifelse(is.na(status.y), 
                                                   status.x, 
                                                   status.y))
    orders_status <- dplyr::select(orders_status, symbol, limit_price, side, type, time_in_force, status, id)
    
  } else {
    orders_status <- orders_alpaca
    orders_status$id <-  NA
  }
  orders_status <- dplyr::select(orders_status, symbol, status, id)
  orders <- dplyr::left_join(orders, orders_status, by = "symbol")
  
  return(orders)
}
