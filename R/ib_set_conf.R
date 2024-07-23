ib_set_conf <- function(
  port, 
  ssl = TRUE, 
  ibc_path = file.path(getwd(), "ibc/clientportal")) {
    # Path to the file
    conf_path <- file.path(ibc_path, "root/conf.yaml")

    # Read lines from the file
    lines <- readLines(conf_path)

    # String to search for
    search_string <- "listenPort"
    # String to replace with
    replace_string <- paste0("    listenPort: ", port)
    # Find lines containing the search string
    line_indices <- grep(search_string, lines)
    # Replace the lines
    lines[line_indices] <- replace_string


    # String to search for
    search_string <- "listenSsl"

    if (ssl == TRUE) {
      # String to replace with
      replace_string <- "    listenSsl: true"
      base_url <- "https://localhost"
    }
    else if (ssl == FALSE) {
      # String to replace with
      replace_string <- "    listenSsl: false"
      base_url <- "http://localhost"
    }
    # Find lines containing the search string
    line_indices <- grep(search_string, lines)
    # Replace the lines
    lines[line_indices] <- replace_string
    # Write the updated lines back to the file
    writeLines(lines, conf_path)
    return(list(url = base_url, port = port))
}