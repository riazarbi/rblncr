ib_install <- function(
  ibc_path = file.path(getwd(), "ibc/clientportal"), 
  ibc_url = "https://download2.interactivebrokers.com/portal/clientportal.gw.zip",
  force = FALSE) {

    # Define the destination path where you want to save the file
    destfile <- file.path(dirname(ibc_path), "clientportal.gw.zip")


    # Create the directory if it does not exist
    if (!dir.exists(ibc_path) | force == TRUE) {
      dir.create(ibc_path, recursive = TRUE, showWarnings = FALSE)
      # Use download.file() to download the file
      curl_download(ibc_url, destfile)
      # Unzip the file into the designated directory
      unzip(destfile, exdir = ibc_path)
      unlink(destfile)
    }

    return(TRUE)

}