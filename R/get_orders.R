

#' Get order history from backend
#'
#' @param connection a trading backend connection
#'
#' @return a data frame of orders
#' @export
#' @importFrom rlang .data
#' @importFrom dplyr select mutate
#'
get_orders <- function(connection) {

  # backend implementations
  if(connection$backend == "alpaca") {
    order_status <- alpaca_get_orders(connection, status = "all")
    order_status <- dplyr::select(order_status,
                                  "submitted_at",
                                  "id",
                                  "status",
                                  "side",
                                  "qty",
                                  "limit_price",
                                  "filled_qty",
                                  "filled_avg_price")
    order_status <- dplyr::mutate(order_status,
                                  timestamp = lubridate::as_datetime(.data$submitted_at),
                                  order = ifelse(.data$side == "sell",
                                                 -as.numeric(.data$qty),
                                                 as.numeric(.data$qty)),
                                  filled = ifelse(.data$side == "sell",
                                                  -as.numeric(.data$filled_qty),
                                                  as.numeric(.data$filled_qty)),
                                  limit = as.numeric(.data$limit_price))
    order_status <- dplyr::select(order_status,
                                  "timestamp",
                                  "order",
                                  "filled",
                                  "limit",
                                  "filled_avg_price",
                                  "status",
                                  "id")

      } else {
    stop("backend connection failed")
  }

  # generic tests
  test <- identical(colnames(order_status),
                    c("timestamp", "order", "filled", "limit",  "filled_avg_price", "status", "id"))

  if(!test) {
    stop("data validation failed. submission probable succeeded, so you need to fix your backend function AND cancel any open orders.")
  } else {
    return(order_status)
  }

}
