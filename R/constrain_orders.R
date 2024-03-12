

#' Constrain orders
#'
#' Ensure that the orders submitted to a `trader()` are within specified constraints.
#'
#' @param solved_portfolio the output of the function `solve_portfolio()`
#' @param connection a backend data connection to obtain daily trade volume data
#' @param daily_vol_pct_limit limit the percentage of average trailing 10 day volume for any trade
#' @param min_order_size minimum order size threshold
#' @param max_order_size maximum order size threshold
#' @param buy_only TRUE/FALSE should we omit any sell orders
#' @param terse TRUE/FALSE should the return value be as terse as possible for downstream processing?
#'
#' @return a data frame of orders that meet the constraints
#' @export
#' @importFrom rlang .data
#' @importFrom dplyr relocate last_col mutate select
#' @importFrom purrr map map_dbl
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
#'   price_portfolio(connection = d_conn, price_type = 'close') |>
#'   solve_portfolio() |>
#'   constrain_orders(d_conn)
#'}
#'
constrain_orders <- function(solved_portfolio,
                             connection,
                             daily_vol_pct_limit = 0.02,
                             min_order_size = 1000,
                             max_order_size = 10000,
                             buy_only = FALSE,
                             terse = TRUE) {

  # extract assets and symbols
  assets <- solved_portfolio$assets
  symbols <- solved_portfolio$assets$symbol

  # get some current volume and price data
  bars <- purrr::map(symbols, ~ get_symbol_10d_bars(.x, connection))
  names(bars) <- symbols

  # get the daily volume
  assets$daily_volume <- purrr::map_dbl(bars, ~ median(.x$volume))

  # work out the per-symbol constraints
  assets$volume_constraint <- floor(assets$daily_volume * daily_vol_pct_limit)
  assets$max_value_constraint <- max_order_size
  assets$min_value_constraint <- min_order_size

  # work out the constrained trade value
  assets$value <- pmin(abs(assets$optimal_order_value), assets$max_value_constraint)
  assets$value <- ifelse(assets$value > assets$min_value_constraint, assets$value, 0)
  # work out constrained order size
  assets$order <- floor(pmin(assets$volume_constraint, assets$value / assets$price))

  # recompute the constrained value for rounding issues
  assets$value <- assets$order * assets$price

  # correct the sign for sell orders
  assets$value <- ifelse(assets$optimal_order_value < 0, -assets$value, assets$value)
  assets$order <- ifelse(assets$optimal_order < 0, -assets$order, assets$order)

  # neaten up
  assets <- dplyr::relocate(assets, "daily_volume", .after = "price")
  assets <- dplyr::relocate(assets, "value", .after = dplyr::last_col())

  # drop sells if buy only constraint
  if(buy_only) {
    assets <- dplyr::mutate(assets,
                            order = ifelse(.data$order < 0, 0, .data$order),
                            value = ifelse(.data$value < 0, 0, .data$value))
  }


  # drop cols if terse
  if(terse) {
    assets <- dplyr::select(assets, "symbol", "order", "value")
  }

  return(assets)

}
