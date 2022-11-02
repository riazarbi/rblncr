#' Get symbol 10 day bars
#'
#' @param symbol a stock symbol
#' @param connection a backend data connection
#'
#' @return a data frame of 10 day bars
#' @importFrom rlang .data
#' @noRd
get_symbol_10d_bars <- function(symbol, connection) {
  # backend implementations
  if(connection$backend == "alpaca") {
    dailies <- alpaca_daily_bars(symbol, 10, connection)
    dailies$t <- lubridate::ymd_hms(dailies$t)
    dailies <- dplyr::rename(dailies,
                             timestamp = .data$t,
                             open= .data$o,
                             high = .data$h,
                             low = .data$l,
                             close = .data$c,
                             volume = .data$v,
                             trades = .data$n,
                             vwap = .data$vw)
    dailies <- dplyr::arrange(dailies, .data$timestamp)

  } else {
    stop("backend connection failed")
  }

  # arrange
  dailies <- dplyr::filter(dailies, .data$timestamp < lubridate::today())
  # generic tests
  test <- identical(colnames(dailies),
                    c("timestamp", "open", "high", "low", "close", "volume", "trades", "vwap"))

  if(!test) {
    stop("data validation failed")
  } else {
    return(dailies)
  }
}
