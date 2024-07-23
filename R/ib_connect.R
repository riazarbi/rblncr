ib_connect <- function(account_id, port = "5001", url = "http://localhost", timeout = 20) {
  backend <- "ib"
  domain <- paste0(url, ":", port)
  account_id = account_id  
  creds <- list(backend = backend,
                domain = domain,
                account_id = account_id)

  retry = 5
  authenticated <- FALSE
  while (!authenticated) {
    response <- POST(paste0(domain,"/v1/api/iserver/auth/status"), config(ssl_verifypeer = 0, ssl_verifyhost = 0))
    if (response$status_code != 200 ) {
      timeout = timeout - retry
      if (timeout < 0) {
        stop("Connection timed out.")
      }
      print(paste0("Waiting for successful authentication. Sleeping for ",as.character(retry)," seconds..."))
      Sys.sleep(retry)
    }
    else {
      authenticated = TRUE
      print("Authentication succeeded!")
    }
    }
  return(creds)
}