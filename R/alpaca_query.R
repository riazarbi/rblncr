alpaca_query <- function(endpoint, alpaca_connection, http_get = make_http_get_request) {
  url <- paste0(alpaca_connection$domain, endpoint)
  result <- http_get(url, alpaca_connection$headers, httr::content_type("application/octet-stream"), httr::accept("application/json"))
  if (result$status_code == 200) {
    return(httr::content(result, type = "application/json", as = "text", encoding = "UTF-8"))
  } else {
    stop(as.character(result$status_code))
  }
}