check_java <- function() {
    # Command to check Java version
    java_check <- system2("java", args = "-version", stderr = TRUE, stdout = TRUE)

    # Check if Java is installed by looking for "not recognized", "not found", or similar in the output
    if (any(grepl("not found|not recognized|unable to locate", java_check, ignore.case = TRUE))) {
      cat("Java is not installed.\n")
      return(FALSE)
    } else {
      cat("Java installation found:\n", java_check, sep = "\n")
      return(TRUE)
    }

}