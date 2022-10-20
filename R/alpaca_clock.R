alpaca_clock <- function(alpaca_connection) {
  result <- alpaca_query("/v2/clock", alpaca_connection)
  as.data.frame(rbind.data.frame)
}
