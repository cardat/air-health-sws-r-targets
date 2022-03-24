#' Run a connection test of Cloudstor via the cloudstoR package
#'
#' @param path A Cloudstor file path to attempt to access. Defaults to Shared folder.
#'
#' @return Returns TRUE if no error encountered, otherwise tries to print a more explanatory error message.
#' 
#' @examples
#' test_cloudstor()

test_cloudstor <- function(path = "Shared"){
  tryCatch(
    cloudstoR::cloud_meta(path),
    error = function(e){
      if (grepl("401", e$message)){
        message("Unable to authenticate. If your credentials are invalid, rerun cloudstoR::cloud_auth() and enter valid credentials. Otherwise it may be a server problem - wait a few minutes and try again.")
      } else if (grepl("(Could not resolve host|Host unreachable)", e$message)){
        message("Could not contact CloudStor. Please check your internet connection and/or the CloudStor status (https://status.aarnet.edu.au).")
      }
      stop(e)
    }
  )
  return(TRUE)
}
