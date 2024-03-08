alpaca_clock <- function(alpaca_connection) {
  result <- alpaca_query("/v2/clock", alpaca_connection)
  df <- jsonlite::fromJSON(paste0("[", result, "]"), flatten = TRUE)
}
