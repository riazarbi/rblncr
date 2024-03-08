library(testthat)

test_that("returns correct domain for live mode", {
  expect_equal(alpaca_domain("live"), "https://api.alpaca.markets")
})

test_that("returns correct domain for paper mode", {
  expect_equal(alpaca_domain("paper"), "https://paper-api.alpaca.markets")
})

test_that("returns correct domain for data mode", {
  expect_equal(alpaca_domain("data"), "https://data.alpaca.markets")
})

test_that("throws error for invalid mode", {
  expect_error(alpaca_domain("invalid"), "arg mode must be either 'live', 'paper' or 'data'.")
})
