

#' Interact with a trading backend
#'
#' @param orders a data frame of orders
#' @param trader_life how long, in seconds, the trader should operate before timeout
#' @param resubmit_interval how long, in seconds, the trader should wait before cancelling all open orders, recompute price limits, and resubmit orders
#' @param trading_connection the backend trading connection for submitting orders
#' @param pricing_connection the backend trading connection for computing price limits
#' @param pricing_spread_tolerance the maximum bid-ask spread which can be tolerated for a limit price to be computed
#' @param pricing_overrides optional data frame of limit prices to assign to each symbol
#' @param verbose TRUE/FALSE should the function be chatty?
#'
#' @return a data frame detailing the outcome of each attempted order
#' @export
#' @importFrom rlang .data
#' @importFrom dplyr filter select left_join mutate bind_rows
#' @importFrom lubridate POSIXct
#' @examples
#' t_conn <- alpaca_connect('paper',
#'                          Sys.getenv("ALPACA_PAPER_KEY"),
#'                          Sys.getenv("ALPACA_PAPER_SECRET"))
#' d_conn <- alpaca_connect('data',
#'                          Sys.getenv("ALPACA_LIVE_KEY"),
#'                          Sys.getenv("ALPACA_LIVE_SECRET"))
#'
#' portfolio_model <- read_portfolio_model(system.file(package='rblncr','extdata/sample_portfolio.yaml'))
#'
#' get_portfolio_current(t_conn) |>
#'   load_portfolio_targets(portfolio_model) |>
#'   price_portfolio(connection = d_conn, price_type = 'close') |>
#'   solve_portfolio() |>
#'   constrain_orders(d_conn) |>
#'   trader(trading_connection = t_conn,
#'          pricing_connection = d_conn,
#'          verbose = FALSE)
#'
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
    order_status <- dplyr::filter(order_status, .data$id %in% submitted$id)
    order_status <- dplyr::select(order_status,
                                  .data$timestamp,
                                  .data$id,
                                  .data$status,
                                  .data$filled,
                                  .data$filled_avg_price)

    order_status <- dplyr::left_join(submitted, order_status, by = "id")
    order_status <- dplyr::mutate(order_status,
                                  status = ifelse(!is.na(.data$status.y),
                                                  .data$status.y,
                                                  .data$status.x))
    order_status <- dplyr::select(order_status,
                                  .data$timestamp,
                                  .data$symbol,
                                  .data$order,
                                  .data$limit,
                                  .data$value,
                                  .data$filled,
                                  .data$status,
                                  .data$id)
    order_status <- dplyr::select(order_status,
                                  .data$timestamp,
                                  .data$symbol,
                                  .data$order,
                                  .data$limit,
                                  .data$filled,
                                  .data$status)
    order_status <- dplyr::mutate(order_status,
                                  filled = ifelse(is.na(.data$filled),
                                                  0,
                                                  .data$filled))

    if(verbose){message(paste0(" - calculating remaining order amounts"))}
    # BUG: IF FILLED NA, KICKS OUT ORDER
    new_orders <- dplyr::mutate(order_status, order = .data$order - .data$filled)
    new_orders <- dplyr::mutate(new_orders, value = .data$order * .data$limit)
    new_orders <- dplyr::select(new_orders, .data$symbol, .data$order, .data$value)
    new_orders <- dplyr::filter(new_orders, .data$order != 0)

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

