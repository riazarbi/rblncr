alpaca_query <- function(endpoint, alpaca_connection) {
  url <- paste0(alpaca_connection$domain, endpoint)
  
  result <- httr::GET(url, 
                      alpaca_connection$headers)
  
  if(result$status_code == 200) {
    return(httr::content(result))
  } else {
    stop(result$status_code)    
  }
}
