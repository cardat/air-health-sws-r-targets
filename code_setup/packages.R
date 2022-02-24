# Packages ----------------------------------------------------------------

message("\n########################\nPackage Install - Starting\n########################\n")

pkgs_cran <-  c(
  "targets",
  "tarchetypes",
  "data.table",
  "sf",
  "raster",
  "exactextractr",
  # "rlang"
  # "car",
  # "readr",
  # "rgdal",
  # "dplyr",
  # "rgeos",
  # "zoo",
  # "tidyr",
  # "openxlsx",
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


# ## iom life tables (github install)
# if(!require(devtools)) install.packages("devtools"); library(devtools)
# if(!require(iomlifetR)) install_github("richardbroome2002/iomlifetR", build_vignettes = TRUE)
# 
# pkg_req <- c(
#   # "car",
#   "data.table",
#   # "readr",
#   # "rgdal",
#   # "dplyr",
#   # "rgeos",
#   # "zoo",
#   # "tidyr",
#   # "openxlsx",
#   "sf"
# )

# Exit if all packages present
#if(all(pkg_req %in% installed.packages()[,"Package"])) q()

# Ask to install if some packages missing ---------------------------------

# readLine only works in an interactive session - returns "" by default
# user_input <- readline("Some packages required packages are not installed. Install Y/n?")

# if(tolower(user_input)!="y") message("No packages were installed"); q()

# 
# for(pkg_i in pkg_req){
#   #pkg_i = pkg_req[1]
#   if(!(pkg_i %in% installed.packages()[,"Package"])) install.packages(pkg_i)
# }
# 
# # a <- lapply(pkg_req, library, character.only = TRUE)
# 

message("\n########################\nCompleted\n########################")
