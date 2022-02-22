library(targets)
library(tarchetypes)
library(data.table)

# source globals
datadir <- "~/../cloudstor/Shared/Environment_General/"
sapply(list.files(pattern="[.]R$", path="R/", full.names=TRUE), source) # functions
source("scope_config.R")

# Set target-specific options such as packages.
tar_option_set(packages = c("rlang", 
                            "data.table",
                            "sf",
                            "raster",
                            "exactextractr"))

targets_exposures <- list(
  spatial = tar_file(infile_geog, input_expo_pop_shp$path),
  population = tar_file(infile_pop_exp, input_expo_pop$path),
  population_load = tar_target(data_exp_pop,
                               extract_dt(
                                 infile_pop_exp,
                                 c("MB_CODE16" = "MB_CODE_2016",
                                   "pop" = "Person")
                                 )
                               ), 
  processing = tar_map(
    input_poll,
    tar_target(infile_exp, path, format = "file"),
    tar_target(dat_level, {
      # assume only raster for now
      load_exposure_raster(
        infile_exp,
        infile_geog,
        "MB_CODE16",
        2015,
        "pm25",
        "MB_CODE16"
      )
    }),
    tar_target(dat_level_cf,
               do_counterfactual_exposures(
                 dat_level,
                 delta_x = 1,
                 mode = "abs"
               )
    ),
    tar_target(dat_exposure, {
               dat1 <- do_exposure_pop_weighted(
                 dat_level,
                 data_exp_pop
               )
               setnames(dat1, "value_pw", "x")
               
               dat2 <- do_exposure_pop_weighted(
                 dat_level_cf,
                 data_exp_pop
               )
               setnames(dat2, "value_pw", "v1")
               
               dat_all <- merge(dat1, dat2)
               dat_all[, pollutant := name]
               
    }
    ),
    names = c(name, year)
  )
)

targets_response <- list(
  tar_file(infile_pop_health, file.path(datadir, "Australian_Mortality_ABS/ABS_MORT_2006_2016/data_provided/DEATHS_AGESPECIFIC_OCCURENCEYEAR_04042018231304281.csv")),
  tar_file(infile_pop_study, file.path(datadir, "ABS_data/ABS_Census_2016/abs_gcp_2016_data_derived/abs_sa2_2016_agecatsV2_total_persons_20180405.csv")),
  
  tar_target(study_population,
             extract_dt(infile_pop_study,
                        c("SA2_MAIN" = "SA2_MAINCODE_2016",
                          "age" = "Age",
                          "pop" = "value"),
                        'Age != "All ages"',
                        colClasses = list(character = "SA2_MAINCODE_2016")
             )
  ),
  tar_target(standard_pop_health, 
             {
               dt <- extract_dt(infile_pop_health,
                                c("STE11" = "ASGS_2011",
                                  "year" = "Time",
                                  "age" = "Age",
                                  "variable" = "Measure",
                                  "value" = "Value"),
                                'Region == "Victoria" & Measure %in% c("Deaths", "Population") & Sex == "Persons" & !grepl("(All ages|not stated|^[0-9]+$)", Age)',
                                colClasses = list(character = "ASGS_2011")
               )
               dcast(dt, formula = STE11 + age ~ variable, fun.aggregate = mean)
               
             }
  )
)

list(
  #### Load data ####
  targets_response,

  targets_exposures,
  tarchetypes::tar_combine(
    all_exposures,
    targets_exposures$processing$dat_exposure,
    command = rbind(!!!.x)
  ),

#### Analysis ####
tar_target(health_impact_function,
           do_health_impact_function(
             case_definition = 'crd',
             exposure_response_func = c(1.06, 1.02, 1.08),
             theoretical_minimum_risk = 0
           )
           ),

tar_target(dat_linked_pop_health_enviro,
             load_linked_pop_health_enviro(
               study_pop_health = dat_study_pop_health,
               exposures_counterfactual_linked = dat_exposures_counterfactual_linked
             )
             ),

tar_target(dat_attributable_number,
           do_attributable_number(
             hif = health_impact_function,
             linked_pop_health_enviro = dat_linked_pop_health_enviro
           )
           ),

tar_target(dat_study_pop_health,
           do_study_pop_health(
             study_population,
             standard_pop_health,
             "Deaths", "Population"
           ),

          )

# end
)
