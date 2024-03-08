

#' Submit orders to alpaca backend
#'
#' @param orders a data frame of orders
#' @param alpaca_connection an alpaca connection, as returned from alpaaca_connect()
#'
#' @return a data frame of submitted orders
#' @importFrom rlang .data
#' @noRd
#'
#' @examples
#'\dontrun{
#' alpaca_submit_orders(orders, t_conn)
#'}
alpaca_submit_orders <- function(orders, alpaca_connection) {
  test <- is.data.frame(orders) &
    identical(sort(colnames(orders)), c("limit", "order", "symbol", "value"))
  if(!test) {
    stop("Order data validation failed. Ensure order dataframe structure is correct.")
  }

  orders_alpaca <- orders
  orders_alpaca <- dplyr::rename(orders_alpaca, qty = "order", limit_price = "limit")
  orders_alpaca <- dplyr::select(orders_alpaca, "symbol", "qty", "limit_price")
  orders_alpaca <- dplyr::mutate(orders_alpaca, side = ifelse(.data$qty < 0, 'sell','buy'))
  orders_alpaca <- dplyr::mutate(orders_alpaca,
                          qty = as.character(abs(.data$qty)),
                          limit_price = as.character(.data$limit_price))
  orders_alpaca$type <- 'limit'
  orders_alpaca$time_in_force <- 'day'

  orders_alpaca <- dplyr::mutate(orders_alpaca, status = ifelse(is.na(.data$limit_price), "no_limit", NA))
  orders_alpaca <- dplyr::mutate(orders_alpaca, status = ifelse(.data$qty == 0, "no_volume", .data$status))
  orders_for_submission <- dplyr::filter(orders_alpaca, is.na(.data$status))

  if(nrow(orders_for_submission) > 0) {
    order_list <- split(orders_for_submission, 1:nrow(orders_for_submission))
    submissions <- purrr::map(order_list,
                              function(order)
                              {

                                httr::POST("https://paper-api.alpaca.markets/v2/orders",
                                           body = as.list(order),
                                           encode = "json",
                                           alpaca_connection$headers)
                              }
    )
    submission_status <- purrr::map_dbl(submissions, ~ .x$status)
    orders_for_submission$status <- submission_status
    orders_for_submission$status <- ifelse(orders_for_submission$status == 200, "submitted", "rejected")
    orders_for_submission

    submissions_df <- purrr::map_df(submissions, httr::content)
    submissions_short <- dplyr::select(submissions_df, "symbol", "id", "status")

    orders_status <- dplyr::bind_rows(orders_alpaca, orders_for_submission)
    orders_status <- dplyr::filter(orders_status, !is.na(.data$status))

    # overlay client status with alpaca status and add id
    orders_status <- dplyr::left_join(orders_status, submissions_short, by = "symbol")
    orders_status <- dplyr::mutate(orders_status,
                                   status = ifelse(is.na(.data$status.y),
                                                   .data$status.x,
                                                   .data$status.y))
    orders_status <- dplyr::select(orders_status,
                                   "symbol",
                                   "limit_price",
                                   "side",
                                   "type",
                                   "time_in_force",
                                   "status",
                                   "id")

  } else {
    orders_status <- orders_alpaca
    orders_status$id <-  NA
  }
  orders_status <- dplyr::select(orders_status,
                                 "symbol",
                                 "status",
                                 "id")
  orders <- dplyr::left_join(orders, orders_status, by = "symbol")

  return(orders)
}
