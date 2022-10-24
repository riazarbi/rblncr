validate_cash <- function(cash) {
  tests <- is.list(cash) &
    !(is.data.frame(cash)) &
    identical(sort(names(cash)), c("percent")) &
    cash$percent >= 0 &
    cash$percent <= 100  
  
  return(tests)
}
