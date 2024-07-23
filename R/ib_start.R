ib_start <- function(ibc_path = file.path(getwd(), "ibc/clientportal")) {

    ibc_process <- process$new(
      command = "bash", 
      args = c("bin/run.sh", "root/conf.yaml"),
      wd = ibc_path,
      supervise = TRUE,
      cleanup_tree = TRUE,
      stderr = "2>&1",
      stdout = "|")
    
    Sys.sleep(5)

    ibc_stdout <- ibc_process$read_output_lines()

    if (ibc_process$is_alive()) {
      # Filter the vector for each substring
      urls <- grep("http", ibc_stdout, value = TRUE)
      open_strings <- grep("Open", ibc_stdout, value = TRUE)
      selected_string <- intersect(urls, open_strings)
      print(selected_string)
      return(ibc_process)
    } else {
      print(ibc_stdout)
      stop("Process did not start")
    }
    

}
