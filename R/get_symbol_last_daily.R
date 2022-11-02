

#' Get last daily bar for a symbol
#'
#' @param symbol a stock symbol
#' @param connection a backend data connection
#'
#' @return a data frame
#' @importFrom rlang .data
#' @noRd
#'
get_symbol_last_daily <- function(symbol, connection) {
  # backend implementations
  if(connection$backend == "alpaca") {
    dailies <- alpaca_daily_bars(symbol, 7, connection)
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
    dailies <- dplyr::filter(dailies, .data$timestamp < lubridate::today())
    last_daily <- utils::tail(dailies, 1)
    last_daily <- dplyr::select(last_daily,
                                .data$timestamp,
                                .data$open,
                                .data$high,
                                .data$low,
                                .data$close,
                                .data$volume)

  } else {
    stop("backend connection failed")
  }

  # generic tests
  test <- identical(colnames(last_daily),
                    c("timestamp", "open", "high", "low", "close", "volume"))

  if(!test) {
    stop("data validation failed")
  } else {
    return(last_daily)
  }
}
