##%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
##
## Construct and run a Health Impact Assessment (HIA) pipeline
## Cassandra Yuen and Ivan Hanigan
##
##%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


## use this helper download function
source("R/func_helpers/helper_install_pkgs.R")
install_pkgs(repos = getOption("repos")) # provide a repository URL if necessary

# Load libraries and functions --------------------------------------------
library(targets)

# Run pipeline ------------------------------------------------------------
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
tar_meta(tar_errored(), fields = error)

## load libraries here
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
