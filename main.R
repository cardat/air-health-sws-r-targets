library(targets)
library(tarchetypes)

source("R/packages.R")

#### Debug ####
library(data.table)
library(sf)
library(raster)

tar_manifest()
# tar_option_set(debug = "health_impact_function")
# tar_make(names = health_impact_function, callr_function = NULL)


# tar_manifest(fields = "command")
# tar_glimpse(targets_only = FALSE)

#### Run ####
# tar_make() # run pipeline
# tar_read(prep_exposure_pm25) # see results of specified target

tar_visnetwork()

#browseURL("index.html")
