

#' Load portfolio targets
#'
#' @param portfolio a portfolio object, as returned from `get_portfolio_current()`
#' @param portfolio_model a portfolio model, as returned from `read_portfolio_model()` or `create_portfolio_model()`
#'
#' @return an extended portfolio object which can be passed to `price_portfolio()`
#' @export
#' @importFrom rlang .data
#' @importFrom dplyr full_join rename
#' @examples
#' t_conn <- alpaca_connect('paper',
#'                          Sys.getenv("ALPACA_PAPER_KEY"),
#'                          Sys.getenv("ALPACA_PAPER_SECRET"))
#'
#' portfolio_model <- read_portfolio_model(system.file(package='rblncr','extdata/sample_portfolio.yaml'))
#'
#' get_portfolio_current(t_conn) |>
#'   load_portfolio_targets(portfolio_model)
#'
load_portfolio_targets <- function(portfolio, portfolio_model) {
  assets <- dplyr::full_join(portfolio$assets,
                             portfolio_model$assets, by = "symbol")
  assets[is.na(assets)] <- 0
  assets <- dplyr::rename(assets, percent_target = "percent")

  portfolio$cash$percent <- portfolio_model$cash$percent
  portfolio$cash$tolerance <- portfolio_model$cash$tolerance
  cash <- portfolio$cash
  cash[is.na(cash)] <- 0
  cash <- dplyr::rename(cash, percent_target = "percent")

  rebalancing_frame <- list(cash = cash,
                            assets = assets,
                            tolerance = portfolio_model$tolerance)

  return(rebalancing_frame)
}
