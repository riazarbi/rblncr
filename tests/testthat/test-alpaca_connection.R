# Mocking the alpaca_domain function
# If alpaca_domain is simple and deterministic, you might not need this step.
# Instead, directly test with expected outcomes based on 'mode'
mock_alpaca_domain <- function(mode) {
  if (mode == "live") {
    return("https://api.alpaca.markets")
  } else if (mode == "paper") {
    return("https://paper-api.alpaca.markets")
  } else if (mode == "data") {
    return("https://data.alpaca.markets")
  } else {
    stop("Invalid mode")
  }
}

test_that("alpaca_connect returns correct credentials structure", {
  # Replace 'alpaca_domain' with 'mock_alpaca_domain' in your actual test setup if necessary
  creds <- alpaca_connect("paper", "api_key_example", "api_secret_example")
  
  expect_equal(creds$backend, "alpaca")
  expect_true("domain" %in% names(creds))
  expect_true("headers" %in% names(creds))
  expect_equal(creds$domain, mock_alpaca_domain("paper"))
  # Checking headers
  expect_equal(creds$headers$headers[['APCA-API-KEY-ID']], "api_key_example")
  expect_equal(creds$headers$headers[['APCA-API-SECRET-KEY']], "api_secret_example")
})

test_that("alpaca_connect handles different modes correctly", {
  creds_live <- alpaca_connect("live", "api_key_example", "api_secret_example")
  creds_paper <- alpaca_connect("paper", "api_key_example", "api_secret_example")
  
  expect_true(creds_live$domain != creds_paper$domain)
  expect_equal(creds_live$domain, mock_alpaca_domain("live"))
  expect_equal(creds_paper$domain, mock_alpaca_domain("paper"))
})

