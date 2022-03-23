##%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
##
## Construct and run a Health Impact Assessment (HIA) pipeline
##
##
##%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# Restore environment with renv -------------------------------------------

## Opening this project should have autoloaded renv - if not, use install.package("renv") to install then renv::activate() to load the renv lockfile

# restore the environment
renv::restore()

# Load libraries and functions --------------------------------------------
library(targets)

# Run pipeline ------------------------------------------------------------

## If download_data is not NULL in _targets.R, please ensure you have authenticated cloudstoR's access to CloudStor
## Run the next couple of lines to check your cloudstoR access
# source("R/func_helpers/helper_test_cloudstor.R")
# test_cloudstor()
## run this if test_cloudstor() raises an authentication error
# cloud_auth()

# visualise targets
tar_glimpse()
tar_manifest() # or get a tibble
# run pipeline
tar_make()

# visualise target status
tar_visnetwork(targets_only = T)

# View target output ------------------------------------------------------

tar_read(calc_attributable_number) # see results of specified target
tar_read(viz_an) # see results of specified target

#browseURL("index.html")

# Debugging help ----------------------------------------------------------

## lOad libraries here
# library(data.table)
# library(sf)
# library(raster)

## remove targets-generated files (options to selectively remove objects, metadata, etc.)
# tar_destroy() 

## load target output from last successful build of target
# tar_read(data_study_pop_health)

## run a specific branch in debug mode - do not use callr_function = NULL in regular usage
# tar_option_set(debug = "health_impact_function")
# tar_make(names = health_impact_function, callr_function = NULL)

# tar_manifest(fields = "command")
# tar_glimpse(targets_only = FALSE)
