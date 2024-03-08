library(testthat)
library(httr) # for content_type(), accept(), and handling responses

# Test successful response from the mock HTTP GET function
test_that("alpaca_query returns data on successful response", {
  mock_http_get_success <- function(url, headers, content_type, accept) {
    content_as_json <- jsonlite::toJSON(list(success = TRUE, message = "Data retrieved"), auto_unbox = TRUE)
    content_as_raw <- charToRaw(content_as_json)
    
    # Create a dummy request object with a URL, since httr::content() seems to require it for MIME type guessing
    request <- list(url = url)
    class(request) <- "request"
    
    response <- list(
      status_code = 200L,
      headers = list(`content-type` = "application/json; charset=UTF-8"),
      content = content_as_raw,
      request = request  # Include the request object in the response
    )
    class(response) <- c("response", "httr_response")
    
    response
  }
  
  
  alpaca_connection <- list(domain = "https://api.alpaca.markets", headers = list())
  result <- alpaca_query("/test_endpoint", alpaca_connection, mock_http_get_success)
  
  # Depending on how httr::content() is called in alpaca_query, you might need to adjust its usage.
  # If using httr::content() directly in tests, ensure you're handling the response type correctly.
  expect_equal(jsonlite::fromJSON(result)$success, TRUE)
  expect_equal(jsonlite::fromJSON(result)$message, "Data retrieved")

})

# Test error response from the mock HTTP GET function
test_that("alpaca_query stops on error response", {
  mock_http_get_error <- function(url, headers, content_type, accept) {
    response <- list(status_code = 404L)
    class(response) <- "response"
    return(response)
  }
  
  alpaca_connection <- list(domain = "https://api.alpaca.markets", headers = list())
  expect_error(alpaca_query("/wrong_endpoint", alpaca_connection, mock_http_get_error), "404")
})
