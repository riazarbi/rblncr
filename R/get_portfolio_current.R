#' Get current portfolio holdings
#'
#' @param connection a backend trading connection
#'
#' @return a portfolio object which can be passed to `load_portfolio_targets()`
#' @export
#' @examples
#' t_conn <- alpaca_connect('paper',
#'                          Sys.getenv("ALPACA_PAPER_KEY"),
#'                          Sys.getenv("ALPACA_PAPER_SECRET"))
#' get_portfolio_current(t_conn)

get_portfolio_current <- function(connection) {
 positions <- get_positions(connection)
 cash <- get_cash(connection)
 portfolio <- list(cash = cash,
                   assets = positions)
 return(portfolio)
}
