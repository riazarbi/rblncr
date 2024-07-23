make_http_get_request <- function(url, headers, content_type, accept, config = httr::config()) {
  httr::GET(url, headers, content_type, accept, config)
}