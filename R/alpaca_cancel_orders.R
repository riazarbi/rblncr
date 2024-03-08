alpaca_cancel_orders <- function(alpaca_connection) {
  result <- httr::DELETE(paste0(alpaca_connection$domain,"/v2/orders"), 
                         alpaca_connection$headers)
  

  if(result$status_code == 207) {
    contents <- httr::content(result, type = "application/json", encoding = "UTF-8")
    contents <- do.call(rbind.data.frame, contents)
    if(all(contents$status == 200)) {
      return(TRUE)
    } else {
      return(FALSE)
    } 
  } else {
    stop(result$status_code)    
  }
}
