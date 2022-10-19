alpaca_connect <- function(mode, api_key, api_secret) {
  backend <- "alpaca"
  domain <- alpaca_domain(mode)
  headers <- httr::add_headers('APCA-API-KEY-ID' = api_key,
                               'APCA-API-SECRET-KEY' = api_secret)
  creds <- list(backend = backend,
                domain = domain,
                headers = headers)
  return(creds)
}

