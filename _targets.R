library(targets)
library(tarchetypes)

# source globals
datadir <- "~/../cloudstor/Shared/Environment_General/"
sapply(list.files(pattern="[.]R$", path="R/", full.names=TRUE), source)

# Set target-specific options such as packages.
tar_option_set(packages = c("rlang", 
                            "data.table",
                            "sf",
                            "raster",
                            "exactextractr"))

targets_exposures <- tar_map(
  list(
    dataset = c("pm25", "uvr"),
    input = c(
      file.path(datadir, "Air_pollution_model_GlobalGWR_PM25/GlobalGWR_PM25_V4GL02/data_derived/GlobalGWR_PM25_GL_201501_201512-RH35-NoNegs_AUS_20180618.tif"),
      file.path(datadir, "UVR_Solar_BOM/seasonal_daily_avg_solar_uv_aust_1990_2011/data_provided/annual_mean_solar_uvr_summer_1990_2011.tif")
    )
  ),
  tar_target(infile_exp, input, format = "file"),
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
  tar_target(dat_exposure,
             do_exposure_pop_weighted(
               dat_level,
               data_exp_pop
             )
  ),
  tar_target(dat_exposure_cf,
             do_exposure_pop_weighted(
               dat_level_cf,
               data_exp_pop
             )
  ),
  names = dataset
)

targets_response <- tar_map(list(
  dataset = c("geog",#"exp1", "exp2", 
              "pop_exp", "pop_health", "pop_study"),
  input = c(
    file.path(datadir, "ABS_data/ABS_meshblocks/abs_meshblocks_2016_data_provided/MB_2016_VIC.shp"),
    # file.path(datadir, "Air_pollution_model_GlobalGWR_PM25/GlobalGWR_PM25_V4GL02/data_derived/GlobalGWR_PM25_GL_201501_201512-RH35-NoNegs_AUS_20180618.tif"),
    # file.path(datadir, "UVR_Solar_BOM/seasonal_daily_avg_solar_uv_aust_1990_2011/data_provided/annual_mean_solar_uvr_summer_1990_2011.tif"),
    file.path(datadir, "ABS_data/ABS_meshblocks/abs_meshblocks_2016_pops_data_provided/2016 census mesh block counts.csv"),
    file.path(datadir, "Australian_Mortality_ABS/ABS_MORT_2006_2016/data_provided/DEATHS_AGESPECIFIC_OCCURENCEYEAR_04042018231304281.csv"),
    file.path(datadir, "ABS_data/ABS_Census_2016/abs_gcp_2016_data_derived/abs_sa2_2016_agecatsV2_total_persons_20180405.csv")
  )
),
tar_target(infile, input, format = "file"),
names = dataset
)

# targets_exposures <- tar_map(
# 
# )
#   UVR_Solar_BOM/seasonal_daily_avg_solar_uv_aust_1990_2011

list(
#### Inputs ####
  targets_response,
  targets_exposures,
  tarchetypes::tar_combine(
    all_exposures,
    targets_exposures$dat_exposure,
    command = rbind(!!!.x)
  ),
  tarchetypes::tar_combine(
    all_exposures_cf,
    targets_exposures$dat_exposure_cf,
    command = rbind(!!!.x)
  ),



## geographical geom
# tar_target(exp_geog_raw_f, file.path(datadir, "ABS_data/ABS_meshblocks/abs_meshblocks_2016_data_provided/MB_2016_VIC.shp"), format = "file"),
# 
# ## pollutant concentration
# tar_target(exposure1_raw_f, file.path(datadir, "Air_pollution_model_GlobalGWR_PM25/GlobalGWR_PM25_V4GL02/data_derived/GlobalGWR_PM25_GL_201501_201512-RH35-NoNegs_AUS_20180618.tif"), format = "file"),
## counterfactual
# ??? numeric/raster/csv/shape
## meshblock pops
# tar_target(exp_pop_raw_f, file.path(datadir, "ABS_data/ABS_meshblocks/abs_meshblocks_2016_pops_data_provided/2016 census mesh block counts.csv"), format = "file"),
# # mb_pops_varlist <- c("MB_CODE16", "MB_CATEGORY_NAME_2016", "Person")
# 
# ## impact
# tar_target(impact_pop_f, file.path(datadir, "Australian_Mortality_ABS/ABS_MORT_2006_2016/data_provided/DEATHS_AGESPECIFIC_OCCURENCEYEAR_04042018231304281.csv"), format = "file"),
# # indat_death_varlist <- c("Region", "Sex", "Age", "Measure", "Time", "Value")
# ## baseline pop stats
# tar_target(study_pop_f, file.path(datadir, "ABS_data/ABS_Census_2016/abs_gcp_2016_data_derived/abs_sa2_2016_agecatsV2_total_persons_20180405.csv"), format = "file"),

#### Load data ####
# tar_target(exp_geog_raw, st_read(exp_geog_raw_f)),
# tar_target(exposure1_raw, raster(exposure1_raw_f)),
tar_target(data_exp_pop, 
           extract_dt(infile_pop_exp,
                      c("MB_CODE16" = "MB_CODE_2016",
                        "pop" = "Person")
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
           ),
tar_target(study_population,
           extract_dt(infile_pop_study,
                      c("SA2_MAIN" = "SA2_MAINCODE_2016",
                        "age" = "Age",
                        "pop" = "value"),
                      'Age != "All ages"',
                      colClasses = list(character = "SA2_MAINCODE_2016")
                      )
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

# tar_target(dat_exposure1_prep,
#   if (endsWith(infile_exp1, ".tif") & endsWith(infile_geog, ".shp")){
#     exp <- load_exposure_raster(
#       infile_exp1,
#       infile_geog,
#       "MB_CODE16",
#       2015,
#       "pm25",
#       "MB_CODE16"
#     )
#   } else if (endsWith(infile_exp1, ".csv")) {
#     exp <- load_exposure_csv(
#       infile_exp1,
#       col_gid,
#       col_year,
#       col_value,
#       poll,
#       area_code
#     )
#   }
# ),
#
# tar_target(dat_baseline_exposures,
#            # pop-weighted
#            do_exposure_pop_weighted(
#              dat_exposure1_prep,
#              data_exp_pop
#              )
#            ),
# 
# tar_target(dat_counterfactual_exposures,
#            do_counterfactual_exposures(
#              dat_exposure1_prep,
#              delta_x = 1,
#              mode = "abs"
#            )
#          ),

# tar_target(dat_exposures_counterfactual_linked,
#            # do_exposures_counterfactual_linked(
#            #   exposure1_prep = dat_baseline_exposures,
#            #   counterfactual_exposures = dat_counterfactual_exposures
#            # )
#            merge(dat_baseline_exposures,
#                  dat_counterfactual_exposures)
#           ),

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
