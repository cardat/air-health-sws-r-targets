#' Install latest version of libraries required (using install.packages)
#'
#' @param repos A character vector to pass to install.packages repos argument.
#'
#' @return Returns NULL.

# Packages ----------------------------------------------------------------

install_pkgs <- function(repos = getOption("repos")){
  
  message("\n########################\nPackage Install - Starting\n########################\n")


# Install CRAN packages ---------------------------------------------------
  
  pkgs_cran <-  c(
    "targets",
    "visNetwork", # suggested by targets to visualise pipeline
    "tarchetypes",
    "sf",
    "terra",
    "exactextractr",
    "data.table",
    "leaflet",
    "ggplot2",
    "rmarkdown"
  )
  
  ## get installed packages
  pkgs_existing <- as.data.frame(installed.packages())
  
  ## check for cran packages, install if not installed
  for(pkg_i in pkgs_cran){
    #pkg_i = pkg_cran[1]
    if(!(pkg_i %in% installed.packages()[,"Package"])) install.packages(pkg_i, repos = repos)
  }
  

# Install GitHub packages -------------------------------------------------

  ## Uncomment and add github packages here
  
  # #github packages as package name = github repository
  # pkgs_github <-  c(
  #   # "iomlifetR" = "richardbroome2002/iomlifetR"
  # )  
  # 
  # ## check for github packages, install if not installed
  # for(pkg_i in names(pkgs_github)){
  #   #pkg_i = pkgs_github[1]
  #   if(!(pkg_i %in% pkgs_existing[,"Package"])) {
  #     if(!require(devtools)) install.packages("devtools"); library(devtools)
  #     if(!require(rmarkdown)) install.packages("rmarkdown"); library(rmarkdown)
  #     devtools::install_github(pkgs_github[pkg_i], build_vignettes = TRUE)
  #   }
  # }
  
  message("\n########################\nCompleted\n########################")
}

