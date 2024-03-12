alpaca_clock <- function(alpaca_connection) {
  result <- alpaca_query("/v2/clock", alpaca_connection)
  df <- jsonlite::fromJSON(paste0("[", result, "]"), flatten = TRUE)
  df <- dplyr::mutate(df, 
                      timestamp = lubridate::ymd_hms(timestamp),
                      next_open = lubridate::ymd_hms(next_open),
                      next_close = lubridate::ymd_hms(next_close))
  df <- validate_clock_class(df)
  df
}
