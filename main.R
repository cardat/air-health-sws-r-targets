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
source("R/func_helpers/helper_test_cloudstor.R")

# Set data path -----------------------------------------------------------

## Download the data from Cloudstor via CloudstoR library?
download_data <- FALSE

## If download_data is TRUE, specify the destination to download to
## Else if a mirror of the required data from the CARDAT data store already exists on your computer, please specify the parent directory of CARDAT's Environment_General folder
#     On Windows using CloudStor sync client, typically "~/../cloudstor/Shared"
#     On Mac using CloudStor sync client, typically "~/cloudstor/Shared"
#     On CoESRA as a member of the car group, use "~/public_share_data/ResearchData_CAR"
cardat_data <- "~/../cloudstor/Shared"


# write the pipeline ------------------------------------------------------
# load function for creating _targets.R for HIA pipeline
source("R/pipelines/write_pipeline_perth.R")

# write _targets.R file
write_pipeline_perth(states = c("NSW", "ACT"), # study area
                     years = 2013:2014, # temporal coverage
                     download_data = download_data,
                     cardat_path = cardat_data
                     )

# Run pipeline ------------------------------------------------------------

if(download_data & !test_cloudstor()){
  cloud_auth()
}

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
