alpaca_assets <- function(alpaca_connection) {
  result <- alpaca_query("/v2/assets?asset_class=us_equity&status=active", alpaca_connection)
  do.call(rbind.data.frame, result)
}
