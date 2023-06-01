alpaca_query <- function(endpoint, alpaca_connection){
  url <- paste0(alpaca_connection$domain, endpoint)
  result <- httr::GET(url, alpaca_connection$headers,httr::content_type("application/octet-stream"), httr::accept("application/json"))
  if (result$status_code == 200) {
    return(httr::content(result))
  }
  else {
    stop(result$status_code)
  }
}
