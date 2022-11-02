#' Connect to an alpaca backend
#'
#' Use this function to specify which credentials to use to connect to Alpaca.
#' @param mode string. 'paper', 'live' or 'data'
#' @param api_key string. corresponding alpaca api key
#' @param api_secret string. corresponding alpaca api secret key
#'
#' @return a connection object that you will pass to other rblncr functions
#' @export
#' @examples
#' alpaca_connect(mode = "paper",
#'                api_key = "REDACTED",
#'                api_secret = "REDACTED")
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

