##%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
##
## Construct and run a Health Impact Assessment (HIA) pipeline
##
##
##%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# Restore environment with renv -------------------------------------------

## Opening this project should have autoloaded renv - if not, use install.package("renv") to install then renv::activate() to load the renv lockfile

## restore the environment
renv::restore()
## or use this helper download function
# source("R/func_helpers/helper_install_pkgs.R")
# install_pkgs(repos = getOption("repos")) # provide a repository URL if necessary

# Load libraries and functions --------------------------------------------
library(targets)

# Run pipeline ------------------------------------------------------------

## If download_data is TRUE in _targets.R, please ensure you have authenticated cloudstoR's access to CloudStor
## Uncomment and run the next couple of lines to check your cloudstoR access

# source("R/func_helpers/helper_test_cloudstor.R")
# test_cloudstor()
# # run the next line if test_cloudstor() raises an authentication error
# cloudstoR::cloud_auth()

## visualise targets
tar_glimpse()
tar_manifest() # or get a tibble
## run pipeline
tar_make()

## visualise target status
tar_visnetwork(targets_only = T, level_separation = 200)
# click a target to highlight linked targets (use argument degree_to/degree_from to control number of edges to highlight, default 1)

# View target output ------------------------------------------------------

## table
# see results of specified target
tar_read(calc_attributable_number)

## maps
## with leaflet
library(leaflet)
tar_read(leaflet_an) %>% addProviderTiles("CartoDB.Positron")
## with ggplot  
# tar_read(viz_an)

## view report
browseURL("report.html")

# Debugging help ----------------------------------------------------------

tar_meta(fields = warnings)
tar_meta(fields = error)

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
