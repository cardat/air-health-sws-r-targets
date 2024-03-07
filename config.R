# Define global variables -------------------------------------------------

#### study coverage
years <- 2013:2014
states <- c("WA") # character vector of state abbreviations

#### data location and retrieval
## boolean, set to TRUE to download data via cloudstoR - ensure you have authenticated before running pipeline
## DEPRECATED: need to remove it and any dependencies in pipeline
download_data <- FALSE

## path to directory mirroring required CARDAT data
# specify the location to which CARDAT's Environment_General should be mirrored
dir_cardat <- "INSERT_PATH_HERE"
# E.G. ON COESRA dir_cardat <- "~/project_group_data/car"

## Environment General folder of CARDAT
dir_envgen <- "Environment_General"