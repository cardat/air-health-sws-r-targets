library(targets)
library(tarchetypes)

source("code_setup/packages.R")

#### Debug ####
library(data.table)
library(sf)
library(raster)
library(exactextractr)

tar_manifest()
tar_read(data_exp_pop)

# tar_option_set(debug = "health_impact_function")
# tar_make(names = health_impact_function, callr_function = NULL)


# tar_manifest(fields = "command")
# tar_glimpse(targets_only = FALSE)

#### Run ####
tar_make() # run pipeline
# tar_read(prep_exposure_pm25) # see results of specified target

tar_visnetwork()

#browseURL("index.html")
