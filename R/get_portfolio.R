get_portfolio <- function(connection) {
 positions <- get_positions(connection)
 cash <- get_cash(connection)
 portfolio <- list(cash = cash,
                   assets = positions)
 return(portfolio)
}
