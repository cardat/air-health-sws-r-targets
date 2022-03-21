##%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
##
## Construct and run a Health Impact Assessment (HIA) pipeline
##
##
##%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#### Restore environment with renv ####
## Opening this project should have autoloaded renv - if not, use install.package("renv") to install then renv::activate() to load the renv lockfile

# restore the environment
renv::restore()

#### Load libraries ####
library(targets)

#### Write the pipeline ####
# load function for creating _targets.R for HIA pipeline
source("R/pipelines/write_pipeline_perth.R")

# write _targets.R file
write_pipeline_perth(states = c("NSW", "ACT"), # study area
                     years = 2013:2014 # temporal coverage
                     )

#### Run pipeline ####

# visualise targets
tar_glimpse()
# run pipeline
tar_make()

# visualise target status
tar_visnetwork(targets_only = T)

#### View target output ####

tar_read(prep_exposure_pm25) # see results of specified target

#browseURL("index.html")


# #### Debug ####
# library(data.table)
# library(sf)
# library(raster)
# library(exactextractr)

# tar_destroy()
# tar_manifest()
# tar_read(data_exp_pop)

# tar_option_set(debug = "health_impact_function")
# tar_make(names = health_impact_function, callr_function = NULL)


# tar_manifest(fields = "command")
# tar_glimpse(targets_only = FALSE)