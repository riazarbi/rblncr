alpaca_domain <- function(mode) {
  if(mode == "live") {
    domain <- "https://api.alpaca.markets"
  }
  else if (mode == "paper") {
    domain <- "https://paper-api.alpaca.markets"
  } else if (mode == "data") {
    domain <- "https://data.alpaca.markets"
  }  else {
    stop("arg mode must be either 'live', 'paper' or 'data'.")
  }
  return(domain)
}
