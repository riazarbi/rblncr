alpaca_assets <- function(alpaca_connection) {
  result <- alpaca_query("/v2/assets?asset_class=us_equity&status=active", alpaca_connection)
  jsonlite::fromJSON(result, flatten = TRUE)
}
