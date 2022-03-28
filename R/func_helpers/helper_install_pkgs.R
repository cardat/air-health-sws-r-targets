# Packages ----------------------------------------------------------------

install_pkgs <- function(){
  
  message("\n########################\nPackage Install - Starting\n########################\n")
  
  pkgs_cran <-  c(
    "targets",
    "visNetwork", # suggested by targets to visualise pipeline
    "tarchetypes",
    "car",
    "sf",
    "data.table",
    "raster",
    "exactextractr",
    "leaflet",
    "ggplot2"
  )
  
  #github packages as package name = github repository
  pkgs_github <-  c(
    # "iomlifetR" = "richardbroome2002/iomlifetR"
  )
  
  ## get installed packages
  pkgs_existing <- as.data.frame(installed.packages())
  
  ## check for cran packages, install if not installed
  for(pkg_i in pkgs_cran){
    #pkg_i = pkg_cran[1]
    if(!(pkg_i %in% installed.packages()[,"Package"])) install.packages(pkg_i)
  }
  
  ## check for github packages, install if not installed
  for(pkg_i in names(pkgs_github)){
    #pkg_i = pkgs_github[1]
    if(!(pkg_i %in% pkgs_existing[,"Package"])) {
      if(!require(devtools)) install.packages("devtools"); library(devtools)
      if(!require(rmarkdown)) install.packages("rmarkdown"); library(rmarkdown)
      install_github(pkgs_github[pkg_i], build_vignettes = TRUE)
    }
  }
  
  message("\n########################\nCompleted\n########################")
}

