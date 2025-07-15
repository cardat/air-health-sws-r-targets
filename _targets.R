#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
##
## _targets.R describing pipeline for PM2.5 Health impact Assessment
## 
## Cassandra Yuen and Ivan Hanigan
##
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

library(targets)
library(tarchetypes)

# Load custom functions ---------------------------------------------------

tar_source()

# Define global variables -------------------------------------------------
source('config.R')

# Set targets options -----------------------------------------------------

tar_option_set(
  packages = c("sf", # packages to load before target builds
               "data.table",
               "raster",
               "exactextractr",
               "leaflet",
               "ggplot2")
)

# Define targets ----------------------------------------------------------

## Read and tidy data -----------------------------------------------------

# use custom functions to import data and tidy
inputs <- list(
  # meshblock geometry
  tar_files_input(
    infile_abs_mb_2016,
    file.path(dir_envgen, sprintf("ABS_data/ABS_meshblocks/abs_meshblocks_2016_data_provided/MB_2016_%s.shp", states))
  ),

  # sa2 geometry
  tar_files_input(
    infile_abs_sa2_2016, 
    file.path(dir_envgen, sprintf("ABS_data/ABS_Census_2016/abs_sa2_2016_data_derived/SA2_2016_%s.shp", states))
  ),
  
  # meshblock populations
  tar_target(
    infile_abs_mb_pop_2016,
    file.path(dir_envgen, "ABS_data/ABS_meshblocks/abs_meshblocks_2016_pops_data_provided/2016 census mesh block counts.csv"),
    format = "file"
  ),
  
  # exposure rasters
  tar_files_input(
    infile_globalgwr_pm25_2010_2015, 
    file.path(dir_envgen, sprintf("Air_pollution_model_GlobalGWR_PM25/GlobalGWR_PM25_V4GL02/data_derived/GlobalGWR_PM25_GL_%s01_%s12-RH35-NoNegs_AUS_20180618.tif", years, years))
  ),
  
  # age-mortality
  tar_target(
    infile_abs_mortality_sa2_2006_2016,
    file.path(dir_envgen, "Australian_Mortality_ABS/ABS_MORT_2006_2016/data_provided/DEATHS_AGESPECIFIC_OCCURENCEYEAR_04042018231304281.csv"),
    format = "file"
  ),
  
  # age-pop study population
  tar_target(
    infile_abs_sa2_pop_age_2016,
    file.path(dir_envgen, "ABS_data/ABS_Census_2016/abs_gcp_2016_data_derived/abs_sa2_2016_agecatsV2_total_persons_20180405.csv"),
    format = "file"
  )
)

tidy <- list(
  tar_target(
    tidy_geom_mb_2016,
    do_tidy_geom_mb_2016(infile_abs_mb_2016),
    pattern = map(infile_abs_mb_2016)
  ),
  
  tar_target(
    tidy_geom_sa2_2016,
    do_tidy_geom_sa2_2016(infile_abs_sa2_2016)
  ),
  
  tar_target(
    tidy_exp_pop, 
    do_tidy_exp_pop(infile_abs_mb_pop_2016)
  ),
  
  tar_target(
    tidy_env_exposure_pm25,
    do_tidy_env_exposure_pm25(infile_globalgwr_pm25_2010_2015)
  ),
  
  tar_target(
    tidy_impact_pop,
    do_tidy_impact_pop(infile_abs_mortality_sa2_2006_2016,
                       smooth_yy = 3)
  ),
  
  tar_target(
    tidy_study_pop,
    do_tidy_study_pop(infile_abs_sa2_pop_age_2016)
  )
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
    combined_exposures,
    do_env_counterfactual(data_env_exposure_pm25,
                          "min"),
    pattern = map(data_env_exposure_pm25),
  ),
  
  # apply population weighting to baseline exposure and delta, aggregate to merge with study population
  tar_target(
    data_linked_pop_health_enviro,
    do_linked_pop_health_enviro(data_study_pop_health,
                                combined_exposures,
                                tidy_exp_pop)
  )
)

## Analysis ---------------------------------------------------------------

analysis <- list(
  # construct a function given relative risks and theoretical minimum risk
  tar_target(health_impact_function,
             do_health_impact_function(
               case_definition = 'crd',
               exposure_response_func = c(1.06, 1.02, 1.08),
               theoretical_minimum_risk = 0
             )
  ),
  
  # calculate the attributable number
  tar_target(calc_attributable_number,
             {dat <- do_attributable_number(
               hif = health_impact_function,
               linked_pop_health_enviro = data_linked_pop_health_enviro
             )
             # limit to ages 30+
             dat <- dat[!age %in% c("0 - 4", "5 - 9", "10 - 14", "15 - 19", "20 - 24", "25 - 29")]
             }
  )
)


## Visualise --------------------------------------------------------------

viz <- list(
  # create map of attributable number, faceted by year (with ggplot2)
  tar_target(
    viz_an,
    {
      # summarise data and merge with spatial for plotting
      dat_an <- calc_attributable_number
      dat_an <- dat_an[,.(pop_tot = sum(pop_study, na.rm = T),
                          expected_tot = sum(expected, na.rm = T),
                          attributable = sum(attributable, na.rm = T),
                          pm25_cf_pw_sa2 = mean(v1, na.rm = T),
                          pm25_pw_sa2 = mean(x, na.rm = T)),
                       by = .(sa2_main16, year)]
      sf_an <- tidy_geom_sa2_2016
      sf_an <- merge(sf_an, dat_an)
      viz_map_an(sf_an)
    }
  ),
  
  # leaflet map of attributable number, summed over SA2s, averaged over years (with leaflet)
  tar_target(
    leaflet_an,
    {
      # get and summarise data
      dat_an <- calc_attributable_number
      dat_an <- dat_an[,.(pop_tot = sum(pop_study, na.rm = T),
                          expected_tot = sum(expected, na.rm = T),
                          attributable = sum(attributable, na.rm = T),
                          pm25_cf = mean(v1, na.rm = T),
                          pm25 = mean(x, na.rm = T)),
                       by = .(sa2_main16, year)]
      # aggregate over years (mean)
      dat_an <- dat_an[,.(pop_tot = mean(pop_tot),
                          expected_tot = mean(expected_tot),
                          attributable = mean(attributable),
                          pm25_cf = mean(pm25_cf),
                          pm25 = mean(pm25)),
                       by = .(sa2_main16)]
        
      # merge with spatial for plotting
      sf_an <- merge(tidy_geom_sa2_2016, dat_an)
      sf_an <- st_simplify(sf_an, dTolerance = 75)
      viz_leaflet_an(sf_an)
    }
  ),
  
  # render an Rmarkdown report
  tar_render(report, "report.Rmd")
)


# List the targets in pipeline --------------------------------------------

list(
  ## list HIA pipeline targets
  inputs = inputs,
  tidy = tidy,
  data = derive_data,
  analysis = analysis,
  viz = viz
)
