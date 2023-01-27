#' Apply price limits to order quantities
#'
#' @param order_quantities a data frame of order quantities
#' @param connection a connection to a quote-providing backend
#' @param spread_tolerance percentage spread allowed between bid and ask quote to create a midpoint limit price. Prevents creating limits when there is very little liquiditiy for a stock.
#' @param override_values optional. Pass a data frame of prices for each stock if you want to manually assign prices.
#'
#' @return a data frame of symbols along with limit prices
#' @importFrom rlang .data
#' @noRd
#'
apply_price_limits <- function(order_quantities,
                               connection = NA,
                                spread_tolerance = 0.02,
                                override_values = NULL) {

  if (!is.null(override_values)) {
    # validation for overide_values data frame
    if(!is.data.frame(override_values)) {
      stop("param override_values must be a data frame")
    }
    if(!identical(sort(colnames(override_values)), c("limit", "symbol"))) {
      stop("column names of override_values must be 'symbol' and 'limit'")
    }
    quotes <- override_values

  } else {
    # or automatically split the spread
    quotes <- get_quotes(order_quantities$symbol, connection)
    quotes <- dplyr::filter(quotes,
                            !(.data$ask_price == 0),
                            !(.data$bid_price == 0),
                            !(.data$ask_size ==0),
                            !(.data$bid_size ==0))
    if(nrow(quotes > 0)) {    
    quotes <- dplyr::mutate(quotes, spread = (.data$ask_price - .data$bid_price)/.data$ask_price)
      }
    quotes <- dplyr::filter(quotes, .data$spread < spread_tolerance)
    if(nrow(quotes > 0)) {
      quotes <- dplyr::mutate(quotes, limit = (.data$ask_price + .data$bid_price)/2)
      quotes <- dplyr::select(quotes, .data$symbol, .data$limit)

    } else {
      quotes <- dplyr::select(order_quantities, .data$symbol)
      quotes$limit <- NA
    }

  }

  # at a limit column if it doesn't exist
  if(is.null(order_quantities$limit)) {
    order_quantities$limit <- NA
  }

  trade_limits <- dplyr::left_join(order_quantities, quotes, by = c("symbol"))
  trade_limits <- dplyr::mutate(trade_limits, limit = ifelse(is.na(.data$limit.y), .data$limit.x, .data$limit.y))
  trade_limits <- dplyr::mutate(trade_limits, limit = round(.data$limit,2))
  trade_limits$value <- trade_limits$order * trade_limits$limit
  trade_limits <- dplyr::select(trade_limits, .data$symbol, .data$order, .data$limit, .data$value)
  return(trade_limits)
}
