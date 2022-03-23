#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
##
## _targets.R describing pipeline for PM2.5 Health impact Assessment
## 
## 
##
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

library(targets)
library(tarchetypes)

# Load custom functions ---------------------------------------------------

sapply(list.files(pattern="[.]R$", path="R/import_data", full.names=TRUE), source)
sapply(list.files(pattern="[.]R$", path="R/func_data", full.names=TRUE), source)
sapply(list.files(pattern="[.]R$", path="R/func_analysis", full.names=TRUE), source)
sapply(list.files(pattern="[.]R$", path="R/func_viz", full.names=TRUE), source)
sapply(list.files(pattern="[.]R$", path="R/func_helpers", full.names=TRUE), source)


# Define global variables -------------------------------------------------

#### study coverage
years <- 2013:2014
states <- c("NSW", "ACT") # character vector of state abbreviations

#### data location and retrieval
# Provide directory to download CARDAT data to (datadir will be ignored), otherwise set to NULL
download_data <- NULL ## TODO - unimplemented
# path to Environment_General folder mirroring required CARDAT data
datadir <- "~/../cloudstor/Shared/Environment_General"


# Set targets options -----------------------------------------------------

tar_option_set(
  packages = c("sf", # packages to load before target builds
               "data.table",
               "raster",
               "exactextractr",
               "ggplot2")
)

# Define targets ----------------------------------------------------------

## Read and tidy data -----------------------------------------------------

# use custom functions to import data and tidy
inputs <- list(
  geog = import_abs_mb_2016(states), # meshblock geometry
  geog_agg = import_abs_sa2_2016(states), # sa2 geometry
  
  exp_pop = import_abs_pop_mb_2016(states), # meshblock populations
  
  exposure = import_globalgwr_pm25_2010_2015(years), # exposure rasters
  
  impact_pop = import_abs_mortality_sa2_2006_2016(states, years, smooth_yy = 3), # age-mortality
  
  study_pop = import_abs_sa2_pop_age_2016(states) # age-pop study population
)

## Data extraction and derivation -----------------------------------------

derive_data <- list(
  
  # Extraction of exposure by given geometry
  tar_target(
    data_env_exposure_pm25,
    do_env_exposure(tidy_env_exposure_pm25, tidy_geom_mb_2016, "pm25"),
    pattern = map(tidy_geom_mb_2016)
  ), 
  
  # apply impact rate to study population
  tar_target(
    data_study_pop_health,
    do_study_pop_impact(tidy_study_pop,
                        tidy_impact_pop)
  ),
  
  # Provide counterfactual scenario and calculate delta
  tar_target(
    combined_exposures_pop,
    do_env_counterfactual(data_env_exposure_pm25,
                          "min"),
    pattern = map(data_env_exposure_pm25),
  ),
  
  # apply population weighting to baseline exposure and delta, aggregate to merge with study population
  tar_target(
    data_linked_pop_health_enviro,
    do_linked_pop_health_enviro(data_study_pop_health,
                                combined_exposures_pop,
                                tidy_exp_pop)
  )
)

## Analysis ---------------------------------------------------------------

analysis <- list(
  # construct a function given relative risks and theoretical minimum risk
  tar_target(health_impact_function,
             do_health_impact_function(
               case_definition = 'crd',
               # exposure_response_func = c(1.06, 1.02, 1.08),
               exposure_response_func = c(1.08, NA, NA),
               theoretical_minimum_risk = 0
             )
  ),
  
  # calculate the attributable number
  tar_target(calc_attributable_number,
             do_attributable_number(
               hif = health_impact_function,
               linked_pop_health_enviro = data_linked_pop_health_enviro
             )
  )
)


## Visualise --------------------------------------------------------------

viz <- list(
  # create map of attributable number
  tar_target(
    viz_an,
    {
      # summarise data and merge with spatial for plotting
      dat_an <- calc_attributable_number
      dat_an <- dat_an[,.(pop_tot = sum(value, na.rm = T),
                          expected_tot = sum(expected, na.rm = T),
                          attributable = sum(attributable, na.rm = T),
                          pm25_cf_pw_sa2 = mean(v1, na.rm = T),
                          pm25_pw_sa2 = mean(x, na.rm = T)),
                       by = .(sa2_main16, year)]
      sf_an <- tidy_geom_sa2_2016
      sf_an <- merge(sf_an, dat_an)
      viz_map_an(sf_an, "attributable")
    }
  )
)


# List the targets in pipeline --------------------------------------------

list(
  inputs = inputs,
  data = derive_data,
  analysis = analysis,
  viz = viz
)