

alpaca_trader <- function(orders,
                          trader_life = 300,
                          resubmit_interval = 5,
                          trading_connection,
                          pricing_connection = NULL,
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
        apply_price_limits(pricing_connection, spread_tolerance = 0.1) 
    }
    
    if(verbose){message(paste0(" - submitting orders"))}
    submitted <- alpaca_submit_orders(orders_priced, trading_connection)
    
    if(verbose){message(paste0(" - waiting ",resubmit_interval," seconds for orders to fill"))}
    Sys.sleep(resubmit_interval)
    
    canceled <- FALSE
    while(!canceled) {
      if(verbose) {message(" - attempting to cancel all unfilled orders")}
      canceled <- alpaca_cancel_orders(trading_connection)
      if(!canceled) {
        if(verbose){message(" - cancellation failed. Retry in 5 seconds.")}
        Sys.sleep(5) 
      }
    } 
    if(verbose) {message(" - all open orders cancelled")}
    
    if(verbose){message(paste0(" - getting order statuses"))}
    order_status <- alpaca_get_orders(trading_connection, status = "all")
    order_status <- dplyr::filter(order_status, id %in% submitted$id)
    order_status <- dplyr::select(order_status, submitted_at, id, status, side, qty, filled_qty, filled_avg_price)
    
    order_status <- dplyr::left_join(submitted, order_status, by = "id")
    order_status <- dplyr::mutate(order_status, status = ifelse(!is.na(status.y), status.y, status.x))
    order_status <- dplyr::select(order_status, submitted_at, symbol, order, limit, value, side, qty, filled_qty, status, id)
    order_status <- dplyr::mutate(order_status, 
                                  submitted_at = lubridate::as_datetime(submitted_at),
                                  qty = ifelse(side == "sell", -as.numeric(qty), as.numeric(qty)),
                                  filled_qty = ifelse(side == "sell", -as.numeric(filled_qty), as.numeric(filled_qty)))
    order_status <- dplyr::rename(order_status, timestamp = submitted_at, filled = filled_qty)
    order_status <- dplyr::select(order_status, timestamp, symbol, order, limit, filled, status)

    if(verbose){message(paste0(" - calculating remaining order amounts"))}
    new_orders <- dplyr::mutate(order_status, order = order - filled)
    new_orders <- dplyr::mutate(new_orders, value = order * limit)
    new_orders <- dplyr::select(new_orders, symbol, order, value)
    new_orders <- dplyr::filter(new_orders, order != 0)
    
    hstry <- dplyr::bind_rows(hstry, order_status)
    
    no_orders <- nrow(new_orders) == 0
    timeout_status <- difftime(Sys.time(),start, units = "secs") 
    timed_out <- timeout_status > trader_life
    
  }
  
  canceled <- FALSE
  while(!canceled) {
    if(verbose) {message("Wind-down attempt to cancel all unfilled orders")}
    canceled <- alpaca_cancel_orders(trading_connection)
    if(!canceled) {
      if(verbose){message(" - cancellation failed. Retry in 5 seconds.")}
      Sys.sleep(5) 
    }
  } 
  if(verbose) {message("Wind-down cancellation success")}
  
  
  if(no_orders) {
    if(verbose){
      message(paste0("\n\nNO ORDERS TO EXECUTE. EXITING.\n\n"))
    }
    return(hstry)
    
  } else if(timed_out) {
    if(verbose) {
      message("\n\nTIMEOUT REACHED. EXITING.\n\n")
    }
    return(hstry)
  } else {
    stop("Not sure why, but the function exited unexpectedly.")
  }
  
}

