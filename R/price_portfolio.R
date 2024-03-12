

#' Price a portfolio
#'
#' Get the current value of a portfolio's holdings
#'
#' @param portfolio an extended portfolio object, as returned from `load_portfolio_targets()`
#' @param price_type which price to use. 'close' is the only supported value at this time.
#' @param connection a backend data connection
#' @param percent_decimal_places define the decimal places to round the portfolio percentage weights calculation to
#'
#' @return a portfolio object with closing prices which can be passed to `solve_portfolio()`
#' @export
#' @importFrom rlang .data
#' @importFrom dplyr rename left_join select
#' @examples
#'\dontrun{
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
#'   price_portfolio(connection = d_conn, price_type = 'close')
#'}
price_portfolio <- function(portfolio,
                            connection,
                            price_type = 'close',
                            percent_decimal_places = 2) {
  symbols <- portfolio$assets$symbol
  if(price_type == "close") {
    prices <- get_symbols_last_closing_price(symbols, connection)
    prices <- dplyr::rename(prices, price = close)
  } else {
    stop("invalid price_type")
  }

  prices <- dplyr::select(prices, -"timestamp")
  portfolio$assets <- dplyr::left_join(portfolio$assets, prices, by = "symbol")
  portfolio$cash$price <- 1

  portfolio$cash$value_held = portfolio$cash$quantity_held *portfolio$cash$price
  portfolio$assets$value_held = portfolio$assets$quantity_held *portfolio$assets$price

  total_value <- portfolio$cash$value_held + sum(portfolio$assets$value_held)

  portfolio$assets$percent_held <- 100 * round(portfolio$assets$value_held / total_value,
                                         percent_decimal_places + 2)
  portfolio$cash$percent_held <- 100 * round(portfolio$cash$value_held / total_value,
                                       percent_decimal_places + 2)


  return(portfolio)
}
