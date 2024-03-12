validate_portfolio_assets <- function(assets) {
  tests <- is.data.frame(assets) &
    identical(sort(colnames(assets)), c("percent", "symbol")) &
    is.character(assets$symbol) &
    all(assets$percent >= 0) &
    all(assets$percent <= 100) 
  
  return(tests)
}
