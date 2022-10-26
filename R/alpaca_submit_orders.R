

alpaca_submit_orders <- function(orders, alpaca_connection) {
  test <- is.data.frame(orders) &
    identical(sort(colnames(orders)), c("limit", "order", "symbol", "value")) 
  if(!test) {
    stop("Order data validation failed. Ensure order dataframe structure is correct.")
  }
  
  orders <- dplyr::rename(orders, qty = order, limit_price = limit)
  orders <- dplyr::select(orders, symbol, qty, limit_price)
  orders <- dplyr::mutate(orders, side = ifelse(qty < 0, 'sell','buy'))
  orders <- dplyr::mutate(orders, 
                          qty = as.character(abs(qty)), 
                          limit_price = as.character(limit_price))
  orders$type <- 'limit'
  orders$time_in_force <- 'day'
  
  orders <- dplyr::filter(orders, !is.na(limit_price))
  order_list <- split(orders, 1:nrow(orders))
  purrr::map(order_list, 
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
  
}
