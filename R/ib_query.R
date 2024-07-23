ib_query <- function(endpoint, ib_connection, http_get = make_http_get_request) {
  url <- paste0(ib_connection$domain, endpoint)
  result <- httr::GET(url, config(ssl_verifypeer = 0, ssl_verifyhost = 0))
  if (result$status_code == 200) {
    return(httr::content(result, type = "application/json", as = "text", encoding = "UTF-8"))
  } else {
    stop(as.character(result$status_code))
  }
}
