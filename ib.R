# lsof -i :5001


# LOAD LIBRARIES

library(httr)
library(curl)
library(sys)
library(tools)
library(devtools)
library(processx)
library(ps)
load_all()

check_java()

ib_install()

port = "5001"
ssl = FALSE

live_account_id = "U2592262"
paper_account_id = "DU1144545"

ib_conf <- ib_set_conf(port = "5001", ssl = FALSE)

ibc_process <- ib_start()

ibc_process$is_alive()


ib_connection <- ib_connect(account_id = paper_account_id, port = ib_conf$port, url = ib_conf$url, timeout = 300)


print(ib_account(ib_connection))

print(ib_positions(ib_connection))


ib_get_orders <- function(ib_connection, status = "open") {
  endpoint <-  paste0("/v1/api/iserver/account/orders")
  result <- ib_query(endpoint, ib_connection)
  jsonlite::fromJSON(result, flatten = TRUE)
}

print(ib_get_orders(ib_connection))




alpaca_quote <- function(symbol, alpaca_connection) {
  endpoint <- paste0("/v2/stocks/",symbol,"/quotes/latest")
  result <- alpaca_query(endpoint, alpaca_connection)
  result_lst <- jsonlite::fromJSON(result, flatten = TRUE)
  result_lst$quote
}


#VT: # 52197301
#BRK: # 	72063691

symbol <- 52197300

# HERE IS WHERE I AM

ib_quote <- function(symbol, ib_connection, retries = 5) {
  # Need to hit this first according to API docs
  endpoint <-  paste0("/v1/api/iserver/accounts")
  ib_query(endpoint, ib_connection)

  # This is the quote endpoint
  endpoint <-  paste0("/v1/api/iserver/marketdata/snapshot?conids=,",symbol,",&fields=55,84,86,88,85")

  # The result is often not ready until the second or third try
  correct_result <- FALSE
  while (retries > 0 | !correct_result) {
    result <- ib_query(endpoint, ib_connection)
    df <- jsonlite::fromJSON(result, flatten = TRUE)
    correct_result <- all(c("_updated", "conid", "55", "88", "84", "85", "86") %in% colnames(df))
    retries <- retries - 1
    Sys.sleep(0.3)
  } 

  dplyr::filter(df, conid == symbol) |>
  
  dplyr::select(`_updated`, `conid`, `55`, `88`, `84`, `85`, `86`) |>
  dplyr::rename(
    timestamp = `_updated`, 
    conid = `conid`, 
    symbol = `55`, 
    bid_size = `88`, 
    bid_value = `84`, 
    ask_size = `85`, 
    ask_value = `86`)
}

ib_quote(symbol, ib_connection)


f"{baseUrl}/iserver/marketdata/snapshot?conids=265598,8314&fields=31,84,86"


ib_kill(ibc_process)


quit()





glimpse(df)



endpoint <- paste0("http://localhost:5001/v1/api/iserver/account/orders?force=true&accountId=",account_id)

endpoint <- "https://localhost:5001/v1/iserver/auth/status"


endpoint <- "https://localhost:5001/v1/api/iserver/accounts"


endpoint <-  paste0("https://localhost:5001/v1/api/portfolio/",account_id,"/ledger")
endpoint <-  paste0("https://localhost:5001/v1/api/portfolio/",account_id,"/summary")
endpoint <-  paste0("https://localhost:5001/v1/api/portfolio/",account_id)

endpoint <-  paste0("https://localhost:5001/v1/api/iserver/account/",account_id,"/summary")
endpoint <-  paste0("https://localhost:5001/v1/api/iserver/account/",account_id,"/summary/market_value")


endpoint <- "http://localhost:5001/v1/api/trsrv/all-conids?exchange=NASDAQ"
endpoint <- "/v1/api/trsrv/secdef/schedule?assetClass=STK&symbol=AAPL&exchange=NASDAQ"
endpoint <- "/v1/api/trsrv/stocks?symbols=BRK-B"


endpoint <- "/v1/api/iserver/secdef/search?symbol=BRK&sectype=STK"



response <- GET(endpoint, config(ssl_verifypeer = 0, ssl_verifyhost = 0))

response <- POST("https://localhost:5001/v1/api/iserver/auth/status", config(ssl_verifypeer = 0, ssl_verifyhost = 0))
response <- POST("http://localhost:5001/v1/api/tickle", config(ssl_verifypeer = 0, ssl_verifyhost = 0))

response <- POST("http://localhost:5001/v1/api/logout", config(ssl_verifypeer = 0, ssl_verifyhost = 0))

response
content(response, "parsed", type = "application/json")
