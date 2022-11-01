

trader <- function(orders,
                          trader_life = 300,
                          resubmit_interval = 5,
                          trading_connection,
                          pricing_connection = NULL,
                          pricing_spread_tolerance = 0.01,
                          pricing_overrides = NULL,
                          verbose = TRUE) {
  start <- Sys.time()
  timed_out <- FALSE
  
  new_orders <- dplyr::filter(orders, 
                              !(is.na(order)),
                              order != 0)
  no_orders <- nrow(new_orders) == 0
  
  hstry <- data.frame(timestamp = lubridate::POSIXct(),
                      symbol = character(), 
                      order = numeric(),
                      limit = numeric(),
                      filled = numeric(),
                      status = character())
  
  while(!timed_out & !no_orders) {
    
    if(verbose){message(paste0("there are ", nrow(new_orders), " new orders to fill"))}
    
    if(verbose){message(paste0(" - pricing new orders"))}
    
    if(!is.null(pricing_overrides)) {
      if(verbose){message(paste0("   using pricing overrides"))}
      orders_priced <- new_orders |>
        apply_price_limits(override_values = pricing_overrides)
    } else {
      orders_priced <- new_orders |> 
        apply_price_limits(pricing_connection, spread_tolerance = pricing_spread_tolerance) 
    }
    
    if(verbose){message(paste0(" - submitting orders"))}
    submitted <- submit_orders(orders_priced, trading_connection)
    
    if(verbose){message(paste0(" - waiting ",resubmit_interval," seconds for orders to fill"))}
    Sys.sleep(resubmit_interval)
    
    canceled <- FALSE
    while(!canceled) {
      if(verbose) {message(" - attempting to cancel all unfilled orders")}
      canceled <- cancel_orders(trading_connection)
      if(!canceled) {
        if(verbose){message(" - cancellation failed. Retry in 5 seconds.")}
        Sys.sleep(5) 
      }
    } 
    if(verbose) {message(" - all open orders cancelled")}
    
    
    Sys.sleep(3) # backoff to allow cancel POST to update order statuses
    
    if(verbose){message(paste0(" - getting order statuses"))}
    order_status <- get_orders(trading_connection)
    order_status <- dplyr::filter(order_status, id %in% submitted$id)
    order_status <- dplyr::select(order_status, timestamp, id, status, filled, filled_avg_price)
    
    order_status <- dplyr::left_join(submitted, order_status, by = "id")
    order_status <- dplyr::mutate(order_status, status = ifelse(!is.na(status.y), status.y, status.x))
    order_status <- dplyr::select(order_status, timestamp, symbol, order, limit, value,  filled, status, id)
    order_status <- dplyr::select(order_status, timestamp, symbol, order, limit, filled, status)
    order_status <- dplyr::mutate(order_status, filled = ifelse(is.na(filled), 0, filled))

    if(verbose){message(paste0(" - calculating remaining order amounts"))}
    # BUG: IF FILLED NA, KICKS OUT ORDER
    new_orders <- dplyr::mutate(order_status, order = order - filled)
    new_orders <- dplyr::mutate(new_orders, value = order * limit)
    new_orders <- dplyr::select(new_orders, symbol, order, value)
    new_orders <- dplyr::filter(new_orders, order != 0)
    
    hstry <- dplyr::bind_rows(hstry, order_status)
    
    no_orders <- nrow(new_orders) == 0
    timeout_status <- difftime(Sys.time(),start, units = "secs") 
    timed_out <- timeout_status > trader_life
    
  }

  if(verbose) {message("\n\ncommencing trader wind-down")}
  canceled <- FALSE
  while(!canceled) {
    if(verbose) {message(" - attempting to cancel all unfilled orders")}
    canceled <- cancel_orders(trading_connection)
    
    if(!canceled) {
      if(verbose){message(" - cancellation failed. Retry in 5 seconds.")}
      Sys.sleep(5) 
    }
  } 
  if(verbose) {message(" - trader wind-down cancellation success")}
  
  
  if(no_orders) {
    if(verbose){
      message(paste0("\n\nNO ORDERS TO EXECUTE. EXITING.\n"))
    }
    return(hstry)
    
  } else if(timed_out) {
    if(verbose) {
      message("\n\nTIMEOUT REACHED. EXITING.\n")
    }
    return(hstry)
  } else {
    stop("not sure why, but the function exited unexpectedly.")
  }
  
}

