get_portfolio_current <- function(connection) {
 positions <- get_positions(connection)
 cash <- get_cash(connection)
 portfolio <- list(cash = cash,
                   assets = positions)
 return(portfolio)
}
